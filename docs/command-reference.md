# Command Reference

A-Z reference of the most commonly used PowerShell cmdlets. Each entry shows the syntax, key parameters, and a quick example.

Use the search bar (<kbd>S</kbd>) to jump straight to any cmdlet.

---

## A

### Add-Content
Appends content to a file without overwriting it.
```powershell
Add-Content [-Path] <string[]> [-Value] <Object[]>
# Example:
Add-Content .\log.txt "$(Get-Date) - Application started"
```

### Add-Member
Adds a property or method to an object.
```powershell
Add-Member -InputObject <psobject> -MemberType <PSMemberTypes> -Name <string> -Value <Object>
# Example:
$proc = Get-Process pwsh
$proc | Add-Member -MemberType NoteProperty -Name "MB" -Value ([math]::Round($proc.WorkingSet64/1MB,1))
$proc.MB
```

---

## C

### Clear-Content
Deletes the content of a file without deleting the file itself.
```powershell
Clear-Content [-Path] <string[]>
# Example:
Clear-Content .\cache.log
```

### Clear-Host
Clears the terminal screen. Aliases: `cls`, `clear`.
```powershell
Clear-Host
```

### Compare-Object
Compares two sets of objects and shows differences.
```powershell
Compare-Object [-ReferenceObject] <PSObject[]> [-DifferenceObject] <PSObject[]>
# Example:
$a = Get-Content .\old.txt
$b = Get-Content .\new.txt
Compare-Object $a $b
```

### Compress-Archive
Creates a `.zip` archive.
```powershell
Compress-Archive [-Path] <string[]> -DestinationPath <string> [-Update]
# Example:
Compress-Archive -Path .\Reports\* -DestinationPath .\Reports.zip
```

### ConvertFrom-Csv
Converts CSV strings to PowerShell objects.
```powershell
"Name,Age`nAlice,30`nBob,25" | ConvertFrom-Csv
Import-Csv .\data.csv   # preferred for files
```

### ConvertFrom-Json
Converts a JSON string to a PowerShell object.
```powershell
'{"name":"Alice","age":30}' | ConvertFrom-Json
(Invoke-RestMethod https://api.github.com/users/octocat) | ConvertFrom-Json
```

### ConvertTo-Csv
Converts objects to CSV text.
```powershell
Get-Process | Select-Object Name, Id | ConvertTo-Csv -NoTypeInformation
```

### ConvertTo-Html
Converts objects to an HTML table string.
```powershell
Get-Process | Select-Object Name, CPU, Id |
    ConvertTo-Html -Title "Running Processes" | Out-File .\report.html
```

### ConvertTo-Json
Converts an object to a JSON string.
```powershell
Get-Date | ConvertTo-Json
@{ name="Alice"; age=30 } | ConvertTo-Json -Depth 5
```

### ConvertTo-SecureString
Creates a SecureString from plain text or an encrypted string.
```powershell
$secure = ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force
```

### Copy-Item
Copies an item to another location.
```powershell
Copy-Item [-Path] <string[]> [[-Destination] <string>] [-Recurse] [-Force]
# Examples:
Copy-Item .\file.txt .\backup.txt
Copy-Item .\src -Destination .\dst -Recurse
Copy-Item C:\Logs\*.log D:\Archive\
```

---

## D

### Disable-LocalUser
Disables a local user account.
```powershell
Disable-LocalUser -Name "alice"
```

### Disable-ScheduledTask
Disables a scheduled task so it will not run automatically.
```powershell
Disable-ScheduledTask -TaskName "DailyBackup"
```

---

## E

### Enable-LocalUser
Enables a disabled local user account.
```powershell
Enable-LocalUser -Name "alice"
```

### Enable-PSRemoting
Configures WinRM to accept remote PowerShell connections.
```powershell
Enable-PSRemoting -Force
```

### Enable-ScheduledTask
Enables a scheduled task so it will run on its trigger.
```powershell
Enable-ScheduledTask -TaskName "DailyBackup"
```

### Enter-PSSession
Starts an interactive remote PowerShell session.
```powershell
Enter-PSSession -ComputerName server01
Enter-PSSession -HostName linuxbox -UserName alice -SSHTransport
```

### Expand-Archive
Extracts files from a `.zip` archive.
```powershell
Expand-Archive -Path .\archive.zip -DestinationPath .\output
Expand-Archive .\archive.zip .\output -Force
```

