# Control Flow

Control flow statements direct the order of execution in a script — branching, looping, and switching.

---

## If / ElseIf / Else

```powershell
$age = 20

if ($age -lt 13) {
    "Child"
} elseif ($age -lt 18) {
    "Teenager"
} elseif ($age -lt 65) {
    "Adult"
} else {
    "Senior"
}
```

### Negation

```powershell
if (-not (Test-Path .\config.json)) {
    Write-Error "Config file missing!"
    exit 1
}
```

### Inline / ternary-style (PS 7+)

```powershell
$label = $score -ge 60 ? "Pass" : "Fail"
```

---

## Switch Statement

`switch` is a multi-branch selector — more powerful than most languages because it supports wildcards, regex, and custom conditions.

```powershell
$day = "Monday"

switch ($day) {
    "Saturday" { "Weekend!" }
    "Sunday"   { "Weekend!" }
    default    { "Weekday" }
}
```

### Multiple patterns in one branch

```powershell
switch ($day) {
    { $_ -in "Saturday","Sunday" } { "Weekend!" }
    default { "Weekday" }
}
```

### Wildcard matching

```powershell
switch -Wildcard ($filename) {
    "*.txt"  { "Text file" }
    "*.csv"  { "CSV file" }
    "*.ps1"  { "PowerShell script" }
    default  { "Unknown type" }
}
```

### Regex matching

```powershell
switch -Regex ($input) {
    "^\d{4}-\d{2}-\d{2}$" { "ISO date" }
    "^\d+$"                { "Integer" }
    "^\d+\.\d+$"           { "Decimal" }
    default                { "Other" }
}
```

### Iterating an array with switch

```powershell
$items = "apple","BANANA","Cherry"
switch -CaseSensitive ($items) {
    { $_ -cmatch "^[A-Z]" } { "Starts with uppercase: $_" }
}
```

---

## For Loop

```powershell
for ($i = 0; $i -lt 5; $i++) {
    "Iteration $i"
}

# Countdown
for ($i = 10; $i -ge 0; $i--) {
    "T-$i..."
}
```

---

## ForEach Loop

```powershell
$fruits = @("apple", "banana", "cherry")

foreach ($fruit in $fruits) {
    Write-Host "Fruit: $fruit"
}

# Iterate over files
foreach ($file in Get-ChildItem .\logs -Filter *.log) {
    "Processing: $($file.Name)"
}
```

### ForEach-Object (pipeline version)

```powershell
Get-ChildItem | ForEach-Object { "File: $($_.Name)" }

# Shorthand
Get-ChildItem | % { "File: $($_.Name)" }
```

---

## While Loop

```powershell
$count = 0
while ($count -lt 5) {
    "Count: $count"
    $count++
}
```

### Wait for a condition

```powershell
$service = "wuauserv"
while ((Get-Service $service).Status -ne 'Running') {
    Write-Host "Waiting for $service..."
    Start-Sleep -Seconds 2
}
Write-Host "$service is running"
```

---

## Do-While and Do-Until

```powershell
# Do-While: runs at least once, continues while condition is true
$i = 0
do {
    "i = $i"
    $i++
} while ($i -lt 3)

# Do-Until: runs at least once, continues until condition is true
do {
    $response = Read-Host "Enter 'yes' to continue"
} until ($response -eq "yes")
```

---

## Loop Control: break, continue, return

```powershell
# break — exit the loop immediately
foreach ($n in 1..100) {
    if ($n -gt 5) { break }
    $n
}

# continue — skip to next iteration
foreach ($n in 1..10) {
    if ($n % 2 -eq 0) { continue }
    "$n is odd"
}

# return — exit the current function/script with an optional value
function Get-Grade ($score) {
    if ($score -ge 90) { return "A" }
    if ($score -ge 80) { return "B" }
    if ($score -ge 70) { return "C" }
    return "F"
}
```

### Labeled break (exit nested loops)

```powershell
:outer foreach ($i in 1..3) {
    foreach ($j in 1..3) {
        if ($j -eq 2) { break outer }
        "$i,$j"
    }
}
```

---

## Try / Catch / Finally

See the [Error Handling](error-handling.md) page for full coverage. Quick reference:

```powershell
try {
    $result = 1 / 0
} catch [System.DivideByZeroException] {
    "Cannot divide by zero"
} catch {
    "Unexpected error: $_"
} finally {
    "This always runs"
}
```

---

## Practical Examples

### Retry logic

```powershell
$maxRetries = 3
$attempt    = 0
$succeeded  = $false

while (-not $succeeded -and $attempt -lt $maxRetries) {
    $attempt++
    try {
        Invoke-RestMethod -Uri 'https://api.example.com/data'
        $succeeded = $true
    } catch {
        Write-Warning "Attempt $attempt failed: $_"
        Start-Sleep -Seconds (2 * $attempt)  # exponential backoff
    }
}

if (-not $succeeded) {
    throw "All $maxRetries attempts failed"
}
```

### Process a batch of servers

```powershell
$servers = Import-Csv .\servers.csv

foreach ($server in $servers) {
    if (-not (Test-Connection $server.Hostname -Count 1 -Quiet)) {
        Write-Warning "$($server.Hostname) is offline — skipping"
        continue
    }

    Invoke-Command -ComputerName $server.Hostname -ScriptBlock {
        Get-Service | Where-Object Status -eq Stopped
    }
}
```
