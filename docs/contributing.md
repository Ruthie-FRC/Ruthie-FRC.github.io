# Contributing

Thank you for your interest in improving the PowerShell Command Encyclopedia! Contributions of all sizes are welcome — from fixing a typo to adding an entirely new guide.

---

## Ways to Contribute

- **Fix a typo or grammar error** — even tiny fixes matter
- **Correct inaccurate information** — PowerShell evolves; outdated details can mislead readers
- **Improve an existing example** — make snippets clearer, more idiomatic, or more practical
- **Add a new recipe** to [Examples & Recipes](examples.md)
- **Expand the Command Reference** — add a missing cmdlet entry
- **Write a new guide** — cover a topic that isn't yet documented
- **Report an issue** — if you spot something wrong but don't want to edit it yourself

---

## Quick Edit (GitHub)

Every page has an **Edit** button (pencil icon :material-pencil:) in the top-right corner. Clicking it opens the source file in GitHub's editor so you can make a change and open a pull request without leaving your browser.

---

## Full Local Setup

For larger contributions, run the site locally to preview your changes before opening a PR.

### 1. Fork and clone

```bash
git clone https://github.com/<your-username>/Powershell-Commands.git
cd Powershell-Commands
```

### 2. Install dependencies

Python 3.9+ and pip are required.

```bash
pip install -r requirements.txt
```

### 3. Serve locally

```bash
mkdocs serve
```

Open [http://127.0.0.1:8000](http://127.0.0.1:8000) in your browser. The site reloads automatically when you save a file.

### 4. Build (optional)

```bash
mkdocs build
```

The static site is written to the `site/` directory.

---

## File Layout

```
docs/
├── index.md                  ← home page
├── contributing.md           ← this page
├── command-reference.md      ← A-Z cmdlet reference
├── examples.md               ← recipes & real-world scripts
├── getting-started/          ← intro pages for new users
├── concepts/                 ← language & runtime concepts
├── guides/                   ← topic-focused how-to guides
└── authoring/                ← writing and publishing modules
```

All documentation is written in **Markdown** with [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/) extensions. The full site configuration lives in `mkdocs.yml` at the root of the repository.

---

## Writing Style

| Guideline | Detail |
|-----------|--------|
| **Accuracy first** | Verify every cmdlet name, parameter, and behavior claim against the official Microsoft docs or a live PowerShell session |
| **Use `pwsh`** | Target PowerShell 7+ (`pwsh`) unless a feature is Windows PowerShell 5.1-only |
| **Complete examples** | Snippets should be copy-paste ready — avoid pseudocode like `...` unless unavoidable |
| **Admonition types** | `!!! tip` for advice, `!!! warning` for danger/data-loss, `!!! note` for neutral info |
| **Code fences** | Always use ` ```powershell ` (or ` ```bash ` / ` ```yaml `) — never a bare ` ``` ` |
| **Sentence case** | Use sentence case for headings: *"Working with credentials"*, not *"Working With Credentials"* |
| **No aliases in examples** | Use full cmdlet names (`Get-ChildItem`, not `ls`) for clarity |

---

## Markdown Reference

The site uses [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/) with the following extensions enabled:

### Admonitions

```markdown
!!! tip "Optional title"
    Content here.

!!! warning
    Be careful!

!!! note
    Neutral information.
```

### Tabbed code blocks

````markdown
=== "Windows"

    ```powershell
    winget install Microsoft.PowerShell
    ```

=== "macOS"

    ```bash
    brew install --cask powershell
    ```
````

### Code with copy button

All ` ```powershell ` blocks automatically get a copy button — no extra markup needed.

---

## Opening a Pull Request

1. Create a branch: `git checkout -b fix/typo-in-providers`
2. Make your changes and preview them with `mkdocs serve`
3. Commit and push: `git push origin fix/typo-in-providers`
4. Open a pull request on GitHub — describe what you changed and why
5. A maintainer will review and merge

---

## Reporting Issues

If you find incorrect information, a broken example, or a missing topic, please [open an issue](https://github.com/Ruthie-FRC/Powershell-Commands/issues) on GitHub. Include:

- The page where the problem appears
- What the content says
- What it should say (and a source link if you have one)
