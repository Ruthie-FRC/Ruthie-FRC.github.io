# Advanced Functions & CmdletBinding

Advanced functions are PowerShell functions that behave exactly like compiled cmdlets — complete with common parameters (`-Verbose`, `-Debug`, `-ErrorAction`, `-WhatIf`, `-Confirm`, `-OutBuffer`, etc.).

---

## The `[CmdletBinding()]` Attribute

Adding `[CmdletBinding()]` to your function declaration unlocks all common parameters:

```powershell
function My-Function {
    [CmdletBinding()]
    param ()
    process {
        Write-Verbose "Running with verbose output"
    }
}

My-Function -Verbose    # now works
My-Function -Debug      # now works
My-Function -ErrorAction Stop  # now works
```

---

## SupportsShouldProcess (–WhatIf and –Confirm)

Add `SupportsShouldProcess` to support `-WhatIf` and `-Confirm` for any function that makes changes:

```powershell
function Remove-OldFiles {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param (
        [Parameter(Mandatory)]
        [string] $Path,

        [int] $DaysOld = 30
    )

    $cutoff = (Get-Date).AddDays(-$DaysOld)
    Get-ChildItem $Path -File |
        Where-Object { $_.LastWriteTime -lt $cutoff } |
        ForEach-Object {
            if ($PSCmdlet.ShouldProcess($_.FullName, "Delete")) {
                Remove-Item $_.FullName -Force
                Write-Verbose "Deleted: $($_.FullName)"
            }
        }
}

# Preview
Remove-OldFiles -Path C:\Logs -DaysOld 7 -WhatIf

# Run with confirmation prompt
Remove-OldFiles -Path C:\Logs -DaysOld 7 -Confirm

# Run silently
Remove-OldFiles -Path C:\Logs -DaysOld 7 -Confirm:$false
```

---

## PositionalBinding

Control whether positional binding is allowed:

```powershell
[CmdletBinding(PositionalBinding = $false)]
# Now all parameters MUST be named — no positional usage
```

---

## Parameter Sets

Use parameter sets to create mutually exclusive groups of parameters (like `Get-ChildItem -File` vs `-Directory`):

```powershell
function Get-Report {
    [CmdletBinding(DefaultParameterSetName = 'ByDate')]
    param (
        [Parameter(ParameterSetName = 'ByDate', Mandatory)]
        [datetime] $StartDate,

        [Parameter(ParameterSetName = 'ByDate')]
        [datetime] $EndDate = (Get-Date),

        [Parameter(ParameterSetName = 'ByCount', Mandatory)]
        [int] $Last,

        [Parameter(ParameterSetName = 'ByCount')]
        [ValidateSet('Hours','Days','Weeks')]
        [string] $Unit = 'Days'
    )

    # Detect which set was used
    switch ($PSCmdlet.ParameterSetName) {
        'ByDate'  { "Report from $StartDate to $EndDate" }
        'ByCount' { "Last $Last $Unit" }
    }
}

Get-Report -StartDate "2024-01-01"
Get-Report -Last 7 -Unit Days
```

---

## Dynamic Parameters

Add parameters at runtime based on conditions:

```powershell
function Get-DriveInfo {
    [CmdletBinding()]
    param ()

    dynamicparam {
        $paramDict = [System.Management.Automation.RuntimeDefinedParameterDictionary]::new()

        # Only add -DriveLetter if on Windows
        if ($IsWindows) {
            $attr = [System.Management.Automation.ParameterAttribute]@{ Mandatory = $false }
            $validateSet = [System.Management.Automation.ValidateSetAttribute](
                (Get-PSDrive -PSProvider FileSystem).Name
            )
            $collection = [System.Collections.ObjectModel.Collection[System.Attribute]]@($attr, $validateSet)
            $param = [System.Management.Automation.RuntimeDefinedParameter]::new('DriveLetter', [string], $collection)
            $paramDict.Add('DriveLetter', $param)
        }
        return $paramDict
    }

    process {
        $dl = $PSBoundParameters['DriveLetter']
        if ($dl) {
            Get-PSDrive -Name $dl
        } else {
            Get-PSDrive -PSProvider FileSystem
        }
    }
}
```

---

## OutputType Declaration

Declare the return type so PowerShell's tab completion knows what properties to suggest:

```powershell
function Get-ActiveProcess {
    [CmdletBinding()]
    [OutputType([System.Diagnostics.Process])]
    param (
        [switch] $Elevated
    )
    process {
        Get-Process | Where-Object {
            -not $Elevated -or $_.Handle
        }
    }
}
```

---

## Verbose, Debug, and Progress

```powershell
function Sync-Files {
    [CmdletBinding()]
    param (
        [string] $Source,
        [string] $Destination
    )

    $files = Get-ChildItem $Source -File
    $total = $files.Count
    $i     = 0

    foreach ($file in $files) {
        $i++
        Write-Progress -Activity "Syncing files" `
                       -Status "Processing $($file.Name)" `
                       -PercentComplete ($i / $total * 100)

        Write-Verbose "Copying $($file.Name)"
        Write-Debug   "  Source: $($file.FullName)"

        Copy-Item $file.FullName $Destination -Force
    }

    Write-Progress -Activity "Syncing files" -Completed
}
```

---

## Complete Advanced Function Template

```powershell
function Verb-Noun {
    <#
    .SYNOPSIS
        One-line description.
    .DESCRIPTION
        Full description.
    .PARAMETER Name
        Description of the Name parameter.
    .EXAMPLE
        Verb-Noun -Name "example"
        Description of what this example does.
    .INPUTS
        System.String
    .OUTPUTS
        System.Management.Automation.PSCustomObject
    .NOTES
        Author: Your Name
        Version: 1.0
    .LINK
        https://docs.example.com/verb-noun
    #>
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Default')]
    [OutputType([PSCustomObject])]
    param (
        [Parameter(
            Mandatory,
            Position       = 0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            HelpMessage    = 'Enter the name',
            ParameterSetName = 'Default'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $Name,

        [Parameter(ParameterSetName = 'Default')]
        [ValidateRange(1, 100)]
        [int] $Count = 1,

        [switch] $Force
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand)] Starting"
    }

    process {
        Write-Verbose "Processing: $Name"

        if ($PSCmdlet.ShouldProcess($Name, "Operation")) {
            [PSCustomObject]@{
                Name   = $Name
                Count  = $Count
                Result = "Success"
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand)] Complete"
    }
}
```