### Export-Csv
Exports objects to a CSV file.
```powershell
Export-Csv [-Path] <string> [-NoTypeInformation] [-Append]
# Example:
Get-Service | Export-Csv .\services.csv -NoTypeInformation
```

### Export-Clixml
Serializes objects to an XML file for later reconstruction.
```powershell
Get-Process | Export-Clixml .\procs.xml
$procs = Import-Clixml .\procs.xml
```

---

## F

### Find-Module
Searches the PowerShell Gallery for modules.
```powershell
Find-Module -Name Pester
Find-Module -Tag Security
Find-Module -Command Get-ADUser
```

### ForEach-Object
Runs a script block for each piped object. Alias: `%`.
```powershell
1..5 | ForEach-Object { $_ * 2 }
Get-ChildItem | ForEach-Object { $_.Name }
# Parallel execution (PS 7+):
1..10 | ForEach-Object -Parallel { Start-Sleep 1; $_ } -ThrottleLimit 5
```

### Format-List
Formats output as a property list. Alias: `fl`.
```powershell
Get-Process pwsh | Format-List *
Get-Service | Format-List Name, Status, StartType
```

### Format-Table
Formats output as a table. Alias: `ft`.
```powershell
Get-Process | Format-Table Name, Id, CPU -AutoSize
Get-Service | Format-Table -GroupBy Status
```

### Format-Wide
Formats output in a multi-column wide list.
```powershell
Get-Process | Format-Wide Name -Column 4
```

---

## G

### Get-Acl
Gets the security descriptor (ACL) for a file, folder, or registry key.
```powershell
Get-Acl .\sensitive.txt
(Get-Acl .\folder).Access | Format-Table IdentityReference, FileSystemRights
```

### Get-Alias
Lists defined command aliases.
```powershell
Get-Alias
Get-Alias ls
Get-Alias -Definition Get-ChildItem
```

### Get-AuthenticodeSignature
Gets the digital signature on a script or executable.
```powershell
Get-AuthenticodeSignature .\myscript.ps1
Get-ChildItem .\scripts -Filter *.ps1 | Get-AuthenticodeSignature
```

### Get-ChildItem
Lists items in a location. Aliases: `ls`, `dir`, `gci`.
```powershell
Get-ChildItem [[-Path] <string[]>] [-Filter <string>] [-Recurse] [-Force] [-File] [-Directory]
# Examples:
Get-ChildItem C:\Windows -Filter *.exe -Recurse
Get-ChildItem -Force   # include hidden and system items
Get-ChildItem HKLM:\Software   # registry
```

### Get-CimInstance
Gets hardware and OS information via CIM/WMI.
```powershell
Get-CimInstance Win32_OperatingSystem
Get-CimInstance Win32_Processor
Get-CimInstance Win32_LogicalDisk | Where-Object DriveType -eq 3
Get-CimInstance Win32_PhysicalMemory | Measure-Object Capacity -Sum
```

### Get-Command
Finds available cmdlets, functions, scripts, and aliases.
```powershell
Get-Command -Verb Get
Get-Command -Noun Service
Get-Command *dns*
Get-Command -Module ActiveDirectory
```

### Get-Content
Reads a file. Aliases: `cat`, `gc`, `type`.
```powershell
Get-Content [-Path] <string[]> [-TotalCount <int>] [-Tail <int>] [-Wait] [-Raw] [-Encoding <Encoding>]
# Examples:
Get-Content .\file.txt
Get-Content .\big.log -Tail 20 -Wait   # like tail -f
Get-Content .\data.json -Raw | ConvertFrom-Json
```

### Get-Credential
Prompts for a username and password and returns a PSCredential.
```powershell
$cred = Get-Credential
$cred = Get-Credential -Message "Enter admin credentials" -UserName "DOMAIN\admin"
```

### Get-Date
Gets the current date and time.
```powershell
Get-Date
Get-Date -Format "yyyy-MM-dd HH:mm:ss"
(Get-Date).AddDays(-7)
Get-Date -UFormat "%s"   # Unix timestamp
```

### Get-ExecutionPolicy
Gets the current PowerShell script execution policy.
```powershell
Get-ExecutionPolicy
Get-ExecutionPolicy -List   # all scopes
```

