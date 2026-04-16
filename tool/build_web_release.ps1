param()

$ErrorActionPreference = 'Stop'

function Get-PubspecVersion {
  param(
    [string]$PubspecPath
  )

  $versionLine = Get-Content $PubspecPath | Where-Object { $_ -match '^version:\s*' } | Select-Object -First 1
  if (-not $versionLine) {
    throw 'Could not resolve app version from pubspec.yaml'
  }
  return ($versionLine -replace '^version:\s*', '').Trim()
}

function Get-ReleaseMetadata {
  param(
    [string]$RootPath,
    [string]$PubspecPath
  )

  $appVersion = if ($env:AI_PRG_APP_VERSION) { $env:AI_PRG_APP_VERSION.Trim() } else { Get-PubspecVersion -PubspecPath $PubspecPath }
  $releaseId = if ($env:AI_PRG_RELEASE_ID) { $env:AI_PRG_RELEASE_ID.Trim() } else { "web-$((Get-Date).ToUniversalTime().ToString('yyyyMMddTHHmmssZ'))" }
  $releasedAt = if ($env:AI_PRG_RELEASED_AT) { $env:AI_PRG_RELEASED_AT.Trim() } else { (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ') }
  $siteUrl = if ($env:AI_PRG_SITE_URL) { $env:AI_PRG_SITE_URL.Trim().TrimEnd('/') } else { 'https://example.com' }

  return @{
    app_version = $appVersion
    asset_version = $releaseId
    release_id = $releaseId
    released_at = $releasedAt
    site_url = $siteUrl
    root_path = $RootPath
  }
}

Write-Host 'Building Flutter web release...'

$toolRoot = $PSScriptRoot
$projectRoot = (Resolve-Path (Join-Path $toolRoot '..')).Path
$pubspecPath = Join-Path $projectRoot 'pubspec.yaml'
$metadata = Get-ReleaseMetadata -RootPath $projectRoot -PubspecPath $pubspecPath

$definesFile = Join-Path $toolRoot 'web_release_defines.json'
$buildDefines = @{}
if (Test-Path $definesFile) {
  $rawDefines = Get-Content $definesFile -Raw | ConvertFrom-Json
  $rawDefines.PSObject.Properties | ForEach-Object {
    $buildDefines[$_.Name] = $_.Value
  }
}
$buildDefines['AI_PRG_APP_VERSION'] = $metadata.app_version
# Keep AI_PRG_ASSET_VERSION from web_release_defines.json when set (e.g. dev-local
# to match SYMMETRY_WEB_ASSET_VERSION); otherwise use a unique per-build id.
$existingAsset = ''
if ($buildDefines.ContainsKey('AI_PRG_ASSET_VERSION')) {
  $existingAsset = [string]$buildDefines['AI_PRG_ASSET_VERSION']
}
if ([string]::IsNullOrWhiteSpace($existingAsset)) {
  $buildDefines['AI_PRG_ASSET_VERSION'] = $metadata.asset_version
}
$buildDefines['AI_PRG_RELEASE_ID'] = $metadata.release_id

$tempDefinesPath = Join-Path $toolRoot 'web_release_defines.generated.json'
$buildDefines | ConvertTo-Json | Set-Content -Path $tempDefinesPath -NoNewline

try {
  $definesResolved = (Resolve-Path $tempDefinesPath).Path
  Write-Host "Using dart defines from: $definesResolved"
  flutter build web --no-tree-shake-icons --dart-define-from-file=$definesResolved

  $buildWebPath = Join-Path $projectRoot 'build\web'
  $bootstrapPath = Join-Path $buildWebPath 'flutter_bootstrap.js'
  $resolvedBootstrapPath = (Resolve-Path $bootstrapPath).Path
  $bootstrap = Get-Content $resolvedBootstrapPath -Raw

  $replacement = @"
window.__codexLaunchFlutterApp = async function () {
  return _flutter.loader.load({
    serviceWorkerSettings: {
      serviceWorkerVersion: serviceWorkerVersion
    },
    onEntrypointLoaded: async function (engineInitializer) {
      const appRunner = await engineInitializer.initializeEngine();
      await appRunner.runApp();
    },
  });
};
"@

  $pattern = "_flutter\.loader\.load\(\{\s*serviceWorkerSettings:[\s\S]*?\}\);"
  $patchedBootstrap = [regex]::Replace($bootstrap, $pattern, $replacement)

  if ($patchedBootstrap -eq $bootstrap) {
    throw 'Failed to patch flutter_bootstrap.js'
  }

  Set-Content -Path $resolvedBootstrapPath -Value $patchedBootstrap -NoNewline

  $versionPath = Join-Path $buildWebPath 'version.json'
  @{
    app_version = $metadata.app_version
    asset_version = $metadata.asset_version
    release_id = $metadata.release_id
    released_at = $metadata.released_at
  } | ConvertTo-Json | Set-Content -Path $versionPath -NoNewline

  $sitemapPath = Join-Path $buildWebPath 'sitemap.xml'
  @"
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url>
    <loc>$($metadata.site_url)/</loc>
    <changefreq>daily</changefreq>
    <priority>1.0</priority>
  </url>
</urlset>
"@ | Set-Content -Path $sitemapPath -NoNewline

  $robotsPath = Join-Path $buildWebPath 'robots.txt'
  @"
User-agent: *
Allow: /

Sitemap: $($metadata.site_url)/sitemap.xml
"@ | Set-Content -Path $robotsPath -NoNewline

  Write-Host 'Patched build\web\flutter_bootstrap.js and generated release metadata assets.'
}
finally {
  if (Test-Path $tempDefinesPath) {
    Remove-Item $tempDefinesPath -Force
  }
}
