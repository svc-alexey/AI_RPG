# AI RPG — Пошаговый план реализации дизайн-исправлений

**Основание:** Design Review 2026-05-05 (70+ скриншотов, 10 экранов, 6 статических страниц)
**Ветка:** master
**Общий объём:** ~25 файлов, 3 этапа, ~8-12 дней

---

## ЭТАП 1 — Критическое (2-3 дня, ~8 файлов)

То, что напрямую влияет на accessibility, читаемость и первое впечатление.

### 1.1 Контраст textDim — WCAG AA

**Файлы:** `lib/src/app/aether_shell.dart` (1 строка), `deploy/web/legal.css` (1 строка)
**Суть:** `#5A5550` → `#6B6660`. Контраст поднимается с 3.8:1 до 4.5:1.

```dart
// aether_shell.dart:18 — было
static const Color textDim = Color(0xFF5A5550);
// стало
static const Color textDim = Color(0xFF6B6660);
```

```css
/* legal.css:25 — было */
--text-dim: #5A5550;
/* стало */
--text-dim: #6B6660;
```

**Тест:** `flutter test` — проверить что тесты темы не сломались. Визуальная проверка: любой экран с текстом textDim (Settings, Home footer, Map right panel).

---

### 1.2 Фокус-индикаторы — WCAG 2.4.7

**Файл:** `lib/src/app/theme.dart` (изменение ButtonStyle для всех кнопок + IconButton)
**Суть:** Добавить видимый focus ring (2px accent border) при фокусе с клавиатуры, сохраняя отсутствие splash для мыши.

```dart
// theme.dart — в IconButtonTheme, FilledButtonTheme, OutlinedButtonTheme
// Добавить overlayColor только для focused состояния:
overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
  if (states.contains(WidgetState.focused)) {
    return AetherPalette.accent.withValues(alpha: 0.12);
  }
  return Colors.transparent;
}),
// И в ButtonStyle добавить side для focused:
side: WidgetStateProperty.resolveWith<BorderSide?>((states) {
  if (states.contains(WidgetState.focused)) {
    return BorderSide(color: AetherPalette.accent, width: 2);
  }
  return null;
}),
```

**Важно:** Не менять поведение для `WidgetState.hovered` — noir-эстетика без мышиных splash сохраняется. Focus ТОЛЬКО для клавиатуры.

**Файлы (4 шт.):**
- `lib/src/app/theme.dart` — IconButtonTheme, FilledButtonTheme, OutlinedButtonTheme, TextButtonTheme
- `lib/src/features/chat/presentation/widgets/chat_composer.dart` — если есть кастомные стили

**Тест:** `flutter test` на тему. Ручная проверка: Tab через Settings-форму, убедиться что видно какой элемент в фокусе.

---

### 1.3 Legal-ссылки — размер и доступность

**Файл:** `lib/src/features/home/presentation/home_screen.dart` (в `_HomeFooter`)
**Суть:** Поднять шрифт с 10px до 12px, увеличить padding.

```dart
// home_screen.dart, _HomeFooter._buildLink — было
fontSize: 10,
// стало
fontSize: 12,
// padding — было
const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
// стало
const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
```

**Тест:** Ручная проверка home screen — ссылки должны быть крупнее и легче нажиматься.

---

### 1.4 Орфография + грамматика

**Суть:** Три точечных исправления в данных/локализации.

| # | Где | Было | Стало |
|---|-----|------|-------|
| 1 | Campaign title field | «паралельный» | «параллельный» |
| 2 | Map event counter | «1 новых событий» | «1 новое событие» |
| 3 | Map event counter (plural) | «2 новых событий» | «2 новых события» |

**Файл:** `lib/src/app/app_localizations.dart` + логика plural в map-виджете.

```dart
// Проблема в методе plural — для 1 нужно единственное число, для 2-4 — родительный ед., для 5+ — родительный мн.
// Было (предположительно)
String mapNewEvents(int count) => '$count новых событий';
// Стало
String mapNewEvents(int count) {
  if (count % 10 == 1 && count % 100 != 11) return '$count новое событие';
  if (count % 10 >= 2 && count % 10 <= 4 && (count % 100 < 10 || count % 100 >= 20)) 
    return '$count новых события';
  return '$count новых событий';
}
```

**Орфография в названии кампании:** править не в коде, а через валидацию при создании (или просто принять — название вводит пользователь).

**Тест:** Юнит-тест на `mapNewEvents()` с числами 0, 1, 2, 5, 11, 21.

---

## ЭТАП 2 — Высокое (4-5 дней, ~10 файлов)

Прямое влияние на UX. Пользователь видит эти проблемы каждый раз.

### 2.1 Унификация шрифтов — Playfair Display на статике

**Файл:** `deploy/web/legal.css` (замена `Noto Serif` → `Playfair Display`)
**Суть:** Заменить все упоминания `"Noto Serif"` на `"Playfair Display"` в CSS.

