# Phase 5: Design/UI/UX Audit — Отчёт

**Дата:** 2026-05-04
**Метод:** Гибридный — brower-based (HTML shell) + code-level audit (Flutter widgets)
**Охват:** Home (P0), New Game Wizard (P0), Chat Screen (P0), Story Library (P1), Settings (P1), Map (P2 — WIP, поверхностно)

---

## 1. Общая оценка

| Категория | Оценка | Комментарий |
|---|---|---|
| Визуальная согласованность | 🟢 8/10 | AetherPalette используется системно, 1 хардкод-цвет |
| Типографика | 🟡 6/10 | Playfair + Inter consistent, но >7 размеров |
| Spacing grid (8px) | 🟢 8/10 | Responsive-токены покрывают spacing |
| Состояния (loading/empty/error) | 🟢 8/10 | Обработаны везде, minor inconsistencies |
| Mobile-first | 🟢 9/10 | Canonical breakpoints, stacked→sidebar layout |
| Доступность (accessibility) | 🔴 4/10 | Touch targets, Semantics — основные проблемы |
| Соответствие гайдлайнам | 🟡 7/10 | Ряд расхождений с UI_UX_Guidelines.md |

---

## 2. Поэкранный аудит

### 2.1 Home Screen (P0) — `home_screen.dart`

**Положительное:**
- `SafeArea` + `ConstrainedBox` + `ScrollConfiguration` (без web-скроллбара)
- AetherPageReveal для анимаций контента
- Bento-row: Row на wide, Column на mobile
- Все 4 состояния sessionState обработаны (data/loading/error + signed in/out)
- RepaintBoundary на карточках с hover-анимацией

**Проблемы:**

| # | Severity | Файл:строка | Описание |
|---|---|---|---|
| H1 | 🟡 Medium | `home_screen.dart:221` | Хардкод-цвет `Color(0xFF3A3530)` — заменить на `AetherPalette.textDim` |
| H2 | 🟡 Medium | `home_screen.dart:147` | Settings IconButton size=22 — ниже 48dp touch target |
| H3 | 🟡 Medium | `home_screen.dart:168` | Max-width 920px (guideline: 760px) |
| H4 | 🔴 High | Весь экран | Нет `Semantics` / `SemanticsProperties` для скрин-ридеров |
| H5 | 🟢 Low | Строки 252-256 | ~15 разных font-size — guideline рекомендует ≤3-4 |
| H6 | 🟢 Low | Строки 641, 1011 | Карточки используют GestureDetector без `minHeight: 48` |

### 2.2 New Game Wizard (P0)

**Положительное:**
- Wizard с режимами (modeSelection → quickStart / customSetup)
- Quick Start Intentional lightweight: имя + пол + авто-выбор
- Custom Setup: 6 шагов с сегментным индикатором
- Story template поддерживается (library flow)
- Генерация промптов, авто-пересборка Character Prompt

**Проблемы:**

| # | Severity | Файл:строка | Описание |
|---|---|---|---|
| N1 | 🟡 Medium | `quick_start_view.dart:82-91` | Кнопка скрывается при открытой клавиатуре — хорошо, но нет анимации появления/исчезновения |
| N2 | 🟢 Low | `new_game_screen.dart:138` | Max-width: 820 (guideline: 600). Отклонение, но full-width wizard может быть оправдан |
| N3 | 🟢 Low | `new_game_screen.dart:213` | Обработка ошибок: смесь `StateError` и generic — нет единого error type |
| N4 | 🟡 Medium | `quick_start_view.dart:81` | `MediaQuery.of(context).viewInsets.bottom == 0` — хрупкая проверка; клавиатура может быть частично открыта |

### 2.3 Chat Screen (P0)

**Положительное:**
- Sidebar на wide, drawer на mobile, bottom sheet на phoneSmall
- mounted-проверки перед SnackBar и навигацией
- Auto-scroll при новых сообщениях (postFrameCallback)
- Composer с LinearProgressIndicator + Cancel
- Intro turn триггерится через статический `Set<_introTriggeredCampaignIds>`
- WidgetsBindingObserver для lifecycle (resumed → scroll)

**Проблемы:**

