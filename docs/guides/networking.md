# Networking

PowerShell provides a comprehensive suite of networking cmdlets for testing connectivity, querying DNS, inspecting connections, and making HTTP requests.

---

## Testing Connectivity

### Ping (ICMP)

```powershell
# Basic ping
Test-Connection google.com

# Quick boolean result
Test-Connection 8.8.8.8 -Quiet

# Ping multiple hosts (PS 6+)
Test-Connection -TargetName 'server1','server2','server3' -Count 1 -Quiet

# Ping with timeout
Test-Connection google.com -TimeoutSeconds 2 -Count 1
```

### TCP port testing

```powershell
# Test if a TCP port is open
Test-NetConnection example.com -Port 443

# Quick boolean
(Test-NetConnection github.com -Port 22).TcpTestSucceeded

# Test multiple ports
80, 443, 8080 | ForEach-Object {
    $result = Test-NetConnection example.com -Port $_
    [PSCustomObject]@{
        Port    = $_
        Open    = $result.TcpTestSucceeded
    }
} | Format-Table
```

---

## DNS Resolution

```powershell
# Resolve a hostname to IP
Resolve-DnsName google.com

# Get A records (IPv4)
Resolve-DnsName github.com -Type A

# Get MX records
Resolve-DnsName gmail.com -Type MX

# Get TXT records (SPF, DKIM, etc.)
Resolve-DnsName example.com -Type TXT

# Use a specific DNS server
Resolve-DnsName example.com -Server 8.8.8.8

# Reverse lookup (IP to hostname)
Resolve-DnsName 8.8.8.8
```

---

## Network Interface Information

```powershell
# All adapters with IP config
Get-NetIPConfiguration

# Detailed info
Get-NetIPConfiguration -Detailed

# All IP addresses (IPv4 and IPv6)
Get-NetIPAddress

# Only IPv4 addresses
Get-NetIPAddress -AddressFamily IPv4

# Physical adapters
Get-NetAdapter | Where-Object Status -eq Up

# Show MAC addresses
Get-NetAdapter | Select-Object Name, MacAddress, LinkSpeed, Status
```

---

## Active TCP Connections (like netstat)

```powershell
# Show all TCP connections
Get-NetTCPConnection

# Listening ports only
Get-NetTCPConnection -State Listen

# Established connections
Get-NetTCPConnection -State Established

# Find what's using a specific port
Get-NetTCPConnection -LocalPort 80

# Map ports to process names
Get-NetTCPConnection -State Listen |
    Select-Object LocalPort,
        @{Name='Process'; Expression={ (Get-Process -Id $_.OwningProcess).Name }} |
    Sort-Object LocalPort |
    Format-Table -AutoSize
```

---

## Trace Route

```powershell
# Trace the route to a host
Test-NetConnection google.com -TraceRoute

# More detailed output
$trace = Test-NetConnection google.com -TraceRoute -InformationLevel Detailed
$trace.TraceRoute   # array of hop IPs
```

---

## HTTP Requests

### GET request

```powershell
# Fetch a URL
Invoke-WebRequest -Uri https://example.com

# Get just the status code
(Invoke-WebRequest -Uri https://example.com).StatusCode

# Download a file
Invoke-WebRequest -Uri https://example.com/file.zip -OutFile .\file.zip

# Show progress while downloading
$ProgressPreference = 'SilentlyContinue'  # disable slow progress bar
Invoke-WebRequest -Uri https://big-file.example.com -OutFile .\big.zip
```

### REST API calls

```powershell
# GET and auto-parse JSON
$user = Invoke-RestMethod https://api.github.com/users/octocat
$user.name
$user.public_repos

# POST with JSON body
$body = @{ name = "test-repo"; private = $true } | ConvertTo-Json
Invoke-RestMethod -Uri https://api.github.com/user/repos `
    -Method Post `
    -Headers @{ Authorization = "token $env:GITHUB_TOKEN" } `
    -Body $body `
    -ContentType "application/json"

# PUT / PATCH / DELETE
Invoke-RestMethod -Uri https://api.example.com/items/42 -Method Delete
```

---

## Network Shares

```powershell
# Map a network drive
New-PSDrive -Name Z -PSProvider FileSystem -Root \\server\share
New-PSDrive -Name Z -PSProvider FileSystem -Root \\server\share -Credential (Get-Credential) -Persist

# List connected shares
Get-PSDrive -PSProvider FileSystem | Where-Object DisplayRoot -like "\\*"

# Remove a mapped drive
Remove-PSDrive -Name Z
```

---

## Firewall Rules

```powershell
# List all firewall rules
Get-NetFirewallRule

# List enabled inbound rules
Get-NetFirewallRule -Direction Inbound -Enabled True

# Find rules by display name
Get-NetFirewallRule -DisplayName "*Remote*"

# Create a rule to allow port 8080 inbound
New-NetFirewallRule -DisplayName "Allow 8080" `
    -Direction Inbound -Protocol TCP `
    -LocalPort 8080 -Action Allow

# Disable a rule
Disable-NetFirewallRule -DisplayName "Allow 8080"

# Remove a rule
Remove-NetFirewallRule -DisplayName "Allow 8080"
```

---

## Practical Recipes

### Network connectivity report

```powershell
$hosts = @(
    [PSCustomObject]@{ Name="Google DNS";    Address="8.8.8.8" },
    [PSCustomObject]@{ Name="GitHub";        Address="github.com" },
    [PSCustomObject]@{ Name="Azure";         Address="azure.microsoft.com" }
)

$hosts | ForEach-Object {
    $online = Test-Connection $_.Address -Count 1 -Quiet
    [PSCustomObject]@{
        Name    = $_.Name
        Address = $_.Address
        Online  = $online
        Status  = if ($online) { "✓ Online" } else { "✗ Offline" }
    }
} | Format-Table -AutoSize
```

### Port scan a host

```powershell
function Test-Ports {
    param(
        [string]   $Target,
        [int[]]    $Ports = @(22,80,443,3389,8080)
    )
    $Ports | ForEach-Object {
        $result = Test-NetConnection $Target -Port $_ -WarningAction SilentlyContinue
        [PSCustomObject]@{
            Port = $_
            Open = $result.TcpTestSucceeded
        }
    }
}

Test-Ports -Target "server01" -Ports 22,80,443,3389 | Format-Table
```

