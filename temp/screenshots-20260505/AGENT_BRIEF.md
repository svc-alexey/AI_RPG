# AI RPG «Стирая Грань» — Бриф для реализации

**Контекст:** Полный дизайн-аудит приложения (70+ скриншотов, 10 экранов, 6 статических страниц).
**Задача:** Реализовать исправления согласно плану ниже.
**Проект:** Flutter (клиент) + статические HTML-страницы. Бэкенд FastAPI не трогаем.
**Ветка:** `master`

---

## ДИЗАЙН-СИСТЕМА (Aether)

Чтобы понимать что и где править:

**Цвета:**
- `background`: #0A0908 | `backgroundElevated`: #0F0D0B | `backgroundTop`: #141210
- `panel`: #12100E | `panelSoft`: #1A1816
- `textPrimary`: #E8E4E0 | `textMuted`: #7A7570 | `textDim`: #5A5550 (→ #6B6660)
- `narrativeText`: #C8C4C0 (для длинных текстов)
- `accent`: #C87941 (медь) | `accentHover`: #D4956A | `gold`: #BFA76F
- `success`: #34D399

**Типографика:**
- Display/Headlines: Playfair Display (300-500 weight)
- Body/UI: Inter (400-600 weight)
- Статика должна использовать Playfair Display (сейчас Noto Serif — баг)

**Компоненты:**
- `AetherCard` — в `lib/src/app/aether_shell.dart`
- `AetherPageReveal` — переходы (на web отключены, нужно включить opacity)
- `AetherPalette` — все цветовые токены в `lib/src/app/aether_shell.dart`
- Тема: `lib/src/app/theme.dart` — Material 3 Dark, NoSplash
- Адаптивность: `lib/src/app/responsive.dart` — 5 breakpoint-ов
- Локализация: `lib/src/app/app_localizations.dart`

---

## ЭТАП 1 — КРИТИЧЕСКОЕ (начинай отсюда)

### 1.1 Контраст textDim — WCAG AA FAIL

**Проблема:** #5A5550 на #0A0908 = контраст 3.8:1 (нужно 4.5:1 для body-текста)

```dart
// Файл: lib/src/app/aether_shell.dart, строка 18
// Было:
static const Color textDim = Color(0xFF5A5550);
// Стало:
static const Color textDim = Color(0xFF6B6660);
```

```css
/* Файл: deploy/web/legal.css, строка 25 */
/* Было: */
--text-dim: #5A5550;
/* Стало: */
--text-dim: #6B6660;
```

### 1.2 Фокус-индикаторы — WCAG 2.4.7 FAIL

**Проблема:** Тема глобально глушит splash/highlight — клавиатурные пользователи не видят, какой элемент в фокусе.

```dart
// Файл: lib/src/app/theme.dart
// В IconButtonTheme, FilledButtonTheme, OutlinedButtonTheme, TextButtonTheme
// добавить в каждый ButtonStyle:

overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
  if (states.contains(WidgetState.focused)) {
    return AetherPalette.accent.withValues(alpha: 0.12);
  }
  return Colors.transparent; // мышь без splash — сохраняем noir
}),
side: WidgetStateProperty.resolveWith<BorderSide?>((states) {
  if (states.contains(WidgetState.focused)) {
    return const BorderSide(color: AetherPalette.accent, width: 2);
  }
  return null;
}),
```

**Важно:** Hover остаётся без splash. Только focused (клавиатура).

### 1.3 Legal-ссылки — размер и touch target

**Проблема:** В футере home screen ссылки 10px с padding 4×2px — область касания ~28px.

```dart
// Файл: lib/src/features/home/presentation/home_screen.dart
// В методе _HomeFooter._buildLink:

// fontSize: 10 → 12
// Padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2) → horizontal: 8, vertical: 4
```

### 1.4 Грамматика — plural для событий на карте

**Проблема:** «1 новых событий» — неправильно для числа 1.

```dart
// Файл: lib/src/app/app_localizations.dart
// Найти метод, возвращающий строку с «новых событий»
// Заменить на правильный plural:
// 1 → «новое событие», 2-4 → «новых события», 5+ → «новых событий»
// Учесть исключения: 11-14 → «новых событий»
```

---

## ЭТАП 2 — ВЫСОКОЕ

### 2.1 Шрифты статики — Noto Serif → Playfair Display

**Проблема:** Статические страницы используют Noto Serif, Flutter — Playfair Display. Два разных продукта.

**Файлы (7 шт.):**
1. `deploy/web/legal.css` — заменить все `"Noto Serif"` на `"Playfair Display"` (~8 правил)
2. `deploy/web/offer.html` — обновить Google Fonts link
3. `deploy/web/privacy.html` — обновить Google Fonts link
4. `deploy/web/consent.html` — обновить Google Fonts link
5. `deploy/web/refunds.html` — обновить Google Fonts link
6. `deploy/web/contacts.html` — обновить Google Fonts link
7. `deploy/web/subscribe.html` — обновить Google Fonts link

В каждом HTML заменить в `<link href="https://fonts.googleapis.com/...">`:
`Noto+Serif` → `Playfair+Display`

### 2.2 Выборы в чате — шире и ярче

**Проблема:** Текст выборов обрезается на 240px, цвет #7A7570 (слишком тусклый для основного действия).

```dart
// Файл: lib/src/features/chat/presentation/widgets/chat_body.dart
// (или где рендерятся InkWell с выбором)

// Ширина: 240 → 320
// Цвет текста: AetherPalette.textMuted → AetherPalette.narrativeText
// maxLines: 1 → 2 (для длинных текстов)
```

### 2.3 Поле ввода чата — граница

