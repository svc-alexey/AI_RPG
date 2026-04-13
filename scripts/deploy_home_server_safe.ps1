# Safe deploy to home server: runs scripts/deploy_home_server_safe.sh over SSH.
# Does NOT touch remote backend/symmetry/.env (see bash script).
#
# Prerequisites: OpenSSH or Git's ssh.exe; one-time password OR SSH key for the server user.
#
# Usage:
#   .\scripts\deploy_home_server_safe.ps1
#   .\scripts\deploy_home_server_safe.ps1 -HostName 192.168.1.68 -User alexeyko
#
param(
    [string] $HostName = "192.168.1.68",
    [string] $User = "alexeyko"
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
$bashScript = Join-Path $repoRoot "scripts\deploy_home_server_safe.sh"
if (-not (Test-Path $bashScript)) {
    Write-Error "Missing $bashScript"
    exit 1
}

$ssh = "ssh.exe"
if (-not (Get-Command ssh -ErrorAction SilentlyContinue)) {
    $gitSsh = "C:\Program Files\Git\usr\bin\ssh.exe"
    if (Test-Path $gitSsh) {
        $ssh = $gitSsh
    } else {
        Write-Error "ssh not found. Install OpenSSH Client or Git for Windows."
        exit 1
    }
}

Write-Host "Connecting ${User}@${HostName} (you may be prompted for password)..." -ForegroundColor Cyan
Write-Host "Remote script preserves backend/symmetry/.env — never copies from .example over it." -ForegroundColor DarkGray

Get-Content -LiteralPath $bashScript -Raw | & $ssh -o ConnectTimeout=20 "${User}@${HostName}" "bash -s"