### Get-Help
Displays documentation for commands. Alias: `man`.
```powershell
Get-Help Get-Process
Get-Help Get-Process -Examples
Get-Help Get-Process -Full
Get-Help *dns*
Update-Help   # download latest help content
```

### Get-History
Gets the command history for the current session.
```powershell
Get-History
Get-History -Count 20
```

### Get-Item
Gets an item at a specified path.
```powershell
Get-Item C:\Windows\System32
Get-Item HKLM:\Software\Microsoft
Get-Item Env:\PATH
```

### Get-ItemProperty
Gets the properties (values) of an item.
```powershell
Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ProductName
(Get-ItemProperty "HKCU:\Software\MyApp").Theme
```

### Get-Job
Gets PowerShell background jobs.
```powershell
Get-Job
Get-Job | Where-Object State -eq Running
```

### Get-LocalGroup
Gets local security groups.
```powershell
Get-LocalGroup
Get-LocalGroupMember -Group Administrators
```

### Get-LocalUser
Gets local user accounts.
```powershell
Get-LocalUser
Get-LocalUser -Name alice
```

### Get-Location
Gets the current working directory. Aliases: `pwd`, `gl`.
```powershell
Get-Location
(Get-Location).Path
```

### Get-Member
Gets the properties and methods of an object. Alias: `gm`.
```powershell
Get-Process | Get-Member
"hello" | Get-Member -MemberType Method
42 | Get-Member
```

### Get-Module
Gets loaded or available modules.
```powershell
Get-Module                          # currently loaded
Get-Module -ListAvailable           # all installed
Get-Module -ListAvailable -Name Az  # specific module
```

### Get-NetIPAddress
Gets IP address configuration for all network adapters.
```powershell
Get-NetIPAddress
Get-NetIPAddress -AddressFamily IPv4
Get-NetIPAddress -InterfaceAlias "Ethernet"
```

### Get-NetIPConfiguration
Gets full IP configuration per adapter.
```powershell
Get-NetIPConfiguration
Get-NetIPConfiguration -Detailed
```

### Get-NetTCPConnection
Gets TCP connection and listening port information (like `netstat`).
```powershell
Get-NetTCPConnection -State Listen
Get-NetTCPConnection -LocalPort 443
Get-NetTCPConnection | Where-Object OwningProcess -eq (Get-Process pwsh).Id
```

### Get-Process
Gets running processes. Aliases: `ps`, `gps`.
```powershell
Get-Process
Get-Process -Name chrome
Get-Process -Id 1234
Get-Process | Sort-Object CPU -Descending | Select-Object -First 10
```

### Get-PSDrive
Gets drives (file system, registry, certificates, etc.).
```powershell
Get-PSDrive
Get-PSDrive -PSProvider FileSystem
```

### Get-PSSession
Gets active remote PowerShell sessions.
```powershell
Get-PSSession
```

### Get-ScheduledTask
Gets scheduled tasks.
```powershell
Get-ScheduledTask
Get-ScheduledTask -TaskName "DailyBackup"
Get-ScheduledTask | Where-Object State -eq Ready
```

### Get-ScheduledTaskInfo
Gets runtime information (last run, next run, result) for a scheduled task.
```powershell
Get-ScheduledTaskInfo -TaskName "DailyBackup"
```

### Get-Service
Gets Windows services. Alias: `gsv`.
```powershell
Get-Service
Get-Service -Name Spooler
Get-Service | Where-Object Status -eq Running
```

### Get-Variable
Gets PowerShell session variables.
```powershell
Get-Variable PSVersionTable
Get-Variable -Scope Global
```

### Get-Verb
Lists all approved PowerShell verbs.
```powershell
Get-Verb
Get-Verb | Sort-Object Verb
Get-Verb Get
```

### Get-Volume
Gets disk volume information.
```powershell
Get-Volume
Get-Volume -DriveLetter C
```

### Get-WinEvent
Gets events from Windows event logs.
```powershell
Get-WinEvent -LogName System -MaxEvents 50
Get-WinEvent -FilterHashtable @{ LogName='Security'; Id=4624 } -MaxEvents 20
Get-WinEvent -ListLog * | Where-Object RecordCount -gt 0
```

### Group-Object
Groups objects by property value. Alias: `group`.
```powershell
Get-Service | Group-Object Status
Get-ChildItem | Group-Object Extension | Sort-Object Count -Descending
Get-Service | Group-Object Status -AsHashTable
```

