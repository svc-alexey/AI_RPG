param()

$ErrorActionPreference = 'Stop'

$version = Get-Content 'build\web\version.json' | ConvertFrom-Json
$stamp = ($version.release_id -replace '^web-', '') -replace 'Z$', ''
$zipName = "ai_prg_web_build_$stamp.zip"

if (Test-Path $zipName) {
  Remove-Item $zipName -Force
}

@'
from pathlib import Path
import zipfile

root = Path(r"build/web")
zip_path = Path(r"ZIP_DESTINATION")

with zipfile.ZipFile(zip_path, "w", compression=zipfile.ZIP_DEFLATED) as zf:
    for path in sorted(root.rglob("*")):
        if path.is_dir():
            continue
        zf.write(path, path.relative_to(root).as_posix())
'@.Replace('ZIP_DESTINATION', $zipName) | python -

$hash = (Get-FileHash $zipName -Algorithm SHA256).Hash.ToLower()
Set-Content -Path ($zipName + '.sha256.txt') -Value $hash -NoNewline

Write-Output $zipName
Write-Output $hash
