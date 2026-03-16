# Installing PowerShell

PowerShell 7+ is available on Windows, macOS, and Linux. Choose your platform below.

---

## Windows

=== "MSI Installer (recommended)"

    1. Go to the [PowerShell releases page](https://github.com/PowerShell/PowerShell/releases/latest)
    2. Download the `.msi` file for your architecture (x64 for most systems)
    3. Run the installer and follow the prompts
    4. Open **Windows Terminal** or search for **PowerShell 7** in the Start menu

=== "winget"

    ```powershell
    winget install Microsoft.PowerShell
    ```

=== "Scoop"

    ```powershell
    scoop install pwsh
    ```

=== "Chocolatey"

    ```powershell
    choco install powershell-core
    ```

!!! note "Windows PowerShell vs PowerShell 7"
    Windows still ships with **Windows PowerShell 5.1** (`powershell.exe`). PowerShell 7+ installs *alongside* it as `pwsh.exe` — they do not replace each other.

---

## macOS

=== "Homebrew (recommended)"

    ```bash
    brew install --cask powershell
    pwsh   # launch
    ```

=== "Direct download"

    Download the `.pkg` file from the [releases page](https://github.com/PowerShell/PowerShell/releases/latest) and run it.

---

## Linux

=== "Ubuntu / Debian"

    ```bash
    # Register the Microsoft repository
    wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb"
    sudo dpkg -i packages-microsoft-prod.deb

    sudo apt-get update
    sudo apt-get install -y powershell

    pwsh   # launch
    ```

=== "Fedora / RHEL"

    ```bash
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    sudo dnf install -y powershell
    ```

=== "Snap"

    ```bash
    sudo snap install powershell --classic
    ```

=== "Docker"

    ```bash
    docker run -it mcr.microsoft.com/powershell
    ```

---

## Verify Your Installation

After installing, confirm the version:

```powershell
$PSVersionTable
```

Expected output (version numbers will vary):

```
Name                           Value
----                           -----
PSVersion                      7.5.0
PSEdition                      Core
GitCommitId                    7.5.0
OS                             Microsoft Windows 10.0.22621
Platform                       Win32NT
PSCompatibleVersions           {1.0, 2.0, 3.0, 4.0…}
PSRemotingProtocolVersion      2.3
SerializationVersion           1.1.0.1
WSManStackVersion              3.0
```

---

## Setting Up the Execution Policy (Windows)

On Windows, scripts are blocked by default. Allow locally-written scripts to run:

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

| Policy | What it allows |
|--------|---------------|
| `Restricted` | No scripts at all (default on Windows) |
| `AllSigned` | Only code-signed scripts |
| `RemoteSigned` | Local scripts + signed remote scripts |
| `Unrestricted` | All scripts (not recommended) |
| `Bypass` | Nothing blocked — use only in pipelines |

---

## Recommended Tools

| Tool | Purpose |
|------|---------|
| [VS Code](https://code.visualstudio.com/) + [PowerShell Extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode.PowerShell) | Best editor with IntelliSense, debugging, and integrated terminal |
| [Windows Terminal](https://aka.ms/terminal) | Modern tabbed terminal that works great with `pwsh` |
| [PSReadLine](https://github.com/PowerShell/PSReadLine) | Included in PS 7 — syntax highlighting and predictive IntelliSense in the console |
| [oh-my-posh](https://ohmyposh.dev/) | Beautiful prompt themes |
| [posh-git](https://github.com/dahlbyk/posh-git) | Git status in your prompt |

---

## Next Step

[:octicons-arrow-right-24: Your First Commands](first-commands.md)
