# PowerShell Syntax Tutorial

These small scripts build PowerShell concepts one step at a time.

## 1. Output: Hello World

[Hello-World.ps1](Hello-World.ps1) contains:

```powershell
Write-Host "Hello, World!" -ForegroundColor Green
```

`Write-Host` writes text to the terminal. `-ForegroundColor` changes the display color.

## 2. Variables

[Variables-Example.ps1](Variables-Example.ps1) defines values with the assignment operator:

```powershell
$courseName = "PowerShell Basics"
$passed = $Score -ge 50
```

PowerShell variables start with `$`. The value can be a string, number, Boolean, array, or another object. PowerShell can infer the type, while parameters can declare one explicitly, such as `[int]$Score`.

Run it with custom values:

```powershell
.\Variables-Example.ps1 -StudentName "Jordan" -Score 95
```

## 3. Parameters and Conditions

[Even-Or-Odd.ps1](Even-Or-Odd.ps1) uses a parameter block:

```powershell
param(
    [Parameter(Mandatory = $true)]
    [int]$Number
)
```

`param` defines input values for a script. `[int]` means the value should be an integer. The modulo operator returns the remainder after division:

```powershell
if ($Number % 2 -eq 0) {
    Write-Host "$Number is even."
}
```

`-eq` means equal to. `else` runs when the `if` condition is false.

## 4. Function Definition

[Function-Example.ps1](Function-Example.ps1) defines reusable instructions:

```powershell
function Get-Greeting {
    param(
        [string]$PersonName
    )

    return "Hello, $PersonName! Welcome to PowerShell."
}
```

A function has a name, optional parameters, and a body. `return` sends a value back to the caller.

The function is called like this:

```powershell
$message = Get-Greeting -PersonName $Name
```

## 5. Function With Numbers

[Function-Calculator.ps1](Function-Calculator.ps1) demonstrates typed parameters and a numeric return value:

```powershell
function Add-Numbers {
    param(
        [int]$First,
        [int]$Second
    )

    return $First + $Second
}
```

The same function can be called with different values:

```powershell
Add-Numbers -First 10 -Second 5
Add-Numbers -First 20 -Second 7
```

This is useful because the addition logic is written once and reused.

## 6. Installing a Python Package

[Install-PythonPackage.ps1](Install-PythonPackage.ps1) demonstrates command lookup, a default parameter, and exit-code checking:

```powershell
$python = Get-Command python -ErrorAction SilentlyContinue

if (-not $python) {
    Write-Host "Python was not found."
    exit 1
}

python -m pip install $PackageName
```

`Get-Command` checks whether a command is available. `-not` reverses a Boolean value. `$LASTEXITCODE` contains the exit code from the last native command; zero normally means success.

## Suggested Learning Order

1. Run `Hello-World.ps1`.
2. Change the text and color.
3. Run `Variables-Example.ps1` with different names and scores.
4. Run `Even-Or-Odd.ps1` with positive and negative integers.
5. Read and call `Get-Greeting` in `Function-Example.ps1`.
6. Change `Add-Numbers` to create a subtraction function.
7. Run `Install-PythonPackage.ps1` only after confirming Python and pip are available.
