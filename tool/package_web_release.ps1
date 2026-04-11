param()

$ErrorActionPreference = 'Stop'

$version = Get-Content 'build\web\version.json' | ConvertFrom-Json
$stamp = ($version.release_id -replace '^web-', '') -replace 'Z$', ''
$zipName = "ai_prg_web_build_$stamp.zip"

if (Test-Path $zipName) {
  Remove-Item $zipName -Force
}

Compress-Archive -Path 'build\web\*' -DestinationPath $zipName -CompressionLevel Optimal

$hash = (Get-FileHash $zipName -Algorithm SHA256).Hash.ToLower()
Set-Content -Path ($zipName + '.sha256.txt') -Value $hash -NoNewline

Write-Output $zipName
Write-Output $hash
