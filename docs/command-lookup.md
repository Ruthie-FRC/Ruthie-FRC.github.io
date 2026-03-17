# Command Lookup

Find any cmdlet two ways — **by name** if you know what you're looking for, or **by function** if you know what you want to *do*.

!!! tip "Quick search"
    Press <kbd>S</kbd> or <kbd>/</kbd> at any time to search across the entire site, including all command names, descriptions, and keywords.

---

## Find a Command by Name

If you know the command name (or part of it), use the [A–Z Command Reference](command-reference.md).  
Common aliases also work in the search bar — type `ls`, `cd`, `grep`, `curl`, or `kill` to find the matching cmdlet.

---

## Find a Command by Function

Browse the categories below to discover which cmdlet does what you need.

---

### :material-folder-open: File System

Work with files, directories, and file content.

| Command | What It Does | Common Aliases |
|---------|-------------|----------------|
| `Get-ChildItem` | List files and directories | `ls`, `dir`, `gci` |
| `Set-Location` | Change the current directory | `cd`, `chdir` |
| `Get-Location` | Show the current directory path | `pwd`, `gl` |
| `New-Item` | Create a new file or directory | `ni` |
| `Remove-Item` | Delete files or directories | `rm`, `del`, `rmdir` |
| `Copy-Item` | Copy a file or directory | `cp`, `copy` |
| `Move-Item` | Move or rename a file or directory | `mv`, `move` |
| `Rename-Item` | Rename an item | `ren` |
| `Get-Content` | Read the contents of a file | `cat`, `type`, `gc` |
| `Set-Content` | Write (overwrite) content to a file | `sc` |
| `Add-Content` | Append content to a file | `ac` |
| `Test-Path` | Check whether a file or path exists | — |
| `Get-Item` | Get metadata about a specific item | `gi` |

**Example — find all `.log` files modified in the last 7 days:**
```powershell
Get-ChildItem C:\ -Recurse -Filter *.log |
    Where-Object { $_.LastWriteTime -gt (Get-Date).AddDays(-7) }
```

---

### :material-cog-play: Process Management

Start, stop, and inspect running processes.

| Command | What It Does | Common Aliases |
|---------|-------------|----------------|
| `Get-Process` | List running processes | `ps`, `gps` |
| `Start-Process` | Launch a new process | `start`, `saps` |
| `Stop-Process` | Kill a running process | `kill`, `spps` |
| `Wait-Process` | Wait for a process to exit | `wps` |

**Example — find the top 10 CPU-hungry processes:**
```powershell
Get-Process | Sort-Object CPU -Descending | Select-Object -First 10
```

---

### :material-wifi: Networking

Test connections, resolve names, and inspect network configuration.

| Command | What It Does | Common Aliases |
|---------|-------------|----------------|
| `Test-Connection` | Ping a host (ICMP) | `ping` |
| `Test-NetConnection` | Test TCP connectivity to a host and port | `tnc` |
| `Get-NetIPConfiguration` | Show IP address, gateway, and DNS | `gip` |
| `Get-NetIPAddress` | List all IP addresses on the machine | — |
| `Resolve-DnsName` | Resolve a hostname to an IP address | — |
| `Get-NetTCPConnection` | List active TCP connections | — |

**Example — check whether port 443 is open on a remote host:**
```powershell
(Test-NetConnection github.com -Port 443).TcpTestSucceeded
```

---

### :material-web: Web & REST APIs

Download files and call web services.

| Command | What It Does | Common Aliases |
|---------|-------------|----------------|
| `Invoke-RestMethod` | Call a REST API and parse the response | `irm` |
| `Invoke-WebRequest` | Download a web page or file | `iwr`, `curl`, `wget` |

**Example — call the GitHub API:**
```powershell
$user = Invoke-RestMethod https://api.github.com/users/octocat
$user.name
```

---

### :material-server: System & Services

Query system information and manage Windows services.

| Command | What It Does | Common Aliases |
|---------|-------------|----------------|
| `Get-ComputerInfo` | Get hardware and OS details | `gin` |
| `Get-PSDrive` | List all drives (disk, registry, cert…) | `gdr` |
| `Get-Service` | List Windows services and their status | `gsv` |
| `Start-Service` | Start a stopped service | `sasv` |
| `Stop-Service` | Stop a running service | `spsv` |
| `Restart-Service` | Stop then start a service | — |
| `Get-EventLog` | Read Windows classic event logs | — |
| `Get-WinEvent` | Read modern Windows event logs (preferred) | — |

**Example — find all stopped services:**
```powershell
Get-Service | Where-Object Status -eq Stopped
```

---

### :material-filter: Pipeline & Filtering

Manipulate and transform objects flowing through the pipeline.

| Command | What It Does | Common Aliases |
|---------|-------------|----------------|
| `Where-Object` | Filter objects by a condition | `where`, `?` |
| `Select-Object` | Pick specific properties or items | `select` |
| `Sort-Object` | Sort objects by a property | `sort` |
| `ForEach-Object` | Run a script block for each object | `foreach`, `%` |
| `Group-Object` | Group objects by a property value | `group` |
| `Measure-Object` | Count, sum, average properties | `measure` |
| `Tee-Object` | Send output to a file *and* the pipeline | `tee` |

**Example — count services by status:**
```powershell
Get-Service | Group-Object Status | Select-Object Name, Count
```

---

### :material-text-box-outline: Output & Formatting

Control how results are displayed or saved.

