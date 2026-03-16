# FrcTools PowerShell Module

`FrcTools` is a reusable PowerShell 7 module that packages all of the FRC helper functions documented in this section into a single, importable module. You install it once and call the functions by name from any script or terminal.

The source lives at [`scripts/frc/FrcTools.psm1`](https://github.com/Ruthie-FRC/Powershell-Commands/blob/copilot/frc-powershell-section/scripts/frc/FrcTools.psm1) in this repository.

---

## Installing the Module

### Temporary (current session only)

```powershell
# From the repository root
Import-Module .\scripts\frc\FrcTools.psm1
```

### Permanent (available in every session)

```powershell
# Copy module files to your PowerShell module path
$dest = "$HOME\Documents\PowerShell\Modules\FrcTools"
New-Item -ItemType Directory -Path $dest -Force | Out-Null
Copy-Item .\scripts\frc\FrcTools.ps* $dest

# Then import it (or add this line to your $PROFILE)
Import-Module FrcTools
```

### Verify the import

```powershell
Get-Module FrcTools
Get-Command -Module FrcTools
```

---

## Available Functions

| Function | Description |
|----------|-------------|
| [`Test-FrcRobotConnection`](#test-frcrobotconnection) | Ping mDNS, fixed IP, and USB addresses and report which respond |
| [`Connect-RoboRioSsh`](#connect-roboriossh) | Open an interactive SSH session or run a single remote command |
| [`Copy-ToRoboRio`](#copy-toroborio) | SCP a local file to the roboRIO |
| [`Copy-FromRoboRio`](#copy-fromroborio) | SCP a file from the roboRIO to your machine |
| [`Install-RoboRioJreIpk`](#install-roboriojreipk) | Copy an IPK, install it with `opkg`, then clean up |
| [`Get-RoboRioLogs`](#get-roboriologss) | Pull all log files from the roboRIO into a dated local folder |
| [`Invoke-WpilibGradle`](#invoke-wpilibgradle) | Run a Gradle task via `gradlew` with actionable error hints |

---

## Function Reference

### Test-FrcRobotConnection

Tests all three common connection paths to the roboRIO and displays a table showing which ones succeed.

```powershell
Test-FrcRobotConnection -TeamNumber 9999
```

**Sample output:**

```
Method  Address                    Reachable
------  -------                    ---------
mDNS    roboRIO-9999-FRC.local     True
IP      10.99.99.2                 True
USB     172.22.11.2                False
```

---

### Connect-RoboRioSsh

Opens an interactive SSH session, or runs a single command non-interactively.

```powershell
# Interactive shell
Connect-RoboRioSsh -TeamNumber 9999

# Run one command and return
Connect-RoboRioSsh -TeamNumber 9999 -Command "df -h"

# Connect via fixed IP instead of mDNS
Connect-RoboRioSsh -TeamNumber 9999 -Method IP
```

| Parameter | Default | Notes |
|-----------|---------|-------|
| `-TeamNumber` | *(required)* | 1–9999 |
| `-Method` | `mDNS` | `mDNS`, `IP`, or `USB` |
| `-Command` | *(none)* | If omitted, opens an interactive shell |

---

### Copy-ToRoboRio

Copies a local file or directory to the roboRIO using `scp`. Handles paths with spaces correctly.

```powershell
# Copy a file
Copy-ToRoboRio -TeamNumber 9999 -LocalPath .\frcjre.ipk -RemotePath /tmp/frcjre.ipk

# Copy a directory
Copy-ToRoboRio -TeamNumber 9999 -LocalPath .\deploy -RemotePath /home/lvuser/deploy

# Preview what would happen without actually copying (-WhatIf)
Copy-ToRoboRio -TeamNumber 9999 -LocalPath .\file.txt -RemotePath /tmp/file.txt -WhatIf
```

---

### Copy-FromRoboRio

Retrieves a file from the roboRIO to your local machine.

```powershell
# Copy a single log file
Copy-FromRoboRio -TeamNumber 9999 -RemotePath /var/log/ni-rt.log -LocalPath .\ni-rt.log

# Copy to a directory
Copy-FromRoboRio -TeamNumber 9999 -RemotePath /home/lvuser/FRCUserProgram.log -LocalPath .\logs\
```

---

### Install-RoboRioJreIpk

Automates the three-step JRE install process from the allwpilib test-scripts workflow:

1. `scp` the IPK to `/tmp/` on the roboRIO
2. Run `opkg install` over SSH
3. Remove the temporary file to free disk space

```powershell
Install-RoboRioJreIpk -TeamNumber 9999 -IpkPath "C:\Users\me\frcjre.ipk"
```

!!! warning "Disk space"
    The roboRIO has very limited storage. Always clean up after installing packages. This function does so automatically.

---

### Get-RoboRioLogs

Downloads all `.wpilog`, `.dslog`, and `.dsevents` files from `/home/lvuser/` on the roboRIO into a dated sub-folder.

```powershell
# Saves to .\logs\2025-06-01\
Get-RoboRioLogs -TeamNumber 9999

# Custom output directory
Get-RoboRioLogs -TeamNumber 9999 -OutputDirectory "C:\FRC\logs"
```

---

### Invoke-WpilibGradle

Runs `gradlew.bat` (Windows) or `./gradlew` (other platforms) and prints actionable error hints if the task fails.

```powershell
# Common tasks
Invoke-WpilibGradle build
Invoke-WpilibGradle deploy
Invoke-WpilibGradle compileJava
Invoke-WpilibGradle installRoboRioToolchain

# Pass extra Gradle flags
Invoke-WpilibGradle build --parallel --build-cache

# Run from a specific project directory
Invoke-WpilibGradle build -ProjectDir "C:\FRC\MyRobot"
```

If Gradle exits with a non-zero code, the function prints hints like:

```
Gradle task 'build' FAILED (exit code 1).
Common causes:
  - JAVA_HOME not set to JDK 17
  - Toolchain not installed (run: .\gradlew installRoboRioToolchain)
  - Corrupt Gradle cache (run: .\gradlew build --refresh-dependencies)
  - roboRIO unreachable for deploy tasks (run: Test-FrcRobotConnection)
```

---

## Requirements

- **PowerShell 7.0+** — `pwsh` (not Windows PowerShell 5.1)
- **OpenSSH client** — `ssh.exe` and `scp.exe` on `PATH`. Install with:

```powershell
# Check if OpenSSH is already present
Get-Command ssh -ErrorAction SilentlyContinue

# Install if missing (requires elevation)
Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0
```
