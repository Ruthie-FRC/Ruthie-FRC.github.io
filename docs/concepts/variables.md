# Variables & Scope

Variables are the building blocks of every script. In PowerShell, a variable is a named container for any .NET object.

---

## Declaring Variables

Variables begin with `$`. You don't need to declare a type — PowerShell infers it:

```powershell
$name    = "Alice"
$age     = 30
$pi      = 3.14159
$today   = Get-Date
$running = $true
$nothing = $null
```

### Multiple assignment

```powershell
$a = $b = $c = 0          # all three start at 0
$x, $y, $z = 1, 2, 3      # destructuring assignment
$first, $rest = 1..10     # $first = 1, $rest = 2..10
```

---

## Reading and Writing

```powershell
$greeting = "Hello"
$greeting             # output: Hello
$greeting = "Hi"      # reassign
"${greeting}, World!" # interpolate in a string
```

### String interpolation

Double-quoted strings expand variables; single-quoted strings do not:

```powershell
$name = "Bob"
"Hello, $name"        # → Hello, Bob
'Hello, $name'        # → Hello, $name  (literal)
"Today is $(Get-Date -Format 'yyyy-MM-dd')"  # expression inside $()
```

---

## Variable Types

PowerShell uses dynamic typing but you can declare a type to enforce it:

```powershell
[int]    $count   = 42
[string] $label   = "items"
[bool]   $enabled = $true
[double] $rate    = 0.07
[datetime] $start = "2024-01-01"
```

| Type Accelerator | .NET Type | Example |
|-----------------|-----------|---------|
| `[string]` | `System.String` | `"hello"` |
| `[int]` | `System.Int32` | `42` |
| `[long]` | `System.Int64` | `1000000000000` |
| `[double]` | `System.Double` | `3.14` |
| `[bool]` | `System.Boolean` | `$true` / `$false` |
| `[datetime]` | `System.DateTime` | `Get-Date` |
| `[array]` | `System.Object[]` | `@(1,2,3)` |
| `[hashtable]` | `System.Collections.Hashtable` | `@{a=1}` |
| `[PSCustomObject]` | `System.Management.Automation.PSCustomObject` | `[PSCustomObject]@{}` |

---

## Special Variables

PowerShell provides many built-in automatic variables:

| Variable | Meaning |
|----------|---------|
| `$_` / `$PSItem` | Current pipeline object |
| `$?` | `$true` if last command succeeded |
| `$LASTEXITCODE` | Exit code of last native command |
| `$Error` | Array of recent errors |
| `$null` | Null / nothing |
| `$true` / `$false` | Boolean constants |
| `$env:PATH` | Environment variable access |
| `$PSVersionTable` | PowerShell version info |
| `$HOME` | User home directory |
| `$PWD` | Current directory (object) |
| `$args` | Arguments passed to a script |
| `$MyInvocation` | Info about the current script/function |
| `$PSScriptRoot` | Directory containing the running script |
| `$PSBoundParameters` | Parameters explicitly passed to a function |

---

## Environment Variables

Access environment variables through the `env:` drive:

```powershell
$env:USERNAME          # current Windows username
$env:COMPUTERNAME      # machine name
$env:PATH              # the PATH variable
$env:TEMP              # temp directory

# Set an environment variable (current session only)
$env:MY_VAR = "hello"

# Set it permanently (user scope)
[System.Environment]::SetEnvironmentVariable("MY_VAR","hello","User")
```

---

## Variable Scope

Scope controls where a variable is visible:

| Scope | Description |
|-------|-------------|
| **Local** (default) | Visible only in the current scope (function, script block) |
| **Script** | Visible throughout the current `.ps1` file |
| **Global** | Visible in the entire session |
| **Private** | Visible only in the current scope; not inherited by child scopes |

```powershell
$x = 10           # local scope

function Show-X {
    Write-Host $x   # can READ parent scope variables
    $x = 99         # creates a NEW local $x — does NOT change the parent
}
Show-X             # outputs: 10
$x                 # still 10

# Use $script: or $global: to write to outer scopes
function Update-X {
    $global:x = 99
}
Update-X
$x   # now 99
```

---

## Arrays

```powershell
$fruits = @("apple", "banana", "cherry")
$fruits[0]          # apple (0-indexed)
$fruits[-1]         # cherry (last element)
$fruits[0..1]       # apple, banana (slice)
$fruits.Count       # 3

# Add an element (creates a new array)
$fruits += "date"

# Iterate
foreach ($fruit in $fruits) {
    Write-Host $fruit
}
```

### Typed arrays

```powershell
[int[]] $numbers = 1, 2, 3, 4, 5
$numbers | Measure-Object -Sum
```

---

## Hash Tables

```powershell
$person = @{
    Name = "Alice"
    Age  = 30
    City = "Boston"
}

$person.Name          # Alice  (dot notation)
$person["Age"]        # 30     (index notation)
$person.Keys          # Name, Age, City
$person.Values        # Alice, 30, Boston

# Add or update
$person.Email = "alice@example.com"
$person["Age"] = 31

# Remove
$person.Remove("City")

# Check for key
$person.ContainsKey("Name")  # $true
```

---

## PSCustomObject

For structured data, `PSCustomObject` is more powerful than a hashtable because it preserves property order and supports methods:

```powershell
$user = [PSCustomObject]@{
    Name  = "Alice"
    Age   = 30
    Email = "alice@example.com"
}

$user.Name   # Alice
$user | Format-Table

# Add a property after creation
$user | Add-Member -MemberType NoteProperty -Name Role -Value "Admin"
```

---

## Checking and Removing Variables

```powershell
Test-Path variable:\myVar      # $true if variable exists
Get-Variable myVar             # get the variable object
Remove-Variable myVar          # delete the variable
Clear-Variable myVar           # set to $null without deleting
```
