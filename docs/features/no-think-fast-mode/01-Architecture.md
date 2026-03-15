# Architecture Plan: no-think-fast-mode

## Контекст

Фича ускоряет ответы локальной модели LM Studio за счет `/no_think` и более строгого response format.

## Архитектурное решение

1. Использовать fast mode только там, где это уместно для LM Studio.
2. Сохранять fallback на обычный режим, если fast mode ломает ответ.
3. Не ломать structured JSON contract.

## Затронутые области

1. `ai_settings.dart`
2. `settings_screen.dart`
3. `openai_compatible_ai_client.dart`

## Риски

1. `/no_think` может работать нестабильно на разных моделях.
2. Ускорение может ухудшать качество ответа без fallback.
