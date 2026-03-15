# Functions

Functions let you package reusable logic, give it a name, and call it with parameters. They are the primary unit of reusable code in PowerShell.

---

## Basic Function

```powershell
function Say-Hello {
    Write-Host "Hello, World!"
}

Say-Hello   # call it
```

---

## Functions with Parameters

```powershell
function Get-Greeting {
    param (
        [string] $Name,
        [string] $Title = "Dr."   # default value
    )
    "Hello, $Title $Name!"
}

Get-Greeting -Name "Smith"             # Hello, Dr. Smith!
Get-Greeting -Name "Jones" -Title "Mr" # Hello, Mr Jones!
Get-Greeting "Alice"                   # positional — Hello, Dr. Alice!
```

---

## Return Values

Functions return the **last expression evaluated** (or use `return` explicitly):

```powershell
function Add-Numbers {
    param ([int]$A, [int]$B)
    $A + $B         # implicitly returned
}

$sum = Add-Numbers 3 7    # $sum = 10
```

```powershell
function Get-Status {
    param ([string]$Name)
    $svc = Get-Service -Name $Name -ErrorAction SilentlyContinue
    if ($null -eq $svc) { return "Not found" }
    return $svc.Status
}
```

!!! warning "All output is returned"
    In PowerShell, **every uncaptured expression** in a function becomes part of the return value — not just the `return` statement. Assign intermediate results to `$null` or use `[void]` to suppress unintended output:
    ```powershell
    $null = Some-Command-With-Output
    [void](Another-Command)
    ```

---

## Pipeline Input

Make a function accept pipeline input with `[Parameter(ValueFromPipeline)]`:

```powershell
function Show-Name {
    param (
        [Parameter(ValueFromPipeline)]
        [string] $Name
    )
    process {
        "Name: $Name"
    }
}

"Alice","Bob","Charlie" | Show-Name
```

The `process` block runs once **per pipeline object**. Use `begin` and `end` for setup/teardown:

```powershell
function Count-Items {
    param (
        [Parameter(ValueFromPipeline)]
        $InputObject
    )
    begin   { $count = 0 }
    process { $count++ }
    end     { "Total: $count items" }
}

1..100 | Count-Items
```

---

## Scope

Variables created inside a function are **local** by default:

```powershell
$x = "outer"

function Test-Scope {
    $x = "inner"
    "Inside: $x"
}

Test-Scope      # Inside: inner
"Outside: $x"  # Outside: outer
```

Use scope modifiers to write to outer scopes (use sparingly — prefer returning values):

```powershell
function Set-GlobalConfig {
    $global:AppConfig = @{ Theme = "Dark" }
}
```

---

## Splatting Parameters

Use a hashtable to pass named parameters — useful for building dynamic parameter sets:

```powershell
$params = @{
    Path        = "C:\Windows"
    Filter      = "*.exe"
    Recurse     = $true
    ErrorAction = "SilentlyContinue"
}

Get-ChildItem @params
```

You can also splat arrays for positional parameters:

```powershell
$args = @("Hello", "World")
Write-Host @args
```

---

## CmdletBinding and Common Parameters

Add `[CmdletBinding()]` to make your function behave like a real cmdlet with all the common parameters (`-Verbose`, `-Debug`, `-ErrorAction`, `-WhatIf`, `-Confirm`, etc.):

```powershell
function Remove-OldLogs {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $Path = ".\logs",
        [int]    $DaysOld = 30
    )

    $cutoff = (Get-Date).AddDays(-$DaysOld)
    Get-ChildItem $Path -Filter *.log |
        Where-Object { $_.LastWriteTime -lt $cutoff } |
        ForEach-Object {
            if ($PSCmdlet.ShouldProcess($_.FullName, "Delete")) {
                Remove-Item $_.FullName
                Write-Verbose "Deleted $($_.FullName)"
            }
        }
}

Remove-OldLogs -Path C:\Logs -DaysOld 7 -WhatIf
Remove-OldLogs -Path C:\Logs -DaysOld 7 -Verbose
```

See [Advanced Functions](../authoring/advanced-functions.md) for the full details.

---

## Anonymous Script Blocks

Script blocks `{ }` are unnamed functions. Use them with `Invoke-Command`, `&`, and pipeline cmdlets:

```powershell
$double = { param($n) $n * 2 }
& $double 5   # 10

$greet = { "Hello, $_!" }
"Alice","Bob" | ForEach-Object $greet
```

---

## Best Practices

1. **Use Verb-Noun names** from the approved verb list (`Get-Verb`)
2. **Always add type constraints** to parameters — it catches bugs early
3. **Use `Write-Verbose` for diagnostic messages** — not `Write-Host`
4. **Return objects, not formatted strings** so callers can further process them
5. **Support `-WhatIf` and `-Confirm`** for functions that make changes
6. **Add comment-based help** so `Get-Help` works on your function

```powershell
function Get-ActiveUser {
    <#
    .SYNOPSIS
        Returns users who logged in within the last N days.
    .PARAMETER Days
        Number of days to look back (default: 30).
    .EXAMPLE
        Get-ActiveUser -Days 7
    #>
    [CmdletBinding()]
    param (
        [int] $Days = 30
    )

    $cutoff = (Get-Date).AddDays(-$Days)
    Get-LocalUser | Where-Object {
        $_.LastLogon -gt $cutoff -and $_.Enabled
    }
}
```
