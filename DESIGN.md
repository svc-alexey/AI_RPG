---
version: alpha
name: AI_PRG (Aether)
description: Тёмный фэнтези-/нуар UI для нарративной RPG на Flutter. Mobile-first, ru/en, сервер-авторитативный бэкенд Symmetry. Визуальный язык — «Aether» noir, без тяжёлых full-screen CustomPaint-фонов; один слой градиентного backdrop.
colors:
  background: "#0A0908"
  background-elevated: "#0F0D0B"
  background-top: "#141210"
  surface-panel: "#12100E"
  surface-panel-soft: "#1A1816"
  border-subtle: "#1A1816"
  border-warm-hint: "#3D3328"
  text-primary: "#E8E4E0"
  text-muted: "#7A7570"
  text-dim: "#5A5550"
  text-narrative: "#C8C4C0"
  accent: "#C87941"
  accent-hover: "#D4956A"
  accent-soft-surface: "#1A1512"
  on-accent: "#0A0908"
  gold: "#BFA76F"
  success: "#34D399"
  gradient-end: "#0A0908"
typography:
  display-hero:
    fontFamily: Playfair Display
    fontSize: 72px
    fontWeight: 300
    lineHeight: 0.95
    letterSpacing: -1px
  display-large:
    fontFamily: Playfair Display
    fontSize: 58px
    fontWeight: 300
    lineHeight: 1.1
    letterSpacing: -0.5px
  headline-large:
    fontFamily: Playfair Display
    fontSize: 50px
    fontWeight: 400
  headline-medium:
    fontFamily: Playfair Display
    fontSize: 42px
    fontWeight: 400
  headline-small:
    fontFamily: Playfair Display
    fontSize: 30px
    fontWeight: 500
  title-large:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: 600
    letterSpacing: 0.2px
  title-medium:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: 600
    letterSpacing: 0.1px
  body-large:
    fontFamily: Inter
    fontSize: 15px
    fontWeight: 400
    lineHeight: 1.6
  body-medium:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: 400
    lineHeight: 1.5
  body-small:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: 400
    lineHeight: 1.4
  label-action:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: 600
    letterSpacing: 0.5px
  app-bar-title:
    fontFamily: Playfair Display
    fontSize: 22px
    fontWeight: 400
rounded:
  sm: 12px
  md: 16px
  lg: 22px
  full: 999px
spacing:
  xs: 8px
  sm: 10px
  md: 12px
  lg: 16px
  xl: 20px
  xxl: 24px
components:
  button-filled-primary:
    backgroundColor: "{colors.accent}"
    textColor: "{colors.on-accent}"
    rounded: "{rounded.sm}"
    padding: 16px
    size: 52px
  button-filled-primary-hover:
    backgroundColor: "{colors.accent-hover}"
    textColor: "{colors.on-accent}"
  button-outlined:
    backgroundColor: "transparent"
    textColor: "{colors.text-primary}"
    rounded: "{rounded.sm}"
    padding: 16px
  card-material:
    backgroundColor: "{colors.background-elevated}"
    textColor: "{colors.text-primary}"
    rounded: "{rounded.md}"
  card-aether:
    backgroundColor: "{colors.surface-panel}"
    textColor: "{colors.text-primary}"
    rounded: "{rounded.lg}"
  text-field:
    backgroundColor: "{colors.background-elevated}"
    textColor: "{colors.text-primary}"
    rounded: "{rounded.sm}"
    padding: 16px
  chip:
    backgroundColor: "{colors.background-elevated}"
    textColor: "{colors.text-primary}"
    rounded: "{rounded.full}"
  segmented-control-selected:
    backgroundColor: "{colors.accent-soft-surface}"
    textColor: "{colors.text-primary}"
    rounded: "{rounded.sm}"
  link-text:
    textColor: "{colors.accent-hover}"
    typography: "{typography.label-action}"
  progress-indicator:
    backgroundColor: "{colors.accent}"
  switch-track-on:
    backgroundColor: "{colors.accent}"
  app-bar:
    backgroundColor: "transparent"
    textColor: "{colors.text-primary}"
    typography: "{typography.app-bar-title}"
  body-narrative:
    textColor: "{colors.text-narrative}"
    typography: "{typography.body-large}"
  status-success:
    textColor: "{colors.success}"
  accent-secondary:
    textColor: "{colors.gold}"
