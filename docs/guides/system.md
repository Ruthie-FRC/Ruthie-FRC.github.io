# System Information

PowerShell provides dozens of cmdlets for inspecting hardware, the operating system, event logs, and Windows services.

---

## System Overview

```powershell
# Rich single-object system summary (PS 5.1+)
Get-ComputerInfo

# Selected properties
Get-ComputerInfo -Property OsName, OsVersion, CsProcessors, CsTotalPhysicalMemory

# Classic WMI approach (works everywhere)
Get-CimInstance Win32_OperatingSystem | Select-Object Caption, Version, BuildNumber, LastBootUpTime
```

---

## Hardware Information

```powershell
# CPU
Get-CimInstance Win32_Processor | Select-Object Name, NumberOfCores, NumberOfLogicalProcessors, MaxClockSpeed

# RAM
$ram = Get-CimInstance Win32_PhysicalMemory
$ram | Select-Object BankLabel, Capacity, Speed
"Total RAM: {0} GB" -f ([math]::Round(($ram.Capacity | Measure-Object -Sum).Sum / 1GB, 1))

# Disk drives
Get-CimInstance Win32_DiskDrive | Select-Object Model, Size, MediaType

# Logical disks (C:, D:, etc.)
Get-CimInstance Win32_LogicalDisk | Select-Object DeviceID,
    @{Name='SizeGB'; Expression={ [math]::Round($_.Size/1GB,1) }},
    @{Name='FreeGB'; Expression={ [math]::Round($_.FreeSpace/1GB,1) }},
    @{Name='Free%';  Expression={ [math]::Round($_.FreeSpace/$_.Size*100,1) }}

# BIOS
Get-CimInstance Win32_BIOS | Select-Object Name, Version, Manufacturer, ReleaseDate

# Network adapters
Get-CimInstance Win32_NetworkAdapter | Where-Object PhysicalAdapter | Select-Object Name, MACAddress
```

---

## Drives and Storage

```powershell
# All PowerShell drives
Get-PSDrive

# Filesystem drives with free space
Get-PSDrive -PSProvider FileSystem | Select-Object Name,
    @{Name='Used GB'; Expression={ [math]::Round($_.Used/1GB,2) }},
    @{Name='Free GB'; Expression={ [math]::Round($_.Free/1GB,2) }}

# Volume details
Get-Volume | Format-Table DriveLetter, FileSystemLabel, FileSystem, SizeRemaining, Size -AutoSize
```

---

## Uptime and Boot Time

```powershell
$os = Get-CimInstance Win32_OperatingSystem
$uptime = (Get-Date) - $os.LastBootUpTime

"Last boot: $($os.LastBootUpTime)"
"Uptime: {0} days, {1} hours, {2} minutes" -f $uptime.Days, $uptime.Hours, $uptime.Minutes
```

---

## Windows Services

```powershell
# List all services
Get-Service

# Filter by status
Get-Service | Where-Object Status -eq Running
Get-Service | Where-Object Status -eq Stopped

# Find a specific service
Get-Service -Name wuauserv
Get-Service -DisplayName "*Windows Update*"

# Service details
Get-Service -Name Spooler | Select-Object *

# Start / Stop / Restart
Start-Service   -Name Spooler
Stop-Service    -Name Spooler
Restart-Service -Name Spooler

# Change startup type
Set-Service -Name wuauserv -StartupType Disabled
Set-Service -Name wuauserv -StartupType Automatic

# Show dependent services
Get-Service -Name LanmanWorkstation -DependentServices
Get-Service -Name LanmanWorkstation -RequiredServices
```

---

## Event Logs

```powershell
# List available event logs
Get-WinEvent -ListLog * | Select-Object LogName, RecordCount, IsEnabled | Sort-Object RecordCount -Descending

# Get the last 20 System events
Get-WinEvent -LogName System -MaxEvents 20

# Get errors from Application log
Get-WinEvent -FilterHashtable @{
    LogName   = 'Application'
    Level     = 2   # 1=Critical, 2=Error, 3=Warning, 4=Info
} -MaxEvents 50

# Specific event ID (e.g., 4624 = logon)
Get-WinEvent -FilterHashtable @{
    LogName = 'Security'
    Id      = 4624
} -MaxEvents 20

# Events in a time range
Get-WinEvent -FilterHashtable @{
    LogName   = 'System'
    StartTime = (Get-Date).AddHours(-1)
} | Format-Table TimeCreated, Id, LevelDisplayName, Message -AutoSize

# Search event message text
Get-WinEvent -LogName System |
    Where-Object { $_.Message -like "*error*" } |
    Select-Object -First 10 TimeCreated, Id, Message
```

---

## Environment Information

```powershell
# PowerShell version
$PSVersionTable

# All environment variables
Get-ChildItem Env: | Sort-Object Name

# Specific variables
$env:USERNAME
$env:COMPUTERNAME
$env:OS
$env:PROCESSOR_ARCHITECTURE
$env:NUMBER_OF_PROCESSORS

# .NET runtime
[System.Runtime.InteropServices.RuntimeInformation]::OSDescription
[System.Environment]::Version
```

---

## Installed Software

```powershell
# Via registry (fast)
Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |
    Select-Object DisplayName, DisplayVersion, Publisher, InstallDate |
    Where-Object DisplayName |
    Sort-Object DisplayName |
    Format-Table -AutoSize

# 64-bit programs on 32-bit registry view
Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* |
    Select-Object DisplayName, DisplayVersion |
    Where-Object DisplayName |
    Sort-Object DisplayName
```

---

## Practical Recipes

### System health dashboard

```powershell
$os  = Get-CimInstance Win32_OperatingSystem
$cpu = Get-CimInstance Win32_Processor
$disks = Get-Volume | Where-Object DriveLetter

$uptime = (Get-Date) - $os.LastBootUpTime

Write-Host "═══ System Health ════════════════════════" -ForegroundColor Cyan
Write-Host "Host    : $env:COMPUTERNAME" 
Write-Host "OS      : $($os.Caption) $($os.BuildNumber)"
Write-Host "Uptime  : $($uptime.Days)d $($uptime.Hours)h $($uptime.Minutes)m"
Write-Host "CPU     : $($cpu.Name)"
Write-Host "RAM     : {0:N1} GB free / {1:N1} GB total" -f ($os.FreePhysicalMemory/1MB), ($os.TotalVisibleMemorySize/1MB)
Write-Host "─── Disks ────────────────────────────────" -ForegroundColor DarkGray
$disks | ForEach-Object {
    $pct = [math]::Round($_.SizeRemaining/$_.Size*100)
    Write-Host ("  {0}:  {1:N1} GB free / {2:N1} GB ({3}%)" -f `
        $_.DriveLetter, ($_.SizeRemaining/1GB), ($_.Size/1GB), $pct)
}
```