**Проблема:** `_NoInputBorder()` — поле ввода невидимо на широком экране.

```dart
// Файл: lib/src/features/chat/presentation/widgets/chat_composer.dart

// Заменить _NoInputBorder() на:
focusedBorder: UnderlineInputBorder(
  borderSide: BorderSide(color: AetherPalette.accent, width: 1.5),
),
enabledBorder: UnderlineInputBorder(
  borderSide: BorderSide(color: AetherPalette.panelBorderSolid),
),
```

### 2.4 Tooltip-ы для иконок AppBar

**Проблема:** 4 иконки в AppBar чата без tooltip — пользователь не знает что они делают.

```dart
// Файл: lib/src/features/chat/presentation/widgets/chat_app_bar.dart
// Добавить tooltip к каждому IconButton

// Файл: lib/src/app/app_localizations.dart
// Добавить строки:
String get saveTooltip => 'Сохранить';
String get settingsTooltip => 'Настройки';
String get mapTooltip => 'Карта мира';
String get menuTooltip => 'Меню';
```

### 2.5 Локализация жанров и сеттингов

**Проблема:** «Romantasy», «Sci-Fi», «Young Adult», «Dark academia», «Cozy», «LitRPG», «Cozy crime» на английском в русской локали.

```dart
// Файл: lib/src/core/data/character_templates.dart
// (или где определён список жанров)

// Перевести:
// Romantasy → Романтическое фэнтези
// Young Adult → Подростковая литература
// Sci-Fi → Научная фантастика
// Dark academia → Тёмная академия
// Cozy → Уютное
// LitRPG → ЛитРПГ
// Cozy crime → Уютный детектив
```

### 2.6 Валидация форм

**Проблема:** Settings и Auth формы не валидируются, нет Tab-order, Enter не отправляет.

**Файлы:**
- `lib/src/features/settings/presentation/settings_screen.dart`
- `lib/src/features/auth/presentation/auth_screen.dart`

**Что сделать:**
1. Обернуть поля в `Form(key: _formKey)` + `FocusTraversalGroup`
2. `TextField` → `TextFormField` с `validator`
3. `onFieldSubmitted: (_) => FocusScope.of(context).nextFocus()`
4. Enter на последнем поле → submit формы

### 2.7 Error-компонент

**Проблема:** Story Library показывает Retry, Saves — нет. Нужен единый компонент.

**Создать:** `lib/src/core/presentation/widgets/app_error_view.dart`
```dart
class AppErrorView extends StatelessWidget {
  // Иконка + сообщение + кнопка «Повторить» (опционально)
  // Использовать AetherCard
}
```

**Использовать в:** `lib/src/features/saves/presentation/saves_screen.dart`

---

## ЭТАП 3 — ПОЛИРОВКА

### 3.1 Двойная кнопка «Назад» в wizard

**Файл:** `lib/src/features/new_game/presentation/new_game_screen.dart`
Убрать инлайн-кнопку «Назад» из шагов, где уже есть AppBar.back.

### 3.2 Web-переходы

**Файл:** `lib/src/app/aether_shell.dart` (AetherPageReveal, строка 147-149)
```dart
// Было:
if (kIsWeb) { return widget.child; }
// Стало:
if (kIsWeb) { return FadeTransition(opacity: _fade, child: widget.child); }
```

### 3.3 Zoom-контролы на карте

**Файл:** `lib/src/features/map/presentation/map_canvas.dart`
Добавить кнопки +/- в Stack поверх карты (только для desktop — `responsive.isWide`).

### 3.4 Бейдж «Новый» на карточках

**Файл:** `lib/src/features/story_library/presentation/story_template_detail_screen.dart`
Если 0 лайков и 0 просмотров → показывать Chip «Новый» вместо нулей.

---

## ЧТО НЕ ТРОГАТЬ

- Бэкенд (FastAPI) — только клиентская часть
- Структуру проекта — feature-first сохраняется
- AetherPalette — медный акцент, тёмная тема, всё ОК
- Bento-сетку home screen — работает хорошо
- Hero-типографику — «Стирая Грань» 88/96px — отлично
- Трёхколоночный лейаут чата — не менять
- 6-шаговый wizard — структура правильная

---

## ПОРЯДОК РЕАЛИЗАЦИИ

```
1. 1.1 textDim контраст (2 файла, 2 строки)
2. 1.2 Фокус-индикаторы (1 файл, theme.dart)
3. 1.3 Legal-ссылки (1 файл)
4. 1.4 Plural (1 файл)
5. 2.1 Шрифты статики (7 файлов)
6. 2.2 Выборы в чате (1 файл)
7. 2.3 Поле ввода (1 файл)
8. 2.4 Tooltip-ы (2 файла)
9. 2.5 Локализация жанров (1 файл)
10. 2.6 Валидация форм (2 файла)
11. 2.7 Error-компонент (новый + 1 изменение)
12. 3.1 Двойной Back (1 файл)
13. 3.2 Web-переходы (1 файл)
14. 3.3 Zoom карты (1 файл)
15. 3.4 Бейдж Новый (1 файл)
```

После каждого изменения: `flutter analyze` + `flutter test`.
После этапов 2.1 и 2.6: ручная проверка в браузере.

---

## КОНТЕКСТ ДЛЯ ПОНИМАНИЯ

- Проект: нарративная RPG с AI-рассказчиком «Стирая Грань»
- Flutter-клиент (web) + статические HTML-страницы
- Серверная логика на FastAPI (НЕ трогать)
- Тёмная noir-тема с медным акцентом
- Все изменения — дизайн-исправления по результатам полного аудита
- Главный принцип: ничего не сломать, минимальные диффы
- После каждого этапа: коммит с описанием что и зачем