---

# AI_PRG — Aether design system (Stitch / DESIGN.md)

## Overview

**Продукт:** нарративная RPG на Flutter, кампании и состояние мира с сервера (Symmetry), клиент — настройки, сессия, язык, опциональные user-owned AI keys. **UX:** mobile-first, поддержка desktop/web; **локализация:** русский и английский на одном уровне качества.

**Бренд и стиль:** тёмный **noir / fantasy lounge** — тёплые коричнево-янтарные акценты на почти чёрном фоне, высокий контраст текста, без «игрового неона» и без перегруженных анимированных фонов. Типографика: **Playfair Display** для заголовков и лэндинга, **Inter** для интерфейса и длинного текста. **Material 3** (`useMaterial3: true`) с кастомной палитрой; у кнопок и интерактивов отключены material splash/highlight (спокойные hover-состояния).

**Паттерн оболочки:** весь экран — **статичный линейный градиент** «сверху светлее, к низу глубже» (см. токены фона), без многослойных шейдеров на весь вьюпорт (важно для Web/CanvasKit и стабильного FPS). Поверх — панели/карточки с лёгкой рамкой и при необходимости мягким свечением акцента (highlight).

## Colors

- **background / background-top / background-elevated** — уровни «пола» и поднятых плоскостей; весь UI остаётся в тёмном диапазоне, без светлой темы в текущей спецификации.
- **text-primary** — основной копирайт и заголовки внутри панелей; **text-muted** — вторичные подписи; **text-dim** — плейсхолдеры и неактивное; **text-narrative** — длинные повествовательные блоки (легче, чем primary, но читаемо).
- **accent** — CTA, ссылки, focus border полей, прогресс, выделение; **accent-hover** — состояния наведения/усиленный акцент; **gold** — вторичные акценты (схема `secondary` в Theme).
- **success** — редкие положительные системные сигналы (не заменяет accent для основных CTA).
- **surface-panel** / **surface-panel-soft** — карточки и вложенные панели; **border-subtle** — сплошная деликатная обводка; **border-warm-hint** — ближайший solid к полупрозрачной бронзовой грани в Flutter (`0x26C87941`); в Figma — stroke **accent** ~15% opacity на тёмном фоне.

Контраст: пары **text на surface** и **on-accent на accent** должны оставаться в зоне читаемости (ориентир WCAG AA для основного текста на панелях и кнопках).

## Typography

- **Display / headlines** — Playfair, крупные кегля, плотные интерлиньяжи на hero-уровне; emotional, «книжная» витрина.
- **Title (large/medium)** — Inter semibold, плотный интерфейсный ритм, заголовки секций и карт.
- **Body** — Inter regular; увеличенный `lineHeight` у body-large для длинных формулировок; подписи и метки — body-small.
- **label-action** — капс-ощущение за счёт `letterSpacing`, используется для кнопок и сильных призывов.
- **app-bar-title** — Playfair 22, выравнивание по бренду на внутренних экранах.

В продакшене шрифты подключаются через **google_fonts**; для Stitch при отсутствии Playfair/Inter в окружении — ближайшие serif / neo-grotesk с теми же весами и иерархией размеров.

## Layout

- **Сетка:** fluid-колонка с горизонтальными отступами, зависящими от ширины (от ~8px на очень узких телефонах до ~24px на desktop). Вертикальные шаги: **sectionSpacing** 8–16px, **blockSpacing** 18–24px между крупными блоками; внутри карточек — **cardPadding** 10–24px по брейкпоинтам.
- **Брейкпоинты (логика приложения):** <360 phoneSmall, <390 phone, <600 phoneLarge, <1024 tablet, иначе desktop.
- **Контейнеры:** максимальная ширина контентных колонок на широких экранах — по смыслу экрана (лендинг, библиотека, настройки); на mobile контент на всю ширину с `pagePadding`.
- **Навигация:** в текущем приложении преобладает **императивный Navigator** (`MaterialPageRoute`); глубокие вложенные роут-деревья в спецификации визуала не требуются — важен последовательный отступ и поведение AppBar/кнопок «назад».

