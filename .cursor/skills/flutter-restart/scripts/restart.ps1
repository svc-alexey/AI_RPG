# Stops any Flutter processes (by port) and starts fresh.
# Run from project root or pass path.
# If tool/ai_local_defines.json exists, passes --dart-define-from-file (see tool/ai_local_defines.example.json).

param(
  [string]$ProjectRoot = "D:\AI_PRG",
  [string]$Device = "",
  [switch]$Web
)

$ErrorActionPreference = "SilentlyContinue"

# Kill processes on Flutter web ports to avoid "address already in use"
$ports = @(8080, 8081, 8765)
foreach ($port in $ports) {
  netstat -ano | Select-String ":$port\s" | ForEach-Object {
    if ($_ -match '\s+(\d+)\s*$') {
      $pid = $Matches[1]
      if ($pid -match '^\d+$') {
        taskkill /F /PID $pid 2>$null
      }
    }
  }
}

Start-Sleep -Seconds 2

Set-Location $ProjectRoot

$defineFile = Join-Path $ProjectRoot "tool\ai_local_defines.json"
$flutterArgs = [System.Collections.Generic.List[string]]::new()
$flutterArgs.Add("run")
$flutterArgs.Add("--no-pub")
if (Test-Path $defineFile) {
  $flutterArgs.Add("--dart-define-from-file=tool/ai_local_defines.json")
}

if ($Web) {
  $flutterArgs.Add("-d")
  $flutterArgs.Add("web-server")
  $flutterArgs.Add("--web-hostname")
  $flutterArgs.Add("0.0.0.0")
  $flutterArgs.Add("--web-port")
  $flutterArgs.Add("8080")
} elseif ($Device) {
  $flutterArgs.Add("-d")
  $flutterArgs.Add($Device)
} else {
  $flutterArgs.Add("-d")
  $flutterArgs.Add("chrome")
}

& flutter @flutterArgs
