# Safe deploy to home server from Windows.
# - Builds local Flutter web release.
# - Uploads the web bundle to the server.
# - Resets remote tracked code to origin/master.
# - Preserves remote backend/symmetry/.env and syncs release metadata in it.
# - Rebuilds and restarts docker compose on the server.
#
# Usage:
#   .\scripts\deploy_home_server_safe.ps1
#   $env:AI_PRG_HOME_SERVER_PASSWORD='...'; .\scripts\deploy_home_server_safe.ps1
#
param(
    [string] $HostName = "192.168.1.68",
    [string] $User = "alexeyko",
    [string] $AppRoot = "/home/alexeyko/ai-rpg/app",
    [string] $SiteUrl = "https://beyondtheverge.online"
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
$pythonScript = Join-Path $repoRoot "scripts\deploy_home_server_safe.py"
if (-not (Test-Path $pythonScript)) {
    Write-Error "Missing $pythonScript"
    exit 1
}

if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Error "python not found."
    exit 1
}

Write-Host "Building local web release for ${SiteUrl} ..." -ForegroundColor Cyan
$env:AI_PRG_SITE_URL = $SiteUrl
powershell -ExecutionPolicy Bypass -File (Join-Path $repoRoot "tool\build_web_release.ps1")

Write-Host "Deploying to ${User}@${HostName} ..." -ForegroundColor Cyan
python $pythonScript --host-name $HostName --user $User --app-root $AppRoot --site-url $SiteUrl
