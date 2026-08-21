param(
    [Parameter(Mandatory = $true)] [string] $DacpacPath,
    [Parameter(Mandatory = $true)] [string] $SqlServer,
    [Parameter(Mandatory = $true)] [string] $DatabaseName,
    [string] $SqlUsername,
    [string] $SqlPassword,
    [bool] $BlockOnPossibleDataLoss = $true
)

$sqlPackage = Get-Command SqlPackage -ErrorAction SilentlyContinue
if (-not $sqlPackage) {
    $sqlPackage = Get-ChildItem 'C:\Program Files\Microsoft SQL Server' -Filter SqlPackage.exe -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
}
if (-not $sqlPackage) { throw 'SqlPackage.exe is required on the Octopus deployment target.' }

$arguments = @(
    '/Action:Publish',
    "/SourceFile:$DacpacPath",
    "/TargetServerName:$SqlServer",
    "/TargetDatabaseName:$DatabaseName",
    "/p:BlockOnPossibleDataLoss=$BlockOnPossibleDataLoss",
    '/p:DropObjectsNotInSource=False',
    '/p:GenerateSmartDefaults=True',
    '/p:IncludeTransactionalScripts=True'
)
if ($SqlUsername) {
    $arguments += "/TargetUser:$SqlUsername"
    $arguments += "/TargetPassword:$SqlPassword"
}
else {
    $arguments += '/TargetTrustServerCertificate:True'
}

& $sqlPackage.Source @arguments
if ($LASTEXITCODE -ne 0) { throw "SqlPackage failed with exit code $LASTEXITCODE." }
