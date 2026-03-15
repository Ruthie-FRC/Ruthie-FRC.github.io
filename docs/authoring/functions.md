# Creating Functions

Functions are named, reusable script blocks. They are the foundation of PowerShell scripting.

---

## Naming Conventions

Always use the **Verb-Noun** pattern with an approved verb:

```powershell
# Good — approved verb, clear noun
function Get-DiskReport { ... }
function Send-AlertEmail { ... }
function Invoke-Cleanup   { ... }

# List all approved verbs
Get-Verb
```

!!! tip "Check approved verbs"
    Before naming a function, run `Get-Verb | Sort-Object Verb` to find the right verb. Using unapproved verbs generates a warning on module import.

---

## Basic Function Anatomy

```powershell
function Get-Greeting {
    [CmdletBinding()]   # make it act like a real cmdlet
    param (
        [Parameter(Mandatory, Position = 0)]
        [string] $Name,

        [string] $Title = "Dr."
    )

    begin {
        # optional: runs once before pipeline input
        Write-Verbose "Starting Get-Greeting"
    }
    process {
        # runs once per pipeline input object (or once if no pipeline)
        "Hello, $Title $Name!"
    }
    end {
        # optional: runs once after all pipeline input
        Write-Verbose "Finished Get-Greeting"
    }
}
```

---

## Parameters in Depth

### Mandatory parameters

```powershell
param (
    [Parameter(Mandatory)]
    [string] $Path
)
```

If omitted, PowerShell prompts the user at runtime.

### Positional parameters

```powershell
param (
    [Parameter(Position = 0)]
    [string] $Source,

    [Parameter(Position = 1)]
    [string] $Destination
)

# Now both work:
Copy-MyFile "src" "dst"
Copy-MyFile -Source "src" -Destination "dst"
```

### Validation attributes

```powershell
param (
    [ValidateNotNullOrEmpty()]
    [string] $Name,

    [ValidateRange(1, 100)]
    [int] $Count = 10,

    [ValidateSet("Small", "Medium", "Large")]
    [string] $Size = "Medium",

    [ValidatePattern("^\d{4}-\d{2}-\d{2}$")]
    [string] $Date,

    [ValidateScript({ Test-Path $_ })]
    [string] $FilePath,

    [ValidateLength(1, 50)]
    [string] $Label
)
```

### Pipeline input

```powershell
param (
    [Parameter(ValueFromPipeline)]
    [string] $Name,

    [Parameter(ValueFromPipelineByPropertyName)]
    [string] $ComputerName
)
```

`ValueFromPipeline` accepts any value from the pipeline.  
`ValueFromPipelineByPropertyName` matches by property name — so an object with a `.ComputerName` property will automatically bind.

### Switch parameters (boolean flags)

```powershell
param (
    [switch] $Recurse,
    [switch] $Force
)

if ($Recurse) { "Going deep..." }
```

Usage: `My-Function -Recurse -Force`

---

## Returning Values

```powershell
function Get-Square {
    param ([double] $Number)
    return $Number * $Number   # explicit return
}

function Get-Even {
    param ([int[]] $Numbers)
    # Every uncaptured expression is returned
    $Numbers | Where-Object { $_ % 2 -eq 0 }
}

$evens = Get-Even 1..10   # 2,4,6,8,10
```

!!! warning "All unassigned output is returned"
    Unlike most languages, **any expression that produces output** gets added to the return value:
    ```powershell
    function Bad-Function {
        "This text is unexpectedly returned!"
        42
    }
    $result = Bad-Function   # $result = @("This text...", 42)
    ```
    Suppress unwanted output with `$null = ...` or `[void](...)`

---

## Real-World Example

```powershell
function Get-FolderSize {
    <#
    .SYNOPSIS
        Returns the total size of a folder and its contents.
    .PARAMETER Path
        The folder path to measure.
    .PARAMETER Unit
        The unit to report in: Bytes, KB, MB, or GB.
    .EXAMPLE
        Get-FolderSize C:\Users\Alice -Unit MB
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Path $_ -PathType Container })]
        [string] $Path,

        [ValidateSet("Bytes","KB","MB","GB")]
        [string] $Unit = "MB"
    )

    process {
        $bytes = (Get-ChildItem $Path -Recurse -File -ErrorAction SilentlyContinue |
                  Measure-Object -Property Length -Sum).Sum

        $divisor = switch ($Unit) {
            "Bytes" { 1 }
            "KB"    { 1KB }
            "MB"    { 1MB }
            "GB"    { 1GB }
        }

        [PSCustomObject]@{
            Path = $Path
            Size = [math]::Round($bytes / $divisor, 2)
            Unit = $Unit
        }
    }
}

# Use it:
Get-FolderSize C:\Users\Alice -Unit GB
Get-ChildItem C:\Users -Directory | Get-FolderSize -Unit MB | Sort-Object Size -Descending
```

---

## Organizing Functions

- **Interactive use** — define in your `$PROFILE`
- **Reusable utilities** — place in a `.psm1` script module
- **One-off scripts** — define at the top of the `.ps1` file, call at the bottom
- **Published tools** — package as a module and publish to PSGallery

See [Script Modules](script-modules.md) for packaging guidance.
