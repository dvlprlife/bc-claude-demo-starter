<#
.SYNOPSIS
    Compiles an AL project with alc.exe and the four code analyzers.

.DESCRIPTION
    Build recipe:
    - Calls alc.exe directly. The "al compile" wrapper does not load the analyzers
      (observed with AL tools 18.0.43).
    - Runs CodeCop, AppSourceCop, PerTenantExtensionCop, and UICop with
      supporting-files/project.ruleset.json.
    - Fails if alc reports an error or an AL1003 warning (an analyzer did not load).

    The package goes to .output/<Publisher>_<Name>_<Version>.app. The script deletes older
    packages of the same app in .output, so the test app resolves the current build.

.PARAMETER Project
    The AL project folder, relative to the repo root. Default: "app" (the main app). Use "test" for the test app.

.EXAMPLE
    ./scripts/Build-App.ps1
    ./scripts/Build-App.ps1 -Project test
#>
[CmdletBinding()]
param(
    [string]$Project = 'app'
)

$ErrorActionPreference = 'Stop'

$repo = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$projectPath = (Resolve-Path (Join-Path $repo $Project)).Path
$outFolder = Join-Path $repo '.output'
$ruleset = Join-Path $repo 'supporting-files\project.ruleset.json'
New-Item -ItemType Directory -Force $outFolder | Out-Null

$appJson = Get-Content (Join-Path $projectPath 'app.json') -Raw | ConvertFrom-Json
$appFile = "$($appJson.publisher)_$($appJson.name)_$($appJson.version).app"
$appPath = Join-Path $outFolder $appFile

# Remove older packages of this app, so that only the current build is in the cache.
Get-ChildItem $outFolder -Filter "$($appJson.publisher)_$($appJson.name)_*.app" -ErrorAction SilentlyContinue |
    Remove-Item -Force

# Find alc.exe and the analyzers in the AL tools package.
$alCommand = Get-Command al -ErrorAction SilentlyContinue
if (-not $alCommand) { throw 'The AL tools are not installed. Run: dotnet tool install -g Microsoft.Dynamics.BusinessCentral.Development.Tools' }
$alDir = Split-Path $alCommand.Source
$codeCop = Get-ChildItem "$alDir\.store" -Recurse -Filter Microsoft.Dynamics.Nav.CodeCop.dll | Select-Object -First 1
if (-not $codeCop) { throw 'Microsoft.Dynamics.Nav.CodeCop.dll was not found in the AL tools package.' }
$az = $codeCop.DirectoryName
$alc = Join-Path $az 'alc.exe'

# Symbol folders: the project's own .alpackages, the main app's .alpackages (app/.alpackages), and .output
# (for the test app, which depends on the main app).
$cachePaths = @(
    (Join-Path $projectPath '.alpackages'),
    (Join-Path $repo 'app\.alpackages'),
    $outFolder
) | Select-Object -Unique | Where-Object { Test-Path $_ }
$packageCache = $cachePaths -join ';'

$alcArgs = @(
    "/project:$projectPath",
    "/packagecachepath:$packageCache",
    "/out:$appPath",
    "/ruleset:$ruleset",
    "/analyzer:$az\Microsoft.Dynamics.Nav.CodeCop.dll",
    "/analyzer:$az\Microsoft.Dynamics.Nav.AppSourceCop.dll",
    "/analyzer:$az\Microsoft.Dynamics.Nav.PerTenantExtensionCop.dll",
    "/analyzer:$az\Microsoft.Dynamics.Nav.UICop.dll"
)

Write-Host "Compiling $($appJson.name) $($appJson.version)"
$output = & $alc @alcArgs 2>&1 | ForEach-Object { "$_" }
$exitCode = $LASTEXITCODE
$output | Write-Host

$errors = @($output | Where-Object { $_ -match '(^|: )error [A-Z]{2,3}[0-9]' })
$warnings = @($output | Where-Object { $_ -match '(^|: )warning [A-Z]{2,3}[0-9]' })
$analyzerNotLoaded = @($output | Where-Object { $_ -match 'AL1003' })

Write-Host ''
Write-Host "Errors: $($errors.Count)  Warnings: $($warnings.Count)"

if ($analyzerNotLoaded) {
    Write-Error 'AL1003: an analyzer did not load. The analyzer gate did not run.'
    exit 1
}
if ($exitCode -ne 0 -or $errors.Count -gt 0 -or -not (Test-Path $appPath)) {
    Write-Error "Build failed (alc exit code $exitCode)."
    exit 1
}

Write-Host "Package: $appPath"
