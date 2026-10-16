<#
.SYNOPSIS
    Resets the demo folder to its starting state, so that the demo can run again.

.DESCRIPTION
    Removes the outputs of a demo run:
    - docs/request.md, the FRD and PRD files (all versions), and the wireframes in docs/wireframes
    - the user guide and its screenshots in docs/user-guide
    - the AL source in app/src, the translation files in app/Translations, and the test app in test/
    - the built packages in .output/
    - the dashboard anchor in .dashboard/ (the next run makes a new dashboard)
    Restores app/app.json from supporting-files/app.baseline.json.

    Keeps the workflow files: docs/templates, docs/README.md, reference, scripts,
    supporting-files, .claude, app/.vscode, .mcp.json, CLAUDE.md, README.md, and the symbols
    in app/.alpackages.

    This script does not remove the extension from the Business Central environment.
    The reset-demo skill does that step.

.EXAMPLE
    ./scripts/Reset-Demo.ps1 -WhatIf
    ./scripts/Reset-Demo.ps1
#>
[CmdletBinding(SupportsShouldProcess)]
param()

$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path

$targets = @()
$targets += Get-Item (Join-Path $repo 'docs\request.md') -ErrorAction SilentlyContinue
$targets += Get-ChildItem (Join-Path $repo 'docs') -Filter 'FunctionalRequirements v*.md' -ErrorAction SilentlyContinue
$targets += Get-ChildItem (Join-Path $repo 'docs') -Filter 'ProductRequirements v*.md' -ErrorAction SilentlyContinue
$targets += Get-ChildItem (Join-Path $repo 'docs\wireframes') -File -ErrorAction SilentlyContinue | Where-Object Name -ne '.gitkeep'
$targets += Get-Item (Join-Path $repo 'docs\user-guide') -ErrorAction SilentlyContinue
$targets += Get-ChildItem (Join-Path $repo 'app\src') -Force -ErrorAction SilentlyContinue | Where-Object Name -ne '.gitkeep'
$targets += Get-Item (Join-Path $repo 'app\Translations') -ErrorAction SilentlyContinue
$targets += Get-Item (Join-Path $repo 'test') -ErrorAction SilentlyContinue
$targets += Get-Item (Join-Path $repo '.output') -ErrorAction SilentlyContinue
$targets += Get-Item (Join-Path $repo '.dashboard') -ErrorAction SilentlyContinue
$targets = $targets | Where-Object { $_ }

foreach ($item in $targets) {
    $relative = $item.FullName.Substring($repo.Length + 1)
    if ($PSCmdlet.ShouldProcess($relative, 'Remove')) {
        Remove-Item $item.FullName -Recurse -Force
        Write-Host "Removed $relative"
    }
}
if (-not $targets) { Write-Host 'No demo outputs found.' }

$baseline = Join-Path $repo 'supporting-files\app.baseline.json'
$appJson = Join-Path $repo 'app\app.json'
if (Test-Path $baseline) {
    if ((Get-Content $baseline -Raw) -match '\{\{[A-Z_]+\}\}') {
        Write-Warning 'supporting-files/app.baseline.json still has {{placeholders}}. Run the bootstrap first. app/app.json is not changed.'
    } elseif ($PSCmdlet.ShouldProcess('app/app.json', 'Restore from supporting-files/app.baseline.json')) {
        Copy-Item $baseline $appJson -Force
        Write-Host 'Restored app/app.json from the baseline'
    }
} else {
    Write-Warning 'supporting-files/app.baseline.json was not found. app/app.json is not changed.'
}

foreach ($folder in 'app\src', 'docs\wireframes') {
    $keep = Join-Path $repo "$folder\.gitkeep"
    if (-not (Test-Path $keep) -and $PSCmdlet.ShouldProcess($folder, 'Create empty folder')) {
        New-Item -ItemType File -Force $keep | Out-Null
    }
}
