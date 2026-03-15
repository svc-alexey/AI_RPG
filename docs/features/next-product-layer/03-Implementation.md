# Implementation: Narrative Depth

## Статус

- [x] Архитектура заполнена
- [x] PRD заполнен
- [ ] Реализация начата
- [ ] Реализация завершена
- [ ] Проверки пройдены

## Задачи

- [ ] Расширить system prompt в `openai_compatible_ai_client.dart` инструкциями по narrative depth (ru/en)
- [ ] Добавить ограничения длины narration для fast mode
- [ ] Проверить совместимость с `campaign_memory_manager` и `game_engine`
- [ ] Ручной тест: сцена с диалогом и эмоциями
- [ ] `flutter analyze` и `flutter test` без ошибок

## Примечания

- Реализация ограничена промпт-слоем; изменения state engine не требуются.
- Опциональные поля TurnResult (mood, atmosphere) — фаза 2, после базовой реализации.
