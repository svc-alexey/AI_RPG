# Architecture Plan: docs-encoding-sync

## 1. Контекст

Перед началом учитываются:

- [PRD.md](D:/AI_PRG/PRD.md)
- [Architecture.md](D:/AI_PRG/Architecture.md)
- [FlutterRules.md](D:/AI_PRG/FlutterRules.md)
- [.specify/memory/project-context.md](D:/AI_PRG/.specify/memory/project-context.md)
- [.specify/memory/project-settings.md](D:/AI_PRG/.specify/memory/project-settings.md)

## 2. Цель этапа

Сделать проектные документы читаемыми, согласованными и пригодными для дальнейшего использования SpecKit как source of truth.

## 3. Архитектурное решение

1. Не трогать код продукта, если задача касается только документации.
2. Переписывать битые markdown-файлы целиком в чистом UTF-8, а не пытаться "лечить" их точечно.
3. Синхронизировать документы сверху вниз:
   - продуктовые документы
   - архитектурные документы
   - SpecKit memory
   - feature workflow и шаблоны
4. Обновить implementation plan и каталог фич так, чтобы stage 4 был виден как отдельная завершенная работа.

## 4. Затронутые области

1. `PRD.md`
2. `Architecture.md`
3. `FlutterRules.md`
4. `ImplementationPlan.md`
5. `.specify/memory/*`
6. `docs/features/*`

## 5. Риски

1. Можно случайно потерять часть ранее зафиксированных правил.
2. Можно переписать документ слишком абстрактно и потерять привязку к реальному MVP.
3. Можно оставить часть feature-доков в битом состоянии и получить смешанный scope.

## 6. Границы этапа

В рамках этого этапа:

- чистим кодировку
- синхронизируем правила и roadmap
- не меняем код приложения, кроме случаев, когда это требуется для ссылочной консистентности документов
