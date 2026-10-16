<#
.SYNOPSIS
    Converts wireframe SVG files to PNG files with Microsoft Edge in headless mode.

.DESCRIPTION
    The PRD embeds the PNG files. The SVG files are the source. Run this script after you
    add or change a wireframe. The script reads the width and height from each SVG root
    element and writes a PNG at 2x scale next to the SVG.

.PARAMETER Path
    A folder of SVG files or one SVG file. Default: docs/wireframes in the repo.

.EXAMPLE
    ./scripts/Export-Wireframes.ps1
    ./scripts/Export-Wireframes.ps1 -Path docs/wireframes/02-contract-card.svg
#>
[CmdletBinding()]
param(
    [string]$Path = (Join-Path $PSScriptRoot '..\docs\wireframes'),
    [int]$Scale = 2
)

$ErrorActionPreference = 'Stop'

$edge = @(
    "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe",
    "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $edge) { throw 'Microsoft Edge is not installed. Install Edge or export the PNG files manually.' }

$item = Get-Item (Resolve-Path $Path)
$svgFiles = if ($item.PSIsContainer) { Get-ChildItem $item.FullName -Filter *.svg } else { @($item) }

if (-not $svgFiles) { Write-Warning "No SVG files found in $Path"; return }

$profileDir = Join-Path ([IO.Path]::GetTempPath()) "wireframe-export-$PID"

foreach ($svg in $svgFiles) {
    $content = Get-Content $svg.FullName -Raw
    if ($content -notmatch '<svg[^>]*\swidth="(\d+)"[^>]*\sheight="(\d+)"') {
        Write-Warning "Skipped $($svg.Name): the svg element has no numeric width and height."
        continue
    }
    $width = $Matches[1]; $height = $Matches[2]
    $png = [IO.Path]::ChangeExtension($svg.FullName, '.png')
    if (Test-Path $png) { Remove-Item $png }

    $uri = ([Uri]$svg.FullName).AbsoluteUri
    $edgeArgs = @(
        '--headless=new', '--disable-gpu', '--hide-scrollbars', '--no-first-run',
        "--user-data-dir=$profileDir",
        "--force-device-scale-factor=$Scale",
        "--window-size=$width,$height",
        "--screenshot=$png",
        $uri
    )
    Start-Process -FilePath $edge -ArgumentList $edgeArgs -Wait -WindowStyle Hidden

    if (Test-Path $png) { Write-Host "Exported $($svg.Name) -> $([IO.Path]::GetFileName($png)) ($width x $height @${Scale}x)" }
    else { Write-Warning "Edge did not write $png" }
}

Remove-Item $profileDir -Recurse -Force -ErrorAction SilentlyContinue
