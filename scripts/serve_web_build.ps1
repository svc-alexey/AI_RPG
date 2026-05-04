param(
  [int]$Port = 3010
)

$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$webDir = Join-Path $projectRoot 'build\web'
if (-not (Test-Path (Join-Path $webDir 'index.html'))) {
  Write-Error "Missing build\web. Run: powershell -ExecutionPolicy Bypass -File tool\build_web_release.ps1"
}
Set-Location $webDir
Write-Host "Serving $webDir at http://127.0.0.1:$Port/ (Symmetry API expected at http://127.0.0.1:8080)"
python -m http.server $Port --bind 127.0.0.1
