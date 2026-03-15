# Providers & Drives

PowerShell **providers** expose data stores (file system, registry, certificates, environment variables, and more) through a unified navigation interface — the same `Get-ChildItem`, `Get-Item`, `Set-Item` commands work across all of them.

---

## What is a Provider?

A provider is a .NET plugin that maps a data store to a PowerShell **drive** using a familiar path syntax. This means you can:

```powershell
# Browse the file system
Get-ChildItem C:\Windows\System32

# Browse the registry
Get-ChildItem HKLM:\Software\Microsoft

# Browse environment variables
Get-ChildItem env:

# Browse installed certificates
Get-ChildItem Cert:\LocalMachine\My

# Browse PowerShell functions
Get-ChildItem Function:
```

---

## Built-In Providers

| Provider | Drive(s) | Data |
|----------|---------|------|
| `FileSystem` | `C:\`, `D:\`, etc. / `/` | Files and directories |
| `Registry` | `HKLM:\`, `HKCU:\` | Windows registry |
| `Environment` | `Env:` | Environment variables |
| `Certificate` | `Cert:` | X.509 certificate store |
| `Variable` | `Variable:` | PowerShell session variables |
| `Function` | `Function:` | Loaded functions |
| `Alias` | `Alias:` | Defined aliases |
| `WSMan` | `WSMan:` | WS-Management config |

---

## Working with Drives

```powershell
# List all drives
Get-PSDrive

# Navigate to a drive
Set-Location HKCU:\Software

# Create a custom mapped drive
New-PSDrive -Name Work -PSProvider FileSystem -Root \\server\share
Set-Location Work:

# Remove a drive
Remove-PSDrive -Name Work
```

---

## The Registry Provider

The Registry provider lets you read and write the Windows registry using the same cmdlets as files:

```powershell
# Navigate the registry
Set-Location HKLM:\Software\Microsoft\Windows NT\CurrentVersion
Get-ChildItem   # list sub-keys

# Read a value
Get-ItemProperty . -Name ProductName
(Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").ProductName

# Create a key
New-Item HKCU:\Software\MyApp

# Write a value
Set-ItemProperty HKCU:\Software\MyApp -Name Theme -Value Dark

# Read it back
Get-ItemProperty HKCU:\Software\MyApp -Name Theme

# Delete a value
Remove-ItemProperty HKCU:\Software\MyApp -Name Theme

# Delete a key (and all contents)
Remove-Item HKCU:\Software\MyApp -Recurse
```

!!! warning "Registry modifications require caution"
    Incorrect registry changes can destabilize Windows. Always use `-WhatIf` before destructive operations and consider backing up the key first.

---

## The Certificate Provider

```powershell
# Navigate certificate stores
Set-Location Cert:
Get-ChildItem   # LocalMachine, CurrentUser

# List personal certificates
Get-ChildItem Cert:\CurrentUser\My

# Find certificates expiring in 30 days
Get-ChildItem Cert:\LocalMachine\My |
    Where-Object { $_.NotAfter -lt (Get-Date).AddDays(30) } |
    Select-Object Subject, NotAfter, Thumbprint

# Get a certificate by thumbprint
Get-ChildItem Cert:\LocalMachine\My\<THUMBPRINT>
```

---

## The Environment Provider

```powershell
# List all environment variables
Get-ChildItem Env:

# Read a variable
$env:PATH
Get-Item Env:\COMPUTERNAME

# Set a variable (current session)
$env:MY_VAR = "hello"
New-Item -Path Env:\MY_VAR -Value "hello"

# Delete a variable
Remove-Item Env:\MY_VAR
```

---

## Custom Drives with New-PSDrive

Create temporary drives that are useful as shortcuts:

```powershell
# Map a UNC path
New-PSDrive -Name Share -PSProvider FileSystem -Root \\fileserver\shared

# Map a deep registry path as a short drive
New-PSDrive -Name App -PSProvider Registry -Root HKCU:\Software\MyApp

# Map with credentials
New-PSDrive -Name Remote -PSProvider FileSystem -Root \\server\c$ -Credential (Get-Credential)

# Make it persistent (survives session — stored in profile)
New-PSDrive -Name Docs -PSProvider FileSystem -Root C:\Documents -Persist
```

---

## Provider-Specific Parameters

Some cmdlets expose extra parameters depending on the active provider. For example, `Get-ChildItem` gains `-File`, `-Directory`, `-Hidden`, and `-ReadOnly` on the FileSystem provider.

Use `Get-Help Get-ChildItem -Full` or check parameter sets:

```powershell
(Get-Command Get-ChildItem).ParameterSets | Select-Object Name
```
