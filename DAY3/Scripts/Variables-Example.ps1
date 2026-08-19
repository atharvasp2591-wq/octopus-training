param(
    [string]$StudentName = "Alex",
    [int]$Score = 85
)

# Variables store values that a script can use later.
$courseName = "PowerShell Basics"
$passed = $Score -ge 50

Write-Host "Student: $StudentName"
Write-Host "Course: $courseName"
Write-Host "Score: $Score"

if ($passed) {
    Write-Host "Result: Passed" -ForegroundColor Green
}
else {
    Write-Host "Result: Needs improvement" -ForegroundColor Yellow
}
# [string]   $name = "Alex"       # Text
# [int]      $age = 25            # Whole number
# [double]   $price = 19.99       # Decimal number
# [decimal]  $amount = 99.95      # Precise decimal
# [bool]     $isActive = $true    # True or false
# [char]     $grade = 'A'         # Single character
# [datetime] $today = Get-Date    # Date and time
# [array]    $colors = @("Red", "Blue")
# [hashtable] $user = @{
#     Name = "Alex"
#     Age  = 25
# }
# [object]   $value = "Any value" # 