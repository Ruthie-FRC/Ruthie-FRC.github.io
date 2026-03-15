# Pipelines & Filtering

The PowerShell pipeline passes **.NET objects** between commands — not plain text. This makes filtering, sorting, and transforming data precise and powerful.

---

## Pipeline Fundamentals

### Chaining commands

```powershell
Get-Process | Sort-Object CPU -Descending | Select-Object -First 10
```

Each `|` passes the output of the left command as input to the right command.

### The current object: `$_`

Inside `ForEach-Object`, `Where-Object`, and script block parameters, `$_` (alias `$PSItem`) is the **current pipeline object**:

```powershell
Get-Process | ForEach-Object { "$($_.Name) uses $([math]::Round($_.WorkingSet64/1MB,1)) MB" }
```

---

## Filtering with Where-Object

```powershell
# Simple property comparison (PS 3+ syntax)
Get-Service | Where-Object Status -eq Running
Get-Process | Where-Object CPU -gt 10
Get-ChildItem | Where-Object Length -gt 1MB

# Script block (more flexible)
Get-Process | Where-Object { $_.CPU -gt 10 -and $_.Name -ne 'Idle' }

# String operations
Get-ChildItem | Where-Object { $_.Name -like "*.log" }
Get-Service   | Where-Object { $_.DisplayName -match "^Windows" }

# Combining conditions
Get-Service | Where-Object {
    $_.Status -eq 'Stopped' -and
    $_.StartType -eq 'Automatic'
}
```

---

## Selecting Properties with Select-Object

```powershell
# Pick specific properties
Get-Process | Select-Object Name, CPU, Id, WorkingSet64

# First / last N
Get-Process | Select-Object -First 5
Get-Process | Select-Object -Last 5
Get-Process | Select-Object -Skip 10 -First 5

# Unique values
Get-Process | Select-Object -ExpandProperty Name -Unique

# ExpandProperty — returns the value, not a wrapper object
(Get-Process | Select-Object -ExpandProperty Name)[0]  # string, not PSCustomObject
```

### Calculated properties

Use a hashtable `@{Name='...'; Expression={ ... }}` to create new computed columns:

```powershell
Get-Process | Select-Object Name,
    @{Name='MB';      Expression={ [math]::Round($_.WorkingSet64/1MB, 1) }},
    @{Name='Threads'; Expression={ $_.Threads.Count }} |
    Sort-Object MB -Descending | Format-Table -AutoSize
```

---

## Sorting with Sort-Object

```powershell
# Single property, ascending (default)
Get-ChildItem | Sort-Object Length

# Descending
Get-Process | Sort-Object CPU -Descending

# Multiple properties
Get-Service | Sort-Object Status, DisplayName

# Stable sort: use Top/Bottom (PS 6+)
Get-Process | Sort-Object CPU -Top 10     # efficient: don't sort all, take top 10
```

---

## Grouping with Group-Object

```powershell
# Count services by status
Get-Service | Group-Object Status

# Group files by extension
Get-ChildItem | Group-Object Extension | Sort-Object Count -Descending

# As a hashtable for fast lookup
$byStatus = Get-Service | Group-Object Status -AsHashTable
$byStatus['Running']  # all running services
```

---

## Aggregation with Measure-Object

```powershell
# Count
Get-Process | Measure-Object

# Sum, Average, Min, Max on a numeric property
Get-ChildItem C:\ -Recurse -ErrorAction SilentlyContinue |
    Measure-Object Length -Sum -Average -Maximum

# Word and line count on text files
Get-Content .\README.md | Measure-Object -Word -Line -Character
```

---

## ForEach-Object

```powershell
# Basic iteration
1..5 | ForEach-Object { $_ * 2 }

# Named parameter
Get-Service | ForEach-Object -Process { "Service: $($_.Name)" }

# Begin / Process / End blocks
1..10 | ForEach-Object -Begin {
    $sum = 0
} -Process {
    $sum += $_
} -End {
    "Total: $sum"
}

# Parallel (PS 7+)
1..20 | ForEach-Object -Parallel {
    Start-Sleep -Milliseconds 100
    "Done: $_"
} -ThrottleLimit 5
```

---

## Tee-Object

Split the pipeline to a file or variable while continuing:

```powershell
# Save intermediate results to a variable AND pass through
Get-Process |
    Tee-Object -Variable procs |
    Where-Object CPU -gt 5

# Access both the full set and the filtered set
$procs.Count   # total

# Save to file too
Get-Service | Tee-Object -FilePath .\services.txt | Measure-Object
```

---

## Out-GridView (Interactive Filter)

```powershell
# Browse interactively
Get-Process | Out-GridView

# Select items and return them to the pipeline
$selected = Get-Service | Out-GridView -PassThru -Title "Choose services"
$selected | Restart-Service
```

---

## Practical Pipeline Recipes

### Disk usage by folder

```powershell
Get-ChildItem C:\Users -Directory | ForEach-Object {
    $size = (Get-ChildItem $_.FullName -Recurse -ErrorAction SilentlyContinue |
             Measure-Object Length -Sum).Sum
    [PSCustomObject]@{
        Folder  = $_.Name
        'Size GB' = [math]::Round($size/1GB, 2)
    }
} | Sort-Object 'Size GB' -Descending | Format-Table -AutoSize
```

### Count lines of code

```powershell
Get-ChildItem . -Recurse -Filter *.ps1 |
    Get-Content |
    Where-Object { $_ -notmatch '^\s*#' -and $_ -match '\S' } |
    Measure-Object -Line
```

### Compare two lists

```powershell
$installed = (Get-Service).Name
$required  = @('wuauserv', 'Spooler', 'W32Time', 'MyCustomSvc')

$missing = $required | Where-Object { $_ -notin $installed }
if ($missing) {
    Write-Warning "Missing services: $($missing -join ', ')"
}
```

### Pipeline with error capture

```powershell
$errors   = [System.Collections.Generic.List[string]]::new()
$results  = Get-ChildItem .\servers.txt |
    Get-Content |
    ForEach-Object {
        try {
            [PSCustomObject]@{
                Server = $_
                Online = (Test-Connection $_ -Count 1 -Quiet -ErrorAction Stop)
            }
        } catch {
            $errors.Add("Failed: $_ — $_")
            $null  # don't emit to pipeline
        }
    } |
    Where-Object { $null -ne $_ }
```

