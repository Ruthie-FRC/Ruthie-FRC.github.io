# Welcome to the PowerShell Encyclopedia

<div class="grid cards" markdown>

-   :material-console:{ .lg .middle } **Getting Started**

    ---

    New to PowerShell? Start here — installation, first commands, and the pipeline explained.

    [:octicons-arrow-right-24: Get started](getting-started/what-is-powershell.md)

-   :material-book-open-variant:{ .lg .middle } **Core Concepts**

    ---

    Master variables, data types, control flow, functions, error handling, and modules.

    [:octicons-arrow-right-24: Explore concepts](concepts/variables.md)

-   :material-map:{ .lg .middle } **Guides**

    ---

    Task-focused walkthroughs for filesystem, networking, processes, the registry, and more.

    [:octicons-arrow-right-24: Browse guides](guides/filesystem.md)

-   :material-pencil:{ .lg .middle } **Write Your Own Commands**

    ---

    Learn to create functions, script modules, and publish to the PowerShell Gallery.

    [:octicons-arrow-right-24: Start authoring](authoring/functions.md)

-   :material-book-alphabet:{ .lg .middle } **Command Reference**

    ---

    A-Z reference of 60+ cmdlets with syntax, parameters, and examples.

    [:octicons-arrow-right-24: Open reference](command-reference.md)

-   :material-flask:{ .lg .middle } **Examples & Recipes**

    ---

    Ready-to-run scripts for real-world tasks, from log analysis to system auditing.

    [:octicons-arrow-right-24: See examples](examples.md)

-   :material-source-pull:{ .lg .middle } **Contributing**

    ---

    Fix a typo, improve an example, or write a new guide. All contributions are welcome.

    [:octicons-arrow-right-24: How to contribute](contributing.md)

-   :octicons-issue-opened-16:{ .lg .middle } **Suggest a Change**

    ---

    Found an error, missing cmdlet, or have an idea for a new topic? Open an issue — no coding required.

    [:octicons-arrow-right-24: Open an issue](https://github.com/Ruthie-FRC/Powershell-Commands/issues/new/choose)

</div>

---

## Why PowerShell?

PowerShell is a cross-platform automation and configuration management framework built on **.NET**. It runs on Windows, macOS, and Linux, and it is the standard tool for:

- **System administration** — manage services, processes, users, the registry, and scheduled tasks
- **DevOps & CI/CD** — automate builds, deployments, and infrastructure provisioning
- **Security** — audit event logs, enforce policies, and manage certificates
- **Data processing** — parse CSV, JSON, and XML files; query REST APIs; generate reports

Unlike traditional shells that pass plain text between commands, PowerShell passes **rich .NET objects**. Every cmdlet in the pipeline receives structured data, which you can filter, sort, format, and transform without ever parsing a string.

---

## Quick-Start Examples

```powershell title="Your first five commands"
# Show all running processes sorted by CPU usage
Get-Process | Sort-Object CPU -Descending | Select-Object -First 10

# Find all .log files modified in the last 24 hours
Get-ChildItem C:\ -Recurse -Filter *.log |
    Where-Object { $_.LastWriteTime -gt (Get-Date).AddHours(-24) }

# Check if a TCP port is open
(Test-NetConnection github.com -Port 443).TcpTestSucceeded

# Call a REST API and parse the JSON response
$user = Invoke-RestMethod https://api.github.com/users/octocat
$user.name

# Export a list of running services to CSV
Get-Service | Where-Object Status -eq Running |
    Export-Csv -Path .\services.csv -NoTypeInformation
```

---

## How This Encyclopedia is Organized

| Section | What's Inside |
|---------|--------------|
| **Getting Started** | Installation, shell basics, the object pipeline |
| **Core Concepts** | Variables, types, operators, loops, functions, error handling, modules, providers |
| **Guides** | Hands-on walkthroughs by topic (filesystem, networking, processes, etc.) |
| **Writing Your Own Commands** | Functions, advanced functions, modules, help, PSGallery publishing |
| **Command Reference** | Full A-Z cmdlet listing with syntax and examples |
| **Examples & Recipes** | Complete, copy-pasteable scripts for real tasks |
| **Contributing** | How to fix, improve, or add content to this encyclopedia |
| **Suggest a Change** | Open a GitHub issue to report errors or request new content |

---

!!! tip "Use the search bar"
    Press <kbd>S</kbd> or <kbd>/</kbd> to jump to the search bar and quickly find any cmdlet, concept, or keyword.

