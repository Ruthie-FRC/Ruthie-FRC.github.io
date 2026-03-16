# WPILib & GradleRIO Developer Tasks

This page covers PowerShell workflows for building robot code, running WPILib Gradle tasks, and managing toolchains on Windows.

---

## Prerequisites

WPILib requires **JDK 17** and the WPILib installer places its own JDK under `C:\Users\Public\wpilib\<year>\jdk`. If you installed the WPILib VS Code bundle, the Gradle wrapper (`gradlew.bat`) in your robot project will use that JDK automatically.

```powershell
# Check which Java is on PATH
java -version

# Check the WPILib-managed JDK (adjust year as needed)
& "C:\Users\Public\wpilib\2025\jdk\bin\java.exe" -version

# Set JAVA_HOME to the WPILib JDK for this session
$env:JAVA_HOME = "C:\Users\Public\wpilib\2025\jdk"
$env:PATH = "$env:JAVA_HOME\bin;$env:PATH"
```

---

## Building Robot Code

Navigate to your robot project directory (the one containing `gradlew.bat`), then run any of the tasks below.

```powershell
# Move into your project
Set-Location "C:\Users\YourName\robot-project"

# Build everything (compile + simulate checks)
.\gradlew build

# Compile Java only (faster during development)
.\gradlew compileJava

# Run all unit tests
.\gradlew test

# Deploy to the roboRIO over USB or Ethernet
.\gradlew deploy

# Deploy and open the console output (riolog)
.\gradlew deploy --info
```

!!! tip "Speed up rebuilds"
    Add `--parallel` and `--build-cache` to most tasks to take advantage of Gradle's incremental build cache:
    ```powershell
    .\gradlew build --parallel --build-cache
    ```

---

## Toolchain Install Tasks

WPILib uses GradleRIO to manage the cross-compiler toolchain for the roboRIO (an ARM Linux target). Use these tasks to install or refresh the toolchain.

```powershell
# Install the roboRIO toolchain
.\gradlew installRoboRioToolchain

# Install the desktop toolchain (for simulation)
.\gradlew installDesktopToolchain

# Install all toolchains at once
.\gradlew installAllToolchains

# Check which toolchain versions are currently installed
.\gradlew toolchainDownloads
```

---

## GradleRIO Version Management

GradleRIO is declared in `build.gradle` (or `build.gradle.kts`) as a plugin version. You can inspect and update it from the terminal.

```powershell
# Display the current GradleRIO plugin version used in the project
Select-String -Path build.gradle -Pattern 'edu.wpi.first.GradleRIO'

# Grep recursively if you have sub-projects
Get-ChildItem -Recurse -Filter build.gradle |
    Select-String 'edu.wpi.first.GradleRIO'
```

To use a **development (snapshot) build** of WPILib, add the development Maven repository to your `build.gradle` and change the GradleRIO version to the desired snapshot, then re-run the build.

---

## Running Common Gradle Tasks via Helper Function

The `FrcTools` module (see [FrcTools module page](frctools.md)) includes `Invoke-WpilibGradle`, which wraps `.\gradlew` with friendlier error output:

```powershell
Import-Module .\scripts\frc\FrcTools.psm1

# Run any Gradle task
Invoke-WpilibGradle build
Invoke-WpilibGradle compileJava
Invoke-WpilibGradle deploy

# Pass extra flags
Invoke-WpilibGradle build --parallel --build-cache
```

If Gradle exits with a non-zero code, `Invoke-WpilibGradle` prints a diagnostic hint instead of silently failing.

---

## Cleaning the Build

```powershell
# Delete the build output directory
.\gradlew clean

# Delete the Gradle caches for this project (forces full re-download)
.\gradlew clean --refresh-dependencies

# Nuclear option — wipe the global Gradle cache (see Troubleshooting)
Remove-Item -Recurse -Force "$HOME\.gradle\caches"
```

!!! warning "Clearing the global cache"
    Removing `$HOME\.gradle\caches` forces Gradle to re-download **all** dependencies on the next build. Only do this if you are diagnosing a corrupted cache.

---

## Checking Gradle Wrapper Integrity

```powershell
# Show the Gradle wrapper version declared in the project
.\gradlew --version

# Verify the wrapper JAR checksum matches gradle-wrapper.properties
$props = Get-Content .\gradle\wrapper\gradle-wrapper.properties -Raw
if ($props -match 'distributionSha256Sum=([a-f0-9]+)') {
    $expected = $Matches[1]
    $actual   = (Get-FileHash .\gradle\wrapper\gradle-wrapper.jar -Algorithm SHA256).Hash.ToLower()
    if ($expected -eq $actual) { Write-Host "Checksum OK" -ForegroundColor Green }
    else                       { Write-Warning "Checksum MISMATCH — wrapper may be tampered with!" }
}
```

---

## Practical: One-Line Build & Deploy

```powershell
# Build and immediately deploy if build succeeds
.\gradlew build && .\gradlew deploy
```

---

## Practical: Watch for Build Errors in CI Output

```powershell
# Capture Gradle output and highlight errors
$output = .\gradlew build 2>&1
$output | Where-Object { $_ -match 'error:|FAILED|Exception' } |
    ForEach-Object { Write-Host $_ -ForegroundColor Red }
if ($LASTEXITCODE -ne 0) {
    Write-Error "Build failed with exit code $LASTEXITCODE"
}
```
