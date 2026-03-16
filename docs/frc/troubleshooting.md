# FRC PowerShell Troubleshooting

This page covers common problems FRC teams encounter when using PowerShell on Windows for robot development and competition-day tasks, along with step-by-step fixes.

---

## JAVA_HOME Not Set or Wrong Version

Gradle and WPILib tools need `JAVA_HOME` to point to a JDK 17 installation. If it is missing or points to the wrong version, builds fail with messages like `Could not determine java version` or `unsupported class file major version`.

```powershell
# Check the current value
$env:JAVA_HOME
java -version

# Find WPILib's bundled JDK (adjust the year)
$wpiJdk = "C:\Users\Public\wpilib\2025\jdk"
if (Test-Path $wpiJdk) { Write-Host "Found WPILib JDK at $wpiJdk" -ForegroundColor Green }
else                   { Write-Warning "WPILib JDK not found — run the WPILib installer." }

# Set JAVA_HOME for the current session
$env:JAVA_HOME = $wpiJdk
$env:PATH      = "$env:JAVA_HOME\bin;$env:PATH"
java -version   # should now show 17.x

# Set JAVA_HOME permanently (user-level)
[System.Environment]::SetEnvironmentVariable('JAVA_HOME', $wpiJdk, 'User')
$userPath = [System.Environment]::GetEnvironmentVariable('PATH', 'User')
if ($userPath -notlike "*$wpiJdk\bin*") {
    [System.Environment]::SetEnvironmentVariable('PATH', "$wpiJdk\bin;$userPath", 'User')
}
Write-Host "JAVA_HOME set permanently. Restart your terminal to apply." -ForegroundColor Green
```

---

## Gradle Cache Corruption or Stale Dependencies

Gradle caches downloaded JARs and build outputs under `$HOME\.gradle`. A corrupted cache causes cryptic build failures.

```powershell
# Show how large the Gradle cache is
$cacheRoot = "$HOME\.gradle\caches"
if (Test-Path $cacheRoot) {
    $size = (Get-ChildItem $cacheRoot -Recurse -ErrorAction SilentlyContinue |
             Measure-Object -Property Length -Sum).Sum / 1MB
    Write-Host "Gradle cache size: $([Math]::Round($size, 1)) MB"
}

# Force Gradle to refresh all dependencies without deleting the cache
.\gradlew build --refresh-dependencies

# Delete only the failing module's cached metadata (safer than full wipe)
Remove-Item -Recurse -Force "$HOME\.gradle\caches\modules-*\files-*\edu.wpi.first*" `
    -ErrorAction SilentlyContinue

# Nuclear option: wipe the entire Gradle cache (slow first build after this)
Remove-Item -Recurse -Force "$HOME\.gradle\caches" -ErrorAction SilentlyContinue
Write-Host "Gradle cache cleared. Next build will re-download all dependencies."
```

!!! warning
    Deleting the entire cache can take several minutes to rebuild, especially on a slow competition-venue network. Do this at home or on a fast connection, not at an event.

---

## Toolchain Not Installed or Wrong Version

If `.\gradlew build` fails with `No toolchain found for target` or `arm-frc-linux-gnueabi-g++: not found`, the cross-compiler toolchain needs to be (re)installed.

```powershell
# Reinstall the roboRIO cross-compiler toolchain
.\gradlew installRoboRioToolchain

# If the task itself fails, check the toolchain download location
$toolchainDir = "$HOME\.gradle\toolchains"
Get-ChildItem $toolchainDir -ErrorAction SilentlyContinue | Select-Object Name, LastWriteTime

# Remove stale toolchain files and reinstall
Remove-Item -Recurse -Force $toolchainDir -ErrorAction SilentlyContinue
.\gradlew installRoboRioToolchain
```

---

## mDNS Not Resolving

`roboRIO-####-FRC.local` relies on mDNS. If it fails to resolve while the fixed IP (`10.TE.AM.2`) works, the mDNS service on the Driver Station laptop is broken.

```powershell
# Check the status of Bonjour and NI mDNS services
Get-Service -Name 'Bonjour Service', 'NiMDnsResponder' -ErrorAction SilentlyContinue |
    Select-Object Name, Status, StartType

# Restart the Bonjour service (requires elevation)
Restart-Service -Name 'Bonjour Service' -ErrorAction SilentlyContinue

# Restart the NI mDNS Responder (requires elevation)
Restart-Service -Name 'NiMDnsResponder' -ErrorAction SilentlyContinue

# Flush the DNS cache so stale entries are removed
Clear-DnsClientCache
Write-Host "DNS cache flushed." -ForegroundColor Green

# Test resolution again
Resolve-DnsName roboRIO-####-FRC.local -ErrorAction SilentlyContinue
```

!!! tip
    If neither mDNS service is installed, re-run the **FRC Game Tools** installer from the NI website to restore them.

---

## SSH Known-Hosts Conflict (Host Key Changed)

When you re-image the roboRIO, its SSH host key changes. The next `ssh` attempt fails with `WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!`.

```powershell
# Remove the old host key entries for the roboRIO
ssh-keygen -R roboRIO-####-FRC.local
ssh-keygen -R 10.99.99.2
ssh-keygen -R 172.22.11.2

# Optionally view the known_hosts file
Get-Content "$HOME\.ssh\known_hosts" | Select-String 'roboRIO'
```

After removing the old keys, the next `ssh` connection will prompt you to accept the new host key fingerprint.

---

## gradlew Not Found or Permission Error

On Windows, `.\gradlew` runs `gradlew.bat`. If the file is missing or has the wrong line endings, the task fails.

```powershell
# Confirm gradlew.bat exists
Test-Path .\gradlew.bat

# Check that you are in the correct project directory
Get-ChildItem | Select-Object Name | Where-Object Name -in 'build.gradle','gradlew.bat','settings.gradle'

# If gradlew.bat is missing, regenerate it using the Gradle wrapper task
# (requires Gradle on PATH)
gradle wrapper --gradle-version 8.11
```

---

## Driver Station Cannot Connect

```powershell
# Quick all-in-one connectivity check
$team = 9999    # replace with your team number
$rio  = "roboRIO-$team-FRC.local"
$ip   = "10.$([int]($team/100)).$($team % 100).2"

"mDNS", "IP", "USB" | ForEach-Object {
    $addr = switch ($_) {
        "mDNS" { $rio }
        "IP"   { $ip }
        "USB"  { "172.22.11.2" }
    }
    $ok = Test-Connection $addr -Count 1 -Quiet -TimeoutSeconds 2 -ErrorAction SilentlyContinue
    [PSCustomObject]@{
        Method    = $_
        Address   = $addr
        Reachable = $ok
    }
} | Format-Table -AutoSize

# Check whether the FRC firewall rules are blocking traffic
Get-NetFirewallRule -Direction Inbound -Enabled True |
    Get-NetFirewallPortFilter |
    Where-Object { $_.LocalPort -in @(1110, 1735, 1740) }
```

---

## Resetting the roboRIO Network Settings

If the roboRIO's IP address or hostname appears wrong, you can use SSH to inspect and reset the configuration:

```powershell
# View current IP configuration on the roboRIO
ssh admin@172.22.11.2 "ifconfig"

# View the team number stored on the roboRIO (NI Real-Time config)
ssh admin@172.22.11.2 "cat /etc/natinst/share/ni-rt.ini | grep TeamNumber"
```

For a full network reset, use the **roboRIO Web Dashboard** at `http://172.22.11.2` (USB) or `http://10.TE.AM.2` (Ethernet) — PowerShell cannot modify the NI Real-Time network configuration directly.
