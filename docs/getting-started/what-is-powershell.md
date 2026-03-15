# What is PowerShell?

PowerShell is a **cross-platform task automation shell and scripting language** built on .NET. It was first released by Microsoft in 2006 as *Windows PowerShell* and open-sourced in 2016 as *PowerShell Core* (now simply **PowerShell 7+**).

---

## The Key Difference: Objects, Not Text

Traditional shells like Bash communicate between commands using **plain text**. To extract information you must parse strings, which is fragile and error-prone:

```bash title="Bash — text parsing is brittle"
ps aux | grep "[n]otepad" | awk '{print $2}'   # parse PID from text
```

PowerShell passes **.NET objects** between commands. Every property is accessible by name — no parsing required:

```powershell title="PowerShell — structured objects"
(Get-Process -Name notepad).Id   # access the Id property directly
```

This object model makes PowerShell uniquely powerful for scripting, data manipulation, and automation.

---

## PowerShell vs. Windows PowerShell

| | Windows PowerShell | PowerShell 7+ |
|---|---|---|
| **Runtime** | .NET Framework | .NET 6 / 7 / 8 |
| **Platforms** | Windows only | Windows, macOS, Linux |
| **Version** | 5.1 (final) | 7.x (actively updated) |
| **Executable** | `powershell.exe` | `pwsh.exe` |
| **Status** | Maintenance only | Active development |

!!! tip "Which should I use?"
    Use **PowerShell 7+** (`pwsh`) for all new scripts. Windows PowerShell 5.1 (`powershell`) is still available on Windows but receives no new features.

---

## Core Design Principles

### 1. Verb-Noun Naming
Every cmdlet follows a `Verb-Noun` naming convention:

| Verb | Noun | Cmdlet |
|------|------|--------|
| `Get` | `Process` | `Get-Process` |
| `Stop` | `Service` | `Stop-Service` |
| `Export` | `Csv` | `Export-Csv` |
| `Invoke` | `RestMethod` | `Invoke-RestMethod` |

The approved verb list (`Get-Verb`) keeps commands predictable — once you know the nouns in a module, you can guess the cmdlets.

### 2. Everything is an Object

```powershell
$file = Get-Item .\README.md
$file.Length          # file size in bytes
$file.LastWriteTime   # DateTime object
$file.Extension       # ".md"
```

### 3. The Pipeline

Commands are chained with `|`. The *output object* of one command becomes the *input* of the next:

```powershell
Get-Service |
    Where-Object Status -eq 'Stopped' |
    Sort-Object DisplayName |
    Select-Object Name, DisplayName |
    Export-Csv .\stopped-services.csv -NoTypeInformation
```

### 4. Discoverability

Three commands let you explore anything:

```powershell
Get-Command *dns*          # find cmdlets by name
Get-Help Resolve-DnsName   # read documentation
Get-Process | Get-Member   # inspect object properties
```

---

## Where PowerShell Runs

- **Windows** — built-in (5.1) and downloadable (7+)
- **macOS** — via Homebrew or direct download
- **Linux** — via package managers (apt, dnf, snap) or direct download
- **Azure Cloud Shell** — pre-installed
- **VS Code** — with the PowerShell extension
- **Windows Terminal** — fully supported

---

## Next Step

[:octicons-arrow-right-24: Install PowerShell](installation.md)
