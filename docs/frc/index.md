# FRC PowerShell Automation

PowerShell for FRC teams — automate builds, connect to your robot, and troubleshoot faster. Pick a topic below to get started.

<div class="grid cards" markdown>

-   :material-robot-industrial:{ .lg .middle } **WPILib & GradleRIO**

    ---

    Build robot code, run toolchain installs, clean caches, and deploy — all from the terminal.

    [:octicons-arrow-right-24: WPILib dev tasks](wpilib-dev.md)

-   :material-lan-connect:{ .lg .middle } **roboRIO Utilities**

    ---

    SSH into your roboRIO, copy files with SCP, install IPK packages, and pull logs.

    [:octicons-arrow-right-24: roboRIO utilities](roborio.md)

-   :material-wifi:{ .lg .middle } **Robot Networking**

    ---

    Ping the robot, resolve mDNS names, check firewall rules, and run competition-day pre-checks.

    [:octicons-arrow-right-24: Networking](networking.md)

-   :material-wrench:{ .lg .middle } **Troubleshooting**

    ---

    Fix `JAVA_HOME`, clear Gradle caches, reinstall toolchains, and diagnose Driver Station issues.

    [:octicons-arrow-right-24: Troubleshooting](troubleshooting.md)

-   :material-package-variant:{ .lg .middle } **FrcTools Module**

    ---

    A ready-to-import PowerShell module with all FRC helper functions packaged in one place.

    [:octicons-arrow-right-24: FrcTools module](frctools.md)

</div>

---

## Why PowerShell for FRC?

Most FRC teams develop on Windows, and PowerShell 7 ships built-in. Using PowerShell gives you:

- **One language for everything** — the same shell that manages Windows services can also SSH into your roboRIO, invoke Gradle builds, and parse telemetry logs.
- **Scripted competition-day prep** — verify network settings, ping the robot, and pre-check driver station configuration in a single script.
- **Reusable functions** — wrap complex `ssh`/`scp` one-liners into clearly-named functions any team member can run safely.

!!! tip "Team number format"
    Throughout these docs, **`####`** stands for your four-digit FRC team number. Replace it with your actual number wherever you see it — for example, team 9999 uses `roboRIO-9999-FRC.local` and IP `10.99.99.2`.
