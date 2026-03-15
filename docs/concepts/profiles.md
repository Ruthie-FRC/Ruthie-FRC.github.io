# PowerShell Profiles

A **profile** is a script that runs automatically every time you start a new PowerShell session. Use it to set up aliases, load modules, customize the prompt, and define helper functions.

---

## Profile Files

PowerShell checks several profile files, from most specific to most general:

| Profile Variable | Path | Scope |
|-----------------|------|-------|
| `$PROFILE.CurrentUserCurrentHost` | `~\Documents\PowerShell\Microsoft.PowerShell_profile.ps1` | You, in this host only |
| `$PROFILE.CurrentUserAllHosts` | `~\Documents\PowerShell\profile.ps1` | You, in all hosts |
| `$PROFILE.AllUsersCurrentHost` | `$PSHOME\Microsoft.PowerShell_profile.ps1` | All users, this host |
| `$PROFILE.AllUsersAllHosts` | `$PSHOME\profile.ps1` | All users, all hosts |

`$PROFILE` (without a dot property) points to `CurrentUserCurrentHost`.

!!! note
    `$PSHOME` is PowerShell's install directory. On Windows it's typically `C:\Program Files\PowerShell\7`.

---

## Creating Your Profile

```powershell
# Check if the profile file exists
Test-Path $PROFILE

# Create it if it doesn't exist
if (-not (Test-Path $PROFILE)) {
    New-Item -Path $PROFILE -ItemType File -Force
}

# Open in your default editor
notepad $PROFILE

# Or open in VS Code
code $PROFILE
```

---

## What to Put in Your Profile

### Aliases

```powershell
Set-Alias grep Select-String
Set-Alias which Get-Command
Set-Alias touch New-Item
```

### Useful functions

```powershell
function which ($name) { Get-Command $name | Select-Object -ExpandProperty Source }

function uptime {
    $os = Get-CimInstance Win32_OperatingSystem
    $uptime = (Get-Date) - $os.LastBootUpTime
    "Up {0} days, {1} hours, {2} minutes" -f $uptime.Days, $uptime.Hours, $uptime.Minutes
}

function Reload-Profile {
    . $PROFILE
    Write-Host "Profile reloaded."
}
```

### Environment variables

```powershell
$env:EDITOR = "code"
$env:PAGER  = "less"
```

### Default parameters

```powershell
$PSDefaultParameterValues = @{
    'Format-Table:AutoSize'     = $true
    'Export-Csv:NoTypeInformation' = $true
    'Get-Help:ShowWindow'        = $true
}
```

### Auto-load modules

```powershell
Import-Module PSReadLine
Import-Module Terminal-Icons
Import-Module posh-git
```

### PSReadLine configuration

```powershell
# Predictive IntelliSense from history
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView

# Emacs/Bash-style key bindings
Set-PSReadLineOption -EditMode Emacs

# History search with arrow keys
Set-PSReadLineKeyHandler -Key UpArrow   -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
```

### Custom prompt

```powershell
function prompt {
    $path = $PWD.Path -replace [regex]::Escape($HOME), '~'
    $branch = if (git rev-parse --is-inside-work-tree 2>$null) {
        " (" + (git branch --show-current) + ")"
    }
    Write-Host "PS " -NoNewline -ForegroundColor DarkGray
    Write-Host $path -NoNewline -ForegroundColor Cyan
    Write-Host $branch -NoNewline -ForegroundColor Yellow
    " > "
}
```

---

## Example Profile

```powershell title="~\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
# ── Modules ─────────────────────────────────────────────────────────────
Import-Module PSReadLine -ErrorAction SilentlyContinue
Import-Module Terminal-Icons -ErrorAction SilentlyContinue

# ── PSReadLine ───────────────────────────────────────────────────────────
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# ── Aliases ──────────────────────────────────────────────────────────────
Set-Alias grep Select-String
Set-Alias vi  notepad

# ── Default parameter values ─────────────────────────────────────────────
$PSDefaultParameterValues = @{
    'Format-Table:AutoSize'          = $true
    'Export-Csv:NoTypeInformation'   = $true
    'Out-Default:OutVariable'        = '__'   # last output available as $__
}

# ── Helper functions ─────────────────────────────────────────────────────
function which ($name) {
    (Get-Command $name -ErrorAction SilentlyContinue)?.Source
}

function uptime {
    $boot   = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
    $uptime = (Get-Date) - $boot
    "Up {0}d {1}h {2}m" -f $uptime.Days, $uptime.Hours, $uptime.Minutes
}

# ── Greeting ─────────────────────────────────────────────────────────────
Write-Host "PowerShell $($PSVersionTable.PSVersion)" -ForegroundColor Cyan
```

---

## Reloading the Profile

```powershell
. $PROFILE          # dot-source to reload
```

---

## Conditional Loading

Guard against slow imports or modules that may not be installed:

```powershell
if (Get-Module -ListAvailable -Name posh-git) {
    Import-Module posh-git
}
```
