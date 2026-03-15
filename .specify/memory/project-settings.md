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

## 5. Политика локализации
1. Язык приложения по умолчанию: русский (`ru`).
2. Обязательный второй язык: английский (`en`).
3. Все пользовательские строки должны проектироваться через локализацию, а не оставаться захардкоженными только на одном языке.
4. Переключатель языка должен влиять не только на UI, но и на AI-слой:
   - язык системного промпта;
   - язык narrations и choices;
   - встроенные fallback-ответы.
5. Для новых спецификаций, планов и задач в SpecKit мультиязычность (`ru` + `en`) считается обязательным функциональным требованием.
