# Implementation: Campaign Modules

## Статус

- [x] Архитектура заполнена
- [x] PRD заполнен
- [ ] Реализация начата
- [ ] Реализация завершена
- [ ] Проверки пройдены

## Задачи

### Фаза 1. Domain и storage

- [ ] Ввести `CampaignModule` / `CampaignCapability` model
- [ ] Определить always-on `Core State`
- [ ] Разделить module-specific state slices и сущности хранения
- [ ] Добавить миграцию старых кампаний в module-aware схему

### Фаза 2. Initial activation

- [ ] Добавить module presets для `fantasy`, `detective`, `sciFi`
- [ ] Добавить prompt-based resolver для начального набора модулей
- [ ] Показать активные модули на review step создания кампании

### Фаза 3. Runtime activation и extraction

- [ ] Добавить `CampaignModuleResolver`
- [ ] Добавить `EntityExtractionService`
- [ ] Начать с rule-based extraction для `Inventory`
- [ ] Расширить extraction на `Companions`, `Notes`, `Vitality`, `Resources`
- [ ] Добавить reconciliation перед persistence

### Фаза 4. UI и уведомления

- [ ] Сделать module-aware sidebar
- [ ] Добавить transient overlay notifications
- [ ] Подсвечивать newly unlocked modules
- [ ] Сохранить mobile-first поведение drawer/panels

### Фаза 5. Deterministic systems

- [ ] Привязать `DiceEngine` к `Checks` module
- [ ] Ограничить combat/check reducers активными модулями
- [ ] Обновить prompt contract: AI narrates resolved outcomes

## Примечания

- Первый срез может быть read-only для части модулей, если это ускорит доставку.
- Самый безопасный старт: `Inventory` -> `Companions` -> `Notes` -> `Vitality` -> `Resources` -> `Progression`.
- High-impact auto-activation стоит вводить позже, чем low-risk модули.
