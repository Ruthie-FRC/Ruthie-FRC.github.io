# PowerShell Command Encyclopedia

[![Docs Build](https://github.com/Ruthie-FRC/Powershell-Commands/actions/workflows/docs.yml/badge.svg?branch=main)](https://github.com/Ruthie-FRC/Powershell-Commands/actions/workflows/docs.yml)

The **complete reference for PowerShell commands, scripting, and automation** — from first commands to publishing your own modules on the PowerShell Gallery.

## 📖 Live Documentation

> **[ruthie-frc.github.io/Powershell-Commands](https://ruthie-frc.github.io/Powershell-Commands/)**

---

## What's Inside

| Section | Contents |
|---------|---------|
| **Getting Started** | What is PowerShell, installation, your first commands, the pipeline |
| **Core Concepts** | Variables, data types, operators, control flow, functions, error handling, modules, providers, profiles |
| **Guides** | File system, processes, networking, system info, pipelines & filtering, users & security, registry, scheduled tasks, remote management |
| **Writing Your Own Commands** | Creating functions, advanced functions & CmdletBinding, script modules, comment-based help, publishing to PSGallery |
| **Command Reference** | A-Z reference for 80+ cmdlets with syntax, parameters, and examples |
| **Examples & Recipes** | Complete copy-paste scripts for real-world tasks |

---

## Run Locally

```bash
# Install dependencies
pip install -r requirements.txt

# Serve with live reload
mkdocs serve

# Build static site
mkdocs build
```

The site will be available at `http://127.0.0.1:8000/Powershell-Commands/`

---

## CLI Lookup Tool

```bash
python tools/lookup.py Get-Process
python tools/lookup.py --list-categories
python tools/lookup.py --category filesystem
```

---

## Project Structure

```
docs/
├── getting-started/    # Installation and basics
├── concepts/           # Language and shell concepts
├── guides/             # Task-focused how-to guides
├── authoring/          # How to write your own cmdlets and modules
├── command-reference.md
└── examples.md
data/
└── commands.json       # Machine-readable command database (77+ commands)
tools/
└── lookup.py           # CLI search tool
mkdocs.yml              # MkDocs configuration
```

---

## Contributing

Contributions are welcome! To add or improve content:

1. Fork the repository
2. Edit the relevant Markdown file in `docs/`
3. Run `mkdocs serve` to preview your changes
4. Open a pull request

If you're adding a new cmdlet to the command database, edit `data/commands.json` following the existing schema.
