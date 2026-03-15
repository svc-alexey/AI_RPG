# Architecture Plan: summary-memory

## Контекст

Фича нужна для устойчивого контекста длинной кампании и более стабильной передачи состояния в AI.

## Архитектурное решение

1. Не передавать в AI весь сырой лог сообщений как единственный источник контекста.
2. Ввести отдельную memory-структуру кампании.
3. Хранить:
   - rolling summary
   - active goal
   - active situation
   - recent turns
4. Обновлять memory только после валидного завершенного хода.

## Затронутые области

1. `campaign_models.dart`
2. `game_engine.dart`
3. `openai_compatible_ai_client.dart`
4. `chat_screen.dart`

## Риски

1. Потеря деталей при чрезмерном сжатии контекста.
2. Несовместимость со старыми save без fallback.
