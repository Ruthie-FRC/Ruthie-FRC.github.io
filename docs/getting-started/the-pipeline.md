# Understanding the Pipeline

The pipeline is the heart of PowerShell. It lets you chain commands together so the output of one feeds directly into the input of the next — as **objects**, not text.

---

## The Pipe Operator `|`

```powershell
Command-One | Command-Two | Command-Three
```

Each command receives the objects produced by the previous command.

### A simple example

```powershell
Get-Process | Sort-Object CPU -Descending | Select-Object -First 5
```

Step by step:

1. `Get-Process` — returns a collection of `Process` objects
2. `| Sort-Object CPU -Descending` — sorts them by the `CPU` property, highest first
3. `| Select-Object -First 5` — takes only the first 5 results

---

## How Pipeline Input Works

When you pipe into a cmdlet, PowerShell binds the incoming objects to parameters marked with `ValueFromPipeline` or `ValueFromPipelineByPropertyName`.

### By value

```powershell
"notepad","calc" | Start-Process
```

`Start-Process` accepts strings by value, so each string becomes the `-FilePath`.

### By property name

```powershell
Import-Csv .\servers.csv | Test-Connection -Count 1
```

If the CSV has a column named `ComputerName`, PowerShell automatically binds it to `Test-Connection`'s `-ComputerName` parameter.

---

## The `$_` / `$PSItem` Variable

Inside `ForEach-Object` and `Where-Object` script blocks, `$_` (or its alias `$PSItem`) refers to the **current pipeline object**:

```powershell
Get-ChildItem *.log | ForEach-Object {
    "Processing: $($_.Name) ($($_.Length) bytes)"
}
```

```powershell
Get-Service | Where-Object { $_.Status -eq 'Running' }
# Shorthand syntax (PS 3+):
Get-Service | Where-Object Status -eq Running
```

---

## Essential Pipeline Cmdlets

| Cmdlet | Purpose |
|--------|---------|
| `Where-Object` / `?` | Filter objects by condition |
| `ForEach-Object` / `%` | Run code for each object |
| `Select-Object` | Pick properties or first/last N objects |
| `Sort-Object` | Order objects by property |
| `Group-Object` | Group objects sharing a property value |
| `Measure-Object` | Count, sum, average, min, max |
| `Tee-Object` | Split output to file/variable AND the pipeline |
| `Out-File` | Send formatted output to a file |
| `Export-Csv` | Serialize to CSV |
| `ConvertTo-Json` | Serialize to JSON |

---

## Building Complex Pipelines

### Example: Disk space report

```powershell
Get-PSDrive -PSProvider FileSystem |
    Where-Object { $_.Used -gt 0 } |
    Select-Object Name,
        @{Name='Used GB';  Expression={ [math]::Round($_.Used  / 1GB, 2) }},
        @{Name='Free GB';  Expression={ [math]::Round($_.Free  / 1GB, 2) }},
        @{Name='Total GB'; Expression={ [math]::Round(($_.Used + $_.Free) / 1GB, 2) }} |
    Sort-Object 'Total GB' -Descending |
    Format-Table -AutoSize
```

### Example: Top memory consumers

```powershell
Get-Process |
    Sort-Object WorkingSet64 -Descending |
    Select-Object -First 10 Name, Id,
        @{Name='MB'; Expression={ [math]::Round($_.WorkingSet64 / 1MB, 1) }} |
    Format-Table -AutoSize
```

### Example: Export stopped services

```powershell
Get-Service |
    Where-Object Status -eq Stopped |
    Select-Object Name, DisplayName, StartType |
    Export-Csv .\stopped-services.csv -NoTypeInformation
```

---

## Calculated Properties

Use a hashtable with `Name` and `Expression` keys inside `Select-Object` or `Sort-Object` to create custom computed properties:

```powershell
Get-ChildItem C:\Windows -File |
    Select-Object Name,
        @{Name='SizeKB'; Expression={ [math]::Round($_.Length / 1KB, 1) }},
        LastWriteTime |
    Sort-Object SizeKB -Descending |
    Select-Object -First 20
```

---

## Saving Pipeline Results

### To a variable

```powershell
$procs = Get-Process | Where-Object CPU -gt 5
$procs.Count   # how many?
$procs | Format-Table Name, CPU
```

### To a file

```powershell
Get-Process | Out-File .\processes.txt
Get-Process | Export-Csv .\processes.csv -NoTypeInformation
Get-Process | ConvertTo-Json | Out-File .\processes.json
```

### Both at once with Tee-Object

```powershell
Get-Service |
    Tee-Object -FilePath .\services.txt |
    Where-Object Status -eq Running |
    Measure-Object
```

---

## Pipeline Tips

!!! tip "Use -WhatIf before destructive operations"
    ```powershell
    Get-ChildItem *.tmp | Remove-Item -WhatIf
    ```
    `-WhatIf` shows what *would* happen without actually doing it.

!!! tip "Use Out-GridView for interactive exploration"
    ```powershell
    Get-Process | Out-GridView
    ```
    This opens an interactive filterable table — great for ad-hoc analysis.

!!! warning "Format-* ends the pipeline"
    `Format-Table`, `Format-List`, and `Format-Wide` convert objects to formatting directives. After them, you can't pipe to `Export-Csv` or `Select-Object`. Always format last.

---

## Next Step

[:octicons-arrow-right-24: Variables & Data Types](../concepts/variables.md)
