<#
.SYNOPSIS
    Look up PowerShell commands by name, description, category, or keyword.

.DESCRIPTION
    Searches the local commands database and displays matching cmdlets with their
    synopsis, syntax, aliases, and a quick example.

    Search is case-insensitive and matches command names, synopses, descriptions,
    keywords, and aliases, so you can look up by what a command does as well as
    what it is called.

.PARAMETER Query
    A word or partial name to search for. Examples: "process", "csv", "ping", "rename".

.PARAMETER Category
    Filter results to a specific category.
    Valid values: filesystem, processes, networking, system, pipeline, output,
    formatting, data, utility, text, variables, modules, security, registry,
    remoting, tasks, web, discovery.

.PARAMETER ListCategories
    List all available categories with their command counts.

.EXAMPLE
    .\pshelp.ps1 process
    Find all commands related to processes.

.EXAMPLE
    .\pshelp.ps1 -Category networking
    List all networking commands.

.EXAMPLE
    .\pshelp.ps1 -ListCategories
    Show all categories.

.EXAMPLE
    .\pshelp.ps1 rename file
    Search for commands that rename files.
#>
param(
    [Parameter(Position = 0)]
    [string]$Query,

    [string]$Category,

    [switch]$ListCategories
)

$dataPath = Join-Path $PSScriptRoot '..\data\commands.json'
if (-not (Test-Path $dataPath)) {
    Write-Error "Cannot find commands database at: $dataPath"
    exit 1
}

$commands = Get-Content $dataPath -Raw | ConvertFrom-Json

if ($ListCategories) {
    Write-Host "`nAvailable categories:" -ForegroundColor Cyan
    $commands |
        Group-Object category |
        Sort-Object Name |
        ForEach-Object { Write-Host ("  {0,-20} ({1} commands)" -f $_.Name, $_.Count) }
    Write-Host ""
    exit 0
}

$results = $commands

if ($Category) {
    $results = $results | Where-Object { $_.category -ieq $Category }
    if (-not $results) {
        Write-Warning "No commands found in category '$Category'. Run with -ListCategories to see valid values."
        exit 0
    }
}

if ($Query) {
    $results = $results | Where-Object {
        $_.name        -match $Query -or
        $_.synopsis    -match $Query -or
        $_.description -match $Query -or
        ($_.keywords -and ($_.keywords -join ' ') -match $Query) -or
        ($_.aliases  -and ($_.aliases  -join ' ') -match $Query)
    }
}

if (-not $results) {
    Write-Host "`nNo commands matched '$Query'." -ForegroundColor Yellow
    Write-Host "Tip: try a broader term, or use -ListCategories to browse by category.`n"
    exit 0
}

foreach ($cmd in $results) {
    Write-Host ""
    Write-Host ("=" * 60) -ForegroundColor DarkGray
    Write-Host $cmd.name -ForegroundColor Cyan
    Write-Host $cmd.synopsis
    if ($cmd.aliases -and $cmd.aliases.Count -gt 0) {
        Write-Host ("  Aliases : " + ($cmd.aliases -join ', ')) -ForegroundColor DarkGray
    }
    Write-Host ("  Category: " + $cmd.category) -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  SYNTAX" -ForegroundColor Yellow
    Write-Host ("    " + $cmd.syntax)
    if ($cmd.examples -and $cmd.examples.Count -gt 0) {
        $ex = $cmd.examples[0]
        Write-Host ""
        Write-Host "  EXAMPLE" -ForegroundColor Yellow
        Write-Host ("    # " + $ex.description)
        Write-Host ("    " + $ex.code)
    }
}
Write-Host ""

