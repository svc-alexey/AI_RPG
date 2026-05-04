# Release/profile build with the same dart-defines as local dev.
# Requires tool/ai_local_defines.json (gitignored); copy from ai_local_defines.example.json.

param(
  [string]$ProjectRoot = "D:\AI_PRG",
  [ValidateSet("apk", "appbundle", "web", "windows", "ios", "macos", "linux")]
  [string]$Target = "apk",
  [ValidateSet("release", "profile", "debug")]
  [string]$BuildMode = "release"
)

Set-Location $ProjectRoot

$defineFile = Join-Path $ProjectRoot "tool\ai_local_defines.json"
if (-not (Test-Path $defineFile)) {
  Write-Error "Missing tool/ai_local_defines.json — copy tool/ai_local_defines.example.json, set AI_PRG_API_KEY, save as tool/ai_local_defines.json"
  exit 1
}

$defineArg = "--dart-define-from-file=tool/ai_local_defines.json"
$modeArg = "--$BuildMode"

switch ($Target) {
  "apk" { & flutter build apk $modeArg $defineArg }
  "appbundle" { & flutter build appbundle $modeArg $defineArg }
  "web" { & flutter build web $modeArg $defineArg }
  "windows" { & flutter build windows $modeArg $defineArg }
  "ios" { & flutter build ios $modeArg $defineArg }
  "macos" { & flutter build macos $modeArg $defineArg }
  "linux" { & flutter build linux $modeArg $defineArg }
}
