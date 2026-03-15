# Error Handling

PowerShell has two kinds of errors: **terminating** (stop execution) and **non-terminating** (reported but execution continues). Understanding the difference is key to robust scripts.

---

## Terminating vs. Non-Terminating Errors

| Type | Default Behavior | Examples |
|------|-----------------|---------|
| **Non-terminating** | Writes to error stream, continues | `Get-Item` on missing file, `Get-Process` on missing name |
| **Terminating** | Stops the current command/script | `throw`, `$ErrorActionPreference = 'Stop'`, divide by zero |

### Making non-terminating errors terminating

```powershell
# Per-command
Get-Item .\missing.txt -ErrorAction Stop

# For the entire script
$ErrorActionPreference = 'Stop'
```

---

## `$ErrorActionPreference`

Controls the default behavior for non-terminating errors in the current scope:

| Value | Behavior |
|-------|---------|
| `Continue` | (default) display error and continue |
| `SilentlyContinue` | suppress error output and continue |
| `Stop` | treat as terminating error |
| `Inquire` | prompt user to continue/break/etc. |
| `Ignore` | suppress completely — no error variable update |
| `Break` | break into the debugger |

```powershell
# Suppress errors silently (use sparingly)
Get-Item .\maybe-exists.txt -ErrorAction SilentlyContinue

# Script-wide strict error handling
$ErrorActionPreference = 'Stop'
```

---

## Try / Catch / Finally

The fundamental mechanism for handling terminating errors:

```powershell
try {
    $content = Get-Content .\config.json -ErrorAction Stop | ConvertFrom-Json
    Write-Host "Config loaded: $($content.AppName)"
}
catch [System.IO.FileNotFoundException] {
    Write-Warning "Config file not found. Using defaults."
    $content = @{ AppName = "MyApp"; Debug = $false }
}
catch [System.Management.Automation.PSInvalidCastException] {
    Write-Error "Config file is not valid JSON"
    exit 1
}
catch {
    # Catch-all for any other error
    Write-Error "Unexpected error: $($_.Exception.Message)"
    throw   # re-throw to propagate up
}
finally {
    # Always runs — use for cleanup
    Write-Verbose "Config load attempt complete"
}
```

### The `$_` variable in catch

Inside a `catch` block, `$_` is the `ErrorRecord` object:

```powershell
catch {
    $_.Exception.Message      # human-readable message
    $_.Exception.GetType()    # exception type
    $_.ScriptStackTrace       # where it happened
    $_.CategoryInfo           # category, activity, target
    $_.FullyQualifiedErrorId  # unique error ID
    $_.InvocationInfo.Line    # the line that failed
}
```

---

## Throw

Use `throw` to raise a terminating error from your own code:

```powershell
function Get-Config {
    param ([string]$Path)

    if (-not (Test-Path $Path)) {
        throw "Config file '$Path' does not exist"
    }
    Get-Content $Path -Raw | ConvertFrom-Json
}
```

### Throw with an exception object

```powershell
throw [System.IO.FileNotFoundException]::new("File not found: $path", $path)
```

---

## The `$Error` Variable

`$Error` is an automatic array of the most recent errors (default last 256):

```powershell
$Error[0]              # most recent error
$Error[0].Exception    # the exception
$Error.Count           # number of recorded errors
$Error.Clear()         # clear the error list
```

---

## Checking Command Success

```powershell
# $? is $true if last command succeeded
git pull
if (-not $?) {
    Write-Error "git pull failed"
}

# $LASTEXITCODE holds the exit code of the last native (non-PS) command
& cmd /c exit 2
$LASTEXITCODE   # 2
```

### Strict mode for native commands (PS 7.2+)

```powershell
$ErrorActionPreference  = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true
# Now any native command with a non-zero exit code throws
```

---

## Common Patterns

### Ignore errors, check result

```powershell
$proc = Get-Process -Name notepad -ErrorAction SilentlyContinue
if ($null -eq $proc) {
    "Notepad is not running"
}
```

### Trap errors in a loop and continue

```powershell
$servers = Import-Csv .\servers.csv
$results = foreach ($s in $servers) {
    try {
        [PSCustomObject]@{
            Server = $s.Name
            Online = (Test-Connection $s.Name -Count 1 -Quiet -ErrorAction Stop)
            Error  = $null
        }
    } catch {
        [PSCustomObject]@{
            Server = $s.Name
            Online = $false
            Error  = $_.Exception.Message
        }
    }
}
$results | Format-Table
```

### Retry with error handling

```powershell
function Invoke-WithRetry {
    param(
        [scriptblock] $ScriptBlock,
        [int]         $MaxRetries = 3,
        [int]         $DelaySeconds = 2
    )

    for ($i = 1; $i -le $MaxRetries; $i++) {
        try {
            return (& $ScriptBlock)
        } catch {
            if ($i -eq $MaxRetries) { throw }
            Write-Warning "Attempt $i failed: $_. Retrying in ${DelaySeconds}s..."
            Start-Sleep -Seconds $DelaySeconds
        }
    }
}

Invoke-WithRetry { Invoke-RestMethod https://api.example.com/data }
```

---

## Strict Mode

`Set-StrictMode` catches common scripting mistakes:

```powershell
Set-StrictMode -Version Latest

# Now these will throw instead of silently returning $null:
$undeclaredVariable     # error: undefined variable
$array[99]              # error: index out of bounds
$hash.NonExistentKey    # error: property does not exist
```

| Version | What's checked |
|---------|---------------|
| `1.0` | Variables must be initialized |
| `2.0` | + calls to non-existent functions, arrays without index |
| `Latest` | All checks from the latest version |
