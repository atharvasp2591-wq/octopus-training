param(
    [int]$FirstNumber = 10,
    [int]$SecondNumber = 5
)

function Add-Numbers {
    param(
        [int]$First,
        [int]$Second
    )

    return $First + $Second
}

$total = Add-Numbers -First $FirstNumber -Second $SecondNumber
Write-Host "$FirstNumber + $SecondNumber = $total" -ForegroundColor Cyan
