# AI_PRG: Настройки проекта (SpecKit + Codex)

## 1. Обязательные переменные среды
1. `CODEX_HOME=D:\AI_PRG\.codex`
2. Для PowerShell один раз:
```powershell
setx CODEX_HOME "D:\AI_PRG\.codex"
```

## 2. Кодировка консоли на Windows
SpecKit CLI должен запускаться в UTF-8.

Рекомендуемый запуск:
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

## 4. Локальный quality gate
```powershell
flutter analyze
flutter test
```

## 5. Политика локализации
1. Язык приложения по умолчанию: русский (`ru`).
2. Обязательный второй язык: английский (`en`).
3. Все пользовательские строки должны проектироваться через локализацию.
4. Переключатель языка должен влиять и на UI, и на AI-слой.
5. Для новых спецификаций и планов мультиязычность (`ru` + `en`) считается обязательным требованием.

## 6. Обязательный pipeline для новых фич
1. Если пользователь просит разработать новую фичу, и задача не является bugfix, сначала обязателен архитектурный анализ и план.
2. После архитектурного этапа обязателен аналитический этап с формированием PRD или feature-spec.
3. Только после этого допускается этап разработки.
4. После разработки обязателен этап тестирования и проверок.
5. Порядок ролей для новых фич фиксированный:
   - архитектор
   - аналитик
   - разработчик
   - тестировщик
6. Для исправления ошибок можно использовать сокращенный поток, если изменение не требует пересмотра архитектуры и требований.

## 7. Контекст для SpecKit
1. При создании любой новой спецификации нужно учитывать:
   - `.specify/memory/constitution.md`
   - `.specify/memory/project-context.md`
   - `.specify/memory/project-settings.md`
   - `PRD.md`
   - `Architecture.md`
   - `FlutterRules.md`
   - `ImplementationPlan.md`
   - `docs/features/CATALOG.md`
   - `docs/features/COMMANDS.md`
2. Если новая фича противоречит этим документам, сначала обновляются документы, затем продолжается реализация.

## 8. Правило для implementation plan
1. Отдельный implementation plan ведется в markdown-файле как checklist.
2. Все этапы и подзадачи в implementation plan должны быть оформлены через чекбоксы:
   - `[ ]` не выполнено
   - `[x]` выполнено
3. По мере выполнения задач чекбоксы обязаны обновляться.
4. Если работа разбивается на этапы, у каждого этапа должен быть свой набор чекбоксов.
5. Implementation plan должен в любой момент показывать, что уже сделано, что выполняется и что еще осталось.

## 9. Правило для feature-папок
1. Любая новая фича, если это не bugfix, после добавления в implementation plan должна получить отдельную папку в `docs/features/<feature-slug>/`.
2. Папка создается по шаблону из `docs/features/_template/`.
3. Одновременно фича должна быть зарегистрирована в `docs/features/CATALOG.md`.
4. Внутри feature-папки обязаны существовать:
   - `01-Architecture.md`
   - `02-PRD.md`
   - `03-Implementation.md`
   - `04-QA.md`
5. Перед заполнением feature-документов нужно учитывать:
   - `PRD.md`
   - `Architecture.md`
   - `FlutterRules.md`
   - `ImplementationPlan.md`
   - `docs/features/CATALOG.md`
   - `docs/features/COMMANDS.md`
   - `.specify/memory/constitution.md`
   - `.specify/memory/project-context.md`
   - `.specify/memory/project-settings.md`
6. Реализация не должна стартовать, пока не заполнены архитектурный и аналитический этапы, кроме явного исключения для bugfix.
7. Допускается, что пока одна фича реализуется, другие фичи могут параллельно проходить архитектурный или аналитический этап.
8. Для новой фичи каждый ролевой этап должен вестись в отдельном окне или треде:
   - отдельное окно архитектора
   - отдельное окно аналитика
   - отдельное окно разработчика
   - отдельное окно тестировщика
9. Смешивать несколько ролей в одном окне допускается только для локального bugfix или явного исключения.
