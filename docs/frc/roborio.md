# roboRIO Utilities

This page covers PowerShell helpers for connecting to the roboRIO over SSH, transferring files with SCP, collecting logs, and cleaning up deployment artifacts.

The roboRIO runs a Linux-based NI Real-Time OS. Its default SSH credentials are **`admin`** with no password.

---

## Connecting via SSH

```powershell
# Connect using mDNS hostname (replace #### with your team number)
ssh admin@roboRIO-####-FRC.local

# Connect using the fixed IP (10.TE.AM.2 format)
# e.g., team 9999 → 10.99.99.2
ssh admin@10.99.99.2

# Connect over USB (roboRIO USB always uses this fixed address)
ssh admin@172.22.11.2
```

!!! tip "First-time connection"
    On first connect, SSH asks you to accept the host key fingerprint. Type `yes` and press Enter. If you later re-image the roboRIO, remove the old entry to avoid connection errors:
    ```powershell
    ssh-keygen -R roboRIO-####-FRC.local
    ssh-keygen -R 10.99.99.2
    ```

### Helper function

```powershell
Import-Module .\scripts\frc\FrcTools.psm1

# Interactive SSH session
Connect-RoboRioSsh -TeamNumber 9999

# Run a single remote command non-interactively
Connect-RoboRioSsh -TeamNumber 9999 -Command "cat /etc/natinst/share/ni-rt.ini"
```

---

## Transferring Files with SCP

```powershell
# Copy a file TO the roboRIO
scp .\frcjre.ipk admin@roboRIO-####-FRC.local:/tmp/frcjre.ipk

# Copy a file FROM the roboRIO
scp admin@roboRIO-####-FRC.local:/var/log/ni-rt.log .\ni-rt.log

# Copy an entire directory to the roboRIO
scp -r .\deploy\ admin@roboRIO-####-FRC.local:/home/lvuser/deploy/
```

### Helper functions

```powershell
Import-Module .\scripts\frc\FrcTools.psm1

# Copy local file(s) to the roboRIO
Copy-ToRoboRio -TeamNumber 9999 -LocalPath .\frcjre.ipk -RemotePath /tmp/frcjre.ipk

# Retrieve a file from the roboRIO
Copy-FromRoboRio -TeamNumber 9999 -RemotePath /var/log/ni-rt.log -LocalPath .\ni-rt.log
```

---

## Installing the FRC JRE on the roboRIO

The allwpilib test infrastructure copies a JRE IPK to `/tmp` and installs it with `opkg`. You can replicate that workflow from PowerShell:

```powershell
Import-Module .\scripts\frc\FrcTools.psm1

# SCP the IPK, install it, then clean up — all in one call
Install-RoboRioJreIpk -TeamNumber 9999 -IpkPath "C:\Users\me\frcjre.ipk"
```

Under the hood this runs:

```powershell
# 1. Copy the IPK
scp "C:\Users\me\frcjre.ipk" admin@roboRIO-9999-FRC.local:/tmp/frcjre.ipk

# 2. Install via opkg
ssh admin@roboRIO-9999-FRC.local "opkg install /tmp/frcjre.ipk"

# 3. Remove the temporary file
ssh admin@roboRIO-9999-FRC.local "rm /tmp/frcjre.ipk"
```

!!! warning "Disk space"
    The roboRIO has very limited storage. Always remove installer packages after installation to avoid running out of space.

---

## Collecting Logs

Robot logs (`.wpilog` / `.dslog` / `.dsevents`) are stored on the roboRIO at `/home/lvuser/` and also on the Driver Station laptop. Use SCP to pull them to your dev machine.

```powershell
# Create a local folder with today's date
$today   = (Get-Date -Format 'yyyy-MM-dd')
$logDir  = ".\logs\$today"
New-Item -ItemType Directory -Path $logDir -Force | Out-Null

# Pull all logs from the roboRIO
scp "admin@roboRIO-####-FRC.local:/home/lvuser/*.wpilog" $logDir
scp "admin@roboRIO-####-FRC.local:/home/lvuser/*.dslog"  $logDir

# List what was collected
Get-ChildItem $logDir | Select-Object Name, Length, LastWriteTime
```

### Batch log collection helper

```powershell
Import-Module .\scripts\frc\FrcTools.psm1

# Collect all logs and save to .\logs\<date>\
Get-RoboRioLogs -TeamNumber 9999 -OutputDirectory .\logs
```

---

## Deployment Cleanup

After iterating on code, stale deploy artifacts can accumulate on the roboRIO. Clean them up to free space:

```powershell
# List what is in the deploy directory
ssh admin@roboRIO-####-FRC.local "ls -lh /home/lvuser/deploy/"

# Remove old deploy artifacts (keep the robot program itself)
ssh admin@roboRIO-####-FRC.local "rm -f /home/lvuser/deploy/*.jar"

# Full cleanup of the deploy folder (use with caution)
ssh admin@roboRIO-####-FRC.local "rm -rf /home/lvuser/deploy/*"
```

!!! warning "Be careful with `rm -rf`"
    Deleting the wrong files can prevent the robot from running. Always confirm what is in the directory before removing anything. Use the `ls` command first.

---

## Checking the roboRIO System

```powershell
# Check available disk space
ssh admin@roboRIO-####-FRC.local "df -h"

# Check memory usage
ssh admin@roboRIO-####-FRC.local "free -m"

# Show running processes
ssh admin@roboRIO-####-FRC.local "ps aux"

# View recent system log entries
ssh admin@roboRIO-####-FRC.local "dmesg | tail -30"

# Read the NI RT configuration file
ssh admin@roboRIO-####-FRC.local "cat /etc/natinst/share/ni-rt.ini"
```

---

## Rebooting the roboRIO

```powershell
# Graceful reboot
ssh admin@roboRIO-####-FRC.local "reboot"

# Verify it comes back online (waits up to 60 seconds)
$robot = "roboRIO-####-FRC.local"
Write-Host "Waiting for roboRIO to restart..."
$deadline = (Get-Date).AddSeconds(60)
do {
    Start-Sleep -Seconds 3
    $online = Test-Connection $robot -Count 1 -Quiet -ErrorAction SilentlyContinue
} until ($online -or (Get-Date) -gt $deadline)

if ($online) { Write-Host "roboRIO is back online." -ForegroundColor Green }
else         { Write-Warning "roboRIO did not respond within 60 seconds." }
```
