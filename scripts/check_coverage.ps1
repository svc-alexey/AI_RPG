param(
    [double]$FlutterHardThreshold = 20.0,
    [double]$FlutterSoftThreshold = 25.0,
    [double]$BackendHardThreshold = 55.0,
    [double]$BackendSoftThreshold = 60.0,
    [switch]$SkipFlutter,
    [switch]$SkipBackend
)

$ErrorActionPreference = "Stop"
$failed = $false
$flutterPct = 0.0
$backendPct = 0.0

# ── Flutter ──────────────────────────────────────────────────────────
if (-not $SkipFlutter) {
    Write-Host "=== Flutter Coverage ===" -ForegroundColor Cyan

    $lcov = "coverage/lcov.info"
    if (-not (Test-Path $lcov)) {
        Write-Host "ERROR: $lcov not found. Run flutter test --coverage first." -ForegroundColor Red
        exit 1
    }

    $lf = 0; $lh = 0
    Get-Content $lcov | ForEach-Object {
        if ($_ -match '^LF:(\d+)') { $lf += [int]$Matches[1] }
        if ($_ -match '^LH:(\d+)') { $lh += [int]$Matches[1] }
    }
    $flutterPct = if ($lf -gt 0) { [math]::Round($lh / $lf * 100, 1) } else { 0 }

    Write-Host "  Lines hit : $lh / $lf ($flutterPct%)"

    if ($flutterPct -lt $FlutterHardThreshold) {
        Write-Host "  FAIL: below hard threshold $FlutterHardThreshold%" -ForegroundColor Red
        $failed = $true
    } elseif ($flutterPct -lt $FlutterSoftThreshold) {
        Write-Host "  WARN: below soft threshold $FlutterSoftThreshold%" -ForegroundColor Yellow
    } else {
        Write-Host "  PASS" -ForegroundColor Green
    }
} else {
    Write-Host "=== Flutter Coverage SKIPPED ===" -ForegroundColor DarkGray
}

# ── Backend ──────────────────────────────────────────────────────────
if (-not $SkipBackend) {
    Write-Host "=== Backend Coverage ===" -ForegroundColor Cyan

    Push-Location backend/symmetry
    try {
        $output = python -m pytest --cov=app --cov-report=term 2>&1
        $exitCode = $LASTEXITCODE

        $totalLine = $output | Select-String -Pattern '^TOTAL\s+\d+\s+(\d+)\s+(\d+)%'
        $backendPct = 0.0
        if ($totalLine -and $totalLine.Matches[0].Groups[2].Value) {
            $backendPct = [double]$totalLine.Matches[0].Groups[2].Value
        }

        Write-Host "  Coverage : $backendPct%"

        if ($exitCode -ne 0) {
            Write-Host "  FAIL: tests did not pass (exit $exitCode)" -ForegroundColor Red
            $failed = $true
        } elseif ($backendPct -lt $BackendHardThreshold) {
            Write-Host "  FAIL: below hard threshold $BackendHardThreshold%" -ForegroundColor Red
            $failed = $true
        } elseif ($backendPct -lt $BackendSoftThreshold) {
            Write-Host "  WARN: below soft threshold $BackendSoftThreshold%" -ForegroundColor Yellow
        } else {
            Write-Host "  PASS" -ForegroundColor Green
        }
    } finally {
        Pop-Location
    }
} else {
    Write-Host "=== Backend Coverage SKIPPED ===" -ForegroundColor DarkGray
}

# ── Summary ──────────────────────────────────────────────────────────
Write-Host "=== Summary ===" -ForegroundColor Cyan
if (-not $SkipFlutter) { Write-Host "  Flutter : $flutterPct% (hard=$FlutterHardThreshold%, soft=$FlutterSoftThreshold%)" }
if (-not $SkipBackend) { Write-Host "  Backend : $backendPct% (hard=$BackendHardThreshold%, soft=$BackendSoftThreshold%)" }

if ($failed) {
    Write-Host "Coverage gates FAILED." -ForegroundColor Red
    exit 1
}
Write-Host "Coverage gates PASSED." -ForegroundColor Green
exit 0
