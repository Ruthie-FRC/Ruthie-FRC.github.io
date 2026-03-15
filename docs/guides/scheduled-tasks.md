# Scheduled Tasks

PowerShell provides complete control over Windows Task Scheduler — create, manage, enable, disable, and remove tasks without touching the GUI.

---

## Viewing Scheduled Tasks

```powershell
# List all tasks
Get-ScheduledTask

# Filter by name (wildcard)
Get-ScheduledTask -TaskName "*Backup*"

# Filter by folder
Get-ScheduledTask -TaskPath "\Microsoft\Windows\WindowsUpdate\"

# Get details on a task
Get-ScheduledTask -TaskName "DailyBackup" | Get-ScheduledTaskInfo

# List enabled (Ready) tasks
Get-ScheduledTask | Where-Object State -eq Ready

# List disabled tasks
Get-ScheduledTask | Where-Object State -eq Disabled

# Show task details in full
Get-ScheduledTask -TaskName "DailyBackup" | Select-Object *
```

---

## Creating a Scheduled Task

Building a task requires three objects: an **action**, a **trigger**, and optionally **settings** and **principal** (run-as account).

### Simple example — run a script daily at 2am

```powershell
# 1. Define what to run
$action = New-ScheduledTaskAction `
    -Execute "pwsh.exe" `
    -Argument "-NoProfile -NonInteractive -File `"C:\Scripts\backup.ps1`""

# 2. Define when to run
$trigger = New-ScheduledTaskTrigger -Daily -At "2:00AM"

# 3. Register the task
Register-ScheduledTask `
    -TaskName "DailyBackup" `
    -TaskPath "\MyTasks\" `
    -Action   $action `
    -Trigger  $trigger `
    -Description "Backs up user data every night"
```

### Run as a specific user

```powershell
$principal = New-ScheduledTaskPrincipal `
    -UserId "SYSTEM" `
    -LogonType ServiceAccount `
    -RunLevel Highest

Register-ScheduledTask `
    -TaskName  "SystemMaintenance" `
    -Action    $action `
    -Trigger   $trigger `
    -Principal $principal
```

### Run as current user, only when logged in

```powershell
$principal = New-ScheduledTaskPrincipal `
    -UserId  "$env:USERDOMAIN\$env:USERNAME" `
    -LogonType InteractiveToken

Register-ScheduledTask -TaskName "UserTask" -Action $action -Trigger $trigger -Principal $principal
```

---

## Trigger Types

```powershell
# Daily at a specific time
New-ScheduledTaskTrigger -Daily -At "6:00AM"

# Weekly on Monday and Friday
New-ScheduledTaskTrigger -Weekly -DaysOfWeek Monday,Friday -At "8:00AM"

# Once at a specific date/time
New-ScheduledTaskTrigger -Once -At "2024-03-15 14:00:00"

# At system startup
New-ScheduledTaskTrigger -AtStartup

# At user logon
New-ScheduledTaskTrigger -AtLogOn

# Repeat every 30 minutes indefinitely
$trigger = New-ScheduledTaskTrigger -RepetitionInterval (New-TimeSpan -Minutes 30) -Once -At (Get-Date)

# At system idle
New-ScheduledTaskTrigger -AtIdle
```

---

## Task Settings

```powershell
$settings = New-ScheduledTaskSettingsSet `
    -ExecutionTimeLimit  (New-TimeSpan -Hours 2) `
    -RestartCount        3 `
    -RestartInterval     (New-TimeSpan -Minutes 5) `
    -StartWhenAvailable `
    -RunOnlyIfNetworkAvailable `
    -WakeToRun

Register-ScheduledTask `
    -TaskName "RobustTask" `
    -Action   $action `
    -Trigger  $trigger `
    -Settings $settings
```

---

## Managing Existing Tasks

```powershell
# Enable a disabled task
Enable-ScheduledTask -TaskName "DailyBackup"

# Disable a task
Disable-ScheduledTask -TaskName "DailyBackup"

# Start a task immediately (on-demand)
Start-ScheduledTask -TaskName "DailyBackup"

# Stop a running task
Stop-ScheduledTask -TaskName "DailyBackup"

# Remove a task
Unregister-ScheduledTask -TaskName "DailyBackup" -Confirm:$false

# Update a trigger on an existing task
$task    = Get-ScheduledTask -TaskName "DailyBackup"
$trigger = New-ScheduledTaskTrigger -Daily -At "3:00AM"
Set-ScheduledTask -TaskName "DailyBackup" -Trigger $trigger
```

---

## Viewing Run History

```powershell
# Last run info
Get-ScheduledTask -TaskName "DailyBackup" | Get-ScheduledTaskInfo

# Full output
$info = Get-ScheduledTaskInfo -TaskName "DailyBackup"
$info.LastRunTime
$info.LastTaskResult    # 0 = success
$info.NextRunTime
$info.NumberOfMissedRuns

# Query event log for task results
Get-WinEvent -FilterHashtable @{
    LogName = 'Microsoft-Windows-TaskScheduler/Operational'
    Id      = 201   # Task completed
} -MaxEvents 20 | Select-Object TimeCreated,
    @{Name='Task'; Expression={ $_.Properties[0].Value }},
    @{Name='Result'; Expression={ $_.Properties[2].Value }}
```

---

## Practical Recipes

### Create a script to run at startup as admin

```powershell
$action    = New-ScheduledTaskAction -Execute "pwsh.exe" -Argument "-File C:\Scripts\startup.ps1"
$trigger   = New-ScheduledTaskTrigger -AtStartup
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -RunLevel Highest

Register-ScheduledTask `
    -TaskName  "StartupScript" `
    -Action    $action `
    -Trigger   $trigger `
    -Principal $principal `
    -Force
```

### List all tasks that failed last run

```powershell
Get-ScheduledTask |
    Get-ScheduledTaskInfo |
    Where-Object { $_.LastTaskResult -ne 0 -and $_.LastRunTime -ne [datetime]::MinValue } |
    Select-Object TaskName, LastRunTime, LastTaskResult |
    Format-Table -AutoSize
```
