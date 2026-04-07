param()

$ErrorActionPreference = 'Stop'

Write-Host 'Building Flutter web release...'
$definesFile = Join-Path $PSScriptRoot 'web_release_defines.json'
if (Test-Path $definesFile) {
  $definesResolved = (Resolve-Path $definesFile).Path
  Write-Host "Using dart defines from: $definesResolved"
  flutter build web --no-tree-shake-icons --dart-define-from-file=$definesResolved
} else {
  Write-Host 'No web_release_defines.json found; building with compile-time defaults only.'
  flutter build web --no-tree-shake-icons
}

$bootstrapPath = Join-Path $PSScriptRoot '..\build\web\flutter_bootstrap.js'
$resolvedBootstrapPath = (Resolve-Path $bootstrapPath).Path
$bootstrap = Get-Content $resolvedBootstrapPath -Raw

$replacement = @"
window.__codexLaunchFlutterApp = async function () {
  return _flutter.loader.load({
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

$serviceWorkerPath = Join-Path $PSScriptRoot '..\build\web\flutter_service_worker.js'
if (Test-Path $serviceWorkerPath) {
  Remove-Item $serviceWorkerPath -Force
}

Write-Host 'Patched build\web\flutter_bootstrap.js for mobile-safe startup.'
