# FRC Robot Networking

This page covers PowerShell commands for verifying network connectivity to the robot, resolving mDNS hostnames, and diagnosing common FRC network issues.

---

## IP Addressing Conventions

FRC uses a specific IP addressing scheme at competition:

| Device | Address |
|--------|---------|
| roboRIO | `10.TE.AM.2` |
| Driver Station (radio gateway) | `10.TE.AM.4` |
| Robot radio | `10.TE.AM.1` |
| roboRIO (USB) | `172.22.11.2` |
| roboRIO (mDNS) | `roboRIO-####-FRC.local` |

Replace `TE.AM` with the two parts of your team number — e.g., team 9999 uses `10.99.99.2`.

---

## Pinging the Robot

```powershell
# Basic ping using mDNS (requires mDNS service running on the Driver Station laptop)
Test-Connection roboRIO-####-FRC.local -Count 4

# Quick pass/fail boolean
Test-Connection roboRIO-####-FRC.local -Count 1 -Quiet

# Ping the fixed IP instead
Test-Connection 10.99.99.2 -Count 4

# Ping via USB
Test-Connection 172.22.11.2 -Count 1 -Quiet

# Ping with a short timeout (useful in scripts)
Test-Connection roboRIO-####-FRC.local -Count 1 -TimeoutSeconds 2 -Quiet
```

### Continuous ping (like ping -t)

```powershell
# Ping every second until you press Ctrl+C
while ($true) {
    $result = Test-Connection roboRIO-####-FRC.local -Count 1 -Quiet -ErrorAction SilentlyContinue
    $status = if ($result) { "Online" } else { "OFFLINE" }
    $color  = if ($result) { "Green"  } else { "Red" }
    Write-Host "$(Get-Date -Format HH:mm:ss)  roboRIO: $status" -ForegroundColor $color
    Start-Sleep -Seconds 1
}
```

---

## mDNS Resolution

FRC relies on mDNS to resolve `roboRIO-####-FRC.local`. If mDNS is not working, robot discovery fails.

```powershell
# Resolve the roboRIO mDNS name
Resolve-DnsName roboRIO-####-FRC.local

# Check whether resolution succeeds (returns $true/$false)
try   { Resolve-DnsName roboRIO-####-FRC.local -ErrorAction Stop | Out-Null; $true  }
catch { $false }

# Check the Driver Station laptop's mDNS service (Bonjour / NI mDNS Responder)
Get-Service -Name 'Bonjour Service', 'NiMDnsResponder' -ErrorAction SilentlyContinue |
    Select-Object Name, Status, StartType
```

!!! tip "mDNS not resolving?"
    If `Resolve-DnsName` fails but `Test-Connection 10.TE.AM.2` works, mDNS is broken. See [Troubleshooting](troubleshooting.md#mdns-not-resolving) for fixes.

---

## Network Interface Diagnostics

```powershell
# Show all IPv4 addresses on this machine
Get-NetIPAddress -AddressFamily IPv4 |
    Select-Object InterfaceAlias, IPAddress, PrefixLength |
    Format-Table -AutoSize

# Find the adapter connected to the robot radio subnet (10.TE.AM.x)
Get-NetIPAddress -AddressFamily IPv4 |
    Where-Object { $_.IPAddress -like '10.*' } |
    Select-Object InterfaceAlias, IPAddress

# Show adapter status
Get-NetAdapter | Select-Object Name, Status, LinkSpeed, MacAddress | Format-Table -AutoSize
```

---

## Checking Active Connections to the roboRIO

```powershell
# Show TCP connections to roboRIO IP (replace with your IP)
Get-NetTCPConnection | Where-Object { $_.RemoteAddress -eq '10.99.99.2' } |
    Select-Object LocalPort, RemotePort, State |
    Format-Table -AutoSize

# Check if the Driver Station port (1110) is listening
Get-NetTCPConnection -LocalPort 1110 -ErrorAction SilentlyContinue
```

---

## Firewall Rules for FRC

The FRC Driver Station requires several ports to be open. Use these commands to inspect and, if necessary, add firewall rules.

!!! warning "Elevation required"
    Creating and modifying firewall rules requires an elevated (Administrator) PowerShell session.

```powershell
# List all FRC-related firewall rules
Get-NetFirewallRule | Where-Object { $_.DisplayName -match 'FRC|Driver.?Station|roboRIO' }

# Check if a specific port is allowed inbound
Get-NetFirewallRule -Direction Inbound -Enabled True |
    Get-NetFirewallPortFilter |
    Where-Object { $_.LocalPort -eq 1110 }

# Allow the FRC Driver Station communication ports (UDP 1110-1150, TCP 1735)
# Run in an elevated session
New-NetFirewallRule -DisplayName "FRC Driver Station UDP" `
    -Direction Inbound -Protocol UDP `
    -LocalPort 1110-1150 -Action Allow

New-NetFirewallRule -DisplayName "FRC NetworkTables TCP" `
    -Direction Inbound -Protocol TCP `
    -LocalPort 1735 -Action Allow

# Remove the rules if they cause problems
Remove-NetFirewallRule -DisplayName "FRC Driver Station UDP"
Remove-NetFirewallRule -DisplayName "FRC NetworkTables TCP"
```

---

## Robot Connection Health Check Script

Use the `FrcTools` module for a single-call connection check:

```powershell
Import-Module .\scripts\frc\FrcTools.psm1

# Test all common connection methods for team 9999
Test-FrcRobotConnection -TeamNumber 9999
```

Sample output:

```
Method          Address                      Reachable
------          -------                      ---------
mDNS            roboRIO-9999-FRC.local       True
Fixed IP        10.99.99.2                   True
USB             172.22.11.2                  False
```

---

## Competition-Day Network Pre-Check

Run this script before each match to confirm connectivity:

```powershell
param([int]$TeamNumber = 9999)

$rio  = "roboRIO-$TeamNumber-FRC.local"
$ip   = "10.$([int]($TeamNumber / 100)).$($TeamNumber % 100).2"

Write-Host "`nFRC Pre-Match Network Check — Team $TeamNumber" -ForegroundColor Cyan
Write-Host ("=" * 50)

foreach ($target in @($rio, $ip, '172.22.11.2')) {
    $ok = Test-Connection $target -Count 1 -Quiet -TimeoutSeconds 2 -ErrorAction SilentlyContinue
    $flag = if ($ok) { "[OK]  " } else { "[FAIL]" }
    $color = if ($ok) { "Green" } else { "Red" }
    Write-Host "$flag  $target" -ForegroundColor $color
}

# Check mDNS resolution
try {
    Resolve-DnsName $rio -ErrorAction Stop | Out-Null
    Write-Host "[OK]   mDNS resolution" -ForegroundColor Green
} catch {
    Write-Host "[FAIL] mDNS resolution — try pinging by IP instead" -ForegroundColor Red
}
```
