# PowerShell Beginner Scripts

Small examples for learning PowerShell syntax. Run them from this folder.

## Examples

### 1. Hello World

```powershell
.\Hello-World.ps1
```

Introduces `Write-Host` and simple output.

### 2. Variables

```powershell
.\Variables-Example.ps1
.\Variables-Example.ps1 -StudentName "Sam" -Score 42
```

Shows how to define string and integer variables, compare values, and use a Boolean variable in an `if` statement.

### 3. Even or Odd

```powershell
.\Even-Or-Odd.ps1 -Number 8
.\Even-Or-Odd.ps1 -Number 7
```

Shows parameters, integer types, the modulo operator (`%`), and conditional logic.

### 4. Functions

```powershell
.\Function-Example.ps1
.\Function-Example.ps1 -Name "Taylor"
```

Shows how to define a function, declare a function parameter, call the function, and return a string.

### 5. Function Calculator

```powershell
.\Function-Calculator.ps1
.\Function-Calculator.ps1 -FirstNumber 12 -SecondNumber 8
```

Shows a reusable function with two typed parameters and a returned calculation result.

### 6. Install a Python Package

```powershell
.\Install-PythonPackage.ps1
.\Install-PythonPackage.ps1 -PackageName "requests"
```

Checks for Python and installs a package with `python -m pip`. Run this example only when you intend to change the Python environment.

## Syntax Quick Reference

```powershell
# Variable definition
$name = "Alex"
$count = 3

# Function definition
function Get-Message {
    param([string]$PersonName)
    return "Hello, $PersonName"
}

# Function call
$message = Get-Message -PersonName "Alex"

# Conditional statement
if ($count -gt 0) {
    Write-Host "The count is positive."
}
```

For a longer explanation, see [POWERSHELL_SCRIPTS_TUTORIAL.md](POWERSHELL_SCRIPTS_TUTORIAL.md).