---

## I

### Import-Csv
Reads a CSV file and returns custom objects.
```powershell
Import-Csv -Path .\data.csv
Import-Csv .\data.csv -Delimiter ";"
Import-Csv .\servers.csv | ForEach-Object { Test-Connection $_.Hostname -Count 1 -Quiet }
```

### Import-Clixml
Deserializes objects from a CLIXML file.
```powershell
$data = Import-Clixml .\backup.xml
```

### Import-Module
Loads a module into the current session.
```powershell
Import-Module ActiveDirectory
Import-Module .\MyModule -Force
Import-Module Pester -MinimumVersion 5.0
```

### Install-Module
Installs a module from the PowerShell Gallery.
```powershell
Install-Module Pester
Install-Module Az -Scope CurrentUser
Install-Module PSReadLine -AllowPrerelease
```

### Invoke-Command
Runs commands on local or remote computers.
```powershell
Invoke-Command -ComputerName server01 -ScriptBlock { Get-Service }
Invoke-Command -ComputerName server01,server02 -ScriptBlock { $env:COMPUTERNAME }
Invoke-Command -ComputerName server01 -ScriptBlock { Get-Service $using:svcName }
```

### Invoke-Expression
Evaluates a string as a PowerShell command.
```powershell
$cmd = "Get-Date"
Invoke-Expression $cmd
```

!!! warning "Security risk"
    Never use `Invoke-Expression` with untrusted input — it is a common injection vector.

### Invoke-RestMethod
Sends an HTTP/HTTPS request and parses the JSON or XML response.
```powershell
Invoke-RestMethod -Uri https://api.github.com/users/octocat
Invoke-RestMethod -Uri https://api.example.com/items `
    -Method Post -Body ($body|ConvertTo-Json) -ContentType "application/json"
