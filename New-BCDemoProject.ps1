<#
.SYNOPSIS
    Creates a Business Central demo project from the starter kit template.

.DESCRIPTION
    Copies the template folder to the destination and fills in the project values:
    - supporting-files/app.baseline.json and app/app.json (a new app ID, the name, the publisher,
      the BC version, the runtime, and the object ID range)
    - app/.vscode/launch.json (the sandbox environment name and the tenant)
    - CLAUDE.md (the project name)

    The destination must not exist, or it must be empty. The script does not overwrite files.

    Use -CheckOnly to check the prerequisites and make no changes.

.PARAMETER Destination
    The folder for the new project.

.PARAMETER ProjectName
    The project name. It is the starting app name in app/app.json. Claude changes the app name to
    the solution name when development starts. Maximum 30 characters.

.PARAMETER Publisher
    The publisher in app/app.json, for example your company name.

.PARAMETER EnvironmentName
    The name of the Business Central Online sandbox environment, for example "Sandbox".

.PARAMETER Tenant
    The Microsoft Entra tenant ID (a GUID) or the tenant domain, for example contoso.onmicrosoft.com.

.PARAMETER BCVersion
    The major Business Central version of the sandbox, for example 28. Default: 28.
    The app can install on this version and later versions.

.PARAMETER IdFrom
    The first object ID of the app. Default: 50100.

.PARAMETER IdTo
    The last object ID of the app. Default: 50149. The test app uses 50150-50199.

.EXAMPLE
    ./New-BCDemoProject.ps1 -CheckOnly

.EXAMPLE
    ./New-BCDemoProject.ps1 -Destination C:\AL\BCDemo -ProjectName BCDemo -Publisher Contoso `
        -EnvironmentName Sandbox -Tenant contoso.onmicrosoft.com
#>
[CmdletBinding(DefaultParameterSetName = 'Create')]
param(
    [Parameter(ParameterSetName = 'Check', Mandatory)]
    [switch]$CheckOnly,

    [Parameter(ParameterSetName = 'Create', Mandatory)]
    [string]$Destination,

    [Parameter(ParameterSetName = 'Create', Mandatory)]
    [ValidateLength(1, 30)]
    [string]$ProjectName,

    [Parameter(ParameterSetName = 'Create', Mandatory)]
    [string]$Publisher,

    [Parameter(ParameterSetName = 'Create', Mandatory)]
    [string]$EnvironmentName,

    [Parameter(ParameterSetName = 'Create', Mandatory)]
    [string]$Tenant,

    [Parameter(ParameterSetName = 'Create')]
    [ValidateRange(24, 99)]
    [int]$BCVersion = 28,

    [Parameter(ParameterSetName = 'Create')]
    [ValidateRange(50000, 99999)]
    [int]$IdFrom = 50100,

    [Parameter(ParameterSetName = 'Create')]
    [ValidateRange(50000, 99999)]
    [int]$IdTo = 50149
)

$ErrorActionPreference = 'Stop'
$kit = $PSScriptRoot
$template = Join-Path $kit 'template'

function Test-Prerequisites {
    $results = [ordered]@{}

    $results['Windows'] = $IsWindows -or $env:OS -eq 'Windows_NT'

    $dotnet = Get-Command dotnet -ErrorAction SilentlyContinue
    $results['.NET SDK (dotnet)'] = [bool]$dotnet

    $al = Get-Command al -ErrorAction SilentlyContinue
    $alVersion = if ($al) { (& al --version 2>$null | Select-Object -First 1) } else { $null }
    $results['AL tools (al)'] = [bool]$al
    $alMajor = if ($alVersion -match '^(\d+)\.') { [int]$Matches[1] } else { 0 }
    $results['AL tools version 18 or later'] = $alMajor -ge 18

    $edge = @(
        "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe",
        "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe"
    ) | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1
    $results['Microsoft Edge (wireframe export)'] = [bool]$edge

    foreach ($key in $results.Keys) {
        $mark = if ($results[$key]) { 'OK     ' } else { 'MISSING' }
        Write-Host "$mark $key"
    }
    if ($alVersion) { Write-Host "        AL tools version: $alVersion" }

    return -not ($results.Values -contains $false)
}

if ($CheckOnly) {
    if (Test-Prerequisites) { Write-Host 'All prerequisites are installed.' }
    else { Write-Warning 'One or more prerequisites are missing. See README.md, "Before you start".' }
    return
}

if ($IdTo -lt $IdFrom) { throw "IdTo ($IdTo) is less than IdFrom ($IdFrom)." }
# The package file name is <Publisher>_<Name>_<Version>.app, so these values must be valid in a file name.
foreach ($name in 'ProjectName', 'Publisher') {
    if ((Get-Variable $name -ValueOnly) -match '[\\/:*?"<>|]') {
        throw "$name cannot contain these characters: \ / : * ? `" < > |"
    }
}
if (-not (Test-Path (Join-Path $template 'CLAUDE.md'))) { throw "The template folder was not found at $template." }

