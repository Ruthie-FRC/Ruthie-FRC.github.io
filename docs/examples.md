# Examples & Recipes

Real-world, copy-paste ready PowerShell scripts for common automation tasks.

---

## System Administration

### Clean up temp files older than 30 days

```powershell
$dirs    = @($env:TEMP, "C:\Windows\Temp")
$cutoff  = (Get-Date).AddDays(-30)
$deleted = 0
$errors  = 0

foreach ($dir in $dirs) {
    Get-ChildItem $dir -Recurse -File -ErrorAction SilentlyContinue |
        Where-Object { $_.LastWriteTime -lt $cutoff } |
        ForEach-Object {
            try {
                Remove-Item $_.FullName -Force
                $deleted++
            } catch {
                $errors++
            }
        }
}

Write-Host "Deleted $deleted files. Errors: $errors"
```

---

### System inventory report (CSV)

```powershell
$computers = Get-Content .\servers.txt   # or @('server01','server02')

$report = Invoke-Command -ComputerName $computers -ScriptBlock {
    $os   = Get-CimInstance Win32_OperatingSystem
    $cpu  = Get-CimInstance Win32_Processor | Select-Object -First 1
    $disk = Get-Volume C

    [PSCustomObject]@{
        Computer   = $env:COMPUTERNAME
        OS         = $os.Caption
        Build      = $os.BuildNumber
        CPU        = $cpu.Name
        Cores      = $cpu.NumberOfCores
        RAM_GB     = [math]::Round($os.TotalVisibleMemorySize/1MB, 1)
        FreeRAM_GB = [math]::Round($os.FreePhysicalMemory/1MB, 1)
        Disk_GB    = [math]::Round($disk.Size/1GB, 1)
        FreeDisk_GB= [math]::Round($disk.SizeRemaining/1GB, 1)
    }
} -ErrorAction SilentlyContinue

$report | Sort-Object Computer | Export-Csv .\inventory-$(Get-Date -f yyyyMMdd).csv -NoTypeInformation
Write-Host "Report saved."
```

---

### Service monitor: alert when a service stops

```powershell
$ServiceName  = "Spooler"
$CheckEvery   = 30   # seconds
$EmailTo      = "admin@example.com"

while ($true) {
    $svc = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
    if ($svc -and $svc.Status -ne 'Running') {
        Write-Warning "$(Get-Date) — $ServiceName stopped! Attempting restart..."
        try {
            Start-Service -Name $ServiceName
            Write-Host "$(Get-Date) — $ServiceName restarted successfully." -ForegroundColor Green
        } catch {
            Write-Error "Failed to restart ${ServiceName}: $_"
            # Send-MailMessage -To $EmailTo -Subject "Service down: $ServiceName" ...
        }
    }
    Start-Sleep -Seconds $CheckEvery
}
```

---

## File & Data Processing

### Find duplicate files by hash

```powershell
$folder = "C:\Users\Alice\Documents"

Get-ChildItem $folder -Recurse -File |
    Group-Object -Property {
        Get-FileHash $_.FullName -Algorithm MD5 | Select-Object -ExpandProperty Hash
    } |
    Where-Object Count -gt 1 |
    ForEach-Object {
        Write-Host "Duplicates:" -ForegroundColor Yellow
        $_.Group | Select-Object FullName, Length, LastWriteTime | Format-Table
    }
```

---

### Bulk rename files

```powershell
# Add a date prefix to all .jpg files in a folder
$folder = "C:\Photos"
$date   = Get-Date -Format "yyyy-MM-dd"

Get-ChildItem $folder -Filter *.jpg |
    Where-Object { $_.Name -notmatch "^\d{4}-\d{2}-\d{2}" } |
    Rename-Item -NewName { "${date}_$($_.Name)" } -WhatIf
# Remove -WhatIf to execute
```

---

### Convert JSON to CSV

```powershell
$json = Get-Content .\data.json -Raw | ConvertFrom-Json

# If the JSON is an array of flat objects:
$json | Export-Csv .\data.csv -NoTypeInformation
Write-Host "Converted to CSV."

# If it has nested objects, flatten first:
$json | ForEach-Object {
    [PSCustomObject]@{
        Id    = $_.id
        Name  = $_.name
        Email = $_.contact.email   # nested property
    }
} | Export-Csv .\data-flat.csv -NoTypeInformation
```

---

### Parse a log file and aggregate errors

```powershell
$logPath = "C:\Logs\app.log"
$pattern = "^(?<ts>\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}) \[(?<level>\w+)\] (?<msg>.+)$"

$entries = Get-Content $logPath | ForEach-Object {
    if ($_ -match $pattern) {
        [PSCustomObject]@{
            Timestamp = [datetime]$Matches.ts
            Level     = $Matches.level
            Message   = $Matches.msg
        }
    }
}

# Error summary
$entries |
    Where-Object Level -eq "ERROR" |
    Group-Object -Property { $_.Message -replace "\d+","#" } |  # normalize numbers
    Sort-Object Count -Descending |
    Select-Object Count, Name |
    Format-Table -AutoSize
```

---

## Networking

### Check if a list of URLs are reachable

```powershell
$urls = @(
    "https://google.com",
    "https://github.com",
    "https://api.myapp.example.com/health",
    "https://offline.example.com"
)

$urls | ForEach-Object {
    $url = $_
    try {
        $resp = Invoke-WebRequest -Uri $url -TimeoutSec 5 -ErrorAction Stop
        [PSCustomObject]@{ URL = $url; Status = $resp.StatusCode; OK = $true }
    } catch {
        [PSCustomObject]@{ URL = $url; Status = $_.Exception.Message; OK = $false }
    }
} | Format-Table URL, Status, OK -AutoSize
```

