# Publishing to the PowerShell Gallery

The [PowerShell Gallery](https://www.powershellgallery.com/) is the central repository for PowerShell modules and scripts. Publishing here makes your work discoverable and installable by anyone with `Install-Module`.

---

## Prerequisites

1. A finished module with a valid `.psd1` manifest
2. A [PowerShell Gallery account](https://www.powershellgallery.com/users/account/LogOn) (free)
3. An **API key** from your Gallery profile page

---

## Preparing Your Module

### 1. Create a complete manifest

```powershell
New-ModuleManifest `
    -Path .\MyModule\MyModule.psd1 `
    -RootModule MyModule.psm1 `
    -ModuleVersion "1.0.0" `
    -Guid (New-Guid) `
    -Author "Your Name" `
    -CompanyName "Your Company" `
    -Description "A clear, helpful description of what your module does" `
    -PowerShellVersion "5.1" `
    -Tags @("your", "tags", "here") `
    -ProjectUri "https://github.com/you/MyModule" `
    -LicenseUri "https://github.com/you/MyModule/blob/main/LICENSE" `
    -FunctionsToExport @("Get-Widget", "Set-Widget")
```

### 2. Validate the manifest

```powershell
Test-ModuleManifest .\MyModule\MyModule.psd1
```

Fix any warnings or errors before continuing.

### 3. Lint your code

```powershell
Install-Module PSScriptAnalyzer
Invoke-ScriptAnalyzer -Path .\MyModule -Recurse -Severity Warning
```

Fix all warnings. The Gallery will show analyzer results on your module page.

### 4. Test your module

```powershell
# Import fresh
Import-Module .\MyModule -Force

# Run your Pester tests
Install-Module Pester
Invoke-Pester .\Tests\
```

---

## Publishing

```powershell
# Set your API key (get it from powershellgallery.com → Account → API Keys)
$apiKey = Read-Host "Enter your NuGet API key" -AsSecureString
$apiKeyPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($apiKey)
)

# Publish
Publish-Module -Path .\MyModule -NuGetApiKey $apiKeyPlain

# Or reference by name if already on PSModulePath
Publish-Module -Name MyModule -NuGetApiKey $apiKeyPlain
```

---

## Updating a Published Module

1. Update the version in the `.psd1` manifest — increment per **SemVer**:
   - Bug fix → patch (`1.0.0` → `1.0.1`)
   - New feature, backward compatible → minor (`1.0.1` → `1.1.0`)
   - Breaking change → major (`1.1.0` → `2.0.0`)

2. Update `ReleaseNotes` in the `PSData` section
3. Re-run `Test-ModuleManifest` and `Invoke-ScriptAnalyzer`
4. Re-publish:

```powershell
Publish-Module -Path .\MyModule -NuGetApiKey $apiKeyPlain
```

---

## Publishing a Script (not a module)

```powershell
# A script needs a comment-based metadata block at the top
# Add it manually or use New-ScriptFileInfo:
New-ScriptFileInfo `
    -Path .\Invoke-MyTool.ps1 `
    -Version "1.0.0" `
    -Author "Your Name" `
    -Description "What my tool does"

# Publish the script
Publish-Script -Path .\Invoke-MyTool.ps1 -NuGetApiKey $apiKeyPlain
```

---

## Gallery Best Practices

| Practice | Why It Matters |
|----------|---------------|
| Write descriptive `.SYNOPSIS` and `.DESCRIPTION` | Shown on the Gallery search results page |
| Add relevant tags | Helps users find your module |
| Include a `LICENSE` file and `LicenseUri` | Required for enterprise use |
| Link to a `ProjectUri` (GitHub) | Users can file issues and see the source |
| Add `ReleaseNotes` on every version | Users can review what changed |
| Write Pester tests | Demonstrates quality; CI badges build trust |
| Follow PSScriptAnalyzer rules | Analyzer score shown on your Gallery page |
| Keep `-WhatIf` support | Best practice for any function that changes system state |

---

## Checking Your Published Module

```powershell
# Find it on the Gallery
Find-Module -Name MyModule

# See all versions
Find-Module -Name MyModule -AllVersions

# Check it from the consumer's perspective
Install-Module MyModule -Scope CurrentUser
Import-Module MyModule
Get-Command -Module MyModule
Get-Help Get-Widget -Full
```

---

## Automating Publish with GitHub Actions

```yaml title=".github/workflows/publish.yml"
name: Publish to PSGallery

on:
  push:
    tags: ['v*']

jobs:
  publish:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v4

      - name: Publish Module
        shell: pwsh
        env:
          PSGALLERY_API_KEY: ${{ secrets.PSGALLERY_API_KEY }}
        run: |
          $ErrorActionPreference = 'Stop'
          Test-ModuleManifest .\MyModule\MyModule.psd1
          Invoke-ScriptAnalyzer -Path .\MyModule -Recurse -Severity Error
          Publish-Module -Path .\MyModule -NuGetApiKey $env:PSGALLERY_API_KEY
```

Store your API key as a repository secret named `PSGALLERY_API_KEY`.