$ok = Test-Prerequisites
if (-not $ok) { Write-Warning 'One or more prerequisites are missing. The project is created, but the build and publish steps need them.' }

# The destination must be new or empty.
if (Test-Path $Destination) {
    if (Get-ChildItem $Destination -Force | Select-Object -First 1) {
        throw "The destination '$Destination' is not empty. Use a new folder or an empty folder."
    }
} else {
    New-Item -ItemType Directory -Path $Destination | Out-Null
}
$Destination = (Resolve-Path $Destination).Path

# The runtime: the AL tools give the latest runtime for a BC version (28.0 -> 17.1).
# Use the major part with minor 0 (17.0), the same as a new AL project.
$runtime = $null
if (Get-Command al -ErrorAction SilentlyContinue) {
    $latest = (& al GetLatestSupportedRuntimeVersion "$BCVersion.0" 2>$null | Select-Object -First 1)
    if ($latest -match '^(\d+)\.') { $runtime = "$($Matches[1]).0" }
}
if (-not $runtime) { $runtime = "$($BCVersion - 11).0" }

Copy-Item -Path (Join-Path $template '*') -Destination $Destination -Recurse -Force

# Files from a downloaded zip carry the "downloaded from the internet" mark, and PowerShell
# can block the scripts. Remove the mark from the new project.
Get-ChildItem $Destination -Recurse -File -Force | Unblock-File

$values = @{
    '{{APP_ID}}'           = [guid]::NewGuid().ToString()
    '{{PROJECT_NAME}}'     = $ProjectName
    '{{PUBLISHER}}'        = $Publisher
    '{{APPLICATION}}'      = "$BCVersion.0.0.0"
    '{{RUNTIME}}'          = $runtime
    '{{ID_FROM}}'          = "$IdFrom"
    '{{ID_TO}}'            = "$IdTo"
    '{{ENVIRONMENT_NAME}}' = $EnvironmentName
    '{{TENANT}}'           = $Tenant
}

$tokenFiles = @(
    'supporting-files\app.baseline.json',
    'app\.vscode\launch.json',
    'CLAUDE.md'
)
foreach ($relative in $tokenFiles) {
    $path = Join-Path $Destination $relative
    $text = [IO.File]::ReadAllText($path)
    foreach ($token in $values.Keys) {
        $value = $values[$token]
        if ($relative -like '*.json') { $value = $value.Replace('\', '\\').Replace('"', '\"') }
        $text = $text.Replace($token, $value)
    }
    if ($text -match '\{\{[A-Z_]+\}\}') { throw "A placeholder is left in $relative`: $($Matches[0])" }
    [IO.File]::WriteAllText($path, $text, [Text.UTF8Encoding]::new($false))
}

Copy-Item (Join-Path $Destination 'supporting-files\app.baseline.json') (Join-Path $Destination 'app\app.json')

# Check that the JSON files are valid.
foreach ($relative in 'app\app.json', 'app\.vscode\launch.json') {
    Get-Content (Join-Path $Destination $relative) -Raw | ConvertFrom-Json | Out-Null
}

Write-Host ''
Write-Host "Created the project in $Destination"
Write-Host "  App name:     $ProjectName"
Write-Host "  Publisher:    $Publisher"
Write-Host "  BC version:   $BCVersion.0.0.0 (runtime $runtime)"
Write-Host "  Object IDs:   $IdFrom-$IdTo (test app: 50150-50199)"
Write-Host "  Sandbox:      $EnvironmentName (tenant $Tenant)"
Write-Host ''
Write-Host 'Next: close Claude Code, then start it again in the new folder:'
Write-Host "  cd `"$Destination`""
Write-Host '  claude'
