# File System Management

PowerShell's FileSystem provider gives you a rich, object-based interface for working with files and directories.

---

## Navigating

```powershell
# Where am I?
Get-Location              # or: pwd

# Change directory
Set-Location C:\Users     # or: cd C:\Users
Set-Location ..           # up one level
Set-Location ~            # home directory
Set-Location -            # previous location (like cd -)

# List contents
Get-ChildItem             # or: ls, dir
Get-ChildItem -Force      # include hidden and system files
Get-ChildItem -Directory  # only folders
Get-ChildItem -File       # only files
Get-ChildItem -Name       # names only (strings instead of objects)
```

---

## Listing Files

```powershell
# Find all .log files recursively
Get-ChildItem C:\Logs -Filter *.log -Recurse

# Find files modified in the last 24 hours
Get-ChildItem C:\Logs -Recurse |
    Where-Object { $_.LastWriteTime -gt (Get-Date).AddHours(-24) }

# Find files larger than 100 MB
Get-ChildItem C:\ -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object { $_.Length -gt 100MB }

# Find empty files
Get-ChildItem . -File | Where-Object Length -eq 0

# Get the 10 largest files on a drive
Get-ChildItem C:\ -Recurse -File -ErrorAction SilentlyContinue |
    Sort-Object Length -Descending |
    Select-Object -First 10 FullName,
        @{Name='MB'; Expression={ [math]::Round($_.Length/1MB,1) }}
```

---

## Creating Files and Directories

```powershell
# Create a file
New-Item -Path .\notes.txt -ItemType File

# Create a file with content
New-Item -Path .\hello.txt -ItemType File -Value "Hello, World!"

# Create a directory
New-Item -Path .\MyFolder -ItemType Directory
# or the traditional way:
mkdir .\MyFolder

# Create nested directories
New-Item -Path .\a\b\c -ItemType Directory -Force

# Create a symbolic link
New-Item -ItemType SymbolicLink -Path .\link -Target C:\ActualPath
```

---

## Reading Files

```powershell
# Read all lines (returns string array)
$lines = Get-Content .\data.txt

# Read as a single string
$raw = Get-Content .\data.json -Raw

# Read just the first 10 lines
Get-Content .\big.log -TotalCount 10

# Read the last 20 lines (like tail)
Get-Content .\big.log -Tail 20

# Watch a log file (like tail -f)
Get-Content .\app.log -Tail 20 -Wait

# Read a specific encoding
Get-Content .\legacy.txt -Encoding Default
```

---

## Writing Files

```powershell
# Overwrite with new content
Set-Content .\output.txt "New content"
"Line one","Line two","Line three" | Set-Content .\file.txt

# Append to a file
Add-Content .\log.txt "Entry at $(Get-Date)"

# Write pipeline output (formatted text)
Get-Process | Out-File .\procs.txt

# Redirect operators
Get-Process > .\procs.txt       # overwrite
Get-Process >> .\procs.txt      # append
```

---

## Copying, Moving, Renaming

```powershell
# Copy a single file
Copy-Item .\source.txt .\backup.txt

# Copy a directory recursively
Copy-Item .\src -Destination .\dst -Recurse

# Copy multiple files (wildcard)
Copy-Item C:\Logs\*.log D:\Archive\

# Move (also renames)
Move-Item .\old-name.txt .\new-name.txt
Move-Item .\file.txt C:\Archive\

# Rename without moving
Rename-Item .\draft.docx .\final.docx

# Bulk rename (add prefix)
Get-ChildItem .\images\*.jpg |
    Rename-Item -NewName { "2024_" + $_.Name }
```

---

## Deleting Files

```powershell
# Delete a file
Remove-Item .\temp.txt

# Delete a directory and all contents
Remove-Item .\TempFolder -Recurse

# Force-delete read-only files
Remove-Item .\locked.txt -Force

# Delete multiple by wildcard
Remove-Item .\logs\*.tmp

# Preview before deleting (-WhatIf)
Remove-Item .\logs\* -WhatIf

# Delete files older than 30 days
Get-ChildItem C:\Logs\*.log |
    Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-30) } |
    Remove-Item
```

---

## Working with Paths

```powershell
# Check if a path exists
Test-Path .\config.json            # file or directory?
Test-Path .\folder -PathType Container  # directory only
Test-Path .\file.txt -PathType Leaf    # file only

# Combine paths safely (handles separators)
Join-Path C:\Users $env:USERNAME "Documents"

# Split a path
Split-Path -Path "C:\Users\Alice\file.txt" -Parent   # C:\Users\Alice
Split-Path -Path "C:\Users\Alice\file.txt" -Leaf     # file.txt
Split-Path -Path "C:\Users\Alice\file.txt" -Extension # .txt (PS 6+)

# Resolve to absolute path
Resolve-Path .\relative\path.txt

# Convert to absolute without requiring existence
$absolute = [System.IO.Path]::GetFullPath(".\relative")
```

---

## File Attributes and Metadata

```powershell
$file = Get-Item .\README.md
$file.Length          # size in bytes
$file.CreationTime    # DateTime
$file.LastWriteTime   # DateTime
$file.LastAccessTime  # DateTime
$file.Extension       # ".md"
$file.BaseName        # "README"
$file.DirectoryName   # parent directory
$file.Attributes      # ReadOnly, Hidden, Archive, etc.

# Make a file hidden
$file.Attributes = $file.Attributes -bor [System.IO.FileAttributes]::Hidden

# Get total size of a directory
$size = (Get-ChildItem C:\Windows -Recurse -ErrorAction SilentlyContinue |
    Measure-Object Length -Sum).Sum
"{0:N1} GB" -f ($size / 1GB)
```

---

## Zip Archives (PS 5+)

```powershell
# Compress a folder
Compress-Archive -Path .\MyFolder -DestinationPath .\MyFolder.zip

# Add to an existing archive
Compress-Archive -Path .\newfile.txt -DestinationPath .\MyFolder.zip -Update

# Extract
Expand-Archive -Path .\MyFolder.zip -DestinationPath .\Extracted

# Overwrite existing extraction
Expand-Archive .\archive.zip .\output -Force
```

---

## Practical Recipes

### Find and replace text across files

```powershell
Get-ChildItem .\src -Filter *.ps1 -Recurse |
    ForEach-Object {
        $content = Get-Content $_.FullName -Raw
        if ($content -match 'oldFunctionName') {
            $new = $content -replace 'oldFunctionName', 'newFunctionName'
            Set-Content $_.FullName $new
            Write-Host "Updated $($_.Name)"
        }
    }
```

### Backup files before editing

```powershell
function Backup-File {
    param([string]$Path)
    $backup = "$Path.bak"
    Copy-Item $Path $backup
    Write-Verbose "Backed up to $backup"
}
```

### Sync two directories (one-way copy)

```powershell
$src = "C:\Source"
$dst = "D:\Backup"

Get-ChildItem $src -Recurse | ForEach-Object {
    $target = $_.FullName -replace [regex]::Escape($src), $dst
    if (-not (Test-Path $target) -or
        $_.LastWriteTime -gt (Get-Item $target).LastWriteTime) {
        Copy-Item $_.FullName $target -Force
        Write-Host "Copied: $($_.Name)"
    }
}
```

