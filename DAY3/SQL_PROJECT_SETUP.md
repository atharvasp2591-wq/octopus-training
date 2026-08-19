# Sample SQL Database Project Setup

This document provides example SQL objects and scripts for the SQL Server Database Project.

## Directory Structure

```
DAY3/
├── Database/
│   ├── dbo/
│   │   ├── Tables/
│   │   │   ├── Users.sql
│   │   │   ├── Products.sql
│   │   │   └── Orders.sql
│   │   ├── Views/
│   │   │   └── vw_UserOrders.sql
│   │   ├── StoredProcedures/
│   │   │   ├── sp_GetUserById.sql
│   │   │   └── sp_InsertOrder.sql
│   │   ├── Functions/
│   │   │   └── fn_CalculateOrderTotal.sql
│   │   └── Security/
│   │       └── Roles.sql
│   ├── Properties/
│   │   └── Database.sqlsettings
│   ├── Database.sqlproj
│   ├── publish.xml
│   └── Pre-Deployment/
│       └── Script.PreDeployment.sql
├── Scripts/
│   ├── Create-SqlProject.ps1
│   └── Deploy-DACPAC.ps1
└── azure-pipelines.yml
```

## Creating the SQL Project

### Option 1: Using Visual Studio

1. Create new project: **SQL Server Database Project**
2. Add SQL objects via **Add → New Item**
3. Build to generate `.dacpac` file

### Option 2: Using Command Line

```powershell
# Install SQL Server tools
dotnet tool install -g Microsoft.SqlPackage

# Create sample DACPAC from script
sqlcmd -S localhost -U sa -P YourPassword -i setup.sql
```

## Sample SQL Objects

### Sample Table: Users

```sql
CREATE TABLE [dbo].[Users] (
    [UserId] INT IDENTITY(1,1) PRIMARY KEY,
    [Username] NVARCHAR(100) NOT NULL UNIQUE,
    [Email] NVARCHAR(255) NOT NULL UNIQUE,
    [FirstName] NVARCHAR(100),
    [LastName] NVARCHAR(100),
    [CreatedAt] DATETIME2 DEFAULT GETUTCDATE(),
    [UpdatedAt] DATETIME2 DEFAULT GETUTCDATE(),
    [IsActive] BIT DEFAULT 1
);
```

### Sample Stored Procedure

```sql
CREATE PROCEDURE [dbo].[sp_GetUserById]
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        UserId,
        Username,
        Email,
        FirstName,
        LastName,
        CreatedAt,
        IsActive
    FROM [dbo].[Users]
    WHERE UserId = @UserId;
END;
```

### Sample Function

```sql
CREATE FUNCTION [dbo].[fn_GetUserFullName]
    (@UserId INT)
RETURNS NVARCHAR(200)
AS
BEGIN
    DECLARE @FullName NVARCHAR(200);
    
    SELECT @FullName = CONCAT(FirstName, ' ', LastName)
    FROM [dbo].[Users]
    WHERE UserId = @UserId;
    
    RETURN ISNULL(@FullName, 'Unknown');
END;
```

## Database Deployment Configuration

### publish.xml (Deployment Settings)

```xml
<?xml version="1.0" encoding="utf-8"?>
<Project ToolsVersion="Current" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
    <Import Condition="Exists('Database.sqlsettings')" Project="Database.sqlsettings" />
    <PropertyGroup>
        <TargetConnectionString>Server=localhost;Integrated Security=true;Pooling=false;Max Pool Size=0</TargetConnectionString>
        <TargetDatabaseName>OctopusDeploymentDB</TargetDatabaseName>
        <BlockOnPossibleDataLoss>true</BlockOnPossibleDataLoss>
        <DropObjectsNotInSource>false</DropObjectsNotInSource>
        <GenerateSmartDefaults>true</GenerateSmartDefaults>
        <IncludeTransactionalScripts>true</IncludeTransactionalScripts>
    </PropertyGroup>
</Project>
```

## PowerShell Deployment Scripts

### Deploy-DACPAC.ps1

```powershell
param(
    [string]$DacpacPath,
    [string]$ServerName = "localhost",
    [string]$DatabaseName = "OctopusDeploymentDB",
    [string]$Username = "sa",
    [string]$Password,
    [bool]$BlockOnDataLoss = $true
)

# Install SqlPackage if not present
$sqlPackageExists = dotnet tool list -g | Select-String "Microsoft.SqlPackage"
if (-not $sqlPackageExists) {
    Write-Host "Installing SqlPackage..."
    dotnet tool install -g Microsoft.SqlPackage
}

# Deploy DACPAC
Write-Host "Deploying DACPAC from: $DacpacPath"
Write-Host "Target Server: $ServerName"
Write-Host "Target Database: $DatabaseName"

SqlPackage /Action:Publish `
    /SourceFile:"$DacpacPath" `
    /TargetServerName:"$ServerName" `
    /TargetDatabaseName:"$DatabaseName" `
    /TargetUser:"$Username" `
    /TargetPassword:"$Password" `
    /p:BlockOnPossibleDataLoss=$BlockOnDataLoss `
    /p:DropObjectsNotInSource=false `
    /p:GenerateSmartDefaults=true `
    /p:IncludeTransactionalScripts=true

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ DACPAC deployment successful!" -ForegroundColor Green
} else {
    Write-Host "✗ DACPAC deployment failed!" -ForegroundColor Red
    exit 1
}
```

## Integration Points

### With DAY2 Python Package
You can enhance the pipeline to:
1. Pull DACPAC from Azure Artifacts
2. Use versioning for schema changes
3. Coordinate with application deployments

### Environment-Specific Settings

```yaml
# Development
BlockOnPossibleDataLoss: false
DropObjectsNotInSource: false

# Production
BlockOnPossibleDataLoss: true
DropObjectsNotInSource: false
VerifyDeployment: true
BackupDatabase: true
```

## Testing the Deployment

```powershell
# Verify database connection
sqlcmd -S localhost -U sa -P YourPassword -d OctopusDeploymentDB -Q "SELECT @@VERSION;"

# List tables
sqlcmd -S localhost -U sa -P YourPassword -d OctopusDeploymentDB -Q "SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA='dbo';"

# Test stored procedure
sqlcmd -S localhost -U sa -P YourPassword -d OctopusDeploymentDB -Q "EXEC sp_GetUserById @UserId=1;"
```

## Migration Considerations

- **Pre-deployment scripts** for backups
- **Post-deployment scripts** for data transformations
- **Schema versioning** for tracking changes
- **Rollback procedures** for emergency situations
- **Snapshot backups** before production deployments

## References

- [SQL Server Database Projects](https://learn.microsoft.com/en-us/sql/ssdt/sql-server-data-tools)
- [SqlPackage Documentation](https://learn.microsoft.com/en-us/sql/tools/sqlpackage/sqlpackage)
- [T-SQL Best Practices](https://learn.microsoft.com/en-us/sql/t-sql/queries/query-hints-transact-sql)
