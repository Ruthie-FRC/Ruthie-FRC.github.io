# Comment-Based Help

PowerShell's built-in `Get-Help` system works with your own functions and scripts — you just need to add **comment-based help** in the right format.

---

## Basic Structure

Place the help block **immediately before** or **inside** the function:

```powershell
function Get-Greeting {
    <#
    .SYNOPSIS
        Returns a greeting string.
    .DESCRIPTION
        Generates a personalized greeting. Supports formal, casual,
        and default styles. Can accept pipeline input.
    .PARAMETER Name
        The person to greet. Accepts pipeline input.
    .PARAMETER Style
        The greeting style: Formal, Casual, or Default.
    .EXAMPLE
        Get-Greeting -Name "Alice"
        Returns: Hello, Alice!
    .EXAMPLE
        "Alice","Bob" | Get-Greeting -Style Formal
        Returns formal greetings for both names.
    .INPUTS
        System.String — names can be piped in.
    .OUTPUTS
        System.String — the greeting text.
    .NOTES
        Author: Your Name
        Version: 1.0
        Change Log:
            1.0 - 2024-03-01 - Initial release
    .LINK
        https://docs.example.com/Get-Greeting
    .LINK
        Get-Help
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string] $Name,

        [ValidateSet("Formal","Casual","Default")]
        [string] $Style = "Default"
    )
    process {
        switch ($Style) {
            "Formal"  { "Dear $Name," }
            "Casual"  { "Hey $Name!" }
            default   { "Hello, $Name!" }
        }
    }
}
```

---

## Help Keywords Reference

| Keyword | Purpose | Required? |
|---------|---------|-----------|
| `.SYNOPSIS` | One-line description | Recommended |
| `.DESCRIPTION` | Full description (can span multiple paragraphs) | Recommended |
| `.PARAMETER <Name>` | Describes a specific parameter | Recommended for each param |
| `.EXAMPLE` | Shows a usage example (can appear multiple times) | Recommended |
| `.INPUTS` | Describes accepted pipeline input types | Optional |
| `.OUTPUTS` | Describes return types | Optional |
| `.NOTES` | Free-form: author, version, change log, etc. | Optional |
| `.LINK` | Related links (can appear multiple times) | Optional |
| `.COMPONENT` | Component the function belongs to | Optional |
| `.ROLE` | Required role | Optional |
| `.FUNCTIONALITY` | Feature the function implements | Optional |
| `.FORWARDHELPTARGETNAME` | Redirect help to another command | Advanced |
| `.EXTERNALHELP` | Link to external MAML help file | Advanced |

---

## Viewing Help

```powershell
# Basic help
Get-Help Get-Greeting

# Detailed (includes parameter descriptions)
Get-Help Get-Greeting -Detailed

# Full (everything, including technical notes)
Get-Help Get-Greeting -Full

# Examples only
Get-Help Get-Greeting -Examples

# Parameter details
Get-Help Get-Greeting -Parameter Name

# Open in a separate window (Windows)
Get-Help Get-Greeting -ShowWindow
```

---

## Help for Scripts

Add help at the very top of a `.ps1` file (before any code):

```powershell title="Invoke-Cleanup.ps1"
<#
.SYNOPSIS
    Removes temporary files older than N days.
.DESCRIPTION
    Scans the specified directory recursively for files whose LastWriteTime
    is older than DaysOld days and removes them. Supports -WhatIf.
.PARAMETER Path
    The directory to clean up.
.PARAMETER DaysOld
    Files older than this many days are removed. Default: 30.
.EXAMPLE
    .\Invoke-Cleanup.ps1 -Path C:\Logs -DaysOld 7 -WhatIf
.EXAMPLE
    .\Invoke-Cleanup.ps1 -Path C:\Temp
#>
[CmdletBinding(SupportsShouldProcess)]
param (
    [string] $Path = $env:TEMP,
    [int]    $DaysOld = 30
)

$cutoff = (Get-Date).AddDays(-$DaysOld)
Get-ChildItem $Path -Recurse -File |
    Where-Object { $_.LastWriteTime -lt $cutoff } |
    ForEach-Object {
        if ($PSCmdlet.ShouldProcess($_.FullName, "Delete")) {
            Remove-Item $_.FullName -Force
        }
    }
```

---

## Writing Good Examples

The best examples are:

1. **Runnable** — they actually work
2. **Progressive** — start simple, add complexity in later examples
3. **Explained** — describe what the output will look like

```powershell
<#
.EXAMPLE
    Get-DiskReport
    Lists all FileSystem drives with used and free space in GB.

.EXAMPLE
    Get-DiskReport -Unit MB
    Reports disk space in megabytes instead of gigabytes.

.EXAMPLE
    Get-DiskReport | Where-Object { $_.'Free%' -lt 20 }
    Finds drives with less than 20% free space.

.EXAMPLE
    Get-DiskReport | Export-Csv .\disk-report.csv -NoTypeInformation
    Exports the report to a CSV file for later analysis.
#>
```

---

## Linting Help with PSScriptAnalyzer

```powershell
Install-Module PSScriptAnalyzer
Invoke-ScriptAnalyzer -Path .\MyFunction.ps1 -IncludeRule PSUseShouldProcessForStateChangingFunctions
```

Key analyzer rules for documentation:
- `PSProvideCommentHelp` — warns if a function has no comment-based help
- `PSUseShouldProcessForStateChangingFunctions` — warns if a function that changes state doesn't use `SupportsShouldProcess`
