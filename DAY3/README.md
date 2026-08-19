# DAY 3: SQL Server DACPAC Deployment Pipeline

This pipeline automates the deployment of SQL Server DACPAC (Data-tier Application Package) files to development and production environments using Azure Pipelines.

## Pipeline Overview

The pipeline consists of three stages:

### Stage 1: Package
- Builds SQL Database Project and generates DACPAC files
- Publishes DACPAC artifacts to Azure Pipeline artifacts

### Stage 2: DeployDev (Development)
- Downloads DACPAC artifacts from the build
- Deploys to Development SQL Server using SqlPackage
- Verifies database connection post-deployment

### Stage 3: DeployProd (Production)
- Only runs on `main` branch after successful Dev deployment
- Deploys to Production SQL Server with strict data loss protection
- Requires `Production` environment approval (security gate)

## Prerequisites

1. **SQL Database Project (.sqlproj)**
   - Create a SQL Server Database Project in Visual Studio
   - Place it in the `DAY3` directory
   - Example structure:
     ```
     DAY3/
     ├── Database/
     │   ├── Database.sqlproj
     │   ├── dbo/
     │   │   ├── Tables/
     │   │   ├── Views/
     │   │   ├── StoredProcedures/
     │   │   └── Functions/
     │   └── Properties/
     ├── azure-pipelines.yml
     └── README.md
     ```

2. **Pipeline Variables**
   - Set in Azure Pipeline → Variables or as pipeline secrets:

   **Development Environment:**
   - `SqlServerUsername` - SQL Server login username
   - `SqlServerPassword` - SQL Server password (use secret variable)

   **Production Environment:**
   - `ProdSqlServer` - Production SQL Server address (e.g., prod-db.azure.com)
   - `ProdSqlDatabase` - Production database name
   - `ProdSqlUsername` - Production SQL Server username
   - `ProdSqlPassword` - Production SQL Server password (use secret variable)

3. **Service Connections**
   - SQL Server connection details (or use inline credentials in variables)
   - Azure DevOps service connection for artifact access

4. **Environments (for approvals)**
   - Create `Development` environment in Pipelines → Environments
   - Create `Production` environment with required approvers

## SQL Server Connection Details

Update these in the pipeline or Azure Pipeline variables:

```batch
SQL_SERVER=localhost              # or your server address
SQL_DATABASE=OctopusDeploymentDB  # or your database name
SQL_USERNAME=sa                   # SQL Server login
SQL_PASSWORD=YourPassword         # Use secret variables!
```

## SqlPackage Deployment Options

The pipeline uses SqlPackage with these key parameters:

| Parameter | Value | Purpose |
|-----------|-------|---------|
| `/Action:Publish` | - | Deploy DACPAC to target database |
| `/SourceFile` | *.dacpac | DACPAC package file path |
| `/TargetServerName` | SQL Server address | Target server |
| `/TargetDatabaseName` | Database name | Target database |
| `/p:BlockOnPossibleDataLoss` | Development: false | Allow schema changes that might lose data in Dev |
| `/p:BlockOnPossibleDataLoss` | Production: true | Prevent risky deployments in Prod |
| `/p:DropObjectsNotInSource` | false | Don't drop objects not in DACPAC |

## Creating a SQL Database Project

### Option 1: Visual Studio
```powershell
# Create new SQL Server Database Project in Visual Studio
# File → New → Project → SQL Server Database Project
# Add SQL objects (Tables, Procedures, etc.)
# Build to generate .dacpac file
```

### Option 2: Azure Data Studio + Command Line
```powershell
# Install SQL tools
dotnet tool install -g Microsoft.SqlPackage

# Create DACPAC from existing database
SqlPackage /Action:Extract `
  /SourceConnectionString:"Server=localhost;Initial Catalog=MyDb;Integrated Security=true;" `
  /TargetFile:"Database.dacpac"
```

## Deployment Workflow

1. **Commit SQL changes** to repository
2. **Push to branch** (main/master)
3. **Pipeline triggers**:
   - Builds DACPAC package
   - Publishes to Azure Artifacts
4. **Automatic Dev deployment**
   - Downloads DACPAC artifact
   - Deploys to Development SQL Server
   - Verifies connection
5. **Production deployment** (main branch only):
   - Waits for `Production` environment approval
   - Deploys with strict data loss protection
   - Verifies deployment

## Troubleshooting

### SqlPackage not found
```powershell
dotnet tool install -g Microsoft.SqlPackage
SqlPackage --version
```

### SQL Connection Failed
- Verify SQL Server is running
- Check firewall rules allow connection
- Verify credentials in pipeline variables (secrets)
- Test connection: `sqlcmd -S servername -U username -P password`

### DACPAC Deployment Failed
- Check SqlPackage output logs
- Run with verbose flag:
  ```batch
  SqlPackage /Action:Publish ... /Diagnostics:True
  ```
- Verify database compatibility level
- Review deployment report in artifact logs

### Permissions Error
- Ensure SQL login has `dbcreator` or equivalent permissions
- For production, use least-privilege service account

## Best Practices

1. **Use Secret Variables** for passwords - never commit credentials
2. **Environment Approvals** - require manual approval for production
3. **Test First** - always deploy to Dev before Production
4. **Data Loss Protection** - enable in Production stage
5. **Audit Trail** - use transactional scripts for tracking changes
6. **Pre-deployment Scripts** - include backups before deployment
7. **Post-deployment Validation** - verify schema and data integrity

## Integration with DAY2 Artifacts

This pipeline can be extended to use DACPAC packages published from DAY2:

```yaml
- task: DownloadPackage@1
  inputs:
    packageType: 'pypi'
    feed: 'atharvasp2591'
    definition: 'dacpac-packages'
    version: '*'
```

## Security Considerations

- ✅ Use Azure KeyVault for sensitive credentials
- ✅ Restrict `Production` environment to specific approvers
- ✅ Enable audit logging for database changes
- ✅ Implement pre-deployment backup steps
- ✅ Use Windows Authentication when possible
- ✅ Rotate SQL Server passwords regularly
- ✅ Implement schema validation before deployment

## References

- [SqlPackage Command Line Reference](https://learn.microsoft.com/en-us/sql/tools/sqlpackage/sqlpackage)
- [Azure Pipelines Environments and Approvals](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/environments)
- [SQL Server Database Projects in Visual Studio](https://learn.microsoft.com/en-us/sql/ssdt/sql-server-data-tools)
- [Azure DevOps Deployment Jobs](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/deployment-jobs)
