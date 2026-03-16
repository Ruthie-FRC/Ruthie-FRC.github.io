#Requires -Version 7.0
<#
.SYNOPSIS
    FRC (FIRST Robotics Competition) PowerShell helpers for robot development and competition-day tasks.

.DESCRIPTION
    FrcTools provides functions for:
    - Checking robot network connectivity (Test-FrcRobotConnection)
    - Opening SSH sessions to the roboRIO (Connect-RoboRioSsh)
    - Transferring files via SCP (Copy-ToRoboRio, Copy-FromRoboRio)
    - Installing IPK packages on the roboRIO (Install-RoboRioJreIpk)
    - Collecting roboRIO logs (Get-RoboRioLogs)
    - Running WPILib Gradle tasks with friendly output (Invoke-WpilibGradle)

.NOTES
    Requires ssh.exe and scp.exe on PATH (provided by OpenSSH, which ships with Windows 10/11).
    Replace '####' with your four-digit FRC team number wherever the team number is used.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

#region Internal helpers

function script:Get-RioAddress {
    <#
    .SYNOPSIS
        Returns the roboRIO hostname, fixed IP, or USB address for a given team number.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateRange(1, 9999)]
        [int] $TeamNumber,

        [ValidateSet('mDNS', 'IP', 'USB')]
        [string] $Method = 'mDNS'
    )

    switch ($Method) {
        'mDNS' { return "roboRIO-$TeamNumber-FRC.local" }
        'IP'   {
            $hi = [int]($TeamNumber / 100)
            $lo = $TeamNumber % 100
            return "10.$hi.$lo.2"
        }
        'USB'  { return '172.22.11.2' }
    }
}

function script:Assert-SshAvailable {
    if (-not (Get-Command ssh -ErrorAction SilentlyContinue)) {
        throw ("ssh.exe not found on PATH. Install OpenSSH: " +
               "Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0")
    }
}

function script:Assert-ScpAvailable {
    if (-not (Get-Command scp -ErrorAction SilentlyContinue)) {
        throw ("scp.exe not found on PATH. Install OpenSSH: " +
               "Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0")
    }
}

#endregion

#region Public functions

