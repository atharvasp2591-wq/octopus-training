param(
    [string]$PackageName = "requests"
)

$python = Get-Command python -ErrorAction SilentlyContinue

if (-not $python) {
    Write-Host "Python was not found. Install Python from https://www.python.org/downloads/ and run this script again." -ForegroundColor Red
    exit 1
}

Write-Host "Python found: $($python.Source)" -ForegroundColor Green
Write-Host "Installing package: $PackageName" -ForegroundColor Cyan

python -m pip install $PackageName

if ($LASTEXITCODE -eq 0) {
    Write-Host "$PackageName installed successfully." -ForegroundColor Green
}
else {
    Write-Host "Package installation failed." -ForegroundColor Red
    exit $LASTEXITCODE
}
