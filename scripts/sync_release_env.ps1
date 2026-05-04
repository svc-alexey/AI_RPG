param(
  [string]$EnvPath = 'backend/symmetry/.env',
  [string]$VersionPath = 'build/web/version.json'
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path $EnvPath)) {
  throw "Env file not found: $EnvPath"
}

if (-not (Test-Path $VersionPath)) {
  throw "Version file not found: $VersionPath"
}

$version = Get-Content $VersionPath -Raw | ConvertFrom-Json
$lines = Get-Content $EnvPath

$replacements = [ordered]@{
  'SYMMETRY_RELEASE_ID' = "$($version.release_id)"
  'SYMMETRY_RELEASED_AT' = "$($version.released_at)"
  'SYMMETRY_WEB_ASSET_VERSION' = "$($version.asset_version)"
}

foreach ($key in $replacements.Keys) {
  $newLine = "$key=$($replacements[$key])"
  $existingIndex = -1
  for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match "^$key=") {
      $existingIndex = $i
      break
    }
  }

  if ($existingIndex -ge 0) {
    $lines[$existingIndex] = $newLine
  }
  else {
    $lines += $newLine
  }
}

Set-Content -Path $EnvPath -Value $lines

Write-Output "Synced release metadata from $VersionPath into $EnvPath"
