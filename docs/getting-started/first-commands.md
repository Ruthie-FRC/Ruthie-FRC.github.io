# Your First Commands

Open your PowerShell terminal (type `pwsh` in any terminal, or launch it from the Start menu on Windows) and follow along.

---

## The Prompt

When PowerShell is ready for input, you'll see a prompt like:

```
PS C:\Users\Alice>
```

`PS` indicates PowerShell, and the path shows your current working directory.

---

## Running Your First Cmdlet

Type a cmdlet name and press ++enter++:

```powershell
Get-Date
```

Output:
```
Sunday, March 15, 2026 5:09:24 PM
```

PowerShell returned a `DateTime` **object**. You can access its properties:

```powershell
(Get-Date).Year    # → 2026
(Get-Date).DayOfWeek  # → Sunday
```

---

## Discovering Commands

### Find cmdlets by verb or noun

```powershell
# All commands that "Get" something
Get-Command -Verb Get

# All commands related to "Service"
Get-Command -Noun Service

# Search by partial name
Get-Command *network*
```

### Read the built-in help

```powershell
# Basic help
Get-Help Get-Process

# Detailed examples
Get-Help Get-Process -Examples

# Full parameter documentation
Get-Help Get-Process -Full
```

!!! tip "Update help files first"
    Run `Update-Help` once (as administrator) to download the latest help content from the internet.

---

## Working with Files and Directories

```powershell
# Where am I?
Get-Location          # or: pwd

# List files in current directory
Get-ChildItem         # or: ls, dir

# List including hidden files
Get-ChildItem -Force

# Change directory
Set-Location C:\Users  # or: cd C:\Users
Set-Location ..        # go up one level
Set-Location ~         # go to home directory

# Create a file
New-Item -Path .\hello.txt -ItemType File -Value "Hello, World!"

# Read it back
Get-Content .\hello.txt

# Delete it
Remove-Item .\hello.txt
```

---

## Variables

Variables start with `$`:

```powershell
$name = "Alice"
$age  = 30
$pi   = 3.14159

Write-Host "Hello, $name! You are $age years old."
```

---

## Getting Help On Any Object: `Get-Member`

One of the most important habits in PowerShell is inspecting objects with `Get-Member`:

```powershell
Get-Process | Get-Member
```

This shows every **property** and **method** available on a process object. Once you know the properties, you can access them:

```powershell
$proc = Get-Process -Name pwsh
$proc.Id              # Process ID
$proc.WorkingSet64    # Memory in bytes
$proc.CPU             # CPU seconds used
```

---

## Tab Completion

Press ++tab++ to auto-complete cmdlet names, parameters, and paths:

- `Get-Ch` ++tab++ → `Get-ChildItem`
- `Get-ChildItem -` ++tab++ → cycles through parameters
- `cd C:\Us` ++tab++ → `cd C:\Users\`

Press ++ctrl+space++ in VS Code for full IntelliSense.

---

## Common Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| ++tab++ | Auto-complete |
| ++ctrl+c++ | Cancel running command |
| ++ctrl+z++ | Undo (in the line editor) |
| ++up++ / ++down++ | Command history |
| ++ctrl+r++ | Reverse-search history |
| ++f7++ | Show history in a list |
| `cls` or `Clear-Host` | Clear the screen |

---

## Aliases

PowerShell has many aliases so existing muscle memory from cmd/bash still works:

| Alias | Full Cmdlet |
|-------|-------------|
| `ls` / `dir` | `Get-ChildItem` |
| `cd` | `Set-Location` |
| `pwd` | `Get-Location` |
| `cat` | `Get-Content` |
| `echo` | `Write-Output` |
| `ps` | `Get-Process` |
| `kill` | `Stop-Process` |
| `rm` / `del` | `Remove-Item` |
| `cp` | `Copy-Item` |
| `mv` | `Move-Item` |
| `curl` / `wget` | `Invoke-WebRequest` (aliases removed in PS 7+) |
| `man` | `Get-Help` |

!!! warning "Aliases in scripts"
    Avoid aliases in scripts and functions. Use the full cmdlet name for readability and portability — especially when sharing with others.

---

## Next Step

[:octicons-arrow-right-24: Understanding the Pipeline](the-pipeline.md)