function Test-FrcRobotConnection {
    <#
    .SYNOPSIS
        Tests all common connection methods to the roboRIO and reports which ones succeed.

    .PARAMETER TeamNumber
        Your four-digit FRC team number (e.g., 9999).

    .EXAMPLE
        Test-FrcRobotConnection -TeamNumber 9999
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateRange(1, 9999)]
        [int] $TeamNumber
    )

    $results = foreach ($method in @('mDNS', 'IP', 'USB')) {
        $addr = script:Get-RioAddress -TeamNumber $TeamNumber -Method $method
        $ok   = Test-Connection $addr -Count 1 -Quiet -TimeoutSeconds 2 `
                    -ErrorAction SilentlyContinue
        [PSCustomObject]@{
            Method    = $method
            Address   = $addr
            Reachable = [bool]$ok
        }
    }

    $results | Format-Table -AutoSize
    return $results
}

function Connect-RoboRioSsh {
    <#
    .SYNOPSIS
        Opens an SSH session (or runs a single command) on the roboRIO.

    .PARAMETER TeamNumber
        Your four-digit FRC team number.

    .PARAMETER Method
        Address method: mDNS (default), IP, or USB.

    .PARAMETER Command
        Optional remote command to run non-interactively. If omitted, an interactive
        shell session is opened.

    .EXAMPLE
        Connect-RoboRioSsh -TeamNumber 9999

    .EXAMPLE
        Connect-RoboRioSsh -TeamNumber 9999 -Command "df -h"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateRange(1, 9999)]
        [int] $TeamNumber,

        [ValidateSet('mDNS', 'IP', 'USB')]
        [string] $Method = 'mDNS',

        [string] $Command
    )

    script:Assert-SshAvailable

    $addr = script:Get-RioAddress -TeamNumber $TeamNumber -Method $Method
    Write-Verbose "Connecting to $addr via SSH..."

    if ($Command) {
        ssh "admin@$addr" $Command
    }
    else {
        ssh "admin@$addr"
    }
}

function Copy-ToRoboRio {
    <#
    .SYNOPSIS
        Copies one or more local files to the roboRIO using SCP.

    .PARAMETER TeamNumber
        Your four-digit FRC team number.

    .PARAMETER LocalPath
        Path to the local file or directory to copy. Paths with spaces are handled correctly.

    .PARAMETER RemotePath
        Destination path on the roboRIO (e.g., /tmp/frcjre.ipk).

    .PARAMETER Method
        Address method: mDNS (default), IP, or USB.

    .EXAMPLE
        Copy-ToRoboRio -TeamNumber 9999 -LocalPath .\frcjre.ipk -RemotePath /tmp/frcjre.ipk
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [ValidateRange(1, 9999)]
        [int] $TeamNumber,

        [Parameter(Mandatory)]
        [string] $LocalPath,

        [Parameter(Mandatory)]
        [string] $RemotePath,

        [ValidateSet('mDNS', 'IP', 'USB')]
        [string] $Method = 'mDNS'
    )

    script:Assert-ScpAvailable

    $resolved = (Resolve-Path -LiteralPath $LocalPath -ErrorAction Stop).Path
    $addr     = script:Get-RioAddress -TeamNumber $TeamNumber -Method $Method
    $dest     = "admin@${addr}:${RemotePath}"

    if ($PSCmdlet.ShouldProcess($dest, "SCP copy '$resolved'")) {
        Write-Verbose "Copying '$resolved' to $dest ..."
        scp -- $resolved $dest
        if ($LASTEXITCODE -ne 0) {
            throw "scp exited with code $LASTEXITCODE. Check that the roboRIO is reachable."
        }
    }
}

function Copy-FromRoboRio {
    <#
    .SYNOPSIS
        Copies a file from the roboRIO to the local machine using SCP.

    .PARAMETER TeamNumber
        Your four-digit FRC team number.

    .PARAMETER RemotePath
        Path of the file on the roboRIO (e.g., /var/log/ni-rt.log).

    .PARAMETER LocalPath
        Local destination path (file or directory).

    .PARAMETER Method
        Address method: mDNS (default), IP, or USB.

    .EXAMPLE
        Copy-FromRoboRio -TeamNumber 9999 -RemotePath /var/log/ni-rt.log -LocalPath .\ni-rt.log
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [ValidateRange(1, 9999)]
        [int] $TeamNumber,

        [Parameter(Mandatory)]
        [string] $RemotePath,

        [Parameter(Mandatory)]
        [string] $LocalPath,

        [ValidateSet('mDNS', 'IP', 'USB')]
        [string] $Method = 'mDNS'
    )

    script:Assert-ScpAvailable

    $addr = script:Get-RioAddress -TeamNumber $TeamNumber -Method $Method
    $src  = "admin@${addr}:${RemotePath}"

    if ($PSCmdlet.ShouldProcess($LocalPath, "SCP copy from '$src'")) {
        Write-Verbose "Copying '$src' to '$LocalPath' ..."
        scp -- $src $LocalPath
        if ($LASTEXITCODE -ne 0) {
            throw "scp exited with code $LASTEXITCODE. Check that the roboRIO is reachable."
        }
    }
}

function Install-RoboRioJreIpk {
    <#
    .SYNOPSIS
        Copies a JRE IPK file to the roboRIO, installs it with opkg, then removes the temp file.

    .DESCRIPTION
        Inspired by the allwpilib test-scripts README workflow:
          scp <local path> admin@roboRIO-####-FRC.local:/tmp/frcjre.ipk
          ssh admin@roboRIO-####-FRC.local "opkg install /tmp/frcjre.ipk"
          ssh admin@roboRIO-####-FRC.local "rm /tmp/frcjre.ipk"

    .PARAMETER TeamNumber
        Your four-digit FRC team number.

    .PARAMETER IpkPath
        Local path to the JRE IPK file.

    .PARAMETER Method
        Address method: mDNS (default), IP, or USB.

    .EXAMPLE
        Install-RoboRioJreIpk -TeamNumber 9999 -IpkPath "C:\Users\me\frcjre.ipk"
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [ValidateRange(1, 9999)]
        [int] $TeamNumber,

        [Parameter(Mandatory)]
        [string] $IpkPath,

        [ValidateSet('mDNS', 'IP', 'USB')]
        [string] $Method = 'mDNS'
    )

    script:Assert-SshAvailable
    script:Assert-ScpAvailable

    $resolved = (Resolve-Path -LiteralPath $IpkPath -ErrorAction Stop).Path
    $addr     = script:Get-RioAddress -TeamNumber $TeamNumber -Method $Method
    $tmpPath  = '/tmp/frcjre.ipk'

    if (-not $PSCmdlet.ShouldProcess("roboRIO-$TeamNumber", "Install JRE IPK '$resolved'")) {
        return
    }

    Write-Host "Step 1/3  Copying IPK to roboRIO..." -ForegroundColor Cyan
    scp -- $resolved "admin@${addr}:${tmpPath}"
    if ($LASTEXITCODE -ne 0) { throw "SCP failed with exit code $LASTEXITCODE." }

    Write-Host "Step 2/3  Installing IPK with opkg..." -ForegroundColor Cyan
    ssh "admin@$addr" "opkg install $tmpPath"
    if ($LASTEXITCODE -ne 0) { throw "opkg install failed with exit code $LASTEXITCODE." }

    Write-Host "Step 3/3  Removing temporary file..." -ForegroundColor Cyan
    ssh "admin@$addr" "rm -f $tmpPath"
    if ($LASTEXITCODE -ne 0) { Write-Warning "Could not remove $tmpPath — please clean up manually." }

    Write-Host "JRE installation complete." -ForegroundColor Green
}

function Get-RoboRioLogs {
    <#
    .SYNOPSIS
        Downloads roboRIO log files to a local directory.

    .PARAMETER TeamNumber
        Your four-digit FRC team number.

    .PARAMETER OutputDirectory
        Local root directory where logs are saved. A sub-folder named with today's date
        is created automatically (e.g., .\logs\2025-06-01\).

    .PARAMETER Method
        Address method: mDNS (default), IP, or USB.

    .EXAMPLE
        Get-RoboRioLogs -TeamNumber 9999 -OutputDirectory .\logs
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateRange(1, 9999)]
        [int] $TeamNumber,

        [string] $OutputDirectory = '.\logs',

        [ValidateSet('mDNS', 'IP', 'USB')]
        [string] $Method = 'mDNS'
    )

    script:Assert-ScpAvailable

    $addr   = script:Get-RioAddress -TeamNumber $TeamNumber -Method $Method
    $today  = (Get-Date -Format 'yyyy-MM-dd')
    $logDir = Join-Path $OutputDirectory $today
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null

    $patterns = @('*.wpilog', '*.dslog', '*.dsevents')
    $any      = $false

    foreach ($pat in $patterns) {
        Write-Verbose "Fetching $pat from $addr ..."
        $result = scp "admin@${addr}:/home/lvuser/$pat" $logDir 2>&1
        if ($LASTEXITCODE -eq 0) { $any = $true }
    }

    if ($any) {
        $files = Get-ChildItem $logDir
        Write-Host "Logs saved to '$logDir' ($($files.Count) file(s))." -ForegroundColor Green
        $files | Select-Object Name, @{N='Size (KB)'; E={ [Math]::Round($_.Length / 1KB, 1) }}, LastWriteTime |
            Format-Table -AutoSize
    }
    else {
        Write-Warning "No log files found on the roboRIO at /home/lvuser/."
    }
}

function Invoke-WpilibGradle {
    <#
    .SYNOPSIS
        Runs a Gradle task via the project's Gradle wrapper (gradlew.bat / gradlew) and
        prints a friendly error message if the task fails.

    .PARAMETER Task
        One or more Gradle task names (e.g., 'build', 'deploy', 'compileJava').

    .PARAMETER ExtraArgs
        Additional arguments forwarded to the Gradle wrapper (e.g., '--parallel', '--info').

    .PARAMETER ProjectDir
        Path to the Gradle project directory. Defaults to the current directory.

    .EXAMPLE
        Invoke-WpilibGradle build

    .EXAMPLE
        Invoke-WpilibGradle deploy --info

    .EXAMPLE
        Invoke-WpilibGradle build --parallel --build-cache
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string[]] $Task,

        [Parameter(ValueFromRemainingArguments)]
        [string[]] $ExtraArgs,

        [string] $ProjectDir = '.'
    )

    $gradleScript = if ($IsWindows -or $env:OS -eq 'Windows_NT') { 'gradlew.bat' } else { './gradlew' }
    $wrapper      = Join-Path (Resolve-Path $ProjectDir) $gradleScript

    if (-not (Test-Path $wrapper)) {
        throw "Gradle wrapper not found at '$wrapper'. Are you in the robot project directory?"
    }

    $allArgs = $Task + $ExtraArgs
    Write-Host "Running: $gradleScript $allArgs" -ForegroundColor Cyan

    & $wrapper @allArgs
    $exit = $LASTEXITCODE

    if ($exit -ne 0) {
        Write-Host ""
        Write-Host "Gradle task '$($Task -join ' ')' FAILED (exit code $exit)." -ForegroundColor Red
        Write-Host "Common causes:" -ForegroundColor Yellow
        Write-Host "  - JAVA_HOME not set to JDK 17 (run: Set JAVA_HOME to WPILib JDK)" -ForegroundColor Yellow
        Write-Host "  - Toolchain not installed (run: .\gradlew installRoboRioToolchain)" -ForegroundColor Yellow
        Write-Host "  - Corrupt Gradle cache (run: .\gradlew $($Task -join ' ') --refresh-dependencies)" -ForegroundColor Yellow
        Write-Host "  - roboRIO unreachable for deploy tasks (run: Test-FrcRobotConnection)" -ForegroundColor Yellow
        throw "Gradle exited with code $exit."
    }

    Write-Host "Gradle task '$($Task -join ' ')' completed successfully." -ForegroundColor Green
}

#endregion

Export-ModuleMember -Function @(
    'Test-FrcRobotConnection'
    'Connect-RoboRioSsh'
    'Copy-ToRoboRio'
    'Copy-FromRoboRio'
    'Install-RoboRioJreIpk'
    'Get-RoboRioLogs'
    'Invoke-WpilibGradle'
)
