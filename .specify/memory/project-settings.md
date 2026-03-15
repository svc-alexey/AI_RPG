# AI_PRG: Настройки проекта (SpecKit + Codex)

## 1. Обязательные переменные среды
1. `CODEX_HOME=D:\AI_PRG\.codex`
2. Для PowerShell (однократно):
```powershell
setx CODEX_HOME "D:\AI_PRG\.codex"
```

## 2. Кодировка консоли (Windows)
SpecKit CLI использует rich-баннеры, поэтому при `cp1251` возможна ошибка `UnicodeEncodeError`.

Рекомендуемый запуск команд SpecKit:
```powershell
$env:PATH = "C:\Users\Alexey\.local\bin;$env:PATH"
$env:PYTHONIOENCODING = "utf-8"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
specify check
```

## 3. Базовые команды SpecKit для проекта
```powershell
specify init . --ai codex --script ps --force
/speckit.constitution
/speckit.specify
/speckit.plan
/speckit.tasks
/speckit.implement
```

## 4. Локальный quality gate (Flutter)
```powershell
flutter analyze
flutter test
```
