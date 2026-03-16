# FRC PowerShell Automation

PowerShell is a built-in, cross-platform shell that FRC teams can use to automate the repetitive parts of robot development and competition-day prep — from Gradle builds to roboRIO SSH sessions to network diagnostics. Everything in this section runs on the same Windows machines your team already uses.

Use the navigation on the left to jump to any topic, or read on for a quick overview and a connect-to-robot example.

---

## What's in this section

| Page | What it covers |
|------|---------------|
| [WPILib & GradleRIO](wpilib-dev.md) | Build robot code, run toolchain installs, clean caches, and deploy from the terminal |
| [roboRIO Utilities](roborio.md) | SSH into your roboRIO, copy files with SCP, install IPK packages, and pull logs |
| [Robot Networking](networking.md) | Ping the robot, resolve mDNS names, check firewall rules, and run competition-day pre-checks |
| [Troubleshooting](troubleshooting.md) | Fix `JAVA_HOME`, clear Gradle caches, reinstall toolchains, diagnose Driver Station issues |
| [FrcTools Module](frctools.md) | A ready-to-import module that packages all helper functions in one place |

---

## Quick-start: connect to your robot

```powershell
# Test whether the roboRIO is reachable (replace 9999 with your team number)
Test-Connection roboRIO-9999-FRC.local -Count 1 -Quiet

# Open an interactive SSH session
ssh admin@roboRIO-9999-FRC.local

# Or use the fixed IP (10.TE.AM.2 format)
ssh admin@10.99.99.2
```

---

## Why PowerShell for FRC?

Most FRC teams develop on Windows, and PowerShell 7 ships built-in. Using PowerShell gives you:

- **One language for everything** — the same shell that manages Windows services can also SSH into your roboRIO, invoke Gradle builds, and parse telemetry logs.
- **Scripted competition-day prep** — verify network settings, ping the robot, and pre-check driver station configuration in a single script.
- **Reusable functions** — wrap complex `ssh`/`scp` one-liners into clearly-named functions any team member can run safely.

!!! tip "Team number format"
    Throughout these docs, **`####`** stands for your four-digit FRC team number. Replace it with your actual number wherever you see it — for example, team 9999 uses `roboRIO-9999-FRC.local` and IP `10.99.99.2`.
