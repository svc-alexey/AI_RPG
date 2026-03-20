---
name: flutter-restart
description: >-
  Stops any running Flutter instance and starts the app fresh. Use when the
  user says "перезапусти приложение", "restart app", "hot restart", "перезапуск",
  "локальная сеть", "запуск в сети", "web",
  or wants to avoid multiple sessions.
---

# Flutter App Restart

## When to Apply

Use when the user asks to restart, reload, or re-run the Flutter application. Always use **stop-then-start** to avoid multiple sessions.

## Default Action (Always)

1. **Stop** any processes on ports 8080, 8081, 8765 (frees the port).
2. **Start** `flutter run` in project root (`d:\AI_PRG`).

## How to Execute

Run the restart script (stops old, starts new):

```powershell
cd d:\AI_PRG; .\.cursor\skills\flutter-restart\scripts\restart.ps1
```

For web server (network access from other devices):

```powershell
cd d:\AI_PRG; .\.cursor\skills\flutter-restart\scripts\restart.ps1 -Web
```

Run in background so the user can continue working.

## Script Options

- `-Web` — run on web-server (host `0.0.0.0`, port 8080) for local network access
- `-Device <name>` — run on specific device (e.g. chrome, windows)
- Default: `flutter run` (auto-select device)

## User Shortcut (Cursor)

- **Ctrl+Shift+P** → "Flutter: Hot Restart" (only if app already running)
