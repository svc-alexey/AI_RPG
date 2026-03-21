param()

$ErrorActionPreference = 'Stop'

Write-Host 'Building Flutter web release...'
flutter build web

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
