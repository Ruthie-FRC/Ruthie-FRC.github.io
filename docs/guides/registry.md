# The Windows Registry

The Registry provider lets you navigate, read, and write the Windows registry using the same cmdlets you use for files.

---

## Registry Hives

| Drive | Full Name | Common Uses |
|-------|-----------|------------|
| `HKLM:` | `HKEY_LOCAL_MACHINE` | Machine-wide settings, installed software |
| `HKCU:` | `HKEY_CURRENT_USER` | Per-user settings |
| `HKCR:` | `HKEY_CLASSES_ROOT` | File associations, COM objects |
| `HKU:` | `HKEY_USERS` | All user profiles |
| `HKCC:` | `HKEY_CURRENT_CONFIG` | Current hardware profile |

---

## Navigating the Registry

```powershell
# Navigate to a hive
Set-Location HKLM:\Software

# List sub-keys
Get-ChildItem HKLM:\Software\Microsoft

# Navigate deeply
Set-Location "HKLM:\Software\Microsoft\Windows NT\CurrentVersion"
Get-ChildItem

# List all values in a key (the "properties")
Get-ItemProperty "HKLM:\Software\Microsoft\Windows NT\CurrentVersion"
```

---

## Reading Registry Values

```powershell
# Read a single named value
Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion" `
                 -Name ProductName

# Just the value (no wrapper object)
(Get-ItemProperty "HKLM:\Software\Microsoft\Windows NT\CurrentVersion").ProductName
(Get-ItemPropertyValue "HKLM:\Software\Microsoft\Windows NT\CurrentVersion" -Name "ProductName")

# Read all values in a key
Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"

# Check if a key exists
Test-Path "HKCU:\Software\MyApp"

# Check if a value exists
$key = Get-Item "HKCU:\Software\MyApp" -ErrorAction SilentlyContinue
if ($key -and $key.GetValue("Theme")) { "Value exists" }
```

---

## Creating Keys and Values

```powershell
# Create a new registry key
New-Item -Path "HKCU:\Software\MyApp" -Force

# Create a value in that key
Set-ItemProperty -Path "HKCU:\Software\MyApp" -Name "Theme"   -Value "Dark"
Set-ItemProperty -Path "HKCU:\Software\MyApp" -Name "Version" -Value "1.0.0"

# Specify the value type explicitly
Set-ItemProperty -Path "HKCU:\Software\MyApp" -Name "MaxItems"   -Value 100   -Type DWord
Set-ItemProperty -Path "HKCU:\Software\MyApp" -Name "InstallDir" -Value "C:\MyApp" -Type ExpandString
Set-ItemProperty -Path "HKCU:\Software\MyApp" -Name "Flags"      -Value ([byte[]](0x01,0x02)) -Type Binary

# Create a key and value in one step
New-ItemProperty -Path "HKCU:\Software\MyApp" -Name "EnableFeature" -Value 1 -PropertyType DWord
```

### Registry value types

| Type Name | PowerShell `-Type` | Description |
|-----------|-------------------|-------------|
| String | `String` | Plain text |
| Expandable String | `ExpandString` | Text with `%VARIABLE%` expansion |
| Multi-String | `MultiString` | Array of strings |
| DWORD (32-bit) | `DWord` | 32-bit integer |
| QWORD (64-bit) | `QWord` | 64-bit integer |
| Binary | `Binary` | Raw bytes |

---

## Modifying and Deleting

```powershell
# Update an existing value
Set-ItemProperty "HKCU:\Software\MyApp" -Name Theme -Value "Light"

# Rename a value
Rename-ItemProperty "HKCU:\Software\MyApp" -Name OldName -NewName NewName

# Delete a single value
Remove-ItemProperty "HKCU:\Software\MyApp" -Name Theme

# Delete an entire key (and all its sub-keys and values)
Remove-Item "HKCU:\Software\MyApp" -Recurse
```

---

## Searching the Registry

```powershell
# Find keys containing a name
Get-ChildItem -Path HKLM:\Software -Recurse -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -like "*MyApp*" }

# Find values by name
Get-ChildItem -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall" |
    Get-ItemProperty |
    Where-Object DisplayName -like "*Visual Studio*" |
    Select-Object DisplayName, DisplayVersion, InstallDate
```

---

## Startup Programs (Run Keys)

```powershell
# List startup programs (current user)
Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"

# List startup programs (all users)
Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run"

# Add a startup entry
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" `
    -Name "MyApp" -Value "C:\MyApp\app.exe"

# Remove a startup entry
Remove-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "MyApp"
```

---

## Practical Recipes

### Read Windows product info

```powershell
$key = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
[PSCustomObject]@{
    Product      = (Get-ItemPropertyValue $key -Name ProductName)
    Version      = (Get-ItemPropertyValue $key -Name CurrentVersion)
    Build        = (Get-ItemPropertyValue $key -Name CurrentBuild)
    Edition      = (Get-ItemPropertyValue $key -Name EditionID)
    RegisteredTo = (Get-ItemPropertyValue $key -Name RegisteredOwner)
}
```

### List installed software from registry

```powershell
$paths = @(
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

$paths | ForEach-Object { Get-ItemProperty $_ -ErrorAction SilentlyContinue } |
    Where-Object DisplayName |
    Select-Object DisplayName, DisplayVersion, Publisher |
    Sort-Object DisplayName |
    Format-Table -AutoSize
```

### Backup a registry key

```powershell
# Export to .reg file (using reg.exe)
reg export "HKCU\Software\MyApp" "C:\Backup\MyApp.reg" /y

# Import it back
reg import "C:\Backup\MyApp.reg"
```
