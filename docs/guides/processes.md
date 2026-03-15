# Process Management

PowerShell provides a rich set of cmdlets for discovering, starting, stopping, and monitoring processes on local and remote computers.

---

## Listing Processes

```powershell
# All running processes
Get-Process

# Filter by name (wildcard supported)
Get-Process -Name notepad
Get-Process -Name "chrome*"

# Filter by PID
Get-Process -Id 1234

# Sort by memory usage (descending)
Get-Process | Sort-Object WorkingSet64 -Descending | Select-Object -First 10

# Sort by CPU time
Get-Process | Sort-Object CPU -Descending | Select-Object -First 10

# Show processes with owner (requires elevation)
Get-Process -IncludeUserName | Select-Object Name, UserName, Id | Sort-Object Name
```

---

## Process Properties

Every process object has rich properties:

```powershell
$p = Get-Process -Name pwsh

$p.Id               # process ID
$p.Name             # process name
$p.CPU              # total CPU seconds consumed
$p.WorkingSet64     # RAM in bytes
$p.VirtualMemorySize64
$p.HandleCount
$p.ThreadCount
$p.StartTime        # when the process started
$p.MainWindowTitle  # window title (GUI apps)
$p.Path             # full path to the executable
$p.Company
$p.FileVersion

# Format memory as MB
"{0} uses {1:N1} MB" -f $p.Name, ($p.WorkingSet64 / 1MB)
```

---

## Starting Processes

```powershell
# Open a program
Start-Process notepad
Start-Process "C:\Program Files\MyApp\app.exe"

# Pass arguments
Start-Process pwsh -ArgumentList "-NoProfile -File .\setup.ps1"

# Run as administrator
Start-Process pwsh -Verb RunAs

# Wait for the process to finish
Start-Process msiexec -ArgumentList "/i app.msi /quiet" -Wait

# Capture the process object
$proc = Start-Process notepad -PassThru
$proc.Id   # PID of the new process

# Open a URL in the default browser
Start-Process "https://docs.microsoft.com/powershell"

# Open a file with its default handler
Start-Process .\report.pdf
```

---

## Stopping Processes

```powershell
# Stop by name
Stop-Process -Name notepad

# Stop by PID
Stop-Process -Id 1234

# Force kill (for unresponsive processes)
Stop-Process -Name chrome -Force

# Kill all instances
Get-Process notepad | Stop-Process

# Preview what would be killed
Stop-Process -Name notepad -WhatIf
```

!!! warning "Data loss risk"
    `Stop-Process` sends a kill signal — it does **not** ask the application to save data. Use with caution on interactive apps.

---

## Monitoring Processes

```powershell
# Watch CPU usage every 2 seconds
while ($true) {
    Clear-Host
    Get-Process |
        Sort-Object CPU -Descending |
        Select-Object -First 15 Name, Id,
            @{Name='CPU%'; Expression={ [math]::Round($_.CPU,1) }},
            @{Name='MB';   Expression={ [math]::Round($_.WorkingSet64/1MB,1) }} |
        Format-Table -AutoSize
    Start-Sleep -Seconds 2
}

# Wait for a process to finish
Wait-Process -Name setup -Timeout 300

# Check if a process is running
if (Get-Process -Name notepad -ErrorAction SilentlyContinue) {
    "Notepad is running"
}
```

---

## Jobs (Background Processes)

PowerShell **jobs** run commands asynchronously:

```powershell
# Start a background job
$job = Start-Job -ScriptBlock { Get-Process | Sort-Object CPU -Descending }

# Check job status
Get-Job
$job.State      # Running, Completed, Failed

# Wait for it
Wait-Job $job

# Get results
Receive-Job $job

# Receive and keep in the job queue
Receive-Job $job -Keep

# Clean up
Remove-Job $job

# One-liner: start, wait, get results, remove
Start-Job { Get-Date } | Wait-Job | Receive-Job | Remove-Job -Force
```

---

## Thread Jobs (PS 6.1+, faster than Start-Job)

```powershell
# Requires ThreadJob module (built-in in PS 7)
$jobs = 1..5 | ForEach-Object {
    Start-ThreadJob -ScriptBlock { param($n) $n * $n } -ArgumentList $_
}

$results = $jobs | Wait-Job | Receive-Job
$jobs | Remove-Job
```

---

## Working with Remote Processes

```powershell
# List processes on a remote machine
Get-Process -ComputerName server01

# Kill a process on a remote machine
Invoke-Command -ComputerName server01 -ScriptBlock {
    Stop-Process -Name notepad -Force
}
```

---

## Practical Recipes

### Restart a process if it crashes

```powershell
$appName = "MyWorker"
$appPath = "C:\Apps\worker.exe"

while ($true) {
    if (-not (Get-Process -Name $appName -ErrorAction SilentlyContinue)) {
        Write-Host "$(Get-Date) — Restarting $appName"
        Start-Process $appPath
    }
    Start-Sleep -Seconds 10
}
```

### Get processes using more than X MB

```powershell
$threshold = 500   # MB
Get-Process |
    Where-Object { $_.WorkingSet64 -gt ($threshold * 1MB) } |
    Select-Object Name, Id, @{Name='MB'; Expression={ [math]::Round($_.WorkingSet64/1MB,0) }} |
    Sort-Object MB -Descending |
    Format-Table -AutoSize
```

### Log process list to file

```powershell
$logFile = "C:\Logs\processes-$(Get-Date -Format 'yyyy-MM-dd_HH-mm').csv"
Get-Process |
    Select-Object Name, Id, CPU, WorkingSet64, StartTime |
    Export-Csv $logFile -NoTypeInformation
Write-Host "Saved to $logFile"
```

