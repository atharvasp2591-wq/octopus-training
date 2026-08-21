# Octopus Deploy Integration Guide

This document shows how to integrate the DAY3 DACPAC deployment pipeline with Octopus Deploy for advanced release management.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│ Azure DevOps Pipeline (DAY3)                                │
│ ├─ Build DACPAC Package                                     │
│ ├─ Publish to Azure Artifacts                               │
│ └─ Trigger Octopus Deploy Release                           │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│ Octopus Deploy Server                                       │
│ ├─ Download DACPAC from Azure Artifacts                     │
│ ├─ Backup SQL Databases (Pre-deployment)                    │
│ ├─ Deploy DACPAC using SqlPackage                           │
│ ├─ Run Post-deployment Scripts                              │
│ ├─ Verify Deployment (Health Checks)                        │
│ └─ Notify Stakeholders                                      │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
        ┌──────────────────────────────┐
        │   SQL Server Databases       │
        │  ├─ Development              │
        │  ├─ Staging                  │
        │  └─ Production               │
        └──────────────────────────────┘
```

## Setup Steps

### 1. Install Octopus Deploy

```powershell
# Download and install Octopus Deploy Server
# https://octopus.com/download

# Create Octopus Deploy project
# - Login to Octopus Deploy portal
# - Create new project: "SQL Database Deployment"
```

### 2. Create Deployment Process in Octopus Deploy

#### Step 1: Download DACPAC from Azure Artifacts

```powershell
# Create custom step to download from Azure Artifacts
param(
    $AzureArtifactsFeed,
    $PackageName,
    $PackageVersion
)

# Use NuGet client to download
nuget sources add -Name "Azure Artifacts" -Source "https://pkgs.dev.azure.com/YOUR_ORG/_packaging/YOUR_FEED/nuget/v3/index.json"

nuget install $PackageName -Version $PackageVersion `
    -OutputDirectory "$(Octopus.Action.Package.InstallationDirectoryPath)" `
    -NoCache `
    -NonInteractive
```

#### Step 2: Pre-deployment Database Backup

```powershell
# Octopus Deploy Step: Backup SQL Database
param(
    [string]$SqlServer,
    [string]$DatabaseName,
    [string]$SqlUsername,
    [string]$SqlPassword,
    [string]$BackupPath = "C:\SQLBackups"
)

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupFile = "$BackupPath\$DatabaseName`_$timestamp.bak"

# Create backup directory if it doesn't exist
if (-not (Test-Path $BackupPath)) {
    New-Item -ItemType Directory -Path $BackupPath -Force | Out-Null
}

# Execute backup
$query = @"
BACKUP DATABASE [$DatabaseName] 
TO DISK = N'$backupFile' 
WITH NOFORMAT, NOINIT, 
NAME = N'$DatabaseName Backup', 
SKIP, NOREWIND, NOUNLOAD, 
STATS = 10
"@

try {
    $connectionString = "Server=$SqlServer;User Id=$SqlUsername;Password=$SqlPassword;"
    $connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
    $connection.Open()
    
    $command = $connection.CreateCommand()
    $command.CommandTimeout = 600
    $command.CommandText = $query
    $command.ExecuteNonQuery()
    
    $connection.Close()
    
    Write-Host "Backup created: $backupFile"
    Set-OctopusVariable -name "BackupFile" -value $backupFile
}
catch {
    Write-Error "Backup failed: $_"
    throw
}
```

#### Step 3: Deploy DACPAC

```powershell
# Octopus Deploy Step: Deploy DACPAC
param(
    [string]$DacpacPath,
    [string]$SqlServer,
    [string]$DatabaseName,
    [string]$SqlUsername,
    [string]$SqlPassword,
    [string]$Environment = "Development"
)

# Determine deployment settings based on environment
$blockOnDataLoss = if ($Environment -eq "Production") { $true } else { $false }

