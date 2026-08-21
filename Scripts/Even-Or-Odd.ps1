param(
    [Parameter(Mandatory = $true)]
    [int]$Number
)

if ($Number % 2 -eq 0) {
    Write-Host "$Number is even." -ForegroundColor Green
}
else {
    Write-Host "$Number is odd." -ForegroundColor Yellow
}
