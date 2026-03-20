# Stops any Flutter processes (by port) and starts fresh.
# Run from project root or pass path.

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

if ($Web) {
  flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080 --no-pub
} elseif ($Device) {
  flutter run -d $Device --no-pub
} else {
  # При нескольких устройствах Flutter требует явный выбор; по умолчанию — Chrome
  flutter run -d chrome --no-pub
}