---

### Download all files from a remote directory listing

```powershell
$baseUrl  = "https://downloads.example.com/releases/"
$destDir  = ".\downloads"
$pattern  = 'href="(v\d+\.\d+\.\d+\.zip)"'

New-Item $destDir -ItemType Directory -Force | Out-Null

$page  = (Invoke-WebRequest $baseUrl).Content
$files = [regex]::Matches($page, $pattern) | ForEach-Object { $_.Groups[1].Value }

foreach ($file in $files) {
    $dest = Join-Path $destDir $file
    if (-not (Test-Path $dest)) {
        Write-Host "Downloading $file..."
        Invoke-WebRequest -Uri "$baseUrl$file" -OutFile $dest
    }
}
Write-Host "Done. $($files.Count) files."
```

---

## Active Directory (requires RSAT / ActiveDirectory module)

### Report users who haven't logged in for 90 days

```powershell
Import-Module ActiveDirectory

$cutoff = (Get-Date).AddDays(-90)

Get-ADUser -Filter { LastLogonDate -lt $cutoff -and Enabled -eq $true } `
    -Properties LastLogonDate, Department, Manager |
    Select-Object SamAccountName, Name, LastLogonDate, Department,
        @{Name='Manager'; Expression={ (Get-ADUser $_.Manager).Name }} |
    Sort-Object LastLogonDate |
    Export-Csv .\inactive-users.csv -NoTypeInformation

Write-Host "Report saved to inactive-users.csv"
```

---

### Bulk create users from CSV

```powershell
# CSV: Name,SamAccountName,Department,Password
Import-Csv .\new-users.csv | ForEach-Object {
    $pwd = ConvertTo-SecureString $_.Password -AsPlainText -Force
    $params = @{
        Name              = $_.Name
        SamAccountName    = $_.SamAccountName
        AccountPassword   = $pwd
        Enabled           = $true
        Path              = "OU=Users,DC=example,DC=com"
        Department        = $_.Department
        ChangePasswordAtLogon = $true
    }
    try {
        New-ADUser @params
        Write-Host "Created: $($_.SamAccountName)" -ForegroundColor Green
    } catch {
        Write-Warning "Failed to create $($_.SamAccountName): $_"
    }
}
```

---

## Automation Utilities

### Retry a command with exponential backoff

```powershell
function Invoke-WithRetry {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [scriptblock] $ScriptBlock,

        [int] $MaxAttempts = 5,
        [int] $InitialDelaySeconds = 1
    )

    $attempt = 0
    do {
        $attempt++
        try {
            return (& $ScriptBlock)
        } catch {
            if ($attempt -ge $MaxAttempts) { throw }
            $delay = $InitialDelaySeconds * [math]::Pow(2, $attempt - 1)
            Write-Warning "Attempt $attempt failed: $_  Retrying in ${delay}s..."
            Start-Sleep -Seconds $delay
        }
    } while ($true)
}

# Usage:
Invoke-WithRetry { Invoke-RestMethod https://unstable.api.example.com/data }
```

---

### Run a script block with a timeout

```powershell
function Invoke-WithTimeout {
    param(
        [scriptblock] $ScriptBlock,
        [int] $TimeoutSeconds = 30
    )
    $job = Start-Job -ScriptBlock $ScriptBlock
    if (Wait-Job $job -Timeout $TimeoutSeconds) {
        Receive-Job $job
    } else {
        Stop-Job $job
        throw "Operation timed out after ${TimeoutSeconds} seconds"
    }
    Remove-Job $job -Force
}

Invoke-WithTimeout -ScriptBlock { Start-Sleep 5; "Done" } -TimeoutSeconds 10
```

---

### Send a Teams notification webhook

```powershell
function Send-TeamsMessage {
    param(
        [string] $WebhookUrl,
        [string] $Title,
        [string] $Text,
        [ValidateSet("default","good","warning","attention")]
        [string] $Color = "default"
    )

    $body = @{
        "@type"      = "MessageCard"
        "@context"   = "http://schema.org/extensions"
        themeColor   = switch ($Color) {
            "good"      { "00FF00" }
            "warning"   { "FFA500" }
            "attention" { "FF0000" }
            default     { "0078D7" }
        }
        summary  = $Title
        sections = @(@{ activityTitle = $Title; activityText = $Text })
    } | ConvertTo-Json -Depth 5

    Invoke-RestMethod -Uri $WebhookUrl -Method Post -Body $body -ContentType "application/json"
}

Send-TeamsMessage -WebhookUrl $env:TEAMS_WEBHOOK `
    -Title "Deployment Complete" -Text "Version 2.3.1 deployed to production." -Color good
```

---

### Archive and compress logs older than N days

```powershell
param(
    [string] $LogDir   = "C:\Logs",
    [string] $ArchDir  = "C:\LogArchive",
    [int]    $DaysOld  = 7
)

$cutoff = (Get-Date).AddDays(-$DaysOld)
$stamp  = Get-Date -Format "yyyy-MM-dd"
$dest   = Join-Path $ArchDir "logs-$stamp.zip"

New-Item $ArchDir -ItemType Directory -Force | Out-Null

$toArchive = Get-ChildItem $LogDir -Filter *.log |
    Where-Object { $_.LastWriteTime -lt $cutoff }

if ($toArchive) {
    Compress-Archive -Path $toArchive.FullName -DestinationPath $dest
    $toArchive | Remove-Item -Force
    Write-Host "Archived $($toArchive.Count) logs to $dest"
} else {
    Write-Host "No logs older than $DaysOld days found."
}
```
