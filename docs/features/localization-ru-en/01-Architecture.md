# Architecture Plan: localization-ru-en

## Контекст

Фича переводит проект с разрозненных строк на единый localization layer.

## Архитектурное решение

1. Ввести единый слой локализации на уровне приложения.
2. Хранить выбранный язык в настройках приложения.
3. Передавать язык в AI-слой, чтобы prompt и fallback-тексты менялись вместе с UI.
4. Поддерживать два полноценных режима: `ru` и `en`.

## Затронутые области

1. `lib/src/app/*`
2. `lib/src/features/*`
3. `lib/src/core/services/*`
4. `lib/src/core/repositories/settings_repository.dart`

## Риски

1. Частичная локализация без AI-слоя.
2. Потеря синхронизации между UI и prompt language.
