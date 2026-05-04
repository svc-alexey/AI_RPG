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

$definesFile = Join-Path $toolRoot 'web_release_defines.nginx.json'
$buildDefines = @{}
if (Test-Path $definesFile) {
  $rawDefines = Get-Content $definesFile -Raw | ConvertFrom-Json
  $rawDefines.PSObject.Properties | ForEach-Object {
    $buildDefines[$_.Name] = $_.Value
  }
}
$buildDefines['AI_PRG_APP_VERSION'] = $metadata.app_version
$buildDefines['AI_PRG_ASSET_VERSION'] = $metadata.asset_version
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
    config: {
      canvasKitBaseUrl: 'canvaskit',
      canvasKitVariant: 'canvaskit'
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

  # Post-build cleanup: strip debug symbols and unnecessary assets
  $symbolsFiles = Get-ChildItem (Join-Path $buildWebPath 'canvaskit') -Filter '*.symbols' -ErrorAction SilentlyContinue
  if ($symbolsFiles) {
    $symbolsTotal = [math]::Round(($symbolsFiles | Measure-Object -Property Length -Sum).Sum / 1KB, 1)
    $symbolsFiles | Remove-Item -Force
    Write-Host "Removed $($symbolsFiles.Count) CanvasKit .symbols files ($symbolsTotal KB saved)"
  }

  # Remove unused CanvasKit variants — keep only canvaskit (universal fallback)
  $ckVariants = @('skwasm', 'skwasm_heavy', 'wimp')
  $ckDir = Join-Path $buildWebPath 'canvaskit'
  $variantTotal = 0
  foreach ($variant in $ckVariants) {
    $jsFile = Join-Path $ckDir "$variant.js"
    $wasmFile = Join-Path $ckDir "$variant.wasm"
    foreach ($f in @($jsFile, $wasmFile)) {
      if (Test-Path $f) {
        $variantTotal += (Get-Item $f).Length
        Remove-Item $f -Force
      }
    }
  }
  $chromiumDir = Join-Path $ckDir 'chromium'
  if (Test-Path $chromiumDir) {
    $chromiumTotal = (Get-ChildItem $chromiumDir -Recurse -File | Measure-Object -Property Length -Sum).Sum
    Remove-Item $chromiumDir -Recurse -Force
    $variantTotal += $chromiumTotal
  }
  if ($variantTotal -gt 0) {
    $variantMB = [math]::Round($variantTotal / 1MB, 1)
    Write-Host "Removed unused CanvasKit variants (skwasm, skwasm_heavy, wimp, chromium) — $variantMB MB saved"
  }

  $noticesPath = Join-Path $buildWebPath 'assets\NOTICES'
  if (Test-Path $noticesPath) {
    $noticesSize = [math]::Round((Get-Item $noticesPath).Length / 1KB, 1)
    Remove-Item $noticesPath -Force
    Write-Host "Removed assets/NOTICES ($noticesSize KB saved)"
  }

  $oldFeedbackPng = Join-Path $buildWebPath 'landing\feedback_bg.png'
  if (Test-Path $oldFeedbackPng) {
    $pngSize = [math]::Round((Get-Item $oldFeedbackPng).Length / 1KB, 1)
    Remove-Item $oldFeedbackPng -Force
    Write-Host "Removed old landing/feedback_bg.png ($pngSize KB saved)"
  }
}
finally {
  if (Test-Path $tempDefinesPath) {
    Remove-Item $tempDefinesPath -Force
  }
}
