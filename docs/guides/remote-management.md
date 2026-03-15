# Remote Management

PowerShell Remoting lets you run commands on one or more remote computers over WinRM (Windows Remote Management) — or SSH on non-Windows systems.

---

## Enabling Remoting

### On Windows (WinRM)

```powershell
# On the target machine (requires elevation)
Enable-PSRemoting -Force

# Verify WinRM is running
Get-Service WinRM

# Test from the client
Test-WSMan -ComputerName server01
```

### On Linux/macOS (SSH remoting, PS 7+)

No special server setup is needed — use standard OpenSSH. Enable SSH on the target, then:

```powershell
Enter-PSSession -HostName ubuntu01 -UserName alice -SSHTransport
```

---

## Running Commands Remotely: Invoke-Command

`Invoke-Command` is the primary tool for one-shot remote execution:

```powershell
# Run on one computer
Invoke-Command -ComputerName server01 -ScriptBlock { Get-Process }

# Run on multiple computers simultaneously
Invoke-Command -ComputerName server01, server02, server03 -ScriptBlock {
    [PSCustomObject]@{
        Computer = $env:COMPUTERNAME
        Uptime   = (Get-Date) - (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
    }
}

# Pass variables into the remote script block
$svcName = "Spooler"
Invoke-Command -ComputerName server01 -ScriptBlock {
    param ($name)
    Get-Service -Name $name
} -ArgumentList $svcName

# Use $using: to reference local variables (PS 3+)
$svcName = "Spooler"
Invoke-Command -ComputerName server01 -ScriptBlock {
    Get-Service -Name $using:svcName
}

# Run as a background job
$job = Invoke-Command -ComputerName server01 -ScriptBlock { Start-Sleep 10; "Done" } -AsJob
Receive-Job $job -Wait
```

---

## Interactive Remote Sessions: Enter-PSSession

For an interactive shell on a remote computer:

```powershell
# Connect
Enter-PSSession -ComputerName server01

# You are now in a remote session:
# [server01]: PS C:\Users\alice\Documents>

# Exit the session
Exit-PSSession
```

---

## Persistent Sessions: New-PSSession

Persistent sessions avoid the overhead of creating a new connection for each command:

```powershell
# Create sessions
$s1 = New-PSSession -ComputerName server01
$s2 = New-PSSession -ComputerName server02

# Use a session
Invoke-Command -Session $s1 -ScriptBlock { Get-Process }

# Interactive session
Enter-PSSession -Session $s1

# Import a module from a remote session
Import-PSSession $s1 -Module ActiveDirectory

# See open sessions
Get-PSSession

# Close a session
Remove-PSSession $s1

# Close all sessions
Get-PSSession | Remove-PSSession
```

---

## Running Scripts Remotely

```powershell
# Copy a script and run it
Copy-Item .\deploy.ps1 \\server01\c$\Scripts\

Invoke-Command -ComputerName server01 -FilePath .\deploy.ps1

# Or inline the script content
$script = Get-Content .\deploy.ps1 -Raw
Invoke-Command -ComputerName server01 -ScriptBlock ([scriptblock]::Create($script))
```

---

## SSH Remoting (PS 7+)

```powershell
# Connect interactively via SSH
Enter-PSSession -HostName linuxbox -UserName alice -SSHTransport

# Run a command
Invoke-Command -HostName linuxbox -UserName alice -ScriptBlock { uname -a }

# Key-based authentication (recommended)
Invoke-Command -HostName linuxbox -KeyFilePath ~/.ssh/id_rsa -UserName alice -ScriptBlock { hostname }

# Connect to multiple Linux hosts
Invoke-Command -HostName 'web01','web02','web03' -UserName deploy -ScriptBlock {
    systemctl status nginx
}
```

---

## Working with Credentials

```powershell
$cred = Get-Credential

# Use credentials for remoting
New-PSSession -ComputerName server01 -Credential $cred
Invoke-Command -ComputerName server01 -Credential $cred -ScriptBlock { whoami }

# Use different credentials per host
$creds = @{
    'server01' = Get-Credential -Message "Credentials for server01"
    'server02' = Get-Credential -Message "Credentials for server02"
}

foreach ($srv in $creds.Keys) {
    Invoke-Command -ComputerName $srv -Credential $creds[$srv] -ScriptBlock { hostname }
}
```

---

## Practical Recipes

### Parallel health check across servers

```powershell
$servers = 'web01','web02','db01','db02','app01'

$results = Invoke-Command -ComputerName $servers -ScriptBlock {
    $os  = Get-CimInstance Win32_OperatingSystem
    $cpu = Get-CimInstance Win32_Processor
    [PSCustomObject]@{
        Computer = $env:COMPUTERNAME
        OS       = $os.Caption
        Uptime   = [math]::Round(((Get-Date) - $os.LastBootUpTime).TotalHours, 1)
        CPU      = $cpu.Name
        FreeRAM  = [math]::Round($os.FreePhysicalMemory / 1MB, 1)
        DiskFree = [math]::Round((Get-Volume C).SizeRemaining / 1GB, 1)
    }
} -ErrorAction SilentlyContinue

$results | Sort-Object Computer | Format-Table -AutoSize
```

### Deploy a configuration file to many servers

```powershell
$servers = Get-Content .\servers.txt
$localFile = ".\config\app.conf"

foreach ($srv in $servers) {
    try {
        Copy-Item $localFile "\\$srv\c$\App\app.conf" -Force
        Invoke-Command -ComputerName $srv -ScriptBlock { Restart-Service AppService }
        Write-Host "✓ $srv updated" -ForegroundColor Green
    } catch {
        Write-Warning "✗ $srv failed: $_"
    }
}
```

### Collect event log errors from multiple servers

```powershell
$servers = 'web01','web02','app01'

Invoke-Command -ComputerName $servers -ScriptBlock {
    Get-WinEvent -FilterHashtable @{
        LogName   = 'Application'
        Level     = 2
        StartTime = (Get-Date).AddHours(-24)
    } -MaxEvents 5 -ErrorAction SilentlyContinue |
    Select-Object TimeCreated, Id, Message,
        @{Name='Server'; Expression={ $env:COMPUTERNAME }}
} | Sort-Object TimeCreated -Descending | Format-Table Server, TimeCreated, Id, Message -Wrap
```

---

## Remoting Tips

!!! tip "Firewall and port"
    WinRM uses port **5985** (HTTP) and **5986** (HTTPS). Ensure these are open on firewalls between the client and server.

!!! tip "CredSSP for double-hop scenarios"
    If the remote session needs to connect to a third server (e.g., a file share), you may need CredSSP or Kerberos delegation to pass credentials through.

!!! tip "JEA — Just Enough Administration"
    For production environments, use **JEA** to constrain what commands remote users can run, which roles they run as, and log all activity. See `New-PSSessionConfigurationFile`.
