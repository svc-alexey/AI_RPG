param()

$ErrorActionPreference = 'Stop'

Write-Host 'Building Flutter web release...'
flutter build web

$bootstrapPath = Join-Path $PSScriptRoot '..\build\web\flutter_bootstrap.js'
$resolvedBootstrapPath = (Resolve-Path $bootstrapPath).Path
$bootstrap = Get-Content $resolvedBootstrapPath -Raw

$replacement = @"
const loadingContainer = document.getElementById('loading-container');
const loadingNote = document.getElementById('loading-note');

function setLoadingNote(message, isError) {
  if (!loadingNote) {
    return;
  }
  loadingNote.textContent = message;
  loadingNote.classList.toggle('is-error', Boolean(isError));
}

function hideLoading() {
  if (loadingContainer) {
    loadingContainer.remove();
  }
}

const slowLoadTimer = window.setTimeout(() => {
  setLoadingNote(
    'Loading is taking longer than usual. If this is a phone browser, please wait a few more seconds.',
    false,
  );
}, 8000);

const failedLoadTimer = window.setTimeout(() => {
  setLoadingNote(
    'The app did not finish starting. Please reload the page. If it keeps happening, open it in Chrome or Safari.',
    true,
  );
}, 20000);

window.addEventListener('error', function () {
  window.clearTimeout(slowLoadTimer);
  window.clearTimeout(failedLoadTimer);
  setLoadingNote(
    'A startup error occurred. Please reload the page.',
    true,
  );
});

_flutter.loader.load({
  onEntrypointLoaded: async function (engineInitializer) {
    try {
      const appRunner = await engineInitializer.initializeEngine();
      hideLoading();
      window.clearTimeout(slowLoadTimer);
      window.clearTimeout(failedLoadTimer);
      await appRunner.runApp();
    } catch (error) {
      console.error('Flutter web bootstrap failed', error);
      window.clearTimeout(slowLoadTimer);
      window.clearTimeout(failedLoadTimer);
      setLoadingNote(
        'The app could not start in this browser. Please reload the page.',
        true,
      );
    }
  },
});
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
