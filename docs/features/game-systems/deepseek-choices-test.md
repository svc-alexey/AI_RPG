# DeepSeek Choices Structured Output Test

Date: 2026-05-18
Model: deepseek-v4-flash
Base URL: https://api.deepseek.com/v1
Scenarios tested: 10

## Summary

- **Success:** 10/10 (100%)
- **Failed:** 0/10
- **Average choices:** 3.0
- **Average latency:** 2.8s
- **Average tokens:** 1625
- **Formats:** strings: 10

## Detailed Results

### combat_ambush -- PASS

- Choices: 3 (format: strings)
- Latency: 3.25s
- Tokens: 300 completion / 1649 total
- Finish: stop
- Narration: Ты выхватываешь меч и бросаешься на ближайшего бандита. Тот не ожидает такой дерзости — его глаза расширяются, но он усп
- Labels:
  - Мощный выпад
  - Отступить и оценить
  - Крикнуть подмогу

### combat_boss -- PASS

- Choices: 3 (format: strings)
- Latency: 2.94s
- Tokens: 332 completion / 1687 total
- Finish: stop
- Narration: Ты вытягиваешь руку, и из ладони вырывается огненный шар, ударяя в грудь каменного голема. Взрыв сотрясает пещеру, но го
- Labels:
  - Уклониться
  - Применить щит
  - Атаковать мечом

### combat_defense -- PASS

- Choices: 3 (format: strings)
- Latency: 2.69s
- Tokens: 218 completion / 1567 total
- Finish: stop
- Narration: Ты вскидываешь дробовик и стреляешь в ближайшего мутанта. Грохот выстрела разносится по бункеру, мутант падает замертво.
- Labels:
  - Перезарядить и стрелять
  - Отступить в коридор
  - Крикнуть, отвлекая

### dialogue_negotiation -- PASS

- Choices: 3 (format: strings)
- Latency: 2.59s
- Tokens: 262 completion / 1631 total
- Finish: stop
- Narration: Контрабандист, грузный мужчина в потертой куртке, щурится из-под капюшона. «Информация? — переспрашивает он, почесывая ш
- Labels:
  - Сдать маршруты патрулей
  - Раскрыть данные о грузе
  - Предложить нейтральную информацию

### dialogue_interrogation -- PASS

- Choices: 3 (format: strings)
- Latency: 2.5s
- Tokens: 273 completion / 1632 total
- Finish: stop
- Narration: Пленный культист, мужчина в потрёпанной одежде с вытатуированными на шее рунами, отводит взгляд, когда ты встречаешь его
- Labels:
  - Схватить за горло
  - Предложить сделку
  - Угрожать оружием

### dialogue_persuasion -- PASS

- Choices: 3 (format: strings)
- Latency: 2.92s
- Tokens: 274 completion / 1619 total
- Finish: stop
- Narration: You kneel on the cool marble floor of the Sunlit Hall, the ancient treaty scroll held high. The Queen of Thorns, Elara M
- Labels:
  - Pledge loyalty
  - Offer a trade
  - Wait silently

### exploration_search -- PASS

- Choices: 3 (format: strings)
- Latency: 2.35s
- Tokens: 195 completion / 1544 total
- Finish: stop
- Narration: Вы внимательно осматриваете поляну. Под старым дубом, среди мха, вы замечаете слабое свечение — это светящиеся грибы. Он
- Labels:
  - Собрать грибы
  - Изучить следы
  - Прислушаться

### exploration_discovery -- PASS

- Choices: 3 (format: strings)
- Latency: 2.97s
- Tokens: 326 completion / 1676 total
- Finish: stop
- Narration: Ты зажигаешь факел, и его дрожащий свет выхватывает из тьмы грубо высеченные стены катакомб. Влажный воздух наполнен зап
- Labels:
  - Спуститься на звук воды
  - Подняться к решётке
  - Исследовать стены на предмет ловушек

### exploration_travel -- PASS

- Choices: 3 (format: strings)
- Latency: 2.87s
- Tokens: 233 completion / 1567 total
- Finish: stop
- Narration: You walk the cracked asphalt, the sun beating down. Dust devils dance in the distance. Ahead, a rusted sign dangles: "Ju
- Labels:
  - Take cover behind wrecked car
  - Climb water tower for view
  - Wave them down openly

### social_mystery -- PASS

- Choices: 3 (format: strings)
- Latency: 3.05s
- Tokens: 324 completion / 1682 total
- Finish: stop
- Narration: Вы кружитесь в вальсе с графиней Элизой, её серебристое платье мерцает в свете люстр. Она улыбается, но в глазах мелькае
- Labels:
  - Поблагодарить и отойти
  - Продолжить расспросы
  - Пригласить на танец маркиза

## Conclusion

DeepSeek стабильно генерирует structured choices (10/10).
Можно переходить к Phase 0.2 -- Choices JSON contract.

**Важно:** формат choices -- strings: 10. В Phase 0.2 нужно обновить системный промпт
чтобы модель возвращала объекты {id, label, hint, tag} вместо строк.