```css
/* legal.css — было */
.font-display-large { font-family: "Noto Serif", serif; }
.font-headline-large { font-family: "Noto Serif", serif; }
/* ... ещё 6 правил ... */
/* стало */
.font-display-large { font-family: "Playfair Display", serif; }
.font-headline-large { font-family: "Playfair Display", serif; }
```

**Плюс:** обновить `<link>` Google Fonts в каждом HTML-файле (6 файлов):
```html
<!-- Было -->
<link href="https://fonts.googleapis.com/css2?family=...Noto+Serif...display=swap" rel="stylesheet">
<!-- Стало -->
<link href="https://fonts.googleapis.com/css2?family=...Playfair+Display...display=swap" rel="stylesheet">
```

**Файлы (7 шт.):** `legal.css` + `offer.html`, `privacy.html`, `consent.html`, `refunds.html`, `contacts.html`, `subscribe.html`

**Тест:** Ручная проверка всех 6 статических страниц — заголовки должны отображаться Playfair Display.

---

### 2.2 Выборы в чате — шире + ярче

**Файл:** `lib/src/features/chat/presentation/widgets/chat_body.dart` (или где рендерятся InkWell-выборы)
**Суть:** Увеличить maxWidth выборов с 240px до 320px, цвет текста с `textMuted` на `narrativeText`.

```dart
// Было
width: 240,
// Стало
width: 320,
// Цвет текста — было
color: AetherPalette.textMuted,
// стало
color: AetherPalette.narrativeText,
```

**Дополнительно:** Для очень длинных текстов — `maxLines: 2` вместо `maxLines: 1`.

**Тест:** Создать кампанию с длинными вариантами выборов, проверить что не обрезаются.

---

### 2.3 Поле ввода чата — borderBottom

**Файл:** `lib/src/features/chat/presentation/widgets/chat_composer.dart`
**Суть:** Заменить `_NoInputBorder()` на `UnderlineInputBorder` с accent-цветом.

```dart
// Было
decoration: InputDecoration(
  hintText: "Что делает герой дальше?",
  focusedBorder: _NoInputBorder(),
  enabledBorder: _NoInputBorder(),
  border: _NoInputBorder(),
)
// Стало
decoration: InputDecoration(
  hintText: "Что делает герой дальше?",
  focusedBorder: UnderlineInputBorder(
    borderSide: BorderSide(color: AetherPalette.accent, width: 1.5),
  ),
  enabledBorder: UnderlineInputBorder(
    borderSide: BorderSide(color: AetherPalette.panelBorderSolid),
  ),
)
```

**Тест:** Визуально — поле ввода должно быть заметно на экране.

---

### 2.4 Tooltip-ы для иконок AppBar чата

**Файл:** `lib/src/features/chat/presentation/widgets/chat_app_bar.dart`
**Суть:** Добавить `tooltip` к каждому `IconButton` в AppBar.

```dart
// Было (4 иконки без tooltip)
IconButton(icon: Icon(Icons.save_outlined), onPressed: onSave)
// Стало
IconButton(icon: Icon(Icons.save_outlined), tooltip: 'Сохранить', onPressed: onSave)
```

Иконки: сохранение, настройки, карта, меню. Добавить локализованные tooltip-ы.

**Файл:** `lib/src/app/app_localizations.dart` — добавить 4 строки:
```dart
String get saveTooltip => isRu ? 'Сохранить' : 'Save';
String get settingsTooltip => isRu ? 'Настройки' : 'Settings';
String get mapTooltip => isRu ? 'Карта мира' : 'World Map';
String get menuTooltip => isRu ? 'Меню' : 'Menu';
```

**Тест:** Навести мышкой на каждую иконку — должен появиться tooltip.

---

### 2.5 Локализация жанров и сеттингов

**Файл:** `lib/src/core/data/character_templates.dart` (или где определён список жанров)
**Суть:** Перевести все английские названия на русский.

| Было (EN) | Стало (RU) |
|-----------|-----------|
| Romantasy | Романтическое фэнтези |
| Young Adult | Подростковая литература |
| Sci-Fi | Научная фантастика |
| Dark academia | Тёмная академия |
| Cozy | Уютное |
| LitRPG | ЛитРПГ |
| Cozy crime | Уютный детектив |

**Тест:** Пройти New Game wizard на русской локали — все жанры должны быть на русском.

---

### 2.6 Валидация форм (Settings + Auth)

**Файлы:** 
- `lib/src/features/settings/presentation/settings_screen.dart`
- `lib/src/features/auth/presentation/auth_screen.dart`

**Суть:** Обернуть поля в `Form` + `TextFormField` с `validator`, добавить `FocusTraversalGroup`.