| # | Severity | Файл:строка | Описание |
|---|---|---|---|
| C1 | 🟡 Medium | `responsive.dart:121` | Sidebar width: desktop 288px (guideline: 240px) |
| C2 | 🔴 High | `chat_screen.dart:441` | `_CompactToolbarButton`: touch target 42×42 (ниже 48dp) |
| C3 | 🟡 Medium | `chat_screen.dart:154` | Wide breakpoint: `responsive.isWide` (≥tablet=600px). Guideline: 760px. На планшетах 600-759px sidebar скрывается в drawer — OK, но расхождение с док-й |
| C4 | 🟢 Low | `chat_screen.dart:113` | Magic string `'intro'` как triggerSource — лучше enum |
| C5 | 🟢 Low | `chat_screen.dart:318-323` | `_isPassiveTurnStatus` — жёсткая привязка к строке локализации, хрупко при смене текста |
| C6 | 🔴 High | `chat_screen.dart` | Отсутствуют `Semantics` для сообщений чата (рассказчик vs игрок) |

### 2.4 Story Library (P1)

**Положительное:**
- Все 4 состояния: loading, error, empty catalog, empty search — обработаны
- Поиск real-time (onChanged → setState)
- Фильтр жанров с PopupMenu
- Adaptive grid: 2/3/4 колонки по breakpoint
- CustomScrollView + SliverGrid для performance
- cacheExtent: 1200-1800 для предзагрузки

**Проблемы:**

| # | Severity | Файл:строка | Описание |
|---|---|---|---|
| S1 | 🟡 Medium | `story_library_screen.dart:603-620` | `_ToolbarIconButton`: touch target 40-44px (ниже 48dp) |
| S2 | 🟡 Medium | `story_library_screen.dart:382-387` | Empty catalog — текст без иконки (guideline empty state: icon 64px + title + subtitle + CTA) |
| S3 | 🟢 Low | `story_library_screen.dart:360-374` | Error state: просто Text в AetherCard, нет кнопки Retry |

### 2.5 Settings (P1)

**Положительное:**
- Все состояния аккаунта (signed in/out, loading, error) обработаны
- `SegmentedButton` для языка
- ConstrainedBox с `dialogMaxWidth` (640 tablet / 760 desktop)
- SwitchListTile для content rating
- Три секции: content / language / account — без перегрузки

**Проблемы:**

| # | Severity | Файл:строка | Описание |
|---|---|---|---|
| T1 | 🟡 Medium | `settings_screen.dart:108` | Desktop max-width 760 (guideline: 640). На 120px шире |
| T2 | 🟢 Low | `settings_screen.dart:155-248` | Account section: три разных `sessionState.when` ветки — дублирование статус-текста |
| T3 | 🟢 Low | — | Нет секции "Language" title в `_SettingsSection` — заголовок задан параметром, всё верно ✅ |

### 2.6 Map (P2, WIP)

**Положительное:**
- Feature в активной разработке — не блокируется аудитом
- Тест `test_map_state_service.py` уже написан

**Наблюдения (для учёта при доработке):**
- Map — первый экран с интенсивным CustomPaint. Правило из `.codexrules`: избегать тяжёлых циклов в CustomPaint
- При интеграции: добавить loading state (генерация тайлов), empty state (мир не сгенерирован), error state (тайлы не загрузились)
- Touch target на точках интереса: ≥48dp
- Желательно семантическое описание карты для accessibility

---

## 2.7 HTML Landing Shell — Браузерный `ux-audit`

Данные с реального рендеринга через GStack Browser (`browse ux-audit`):

**Headings structure:**
- ⚠️ Два `<H1>` на странице: "Стирая Грань" и "Поделитесь впечатлением о приложении". Правило accessibility: один H1 на страницу. Второй должен быть H2.
- Иерархия: H1 → H2 → H3 — корректная кроме дубликата H1

**Interactive elements (touch targets):**
| Элемент | Размер | Статус |
|---|---|---|
| Кнопка "РУС" | 159×34 | 🔴 Высота 34px — ниже 48dp |
| Кнопка "ENG" | 159×34 | 🔴 Высота 34px — ниже 48dp |
| Кнопка "Играть" | 274×51 | 🟢 OK |
| Кнопка "Как это работает" | 274×53 | 🟢 OK |
| Кнопка "ОТВЕТИТЬ" | 281×51 | 🟢 OK |
| Кнопка "Обратная связь" | 310×51 | 🟢 OK |

**Навигация:**
- 🔴 `<nav>` landmark отсутствует — скрин-ридеры не могут быстро перейти к навигации
- 🔴 Нет breadcrumbs
- 🔴 Нет поиска по сайту

**Текстовые блоки:**
- 31 текстовый блок, ~4813 слов
- Контент читаемый, структурированный

---

## 3. Accessibility Checklist

