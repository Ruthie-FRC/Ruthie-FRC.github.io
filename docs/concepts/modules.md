# Modules

Modules are packages of reusable PowerShell code — cmdlets, functions, aliases, variables, and providers — distributed as a single unit.

---

## What is a Module?

A module is a self-contained package stored in a folder (or a single `.psm1` file) that you can import into any session. PowerShell ships with dozens of built-in modules and thousands more are available from the [PowerShell Gallery](https://www.powershellgallery.com/).

### Module types

| Type | File Extension | Description |
|------|---------------|-------------|
| Script module | `.psm1` | Functions and variables in a script file |
| Binary module | `.dll` | Compiled .NET assembly (C# cmdlets) |
| Manifest module | `.psd1` | Metadata file that describes the module |
| Dynamic module | (in memory) | Created with `New-Module` |

---

## Finding Modules

```powershell
# List all modules installed on this machine
Get-Module -ListAvailable

# List modules currently loaded in the session
Get-Module

# Search the PowerShell Gallery
Find-Module -Name *azure*
Find-Module -Tag Security
Find-Module -Command Get-ADUser
```

---

## Installing Modules

```powershell
# Install from the PowerShell Gallery
Install-Module -Name Pester

# Install for the current user only (no admin required)
Install-Module -Name PSReadLine -Scope CurrentUser

# Install a specific version
Install-Module -Name Az -RequiredVersion 9.0.0

# Update an installed module
Update-Module -Name Pester

# Uninstall
Uninstall-Module -Name Pester
```

!!! tip "Trust the repository first"
    On the first install, you may be prompted to trust the PSGallery repository. You can pre-approve it:
    ```powershell
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    ```

---

## Importing Modules

```powershell
# Import by name (searches $env:PSModulePath)
Import-Module ActiveDirectory

# Import from a specific path
Import-Module C:\MyModules\MyTools.psm1

# Force reimport (useful during development)
Import-Module MyTools -Force

# Import and return the module object
$mod = Import-Module MyTools -PassThru
```

### Auto-loading

PowerShell 3+ **auto-imports** modules the first time you use a cmdlet from them. Explicit `Import-Module` is only needed when:
- The module is not on `$env:PSModulePath`
- You need specific version control
- You want to ensure all functions are loaded at script start

---

## Module Discovery Path

```powershell
$env:PSModulePath -split [IO.Path]::PathSeparator
```

Modules placed in any of these directories are auto-discoverable. For user-installed modules, PowerShell uses `~\Documents\PowerShell\Modules` (PS 7) or `~\Documents\WindowsPowerShell\Modules` (PS 5.1).

---

## Creating Your Own Module

See [Script Modules](../authoring/script-modules.md) for a complete guide. The quick version:

1. Create a folder: `MyModule\`
2. Add functions in `MyModule\MyModule.psm1`
3. (Optional) Create `MyModule\MyModule.psd1` manifest
4. Place the folder in a `$env:PSModulePath` directory
5. `Import-Module MyModule`

### Minimal example

```powershell title="MyModule/MyModule.psm1"
function Get-Greeting {
    param ([string]$Name)
    "Hello, $Name!"
}

function Get-Farewell {
    param ([string]$Name)
    "Goodbye, $Name!"
}

Export-ModuleMember -Function Get-Greeting, Get-Farewell
```

---

## Useful Built-In Modules

| Module | Purpose |
|--------|---------|
| `Microsoft.PowerShell.Management` | File system, services, processes, registry |
| `Microsoft.PowerShell.Utility` | Formatting, conversion, web requests |
| `Microsoft.PowerShell.Security` | Execution policy, certificates, credentials |
| `PSReadLine` | Command-line editing, syntax highlighting |
| `PackageManagement` | NuGet, Chocolatey, and other package sources |
| `PowerShellGet` | `Install-Module`, `Find-Module`, PSGallery |
| `CimCmdlets` | WMI/CIM queries |
| `NetTCPIP` | `Get-NetIPAddress`, `Test-NetConnection` |
| `ScheduledTasks` | `Get-ScheduledTask`, `Register-ScheduledTask` |
| `ActiveDirectory` | AD user, group, and computer management |
| `Az` | Azure cloud management |
| `AWS.Tools.*` | AWS management |

---

## Popular Community Modules

| Module | Install | Purpose |
|--------|---------|---------|
| `Pester` | `Install-Module Pester` | Testing framework |
| `PSScriptAnalyzer` | `Install-Module PSScriptAnalyzer` | Linter and best-practice analyzer |
| `ImportExcel` | `Install-Module ImportExcel` | Read/write Excel files without Excel |
| `dbatools` | `Install-Module dbatools` | SQL Server management |
| `oh-my-posh` | `Install-Module oh-my-posh` | Shell prompt themes |
| `Terminal-Icons` | `Install-Module Terminal-Icons` | File icons in terminal |
| `PSFzf` | `Install-Module PSFzf` | Fuzzy-finder integration |
