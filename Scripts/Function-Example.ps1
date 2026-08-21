param(
    [string]$Name = "PowerShell learner"
)

# A function groups reusable instructions.
function Get-Greeting {
    param(
        [string]$PersonName
    )

    return "Hello, $PersonName! Welcome to PowerShell."
}

$message = Get-Greeting -PersonName $Name
Write-Host $message -ForegroundColor Green
