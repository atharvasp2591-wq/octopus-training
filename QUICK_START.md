# DAY 3: Quick Start Guide

## 5-Minute Setup

### 1. Prerequisites
```powershell
# Install required tools
dotnet tool install -g Microsoft.SqlPackage

# Verify SQL Server is running
sqlcmd -S localhost -U sa -P YourPassword -Q "SELECT @@VERSION"
```

### 2. Set Pipeline Variables in Azure DevOps

Go to your pipeline → Variables → Add these secret variables:

**Development:**
- `SqlServerUsername` → `sa`
- `SqlServerPassword` → (your SQL Server password)

**Production:**
- `ProdSqlServer` → `prod-db-server.database.windows.net`
- `ProdSqlDatabase` → `OctopusDB`
- `ProdSqlUsername` → (production service account)
- `ProdSqlPassword` → (production password)

### 3. Create SQL Database Project

#### Quick Option: Use Sample Database
```powershell
# Deploy sample database from script
$params = @{
    DacpacPath = ".\bin\Release\Database.dacpac"
    ServerName = "localhost"
    DatabaseName = "OctopusDeploymentDB"
    Username = "sa"
    Password = "YourPassword"
    Environment = "Development"
}

.\Deploy-DACPAC.ps1 @params
```

#### Full Option: Create Visual Studio Project
1. Open Visual Studio
2. File → New → Project → Search "SQL Server Database Project"
3. Name: `Database`
4. Add SQL objects (Tables, Procedures, Views, etc.)
5. Build project → generates `.dacpac` file
6. Place in `DAY3/Database/bin/Release/` folder

### 4. Commit and Push
```powershell
git add .
git commit -m "Add SQL DACPAC deployment pipeline"
git push origin main
```

### 5. Monitor Pipeline

1. Go to Azure DevOps → Pipelines
2. View the running build for DAY3
3. Check artifacts after build succeeds
4. Approve production deployment in Environments

## Common Tasks

### Deploy Locally
```powershell
# Development deployment (allows data loss)
.\Deploy-DACPAC.ps1 `
    -DacpacPath ".\Database\bin\Release\Database.dacpac" `
    -ServerName "localhost" `
    -DatabaseName "OctopusDeploymentDB" `
    -Username "sa" `
    -Password "YourPassword" `
    -Environment "Development"

# Production deployment (blocks data loss)
.\Deploy-DACPAC.ps1 `
    -DacpacPath ".\Database\bin\Release\Database.dacpac" `
    -ServerName "prod-server" `
    -DatabaseName "OctopusDB" `
    -Username "svc_deploy" `
    -Password "ProdPassword" `
    -Environment "Production" `
    -Backup
```

### Generate DACPAC from Existing Database
```powershell
# Extract schema from existing database
SqlPackage /Action:Extract `
    /SourceConnectionString:"Server=localhost;User Id=sa;Password=YourPassword;Initial Catalog=MyDatabase;" `
    /TargetFile:"Database.dacpac"
```

### Verify Deployment
```powershell
# Connect to deployed database
sqlcmd -S localhost -U sa -P YourPassword -d OctopusDeploymentDB -Q "SELECT * FROM INFORMATION_SCHEMA.TABLES"
```

### Create Database Backup Before Deployment
```powershell
# Run with backup flag
.\Deploy-DACPAC.ps1 `
    -DacpacPath ".\Database.dacpac" `
    -ServerName "prod-server" `
    -DatabaseName "OctopusDB" `
    -Username "sa" `
    -Password "YourPassword" `
    -Backup
```

## Troubleshooting Quick Reference

| Issue | Solution |
|-------|----------|
| SqlPackage not found | `dotnet tool install -g Microsoft.SqlPackage` |
| Can't connect to SQL | Check SQL Server running: `sqlcmd -S localhost -Q "SELECT 1"` |
| 403 Permission Error | Add user to feed in Azure Artifacts → Permissions |
| DACPAC not found | Build SQL project first: `dotnet build` in Database folder |
| Data loss error | Set `BlockOnDataLoss=$false` for Development only |
| Deploy stuck | Check deployment logs in pipeline run output |

## Files Created

```
DAY3/
├── azure-pipelines.yml           # Complete Azure Pipeline
├── Deploy-DACPAC.ps1            # PowerShell deployment script
├── README.md                      # Full documentation
├── SQL_PROJECT_SETUP.md          # SQL project guidance
└── QUICK_START.md                # This file
```

## Next Steps

1. ✅ Create SQL Database Project (see SQL_PROJECT_SETUP.md)
2. ✅ Add SQL objects (Tables, Procedures, Views)
3. ✅ Build project to generate DACPAC
4. ✅ Commit to git
5. ✅ Configure pipeline variables
6. ✅ Run pipeline manually
7. ✅ Check deployment results
8. ✅ Set up production approvers

## Integration with DAY2

The DAY3 pipeline can use DACPAC packages published from DAY2:

```yaml
# In azure-pipelines.yml for DAY3
- task: DownloadPackage@1
  inputs:
    packageType: 'pypi'
    feed: 'atharvasp2591'
    definition: 'dacpac-package'
    version: $(Build.BuildNumber)
```

## Security Notes

⚠️ **Important:**
- Never commit passwords to git
- Always use Azure Pipeline secrets for credentials
- Use Service Principals in production
- Enable database backups before production deployments
- Require approvals for production deployments

## References

Quick links to documentation:
- [SqlPackage CLI](https://learn.microsoft.com/en-us/sql/tools/sqlpackage/sqlpackage)
- [SQL Database Projects](https://learn.microsoft.com/en-us/sql/ssdt/sql-server-data-tools)
- [Azure Pipelines](https://learn.microsoft.com/en-us/azure/devops/pipelines/)
- [DACPAC Deployment](https://learn.microsoft.com/en-us/sql/relational-databases/data-tier-applications/data-tier-applications)

## Support

- Check pipeline logs: Pipelines → Runs → Select run → View logs
- Review SQL error logs: SQL Server Management Studio → Error Logs
- Verify database connectivity: `sqlcmd -S servername -U username -P password`