```dart
// Settings — было: ListView с TextField
// Стало: ListView с Form(key: _formKey, child: ...)
// Каждый TextField → TextFormField с validator:
TextFormField(
  controller: _baseUrlController,
  keyboardType: TextInputType.url,
  validator: (v) => v != null && v.isNotEmpty && !Uri.tryParse(v)!.hasScheme 
    ? l10n.invalidUrl 
    : null,
  onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
)
```

**Добавить Tab-order через FocusTraversalGroup:**
```dart
FocusTraversalGroup(
  policy: OrderedTraversalPolicy(),
  child: Form(
    child: Column(children: [/* поля по порядку */]),
  ),
)
```

**Тест:** 
1. Открыть Settings → Tab через поля — порядок должен быть: URL → Model → API Key → Timeout
2. Ввести некорректный URL → должна появиться ошибка валидации
3. Нажать Enter на последнем поле → должно отправить форму

---

### 2.7 Error-состояния — единый компонент

**Файлы:** 
- `lib/src/features/saves/presentation/saves_screen.dart`
- Новый файл: `lib/src/core/presentation/widgets/app_error_view.dart`

**Суть:** Создать переиспользуемый виджет `AppErrorView` с иконкой, сообщением и кнопкой Retry.

```dart
// lib/src/core/presentation/widgets/app_error_view.dart
class AppErrorView extends StatelessWidget {
  const AppErrorView({
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline_rounded,
  });
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;
  // ... build с AetherCard, иконкой, текстом и OutlinedButton "Повторить"
}
```

**Заменить в SavesScreen:**
```dart
// Было
Center(child: Text("Не удалось открыть сохранения."))
// Стало
Center(child: AppErrorView(
  message: l10n.savesLoadFailed,
  onRetry: _load,
))
```

**Тест:** Отключить бэкенд → зайти в Saves → должна быть кнопка «Повторить».

---

## ЭТАП 3 — Полировка (3-5 дней, ~7 файлов)

Влияет на восприятие качества, но не блокирует использование.

### 3.1 Убрать двойную кнопку «Назад» в wizard

**Файл:** `lib/src/features/new_game/presentation/new_game_screen.dart`
**Суть:** Оставить кнопку «Назад» только в AppBar, убрать инлайн-кнопку для шагов 2-6.

```dart
// new_game_screen.dart — в build()
// Для customSetup режима не показывать AppBar (уже так)
// Но инлайн-кнопка «Назад» в CustomSetupView дублируется с AppBar'овской
// Решение: убрать инлайн-кнопку «Назад» из шагов где есть AppBar
```

**Тест:** Пройти wizard — кнопка «Назад» должна быть только одна на каждом шаге.

---

### 3.2 Web-переходы (opacity-only)

**Файл:** `lib/src/app/aether_shell.dart` (AetherPageReveal)
**Суть:** Сейчас web-переходы выключены полностью (`kIsWeb → return child`). Включить облегчённую версию: только opacity, без shader-масок.

```dart
// aether_shell.dart:147-149 — было
if (kIsWeb) {
  return widget.child;
}
// Стало
if (kIsWeb) {
  return FadeTransition(opacity: _fade, child: widget.child);
}
// Убрать SlideTransition и ScaleTransition для web
```

**Тест:** Навигация по экранам в Chrome — должен быть плавный fade вместо мгновенного разрыва.

---

### 3.3 Zoom-контролы на карте

**Файл:** `lib/src/features/map/presentation/map_canvas.dart`
**Суть:** Добавить кнопки +/− для zoom на desktop (где нет pinch-жестов).

```dart
// В MapCanvas, в Stack поверх GestureDetector карты
Positioned(
  right: 16,
  bottom: 16,
  child: Column(
    children: [
      IconButton(icon: Icon(Icons.add), onPressed: _zoomIn),
      IconButton(icon: Icon(Icons.remove), onPressed: _zoomOut),
    ],
  ),
)
```

**Тест:** Открыть карту на desktop — должны быть кнопки zoom.

---

### 3.4 DESIGN.md

**Файл:** `DESIGN.md` (новый, в корне проекта)
**Суть:** Задокументировать дизайн-систему: цвета, типографику, spacing, компоненты.

Содержание:
- Aesthetic direction: Refined Noir
- Color tokens (AetherPalette)
- Typography scale (Playfair Display + Inter)
- Spacing scale (responsive breakpoints)
- Component inventory (AetherCard, AetherPageReveal, etc.)
- Motion principles

**Не требует тестов — документ.**

---

### 3.5 Социальное доказательство на карточках

**Файл:** `lib/src/features/story_library/presentation/story_template_detail_screen.dart`
**Суть:** Для новых шаблонов (0 лайков / 0 просмотров) показывать бейдж «Новый» вместо нулей.

```dart
// Было
Text('0') + Text('Лайки')
// Стало (если шаблон создан < 7 дней назад)
Chip(label: Text(l10n.newLabel))
```