Токены **spacing** в front matter — базовая шкала; точные брейкпоинт-зависимые значения дублируют правила `AppResponsiveData` в коде.

## Elevation & Depth

- **Плоскость:** по умолчанию тени минимальны; «глубина» за счёт **границы** и **лёкого внутреннего тепла** панели, а не сильного drop shadow.
- **Карточка Aether (highlight):** мягкое **свечение** акцентом (diffuse, большой blur, небольшой spread), без резкого чёрного umbra.
- **Material Card в теме:** `elevation: 0`, читаемая обводка `border-subtle` / `panel` границы; фон чуть приподнят относительно backdrop.
- **App bar:** прозрачный фон, без elevation под скроллом, чтобы сливаться с градиентом окна.

## Shapes

- **Поля ввода, кнопки, сегменты** — **12px** радиус (`rounded.sm`).
- **Material Card (Theme)** — **16px**; **AetherCard** / крупные плитки — **14–22px** в зависимости от брейкпоинта (`cardRadius` responsive), в токенах агрегировано как `md` / `lg`.
- **Chips** — полный pill (**full** = 999px).
- **Скаффолд** фона без скруглений; скругления у контентных панелей.

## Components

- **Button filled (primary):** фон `accent`, текст `on-accent`, min height 52px, горизонтальные отступы ~22px, без material splash; disabled — приглушённый panel + text-dim.
- **Button outlined:** прозрачный фон, обводка `border-subtle`, тот же min height; для вторичных действий на тёмном фоне.
- **Text button / link:** цвет `accent-hover`, стиль `label-action`.
- **Text field:** заливка `background-elevated`, бордер по умолчанию как у enabled border; **focused** — бордер `accent` ~1.2px; вертикальный padding 16px, горизонтальный ~18px.
- **Card:** вариант **material** (плотный elevated фон + рамка) и **Aether** (более прозрачная панель, опциональный highlight glow).
- **Chips** — подпись body, выбранное состояние с мягким `accent-soft-surface`.
- **Segmented control** — выбран сегмент на `accent-soft-surface`, общая рамка `border-subtle`.
- **Switch** — track в ON с полупрозрачным accent (в коде alpha ~0.55); thumb `text-primary`.
- **Icon buttons** — иконки `text-muted`, hover-фон `surface-panel-soft`, без всплеска.
- **Progress** — цвет `accent` на тёмном фоне.
- **Обложки / медиа в библиотеке историй** — визуально карточные, с уважением к safe area и сетке; на web загрузка с авторизованным доступом (не `Image.network` без заголовков — см. продуктовые инварианты).

## Do's and Don'ts

**Do**

- Сохранять **тёмный nocturnal** тон, тёплую бронзу и читаемые серые для вторичного текста.
- Использовать **две семейства** чётко: Playfair для «лица» продукта, Inter для UI и чтения.
- Делать **крупные тач-таргеты** (кнопки ~52px высотой), просторные поля ввода.
- Проверять **ru и en** на одних экранах: переносы, длины кнопок, не обрезать смысл.
- Следить за **производительностью:** не строить тяжёлый `CustomPaint` на весь фон; один градиентный слой — норма.

**Don't**

- Не вводить **светлую тему** в макетах как дефолт без отдельного согласования (текущая спецификация — dark-only).
- Не заменять accent радужными градиентами, неоновыми обводками и «кислотным» flat UI — это ломает Aether.
- Не полагаться на **сырой текст нейросети** как на источник истины для игрового состояния (продуктовый инвариант) — визуальные макеты должны показывать **серверно подтверждённые** состояния там, где речь о кампании.
- Не добавлять **второй глобальный service locator** для стиля — токены живут в Theme + Aether-виджетах; Stitch-экспорт должен ссылаться на эту схему.
- Не сокращать **доступность**: мелкий серый на чёрном только для третьичного текста, не для основного сюжетного абзаца.

---

*Соответствует формату [DESIGN.md (Google Labs design.md)](https://github.com/google-labs-code/design.md) / [Stitch — обзор DESIGN.md](https://stitch.withgoogle.com/docs/design-md/overview). Проверка: `npx @google/design.md lint` (при необходимости).*
