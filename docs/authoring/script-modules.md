# Script Modules

A **script module** packages your functions, aliases, and variables into a folder that PowerShell can discover and import automatically.

---

## Module Structure

The minimum viable module is a single `.psm1` file in a folder that shares its name:

```
MyModule/
├── MyModule.psm1    ← required: contains your functions
└── MyModule.psd1    ← optional but recommended: module manifest
```

For larger modules:

```
MyModule/
├── MyModule.psd1
├── MyModule.psm1       ← dot-sources the private/ and public/ files
├── Public/             ← exported (public) functions
│   ├── Get-Widget.ps1
│   └── Set-Widget.ps1
├── Private/            ← internal helper functions
│   └── ConvertTo-WidgetFormat.ps1
└── Tests/
    └── MyModule.Tests.ps1
```

---

## Writing the `.psm1` File

### Simple approach

```powershell title="MyModule/MyModule.psm1"
function Get-Widget {
    [CmdletBinding()]
    param ([string] $Name)
    "Widget: $Name"
}

function Remove-Widget {
    [CmdletBinding(SupportsShouldProcess)]
    param ([string] $Name)
    if ($PSCmdlet.ShouldProcess($Name, "Remove")) {
        "Removed: $Name"
    }
}

# Export only the public functions
Export-ModuleMember -Function Get-Widget, Remove-Widget
```

### Auto-load from Public/Private folders

```powershell title="MyModule/MyModule.psm1"
# Dot-source all private helpers
foreach ($file in Get-ChildItem $PSScriptRoot\Private -Filter *.ps1) {
    . $file.FullName
}

# Dot-source and track all public functions
$publicFunctions = @()
foreach ($file in Get-ChildItem $PSScriptRoot\Public -Filter *.ps1) {
    . $file.FullName
    $publicFunctions += $file.BaseName
}

Export-ModuleMember -Function $publicFunctions
```

---

## Creating a Module Manifest

The manifest (`.psd1`) describes the module — its version, author, dependencies, and what to export:

```powershell
# Generate a manifest with New-ModuleManifest
New-ModuleManifest `
    -Path .\MyModule\MyModule.psd1 `
    -RootModule MyModule.psm1 `
    -ModuleVersion "1.0.0" `
    -Author "Alice Smith" `
    -CompanyName "Acme Corp" `
    -Description "Manages widgets for the Acme platform" `
    -PowerShellVersion "7.0" `
    -FunctionsToExport @("Get-Widget","Remove-Widget") `
    -Tags @("widget","acme") `
    -ProjectUri "https://github.com/acme/MyModule"
```

This produces a human-readable `.psd1` file you can edit directly.

### Example manifest

```powershell title="MyModule/MyModule.psd1"
@{
    RootModule        = 'MyModule.psm1'
    ModuleVersion     = '1.2.0'
    GUID              = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'
    Author            = 'Alice Smith'
    Description       = 'Manages widgets for the Acme platform'
    PowerShellVersion = '7.0'

    FunctionsToExport = @('Get-Widget', 'Remove-Widget', 'New-Widget')
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @('gw')

    RequiredModules   = @()

    PrivateData = @{
        PSData = @{
            Tags        = @('widget', 'acme', 'automation')
            LicenseUri  = 'https://github.com/acme/MyModule/blob/main/LICENSE'
            ProjectUri  = 'https://github.com/acme/MyModule'
            ReleaseNotes = 'Initial release'
        }
    }
}
```

---

## Installing Your Module

Place the module folder in a directory on `$env:PSModulePath`:

```powershell
# View the search paths
$env:PSModulePath -split [IO.Path]::PathSeparator

# Copy to the current user's module directory
$dest = "$HOME\Documents\PowerShell\Modules\MyModule"
Copy-Item .\MyModule $dest -Recurse -Force

# Import it
Import-Module MyModule

# Verify
Get-Command -Module MyModule
```

---

## Testing Your Module During Development

```powershell
# Force-reimport during iteration
Import-Module .\MyModule -Force

# Or use the full path
Import-Module C:\Dev\MyModule\MyModule.psd1 -Force

# Inspect what's exported
Get-Module MyModule | Select-Object -ExpandProperty ExportedFunctions
```

---

## Module Best Practices

1. **One function per file** in `Public/` and `Private/` for easy navigation
2. **Keep the `.psm1` thin** — just dot-source files and call `Export-ModuleMember`
3. **Always use a manifest** (`.psd1`) — it enables versioning, dependency management, and PSGallery publishing
4. **Version with SemVer** — `Major.Minor.Patch` (e.g., `2.1.0`)
5. **Write Pester tests** in a `Tests/` folder
6. **Use PSScriptAnalyzer** to lint your code before publishing:

```powershell
Install-Module PSScriptAnalyzer
Invoke-ScriptAnalyzer -Path .\MyModule -Recurse
```

---

## Complete Module Walkthrough

Here is a complete, production-quality minimal module:

```
📁 GreetingModule/
├── GreetingModule.psd1
├── GreetingModule.psm1
├── Public/
│   ├── Get-Greeting.ps1
│   └── Send-Greeting.ps1
└── Private/
    └── Format-GreetingText.ps1
```

```powershell title="Private/Format-GreetingText.ps1"
function Format-GreetingText {
    param ([string]$Name, [string]$Style)
    switch ($Style) {
        "Formal"   { "Dear $Name," }
        "Casual"   { "Hey $Name!" }
        default    { "Hello, $Name!" }
    }
}
```

```powershell title="Public/Get-Greeting.ps1"
function Get-Greeting {
    <#
    .SYNOPSIS Returns a greeting string.
    .PARAMETER Name Name to greet.
    .PARAMETER Style Formal, Casual, or default.
    .EXAMPLE Get-Greeting -Name Alice -Style Formal
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string] $Name,

        [ValidateSet("Formal","Casual","Default")]
        [string] $Style = "Default"
    )
    process { Format-GreetingText -Name $Name -Style $Style }
}
```

```powershell title="GreetingModule.psm1"
foreach ($f in Get-ChildItem $PSScriptRoot\Private -Filter *.ps1) { . $f.FullName }

$public = Get-ChildItem $PSScriptRoot\Public -Filter *.ps1
foreach ($f in $public) { . $f.FullName }

Export-ModuleMember -Function ($public.BaseName)
```