**Тест:** Создать новый шаблон → открыть карточку → должен быть бейдж «Новый».

---

### 3.6 Subscribe-страница — показывать цены для гостей

**Файл:** `deploy/web/subscribe.html`
**Суть:** Сейчас все кнопки disabled с «Требуется вход». Для гостей показывать тарифы с CTA «Войти чтобы приобрести».

**Тест:** Открыть `/subscribe.html` без авторизации → тарифы видны, кнопки ведут на логин.

---

## КАРТА ЗАВИСИМОСТЕЙ

```
Этап 1 (все независимы):
  1.1 textDim контраст ────────┐
  1.2 Фокус-индикаторы  ───────┤ можно параллельно
  1.3 Legal-ссылки      ───────┤
  1.4 Орфография        ───────┘

Этап 2 (зависимость от 1.2):
  2.1 Шрифты статики    ────────┐
  2.2 Выборы шире       ────────┤
  2.3 Поле ввода        ────────┤ можно параллельно
  2.4 Tooltip-ы         ────────┤ (разные файлы)
  2.5 Локализация       ────────┤
  2.6 Валидация форм    ────────┤ (зависит от 1.2: фокус)
  2.7 Error-компонент   ───────┘

Этап 3 (все независимы):
  3.1 Кнопка Назад      ────────┐
  3.2 Web-переходы      ────────┤ можно параллельно
  3.3 Zoom карты         ────────┤
  3.4 DESIGN.md         ────────┤
  3.5 Соц.доказательство ────────┤
  3.6 Subscribe          ───────┘
```

---

## ПАРАЛЛЕЛЬНЫЕ ЛИНИИ РАЗРАБОТКИ

```
День 1-2:
  Lane A: 1.1 + 1.2 + 1.3 (theme.dart, aether_shell.dart, home_screen.dart)
  Lane B: 1.4 (app_localizations.dart — отдельный файл)

День 3-6:
  Lane A: 2.5 + 2.6 (локализация + валидация — связаны)
  Lane B: 2.1 (статический CSS/HTML — отдельная экосистема)
  Lane C: 2.2 + 2.3 + 2.4 + 2.7 (chat-виджеты + error-компонент)

День 7-10:
  Lane A: 3.1 + 3.2 (new_game_screen + aether_shell)
  Lane B: 3.3 + 3.5 (map_canvas + story_template_detail)
  Lane C: 3.4 + 3.6 (DESIGN.md + subscribe.html)
```

---

## ФАЙЛЫ ПО ЭТАПАМ

### Этап 1 (8 файлов)
```
lib/src/app/aether_shell.dart          — textDim контраст
lib/src/app/theme.dart                 — фокус-индикаторы
lib/src/features/home/presentation/
  home_screen.dart                     — legal-ссылки
lib/src/app/app_localizations.dart      — plural + mapNewEvents
deploy/web/legal.css                   — textDim контраст (статика)
```

### Этап 2 (12 файлов)
```
deploy/web/legal.css                   — шрифт Playfair Display
deploy/web/*.html (6 шт.)              — Google Fonts link
lib/src/features/chat/presentation/
  widgets/chat_body.dart               — выборы шире + ярче
lib/src/features/chat/presentation/
  widgets/chat_composer.dart           — borderBottom
lib/src/features/chat/presentation/
  widgets/chat_app_bar.dart            — tooltip-ы
lib/src/app/app_localizations.dart      — tooltip-строки
lib/src/features/settings/presentation/
  settings_screen.dart                 — Form + валидация
lib/src/features/auth/presentation/
  auth_screen.dart                     — Form + валидация
lib/src/core/presentation/widgets/
  app_error_view.dart                  — новый: error-компонент
lib/src/features/saves/presentation/
  saves_screen.dart                    — использование AppErrorView
lib/src/core/data/
  character_templates.dart             — локализация жанров
```

### Этап 3 (7 файлов)
```
lib/src/features/new_game/presentation/
  new_game_screen.dart                 — убрать двойной Back
lib/src/app/aether_shell.dart          — web-переходы (opacity)
lib/src/features/map/presentation/
  map_canvas.dart                      — zoom-контролы
DESIGN.md                              — новый: дизайн-система
lib/src/features/story_library/
  presentation/
  story_template_detail_screen.dart    — бейдж «Новый»
deploy/web/subscribe.html              — тарифы для гостей
```

---

## ИТОГО

| Параметр | Значение |
|----------|---------|
| Всего находок в работе | 18 |
| Файлов изменяется | ~25 |
| Этапов | 3 |
| Параллельных линий | 3 макс. |
| Оценка времени | 8-12 дней |
| Критических (user-facing broken) | 5 |
| Высоких (UX degradation) | 8 |
| Средних (polish) | 5 |