# Deploy DACPAC
$deployArgs = @(
    "/Action:Publish",
    "/SourceFile:`"$DacpacPath`"",
    "/TargetServerName:$SqlServer",
    "/TargetDatabaseName:$DatabaseName",
    "/TargetUser:$SqlUsername",
    "/TargetPassword:$SqlPassword",
    "/p:BlockOnPossibleDataLoss=$blockOnDataLoss",
    "/p:DropObjectsNotInSource=false",
    "/p:GenerateSmartDefaults=true",
    "/p:IncludeTransactionalScripts=true"
)

Write-Host "Deploying DACPAC to $Environment environment..."
Write-Host "Source: $DacpacPath"
Write-Host "Target: $SqlServer\$DatabaseName"

& SqlPackage @deployArgs

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Deployment successful"
}
else {
    Write-Host "✗ Deployment failed"
    throw "DACPAC deployment failed with exit code: $LASTEXITCODE"
}
```

#### Step 4: Post-deployment Validation

```powershell
# Octopus Deploy Step: Validate Deployment
param(
    [string]$SqlServer,
    [string]$DatabaseName,
    [string]$SqlUsername,
    [string]$SqlPassword
)

try {
    $connectionString = "Server=$SqlServer;User Id=$SqlUsername;Password=$SqlPassword;Initial Catalog=$DatabaseName;"
    $connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
    $connection.Open()
    
    # Verify database is accessible
    $command = $connection.CreateCommand()
    $command.CommandText = "SELECT @@VERSION"
    $version = $command.ExecuteScalar()
    Write-Host "✓ Database version: $version"
    
    # Check table count
    $command.CommandText = "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA='dbo'"
    $tableCount = $command.ExecuteScalar()
    Write-Host "✓ Tables deployed: $tableCount"
    
    # Check procedure count
    $command.CommandText = "SELECT COUNT(*) FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE='PROCEDURE'"
    $procCount = $command.ExecuteScalar()
    Write-Host "✓ Stored procedures deployed: $procCount"
    
    $connection.Close()
    Write-Host "✓ Deployment validation successful"
}
catch {
    Write-Error "Validation failed: $_"
    throw
}
```

### 3. Create Azure DevOps Pipeline Integration

Add to `azure-pipelines.yml`:

```yaml
- stage: TriggerOctopusDeploy
  displayName: Trigger Octopus Deploy Release
  dependsOn: Package
  condition: succeeded()
  jobs:
  - job: OctopusDeployment
    displayName: Create and Deploy Release
    pool:
      vmImage: ubuntu-latest
    
    variables:
      OCTOPUS_URL: 'https://octopus.example.com'
      OCTOPUS_PROJECT: 'SQL Database Deployment'
      OCTOPUS_ENVIRONMENT: 'Development'

    steps:
    - task: OctopusDeployRelease@4
      displayName: Create Octopus Deploy Release
      inputs:
        OctopusUrl: '$(OCTOPUS_URL)'
        OctopusApiKey: '$(OctopusApiKey)'  # Set as secret variable
        Space: 'Default'
        ProjectName: '$(OCTOPUS_PROJECT)'
        ReleaseNumber: '$(Build.BuildNumber)'
        Packages: 'dacpac-packages'
        DeployToEnvironment: '$(OCTOPUS_ENVIRONMENT)'
        ShowProgress: true
        WaitForDeployment: true
        DeploymentTimeout: '00:30:00'

    - task: OctopusDeployPromote@4
      displayName: Promote to Staging
      condition: eq(variables['Build.SourceBranch'], 'refs/heads/main')
      inputs:
        OctopusUrl: '$(OCTOPUS_URL)'
        OctopusApiKey: '$(OctopusApiKey)'
        Space: 'Default'
        ProjectName: '$(OCTOPUS_PROJECT)'
        CurrentDeploymentEnvironment: 'Development'
        DeployToEnvironment: 'Staging'
        ShowProgress: true
```

### 4. Set Octopus Deploy Variables

In Octopus Deploy → Projects → SQL Database Deployment → Variables:

```
SqlServer = localhost
SqlDatabase = OctopusDeploymentDB
SqlUsername = sa
SqlPassword = (encrypted password)

ProdSqlServer = prod-db-server
ProdSqlDatabase = OctopusDB
ProdSqlUsername = svc_deploy
ProdSqlPassword = (encrypted password)
```

## Deployment Workflow

### Development Environment
1. Push code to `develop` branch
2. Azure Pipeline builds DACPAC
3. Automatically deploys to Development SQL Server
4. No approvals required

### Staging Environment
1. Create pull request to `main`
2. PR approved and merged
3. Azure Pipeline builds DACPAC
4. Octopus Deploy waits for approval
5. Approved by Test Team
6. Deploys to Staging SQL Server

### Production Environment
1. Octopus Deploy waits for approval
2. Approved by Database Administrator
3. Pre-deployment backup created
4. DACPAC deployed with data loss protection
5. Post-deployment health checks
6. Notifications sent to stakeholders

## Advanced Features

### Tenant-based Deployments

Deploy different DACPAC versions to different customers:

```yaml
variables:
  OCTOPUS_TENANT: 'Customer_$(Customer_ID)'

steps:
- task: OctopusDeployRelease@4
  inputs:
    TenantName: '$(OCTOPUS_TENANT)'
    DeployToEnvironment: 'Production'
```

### Multi-region Deployments

Deploy to multiple SQL Servers in parallel:

```yaml
strategy:
  matrix:
    NorthAmerica:
      SqlServer: 'na-db.azure.com'
    Europe:
      SqlServer: 'eu-db.azure.com'
    AsiaPacific:
      SqlServer: 'ap-db.azure.com'
```

### Automatic Rollback

Configure automatic rollback on deployment failure:

```yaml
tasks:
- task: OctopusDeployRelease@4
  inputs:
    DeploymentMode: 'IfAnyDeploymentFailed'
    DeploymentAction: 'Rollback'
    RollbackFromEnvironment: 'Production'
    RollbackToEnvironment: 'LastSuccessfulRelease'
```

## Troubleshooting

### Connection Issues
```powershell
# Test Octopus Deploy API
$octopusUrl = "https://octopus.example.com"
$apiKey = "API-XXXXXXXXX"

Invoke-RestMethod -Uri "$octopusUrl/api/spaces" `
    -Headers @{"X-Octopus-ApiKey" = $apiKey}
```

### DACPAC Download Failures
```powershell
# Verify NuGet feed access
nuget sources list
nuget setApiKey -Source "https://pkgs.dev.azure.com/..." -Value "YOUR_PAT"
```

### Deployment Hangs
- Check SQL Server availability
- Verify firewall rules
- Review SqlPackage timeout settings
- Check database locks: `sp_who2`

## References

- [Octopus Deploy Documentation](https://octopus.com/docs)
- [Azure Pipelines - Octopus Deploy Plugin](https://marketplace.visualstudio.com/items?itemName=OctopusDeploy.octopus-deploy-build-release-tasks)
- [SqlPackage Command Reference](https://learn.microsoft.com/en-us/sql/tools/sqlpackage/sqlpackage)
- [DACPAC Best Practices](https://learn.microsoft.com/en-us/sql/relational-databases/data-tier-applications/data-tier-applications)