| Критерий | Статус | Детали |
|---|---|---|
| Цветовой контраст ≥4.5:1 (WCAG AA) | ⚠️ Не проверен | Требуется ручной замер. AetherPalette: textPrimary #E8E4E0 на background #0A0908 = ~12:1 ✅, textMuted #7A7570 = ~5:1 ⚠️ граница |
| Touch targets ≥48×48px | 🔴 Нарушения | Home IconButton: 22px; Chat: 42px; Story: 40-44px |
| Семантические label-ы | 🔴 Отсутствуют | `Semantics` widget не используется на ключевых экранах |
| Отсутствие colour-only информации | 🟢 OK | Иконки + цвет везде, не только цвет |
| Screen reader support | 🔴 Нет | Flutter semantics tree не обогащён |

---

## 4. UI Consistency Checklist

| Критерий | Статус | Детали |
|---|---|---|
| Spacing кратен 8px | 🟡 В основном | Responsive-токены следуют 8px grid. Отдельные hardcoded значения: `height: 2`, `height: 10` |
| Типографика ≤3-4 размера | 🔴 Нарушение | Home screen: ~15 разных font-size. В среднем по проекту: 7-10 |
| Цвета через Theme-токены | 🟢 OK | 1 хардкод-цвет (`0xFF3A3530`), остальное через AetherPalette |
| Loading state | 🟢 OK | `CircularProgressIndicator` на всех экранах |
| Empty state | 🟡 Частично | Saves: полный empty state ✅; Story Library: только текст, без иконки и CTA ❌ |
| Error state | 🟡 Частично | Есть на всех экранах, но не везде с Retry action |
| Success feedback | 🟢 OK | SnackBar при sign out, сохранении |

---

## 5. Сводка проблем по severity

### High (4)
- **C2** — Touch target 42×42 в `_CompactToolbarButton` (chat)
- **L1** — Два `<H1>` на landing page (должен быть один) — нарушение WCAG 2.4.6
- **L2** — Языковые кнопки ("РУС"/"ENG") 159×34 — высота 34px, вдвое ниже 48dp
- **H4/C6/L3** — Отсутствие семантических аннотаций: нет `Semantics` widget + нет `<nav>` landmark

### Medium (7)
- **H1** — Хардкод-цвет в home_screen
- **H2** — IconButton size=22 (touch target)
- **H3** — Home max-width расхождение с guideline
- **C1** — Sidebar width расхождение
- **N4** — Хрупкая проверка клавиатуры в quick_start
- **S1** — Touch target в story library toolbar
- **S2** — Empty state без иконки и CTA
- **T1** — Settings max-width расхождение

### Low (7)
- H5, H6, N1, N2, N3, C3, C4, C5, S3, T2

---

## 6. Рекомендации

### Quick Wins (15-30 мин)
1. Заменить `Color(0xFF3A3530)` → `AetherPalette.textDim` в `home_screen.dart:221`
2. Увеличить `_CompactToolbarButton` Container с 42×42 → 48×48
3. Увеличить `_ToolbarIconButton` (story library) с 40-44 → 48
4. Settings IconButton (home): заменить на 48×48 touch target
5. **Landing page:** Исправить второй H1 → H2 ("Поделитесь впечатлением о приложении")
6. **Landing page:** Увеличить кнопки языка "РУС"/"ENG" с высоты 34px → ≥48px

### Средний приоритет (1-2 часа)
5. Добавить `Semantics` widget на:
   - Карточки Home Screen (label: название карточки)
   - Сообщения чата (label: "Рассказчик" / "Вы")
   - Кнопку поиска в Story Library
6. Добавить empty state с иконкой + CTA в Story Library
7. Привести max-width Home и Settings в соответствие с guideline (или обновить guideline)

### Долгосрочное (отдельная задача)
8. Accessibility audit с реальным screen reader (TalkBack / VoiceOver)
9. Цветовой контраст — замер через инструмент (Lighthouse / Colour Contrast Analyser)
10. Унификация empty-state паттерна как отдельного виджета (`AetherEmptyState`)

---

## 7. Что не проверено (требует ручного запуска)

- Фактический цветовой контраст (нужен инструмент замера)
- Поведение на реальных мобильных устройствах (touch scrolling, keyboard overlap)
- Анимации AetherPageReveal на реальном железе (jank)
- AetherBackdrop шум на native vs web
- Поведение при смене ориентации (portrait ↔ landscape)
- Карта мира (Map) — в активной разработке, преждевременно для UX-аудита

---

**Статус:** DONE_WITH_CONCERNS
**Причина:** Ключевые accessibility-проблемы (touch targets, Semantics) требуют исправления. Аудит на уровне кода полон, но визуальная верификация через браузер ограничена CanvasKit-рендерингом Flutter.
**Рекомендация:** High-priority фиксы выполнить в этом PR. Accessibility — отдельная задача/issue.
