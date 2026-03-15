# Implementation: quality-pass-stabilization

## Ссылка на общий план

Связанный этап в [ImplementationPlan.md](D:/AI_PRG/ImplementationPlan.md): `Этап 5. Quality Pass и стабилизация`

## Чеклист реализации

- [x] Архитектурный этап завершен
- [x] PRD завершен
- [x] Реализация начата
- [ ] Реализация завершена
- [ ] Проверки выполнены
- [ ] QA-этап завершен

## Первый срез реализации

- [x] Исправить high-signal lint issues в `New Game` и `Settings`
- [x] Добавить smoke/widget tests для `New Game -> Chat`
- [ ] Добавить regression checklist для AI error path

## Заметки

Стартуем не с полной зачистки всех 74 info/lint, а с небольшого и безопасного набора, который дает реальную пользу.
После первого прохода:

- `flutter test` проходит
- analyzer noise снижен с 74 до 63 issues
- `New Game` и `Settings` получили более безопасную async-логику