```

### Invoke-WebRequest
Sends an HTTP request and returns the full response object.
```powershell
Invoke-WebRequest -Uri https://example.com
(Invoke-WebRequest -Uri https://example.com).StatusCode
Invoke-WebRequest -Uri https://example.com/file.zip -OutFile .\file.zip
```

---

## J

### Join-Path
Joins a path and a child path into a single path.
```powershell
Join-Path C:\Users $env:USERNAME "Documents"
Join-Path $PSScriptRoot "config.json"
```

---

## M

### Measure-Object
Calculates numeric properties (count, sum, average, min, max). Alias: `measure`.
```powershell
Get-Process | Measure-Object
Get-ChildItem -Recurse | Measure-Object Length -Sum -Average -Maximum
Get-Content .\README.md | Measure-Object -Word -Line -Character
```

### Move-Item
Moves and optionally renames an item. Alias: `mv`, `move`.
```powershell
Move-Item .\old.txt .\new.txt
Move-Item .\file.txt C:\Archive\
Move-Item .\folder D:\NewLocation -Force
```

---

## N

### New-Guid
Generates a new GUID (globally unique identifier).
```powershell
New-Guid
[guid]::NewGuid()
```

### New-Item
Creates a new item (file, directory, registry key, alias, etc.).
```powershell
New-Item -Path .\hello.txt -ItemType File -Value "Hello, World!"
New-Item -Path .\MyFolder -ItemType Directory
New-Item -Path HKCU:\Software\MyApp -Force
```

### New-LocalUser
Creates a new local user account.
```powershell
$pwd = Read-Host "Password" -AsSecureString
New-LocalUser -Name "alice" -Password $pwd -FullName "Alice Smith" -Description "Developer"
```

### New-ModuleManifest
Creates a module manifest (`.psd1`) file.
```powershell
New-ModuleManifest `
    -Path .\MyModule\MyModule.psd1 `
    -RootModule MyModule.psm1 `
    -ModuleVersion "1.0.0" `
    -Author "Your Name" `
    -Description "What this module does"
```

### New-Object
Creates an instance of a .NET or COM object.
```powershell
$wc   = New-Object System.Net.WebClient
$list = New-Object System.Collections.Generic.List[string]
# Preferred modern syntax:
$list = [System.Collections.Generic.List[string]]::new()
```

### New-PSDrive
Creates a new drive mapping.
```powershell
New-PSDrive -Name Z -PSProvider FileSystem -Root \\server\share
New-PSDrive -Name App -PSProvider Registry -Root HKCU:\Software\MyApp
```

### New-PSSession
Creates a persistent remote PowerShell session.
```powershell
$s = New-PSSession -ComputerName server01
Invoke-Command -Session $s -ScriptBlock { Get-Process }
Enter-PSSession -Session $s
```

### New-TimeSpan
Creates a TimeSpan object.
```powershell
New-TimeSpan -Days 7
New-TimeSpan -Hours 2 -Minutes 30
(Get-Date) - (Get-Date).AddDays(-7)   # also returns a TimeSpan
```

---

## O

### Out-File
Sends formatted output to a file.
```powershell
Get-Process | Out-File .\procs.txt
Get-Process | Out-File .\procs.txt -Append
Get-Process | Out-File .\procs.txt -Encoding UTF8
```

### Out-GridView
Displays pipeline output in an interactive filterable grid. Alias: `ogv`.
```powershell
Get-Process | Out-GridView
Get-Service | Out-GridView -PassThru | Stop-Service -WhatIf
```

### Out-Null
Discards all pipeline output.
```powershell
New-Item .\temp.txt | Out-Null
[void](Some-Function)   # equivalent, often faster
```

---

## R

### Read-Host
Reads a line of input from the console.
```powershell
$name = Read-Host "What is your name?"
$pwd  = Read-Host "Password" -AsSecureString
```

### Receive-Job
Gets the output of a background job.
```powershell
$job = Start-Job { Get-Date }
Receive-Job $job -Wait -AutoRemoveJob
```

### Register-ScheduledTask
Creates and registers a new scheduled task.
```powershell
$action  = New-ScheduledTaskAction -Execute "pwsh.exe" -Argument "-File C:\Scripts\job.ps1"
$trigger = New-ScheduledTaskTrigger -Daily -At "2:00AM"
Register-ScheduledTask -TaskName "NightlyJob" -Action $action -Trigger $trigger
```

### Remove-Item
Deletes items (files, folders, registry keys, etc.). Aliases: `rm`, `del`, `ri`.
```powershell
Remove-Item .\temp.txt
Remove-Item .\TempFolder -Recurse
Remove-Item .\*.tmp -Force
Remove-Item HKCU:\Software\MyApp -Recurse
```

### Remove-Job
Deletes one or more background jobs.
```powershell
Remove-Job -Id 5
Get-Job | Remove-Job
```

### Remove-Module
Removes a module from the current session.
```powershell
Remove-Module MyModule
```

### Remove-PSSession
Closes and removes a remote session.
```powershell
$session | Remove-PSSession
Get-PSSession | Remove-PSSession
```

### Rename-Item
Renames an item without moving it. Alias: `ren`.
```powershell
Rename-Item .\draft.docx .\final.docx
Get-ChildItem *.txt | Rename-Item -NewName { $_.Name -replace '\.txt$', '.md' }
```

### Resolve-DnsName
Performs a DNS lookup.
```powershell
Resolve-DnsName google.com
Resolve-DnsName github.com -Type A
Resolve-DnsName gmail.com -Type MX
Resolve-DnsName example.com -Type TXT -Server 8.8.8.8
```

### Resolve-Path
Resolves a relative or wildcard path to an absolute path.
```powershell
Resolve-Path .\relative\path.txt
Resolve-Path .\*.ps1   # expands wildcards to absolute paths
```

### Restart-Computer
Restarts a local or remote computer.
```powershell
Restart-Computer -Force
Restart-Computer -ComputerName server01 -Credential (Get-Credential) -Wait
```

### Restart-Service
Stops and then starts a Windows service.
```powershell
Restart-Service -Name Spooler
Restart-Service -Name Spooler -Force
```

---

## S

### Select-Object
Selects specific properties or a subset of objects. Alias: `select`.
```powershell
Get-Process | Select-Object Name, Id, CPU
Get-Process | Select-Object -First 5
Get-Process | Select-Object -Last 5
Get-Process | Select-Object -Skip 10 -First 5
Get-Process | Select-Object -ExpandProperty Name   # returns strings, not objects
Get-Process | Select-Object Name, @{Name='MB'; Expression={ [math]::Round($_.WorkingSet64/1MB,1) }}
```

### Select-String
Searches for text patterns in files or strings. Alias: `sls`.
```powershell
Select-String -Path .\*.log -Pattern "ERROR"
Get-Content .\file.txt | Select-String "warning" -CaseSensitive
Get-ChildItem .\src -Recurse -Filter *.ps1 | Select-String "TODO"
Select-String -Path .\*.log -Pattern "\d{4}-\d{2}-\d{2}" -AllMatches
```

### Set-Acl
Applies a security descriptor to an item.
```powershell
$acl = Get-Acl .\source
Set-Acl -Path .\destination -AclObject $acl
```

### Set-Content
Writes content to a file, replacing existing content.
```powershell
Set-Content .\file.txt "Hello, World!"
"Line 1","Line 2","Line 3" | Set-Content .\output.txt
```

### Set-ExecutionPolicy
Sets the PowerShell script execution policy.
```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
Set-ExecutionPolicy AllSigned   -Scope LocalMachine
```

### Set-Item
Sets the value of an item (commonly used with the registry provider).
```powershell
Set-Item HKCU:\Software\MyApp -Value "new value"
```

### Set-ItemProperty
Sets a property on an item.
```powershell
Set-ItemProperty HKCU:\Software\MyApp -Name Theme -Value "Dark"
Set-ItemProperty HKCU:\Software\MyApp -Name MaxItems -Value 100 -Type DWord
```

### Set-Location
Changes the current working directory. Aliases: `cd`, `sl`, `chdir`.
```powershell
Set-Location C:\Users
Set-Location ..
Set-Location ~
Set-Location HKCU:\Software
```

### Set-Service
Modifies the configuration of a Windows service.
```powershell
Set-Service -Name wuauserv -StartupType Disabled
Set-Service -Name wuauserv -Status Running -PassThru
```

### Set-StrictMode
Enables strict mode to catch common scripting errors.
```powershell
Set-StrictMode -Version Latest
```

### Set-Variable
Sets the value of a variable.
```powershell
Set-Variable -Name x -Value 42
Set-Variable -Name MAX -Value 100 -Option ReadOnly -Scope Global
```

### Sort-Object
Sorts pipeline objects by one or more properties. Alias: `sort`.
```powershell
Get-Process | Sort-Object CPU -Descending
Get-ChildItem | Sort-Object LastWriteTime
Get-Service | Sort-Object Status, DisplayName
Get-Process | Sort-Object CPU -Top 10   # efficient top-N (PS 6+)
```

### Split-Path
Returns a component of a file system path.
```powershell
Split-Path "C:\Users\Alice\file.txt" -Parent    # C:\Users\Alice
Split-Path "C:\Users\Alice\file.txt" -Leaf      # file.txt
Split-Path "C:\Users\Alice\file.txt" -Extension # .txt (PS 6+)
Split-Path "C:\Users\Alice\file.txt" -IsAbsolute # $true
```

### Start-Job
Starts a PowerShell command as a background job.
```powershell
$job = Start-Job -ScriptBlock { Get-Process | Sort-Object CPU -Descending }
Wait-Job $job
Receive-Job $job
Remove-Job $job
```

### Start-Process
Starts an application or process. Alias: `saps`.
```powershell
Start-Process notepad
Start-Process pwsh -Verb RunAs   # run as administrator
Start-Process msiexec -ArgumentList "/i .\app.msi /quiet" -Wait
Start-Process "https://docs.microsoft.com"   # open URL in browser
```

### Start-ScheduledTask
Runs a scheduled task immediately, on demand.
```powershell
Start-ScheduledTask -TaskName "DailyBackup"
```

### Start-Service
Starts a stopped Windows service.
```powershell
Start-Service -Name Spooler
Start-Service -DisplayName "Print Spooler"
```

### Start-Sleep
Suspends execution for the specified duration.
```powershell
Start-Sleep -Seconds 5
Start-Sleep -Milliseconds 500
Start-Sleep 3   # positional — seconds
```

### Start-Transcript
Records all session input and output to a file.
```powershell
Start-Transcript -Path .\session.log -Append
# ... run commands ...
Stop-Transcript
```

### Stop-Computer
Shuts down the local or a remote computer.
```powershell
Stop-Computer -Force
Stop-Computer -ComputerName server01
```

### Stop-Process
Terminates a running process. Aliases: `kill`, `spps`.
```powershell
Stop-Process -Name notepad
Stop-Process -Id 1234 -Force
Get-Process chrome | Stop-Process
```

### Stop-Service
Stops a running Windows service.
```powershell
Stop-Service -Name Spooler
Stop-Service -Name Spooler -Force
```

---

## T

### Tee-Object
Sends pipeline output to a file or variable AND passes it through.
```powershell
Get-Service | Tee-Object -FilePath .\services.txt | Measure-Object
Get-Process | Tee-Object -Variable procs | Where-Object CPU -gt 5
$procs.Count   # full set is in $procs
```

### Test-Connection
Sends ICMP echo requests (ping). Use `Test-NetConnection` for TCP port testing.
```powershell
Test-Connection google.com
Test-Connection 8.8.8.8 -Count 1 -Quiet   # $true / $false
Test-Connection server01,server02 -Count 1   # ping multiple
```

### Test-ModuleManifest
Validates a module manifest `.psd1` file.
```powershell
Test-ModuleManifest .\MyModule\MyModule.psd1
```

### Test-NetConnection
Tests network connectivity and optionally a TCP port.
```powershell
Test-NetConnection github.com -Port 443
(Test-NetConnection server01 -Port 3389).TcpTestSucceeded
Test-NetConnection google.com -TraceRoute
```

### Test-Path
Tests whether a path exists.
```powershell
Test-Path .\config.json                        # file or directory
Test-Path .\folder -PathType Container         # directory only
Test-Path .\file.txt -PathType Leaf            # file only
Test-Path HKCU:\Software\MyApp                 # registry key
```

### Test-WSMan
Tests WinRM connectivity to a remote computer.
```powershell
Test-WSMan -ComputerName server01
```

---

## U

### Uninstall-Module
Uninstalls a module from the current system.
```powershell
Uninstall-Module -Name OldModule
Uninstall-Module -Name MyModule -AllVersions
```

### Unregister-ScheduledTask
Removes a scheduled task from Task Scheduler.
```powershell
Unregister-ScheduledTask -TaskName "DailyBackup" -Confirm:$false
```

### Update-Help
Downloads and installs the latest help content for all installed modules.
```powershell
Update-Help
Update-Help -Module Microsoft.PowerShell.Management -Force
```

### Update-Module
Updates an installed module to the latest version from the Gallery.
```powershell
Update-Module -Name Pester
Update-Module   # update all installed modules
```

---

## W

### Wait-Job
Waits for one or more background jobs to finish.
```powershell
$job = Start-Job { Start-Sleep 5 }
Wait-Job $job
Receive-Job $job
```

### Where-Object
Filters objects by a condition. Aliases: `where`, `?`.
```powershell
Get-Service | Where-Object Status -eq Running
Get-Process | Where-Object { $_.CPU -gt 10 -and $_.Name -ne 'Idle' }
Get-ChildItem | Where-Object { $_.LastWriteTime -gt (Get-Date).AddDays(-7) }
```

### Write-Debug
Writes a debug message to the debug stream.
```powershell
Write-Debug "Entering loop iteration $i"
```

### Write-Error
Writes an error record to the error stream.
```powershell
Write-Error "Something went wrong"
Write-Error "File not found: $path" -Category ObjectNotFound
```

### Write-Host
Writes text directly to the console (not the pipeline).
```powershell
Write-Host "Hello!" -ForegroundColor Green
Write-Host "Warning" -ForegroundColor Yellow -BackgroundColor Black
```

!!! note
    `Write-Host` output cannot be captured to a variable. Use `Write-Output` for pipeline data.

### Write-Information
Writes a message to the information stream (stream 6).
```powershell
Write-Information "Config loaded successfully" -InformationAction Continue
```

### Write-Output
Writes objects to the success output stream (the pipeline). Alias: `echo`.
```powershell
Write-Output "Hello, World!"
Write-Output $result
```

### Write-Progress
Displays a progress bar in the console.
```powershell
for ($i = 1; $i -le 100; $i++) {
    Write-Progress -Activity "Processing files" -Status "$i% complete" -PercentComplete $i
    Start-Sleep -Milliseconds 50
}
Write-Progress -Activity "Processing files" -Completed
```

### Write-Verbose
Writes a verbose message (visible when `-Verbose` is used).
```powershell
Write-Verbose "Starting sync operation"
```

### Write-Warning
Writes a warning message to the warning stream.
```powershell
Write-Warning "Disk space is critically low"
```