| Command | What It Does | Common Aliases |
|---------|-------------|----------------|
| `Write-Host` | Print text to the console (display only) | — |
| `Write-Output` | Send an object into the pipeline | `echo`, `write` |
| `Write-Error` | Write to the error stream | — |
| `Write-Warning` | Write a yellow warning message | — |
| `Write-Verbose` | Write a verbose message (shown with `-Verbose`) | — |
| `Write-Debug` | Write a debug message (shown with `-Debug`) | — |
| `Out-File` | Redirect output to a text file | — |
| `Out-GridView` | Display output in an interactive grid (Windows) | `ogv` |
| `Format-Table` | Format output as an aligned table | `ft` |
| `Format-List` | Format output as a vertical property list | `fl` |

**Example — save process list to a file:**
```powershell
Get-Process | Format-Table Name, CPU, Id -AutoSize | Out-File .\processes.txt
```

---

### :material-code-json: Data Conversion

Import and export structured data.

| Command | What It Does | Common Aliases |
|---------|-------------|----------------|
| `ConvertTo-Json` | Serialize an object to JSON | — |
| `ConvertFrom-Json` | Parse a JSON string into an object | — |
| `Export-Csv` | Write objects to a CSV file | `epcsv` |
| `Import-Csv` | Read a CSV file into objects | `ipcsv` |

**Example — export running processes to CSV:**
```powershell
Get-Process | Select-Object Name, CPU, Id |
    Export-Csv -Path .\procs.csv -NoTypeInformation
```

---

### :material-magnify: Discovery

Explore what commands, properties, and methods are available.

| Command | What It Does | Common Aliases |
|---------|-------------|----------------|
| `Get-Command` | Find installed cmdlets, functions, and aliases | `gcm` |
| `Get-Help` | Read documentation for any command | `help`, `man` |
| `Get-Member` | List properties and methods of an object | `gm` |

**Example — find all commands that start with the verb `Get`:**
```powershell
Get-Command -Verb Get
```

**Example — explore what properties a process object has:**
```powershell
Get-Process | Get-Member
```

---

### :material-package-variant: Modules

Load and install PowerShell modules.

| Command | What It Does | Common Aliases |
|---------|-------------|----------------|
| `Import-Module` | Load a module into the current session | `ipmo` |
| `Get-Module` | List loaded or available modules | `gmo` |
| `Install-Module` | Download and install a module from PSGallery | — |

---

### :material-shield-lock: Security & Credentials

Manage credentials, secure strings, and execution policies.

| Command | What It Does | Common Aliases |
|---------|-------------|----------------|
| `Get-Credential` | Prompt for a username and password | — |
| `ConvertTo-SecureString` | Create a `SecureString` from plain text | — |
| `Set-ExecutionPolicy` | Change the script execution policy | — |

---

### :material-variable: Variables

Create, inspect, and remove variables.

| Command | What It Does | Common Aliases |
|---------|-------------|----------------|
| `Set-Variable` | Create or update a variable | `set`, `sv` |
| `Get-Variable` | List variables in the current session | `gv` |
| `Remove-Variable` | Delete a variable | `rv` |

---

### :material-database: Registry

Read and write Windows Registry values.

| Command | What It Does | Common Aliases |
|---------|-------------|----------------|
| `Get-ItemProperty` | Read a registry value | `gp` |
| `Set-ItemProperty` | Write or create a registry value | `sp` |

---

### :material-calendar-clock: Scheduled Tasks

Create and manage scheduled tasks.

| Command | What It Does | Common Aliases |
|---------|-------------|----------------|
| `Get-ScheduledTask` | List scheduled tasks | — |
| `Register-ScheduledTask` | Create a new scheduled task | — |

---

### :material-remote-desktop: Remote Management

Run commands on remote machines.

| Command | What It Does | Common Aliases |
|---------|-------------|----------------|
| `Invoke-Command` | Run a script block on a remote computer | `icm` |
| `New-PSSession` | Open a persistent remote session | `nsn` |

---

### :material-tools: Utilities

Handy everyday commands.

| Command | What It Does | Common Aliases |
|---------|-------------|----------------|
| `Get-Date` | Get the current date and time | — |
| `Start-Sleep` | Pause execution for a specified duration | `sleep` |
| `Clear-Host` | Clear the terminal screen | `cls`, `clear` |
| `Read-Host` | Prompt the user for input | — |
| `Select-String` | Search for text patterns in files or strings (like `grep`) | `sls` |

**Example — search all `.ps1` files for the word `error`:**
```powershell
Select-String -Pattern 'error' -Path .\*.ps1 -CaseSensitive
```

---

## Common Task Quick-Reference

| I want to… | Use this command |
|-----------|-----------------|
| List files in a folder | `Get-ChildItem` |
| Read a text file | `Get-Content` |
| Write to a text file | `Set-Content` / `Add-Content` |
| Check if a file exists | `Test-Path` |
| Copy a file | `Copy-Item` |
| Delete a file | `Remove-Item` |
| Find running processes | `Get-Process` |
| Kill a process | `Stop-Process` |
| Ping a server | `Test-Connection` |
| Check a TCP port | `Test-NetConnection` |
| Call a REST API | `Invoke-RestMethod` |
| Download a file | `Invoke-WebRequest` |
| Filter a list | `Where-Object` |
| Sort results | `Sort-Object` |
| Pick columns | `Select-Object` |
| Count items | `Measure-Object` |
| Export to CSV | `Export-Csv` |
| Read a CSV | `Import-Csv` |
| Convert to / from JSON | `ConvertTo-Json` / `ConvertFrom-Json` |
| Get system info | `Get-ComputerInfo` |
| Manage services | `Get-Service`, `Start-Service`, `Stop-Service` |
| Read event logs | `Get-WinEvent` |
| Search file contents | `Select-String` |
| Look up a command | `Get-Command` |
| Read command help | `Get-Help` |
| Explore object properties | `Get-Member` |
