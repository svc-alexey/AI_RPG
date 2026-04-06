# UI/UX Guidelines — AI_PRG

## Обзор изменений

Документ описывает обновлённые UI/UX принципы для всех экранов приложения AI_PRG после комплексного рефакторинга март 2026.

## Общие принципы

### Mobile-First подход

**Правило**: Все новые экраны проектируются для мобильных устройств в первую очередь.

- **Max-width**: 600-720px для основного контента
- **Touch targets**: минимум 48dp для всех интерактивных элементов
- **Spacing**: компактный (12/16/24/32px)
- **Layout**: одна центральная колонка, вертикальная прокрутка

### Canonical breakpoints

Для новых экранов и рефакторинга адаптивности используем единый responsive layer из `lib/src/app/responsive.dart`, а не локальные `MediaQuery`-проверки с произвольными числами.

- `320-359 px` — `phoneSmall`
- `360-389 px` — `phone`
- `390-599 px` — `phoneLarge`
- `600-1023 px` — `tablet`
- `1024+ px` — `desktop`

### Responsive rules

- typography должна масштабироваться через общий responsive helper, особенно для `display`, `headline` и декоративного letter spacing;
- `page padding`, `card padding`, `radius`, `button min height`, `input padding` и `chip spacing` берутся из общих adaptive tokens;
- на маленьких телефонах приоритет у читаемости и отсутствия overflow, а не у сохранения desktop-композиции один в один;
- длинные заголовки, campaign metadata, labels и локализованные строки обязаны иметь безопасное поведение через `Wrap`, `Expanded`, `maxLines` и `TextOverflow.ellipsis`;
- split-layout (`sidebar + content`) включается только на wide/tablet сценариях, а мобильные сценарии используют stacked layout / drawer / compact toolbar.

### Визуальная согласованность

**Компоненты Aether Design System**:
- `AetherCard` — карточки контента
- `AetherPageReveal` — анимация появления страниц
- `AetherBackdrop` — тёмный вертикальный градиент + тёплое радиальное свечение (пульс); «зерно» (`_FilmNoisePainter`) на **native**; на **web** шум отключён (`kIsWeb`), чтобы не наслаиваться на канвас браузера
- `AetherPalette` — палитра noir/copper (фон, акцент, narrative-текст и т.д.)

**Типографика**:
- `display` / крупные заголовки — Playfair Display (через тему / `google_fonts`)
- `headlineLarge` — заголовки страниц
- `headlineMedium` — заголовки секций
- `titleLarge` — заголовки карточек
- `bodyLarge` — основной текст и **тело сообщений рассказчика в чате** (Inter), цвет повествования: `AetherPalette.narrativeText`
- `bodyMedium` — второстепенный текст
- `labelLarge` — метки секций (uppercase, letter-spacing: 2-3)

### Информационная иерархия

**Кнопки**:
1. **Главное действие**: `FilledButton` или `FilledButton.icon`
2. **Второстепенное**: `OutlinedButton`
3. **Третичное**: `TextButton`

**Цвета**:
- `AetherPalette.accent` — акцентные элементы, выделение
- `AetherPalette.textPrimary` — основной текст
- `AetherPalette.textMuted` — второстепенный текст, подсказки
- `AetherPalette.panelSoft` — фон полупрозрачных панелей

## Экран за экраном

### 1. Home Screen — Главный экран

**Layout (актуально):** крупный hero (бренд, подзаголовок, описание), затем **bento-row** на широких экранах: основная карточка «новая кампания» + вторичная «Продолжить», на узких — столбик. Внизу — компактные feature-строки и повтор eyebrow-теглайна.

**Прокрутка:** контент в `SingleChildScrollView` с `ScrollConfiguration`, отключающей desktop/web `RawScrollbar` на лендинге (короткий контент не должен показывать ложную вертикальную полосу).

**Ключевые значения**:
- Max-width контента: ~920px на `tablet/desktop` (`responsive.isWide`), иначе `dialogMaxWidth`
- Отступы из `responsive.pagePadding` / `blockSpacing`
- Настройки — иконка в правом верхнем углу верхней строки

---

### 2. New Campaign Screen — Wizard создания кампании

**Концепция**: Пошаговый wizard с двумя режимами.

#### Режим выбора

```
┌─────────────────────────────┐
│  ← Новая кампания           │
│                             │
│  Как хотите начать?         │
│                             │
│  ⚡ Быстрый старт            │
│  Начать играть за 30 секунд │
│                             │
│  ⚙ Детальная настройка      │
│  Настроить всё под себя     │
└─────────────────────────────┘
```

#### Быстрый старт

3 поля:
1. Setting (3 ChoiceChips с иконками)
2. Имя героя (TextField)
3. Пол (3 ChoiceChips)

Кнопка: "Начать приключение"

#### Детальная настройка (6 шагов)

Общий каркас: заголовок «Создание мира», **сегментный** индикатор прогресса, подпись «Шаг X из Y», контент по центру, снизу «Назад» и основная кнопка «Далее» / «Создать кампанию».

**Шаг 1 — Жанр (`literaryGenre`):** крупный заголовок «Выберите жанр», пиллы жанров (выбранный — рамка акцента + галочка), опция «Случайный жанр».

**Шаг 2 — Сеттинг (`worldSetting`):** аналогично — «Выберите сеттинг», пиллы, случайный сеттинг.

**Шаг 3 — Foundation**:
- Story Mode (DropdownButtonFormField)
- Difficulty (DropdownButtonFormField)
- Имя героя (TextField)

**Шаг 4 — Story**:
- Story Wish (TextField, 3 строки, опционально)
- Генерация промптов (кнопки)
- Custom Story Prompt (TextField, 4 строки)

**Шаг 5 — Character**:
- Character Class (DropdownButtonFormField) — только если для выбранного сеттинга в `classesBySetting` задан непустой список; иначе поле скрыто, класс в данных — `unspecified`
- Race (DropdownButtonFormField)
- Gender (DropdownButtonFormField)
- Personality (TextField)
- Random Character (OutlinedButton.icon)
- Character Prompt (TextField, 3 строки)

**Синхронизация промпта персонажа:** при смене **сеттинга** (на шаге мира или ранее), **расы**, **пола** или **класса** текст в поле «промпт персонажа» пересобирается из актуального профиля через `CharacterPromptBuilder` (в контроллере `NewGameController`). Ручное редактирование этого поля затем может быть перезаписано следующей такой структурной сменой — это ожидаемое поведение привязки к реквизитам.

**Шаг 6 — Review**:
- Карточка с итоговым обзором всех настроек
- Иконки + лейблы для каждой настройки

**Навигация**:
- Сегментная полоса прогресса (равные сегменты по числу шагов)
- "Шаг X из Y" под индикатором
- Кнопки "Назад" и "Далее" / "Создать кампанию" в нижней панели

**Ключевые значения**:
- Max-width контента wizard: см. `new_game_screen` (full-width layout с внутренним max)
- Padding: через `responsive`
- Жанр/сеттинг: пиллы, не обязательно ChoiceChip с иконками

---

### 3. Saves Screen — Сохранённые кампании

#### Empty State

```
┌─────────────────────────────┐
│                             │
│     📖 (icon 64px)          │
│                             │
│  Пока нет сохранений        │
│                             │
│  Создайте новую кампанию,   │
│  чтобы начать приключение   │
│                             │
│  [+ Создать новую кампанию] │
└─────────────────────────────┘
```

#### Save Card (новый дизайн)

```
┌─────────────────────────────────────┐
│ Название кампании                   │
│ Fantasy • Ход 12 • 15.03.2026       │
│                                     │
│ Краткое описание (max 3 строки)... │
│                                     │
│              [🗑 Удалить] [Открыть] │
└─────────────────────────────────────┘
```

**Изменения от предыдущей версии**:
- Мета-информация в одну строку (setting • turn • date)
- Кнопки внизу справа (было: дата слева, кнопки справа)
- Summary с ограничением 3 строки (было: без ограничения)
- Empty state с кнопкой создания (было: только текст)

**Ключевые значения**:
- Max-width: 1040px (для списка)
- Card spacing: 16px
- Meta text: bodySmall, textMuted
- Summary: bodyMedium, italic, maxLines: 3

---

### 4. Settings Screen — Настройки

**Layout (компактный)**:

```
┌─────────────────────────────┐
│  ← Настройки                │
│                             │
│  КОНТЕНТ                    │
│  ☐ Подтвердить 18+          │
│                             │
│  ЯЗЫК ПРИЛОЖЕНИЯ            │
│  [Русский] [English]        │
│                             │
│  АККАУНТ                    │
│  Вы вошли как ...           │
│  [Войти] / [Выйти]          │
│                             │
│  ВАША МОДЕЛЬ                │
│  Model    [____________]    │
│  API Key  [____________]    │
│  "Вы можете ввести свой..." │
│                             │
│  [Сохранить] [Проверить]    │
└─────────────────────────────┘
```

**Поведение экрана настроек:**
- заголовок должен быть нейтральным: `Настройки` / `Settings`;
- экран не должен перегружать пользователя техническими объяснениями про
  backend, CORS или внутренние коды;
- адрес сервера не показывается и не редактируется пользователем на этом
  экране;
- блок аккаунта показывает только статус текущей сессии и действия
  `Войти` / `Выйти`;
- в блоке своей модели остаётся только одна понятная подсказка про локальное
  хранение ключа на устройстве пользователя;
- `Model` и `API Key` отображают только локально сохранённые значения
  пользователя.

**Поведение формы входа:**
- форма входа минимальная: только email, пароль и имя для регистрации;
- на ней нет поля адреса backend;
- на ней нет объяснения про хранение кампаний или внутреннюю архитектуру;
- в правом верхнем углу есть крестик закрытия, который возвращает пользователя
  назад.

**Изменения от предыдущей версии**:
- Max-width: 640px (было: 920px) — на 30% компактнее
- Provider tiles spacing: 8px (было: 12px)
- Section spacing: 16px (было: 20px)
- TextField spacing: 12px (было: 14px)
- Button spacing: 10px (было: 12px)
- Status с иконкой (✓ или ⓘ) слева
- убраны технические справки про direct web-to-model access и compile-time
  подсказки для обычного пользователя

**Ключевые значения**:
- Max-width: 640px
- Padding: 24px
- Section spacing: 16px
- Field spacing: 12px

---

### 5. Chat Screen — Экран игры

**Desktop (>760px)**:
```
┌─────────────────────────────────────────┐
│  Campaign Title        [💾][⚙][🏠]     │
├──────────┬──────────────────────────────┤
│ Sidebar  │  Chat Messages               │
│ (240px)  │                              │
│          │  ┌─[choice]─[choice]──────┐  │
│          │  │ [input]   [send][❌]   │  │
│          │  └────────────────────────┘  │
└──────────┴──────────────────────────────┘
```

**Mobile (<760px)**:
```
┌─────────────────────────────┐
│ ☰ Campaign  [💾][⚙][🏠]     │
├─────────────────────────────┤
│  Chat Messages              │
│                             │
│  ┌─[choice]─[choice]─────┐  │
│  │ [input]   [send][❌]  │  │
│  └───────────────────────┘  │
└─────────────────────────────┘
```

**Сообщения в ленте:**
- Игрок / система: `bodyLarge` темы.
- Рассказчик (в т.ч. стриминг «ожидание ответа»): тот же **sans (Inter)** через `bodyLarge` с цветом `AetherPalette.narrativeText`, межстрочный интервал ~1.75; без Playfair в теле абзаца.

**Композер (упрощённый)**:
- Без адаптивного кода: одна версия для всех размеров
- Кнопка Отправить/Отменить справа в Row
- LinearProgressIndicator сверху композера при отправке
- Всё внутри одного Container с rounded corners
- **Клавиатура (desktop/web):** в многострочном поле ввода **Enter** отправляет ход (эквивалент кнопки отправки), **Shift+Enter** вставляет перевод строки; при активной отправке (`isSending`) сочетания не перехватываются (`FocusNode.onKeyEvent` в `chat_screen.dart`)

```dart
Container(
  decoration: BoxDecoration(
    color: AetherPalette.panel.withValues(alpha: 0.88),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: AetherPalette.panelBorder),
  ),
  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  child: Column(
    children: [
      if (_isSending) LinearProgressIndicator(...),
      Row(
        children: [
          Expanded(TextField(...)),
          SizedBox(width: 8),
          if (_isSending)
            TextButton(onPressed: cancel, child: Text('Отменить'))
          else
            IconButton.filled(onPressed: send, icon: Icon(Icons.send)),
        ],
      ),
    ],
  ),
)
```

**Изменения от предыдущей версии**:
- Suggestion chips вынесены из ListView (были: внутри как item)
- Margin между chips и composer: 12px (лучшая видимость)
- Sidebar width: 240px (было: 260px)
- Message bubbles max-width: ~680px на широких экранах (см. `chat_screen.dart`)
- LinearProgressIndicator в composer при _isSending
- Chips spacing: 8px (было: зависело от card padding)

**Composer improvements**:
- LinearProgressIndicator (minHeight: 2) при отправке
- Column wrapper для прогресс-бара
- Компактнее расположение кнопок
- Cancel кнопка рядом с индикатором

**Ключевые значения**:
- Wide breakpoint: 760px
- Sidebar width: 240px
- Message max-width: ~680px (wide)
- Composer border-radius: 20px
- Suggestion chips spacing: 8px
- Margin между chips и composer: 12px

---

## Компоненты

### ChoiceChip

**Использование**: Выбор из 2-4 вариантов горизонтально.

```dart
ChoiceChip(
  label: Text('Вариант'),
  selected: _selected == item,
  onSelected: (_) => setState(() => _selected = item),
  avatar: Icon(Icons.icon_name, size: 18),
)
```

**Spacing**: `Wrap(spacing: 8, runSpacing: 8)`

### DropdownButtonFormField

**Использование**: Выбор из 3+ вариантов, вертикальный список.

**ВАЖНО**: Использовать `initialValue` вместо `value` (value deprecated).

```dart
DropdownButtonFormField<T>(
  initialValue: _currentValue,
  decoration: InputDecoration(
    labelText: 'Label',
    filled: true,
    fillColor: AetherPalette.panelSoft.withValues(alpha: 0.3),
  ),
  items: values.map((v) => 
    DropdownMenuItem(value: v, child: Text(label(v))),
  ).toList(),
  onChanged: (v) {
    if (v != null) setState(() => _currentValue = v);
  },
)
```

### Step Indicator

```dart
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: List.generate(totalSteps, (i) {
    final bool isCurrent = i == currentStep;
    final bool isPast = i < currentStep;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4),
      width: isCurrent ? 32 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isCurrent || isPast
            ? AetherPalette.accent
            : AetherPalette.textMuted.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }),
)
```

### Section Label

```dart
Text(
  title.toUpperCase(),
  style: Theme.of(context).textTheme.labelLarge?.copyWith(
    color: AetherPalette.textMuted,
    letterSpacing: 2,
  ),
)
```

### Empty State Pattern

```dart
Center(
  child: ConstrainedBox(
    constraints: BoxConstraints(maxWidth: 400),
    child: Padding(
      padding: EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: textMuted.withAlpha(0.5)),
          SizedBox(height: 24),
          Text(title, style: titleLarge, textAlign: center),
          SizedBox(height: 16),
          Text(subtitle, style: bodyMedium, textAlign: center),
          SizedBox(height: 32),
          FilledButton.icon(
            onPressed: action,
            icon: Icon(Icons.add_rounded),
            label: Text(actionLabel),
          ),
        ],
      ),
    ),
  ),
)
```

### Overlay Choice Buttons (NEW)

**Использование**: Кнопки выбора справа от текста истории с прозрачным фоном.

**Компоненты**:
- `OverlayChoiceStack` — контейнер для кнопок, выровненных справа
- `OverlayChoiceButton` — отдельная кнопка с прозрачным фоном и тонкой рамкой

**Визуальные параметры**:
```dart
const double buttonPadding = 12.0;
const double buttonMaxWidth = 180.0;
const double buttonBorderRadius = 12.0;
const double borderOpacity = 0.8;
```

**Пример использования**:

```dart
// Кнопки внутри ListView как последний элемент
ListView.builder(
  itemCount: messages.length + (choices.isNotEmpty ? 1 : 0),
  itemBuilder: (context, index) {
    if (index == messages.length) {
      // Кнопки выбора в конце
      return OverlayChoiceStack(
        choices: choices.take(3).toList(),
        onChoiceSelected: (choice) { /* ... */ },
        enabled: !isSending,
      );
    }
    // ... сообщения ...
  },
)
```

**Особенности**:
- Прозрачный фон (`Colors.transparent`)
- Тонкая рамка accent цвета (α=0.8)
- Выравнивание справа с Column layout
- Текст выровнен по правому краю
- Иконка chevron справа от текста
- Отступы между кнопками: 6px

**Где использовать**:
- Chat Screen — варианты действий игрока после текста истории
- Везде, где нужно показать выбор без перекрытия текста

---

## Адаптивные паттерны

### 1. Автоскролл в чате

**Проблема**: При появлении новых сообщений пользователь не видит последние ответы ИИ.

**Решение**: Автоматический скролл вниз после добавления сообщений.

```dart
void _scrollToBottom() {
  if (!_scrollController.hasClients) return;
  
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  });
}
```

**Применяется в**:
- Chat Screen после получения ответа от ИИ
- Любой экран с динамическим списком сообщений

### 2. Скрытие кнопок при открытой клавиатуре

**Проблема**: На мобильных устройствах клавиатура перекрывает поля ввода, а кнопки навигации остаются видимыми.

**Решение**: Скрывать кнопки навигации при открытой клавиатуре.

```dart
Widget _buildNavigationButtons(BuildContext context) {
  final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
  if (keyboardHeight > 0) {
    return const SizedBox.shrink();
  }

  return Row(
    children: [
      // Кнопки навигации
    ],
  );
}
```

**Применяется в**:
- New Game Screen (wizard navigation)
- Любые формы с кнопками внизу экрана

### 3. Адаптивные размеры и отступы

**Проблема**: Фиксированные размеры не учитывают узкие и мобильные экраны.

**Решение**: Адаптивные значения на основе ширины экрана.

```dart
final double screenWidth = MediaQuery.of(context).size.width;
final bool isNarrow = screenWidth < 400;
final bool isMobile = screenWidth < 600;

// Chat messages
padding: EdgeInsets.all(isNarrow ? 12 : 18),
fontSize: isNarrow ? 14 : 16,
borderRadius: BorderRadius.circular(isNarrow ? 16 : 20),
maxWidth: isNarrow ? screenWidth * 0.85 : 640,

// Saves cards
padding: EdgeInsets.all(isNarrow ? 12 : (isMobile ? 16 : 20)),
fontSize: isNarrow ? 11 : 12,
```

**Применяется в**:
- Chat Screen
- Saves Screen
- Любые экраны с карточками и текстом

### 4. Адаптивная мета-информация

**Проблема**: Длинная мета-информация в одну строку переполняется на узких экранах.

**Решение**: Использовать `Wrap` вместо `Row` для автоматического переноса.

```dart
// Было:
Row(
  children: [
    Text('Fantasy'),
    Text(' • '),
    Text('Ход 12'),
    Text(' • '),
    Text('15.03.2026'),
  ],
)

// Стало:
Wrap(
  spacing: 4,
  runSpacing: 4,
  children: [
    Text('Fantasy'),
    Text(' • '),
    Text('Ход 12'),
    Text(' • '),
    Text('15.03.2026'),
  ],
)
```

### Адаптивный padding

**Использование**: Уменьшать padding на узких экранах (<360px).

```dart
AetherCard(
  padding: EdgeInsets.all(
    MediaQuery.of(context).size.width < 360 ? 16 : 24,
  ),
  child: ...,
)
```

### Flexible кнопки

**Проблема**: Кнопки с длинным текстом обрезаются.

**Решение**: Обернуть в `Flexible`.

```dart
Row(
  mainAxisAlignment: MainAxisAlignment.end,
  children: [
    _SavesToolbarButton(...),
    const SizedBox(width: 8),
    Flexible(
      child: _SavesActionButton(
        label: l10n.loadCampaignAction,
        onTap: onOpen,
      ),
    ),
  ],
)
```

---

## Прогресс-индикаторы и ошибки

### Информативные индикаторы загрузки

**Вместо "..."**  используй понятные тексты:

```dart
String get generatingResponse => switch (language) {
  AppLanguage.ru => 'Генерируется ответ...',
  AppLanguage.en => 'Generating response...',
};

String get creatingCampaign => switch (language) {
  AppLanguage.ru => 'Создание кампании...',
  AppLanguage.en => 'Creating campaign...',
};

String generatingAttempt(int current, int max) => switch (language) {
  AppLanguage.ru => 'Попытка $current из $max...',
  AppLanguage.en => 'Attempt $current of $max...',
};
```

### User-friendly ошибки

Тексты ошибок должны:
1. Объяснять что произошло
2. Подсказывать что делать дальше
3. Быть понятными без технических деталей

```dart
// ❌ Плохо
'Модель не вернула JSON в ожидаемом формате.'

// ✅ Хорошо
'Модель не вернула JSON в ожидаемом формате.\n\n'
'Попробуйте снова. Если проблема не исчезает, возможно модель не поддерживает structured output.'
```

### Логирование для отладки

Используй `AppLogger` для отладки AI запросов:

```dart
AppLogger.logAiRequest(
  endpoint: uri.toString(),
  requestBody: requestBody,
  settings: settings,
);

AppLogger.logAiResponse(
  endpoint: uri.toString(),
  statusCode: response.statusCode,
  rawResponse: rawResponse,
);

AppLogger.logAiError(
  message: 'HTTP ${response.statusCode} error',
  exception: exception,
);
```

**Примечание**: Для полноценного логирования добавь `logger: ^2.0.0` в `pubspec.yaml`. Текущая версия использует `debugPrint`.

---

## Локализация

### Новые строки для wizard

```dart
String get howToStart  // "Как хотите начать?"
String get quickStart  // "Быстрый старт"
String get quickStartDesc  // "Начать играть за 30 секунд"
String get customSetup  // "Детальная настройка"
String get customSetupDesc  // "Настроить всё под себя"
String stepXOfY(int x, int y)  // "Шаг X из Y"
String get startAdventure  // "Начать приключение"
String get nextButton  // "Далее"
String get backButton  // "Назад"
String get reviewTitle  // "Проверьте настройки"
String get readyToStart  // "Всё готово! Нажмите..."
String get storyWishOptional  // "Опционально: опишите..."
String get characterOptional  // "Опционально: настройте..."
```

### Новые строки для empty state

```dart
String get noSavesCreateNew  // "Создайте новую кампанию..."
String get createNewCampaign  // "Создать новую кампанию"
```

---

## Spacing Reference

### Стандартные значения

- **4px** — tight spacing (между иконкой и текстом)
- **8px** — compact spacing (chips, мелкие элементы)
- **12px** — default spacing (между полями, кнопками)
- **16px** — comfortable spacing (между секциями в форме)
- **24px** — section spacing (между крупными блоками)
- **32px** — large spacing (между major sections)

### Padding

- **Страницы**: 24px
- **Карточки**: 20-24px (AetherCard default: 20px)
- **Composer**: 12px horizontal, 8px vertical
- **Chips**: 12px horizontal, 8px vertical

### Max-width

- **Home**: 760px
- **New Campaign**: 600px
- **Saves list**: 1040px
- **Settings**: 640px
- **Chat messages**: 640px

---

## Чеклист для новых экранов

### Дизайн

- [ ] Max-width 600-720px
- [ ] Mobile-first layout (одна колонка)
- [ ] Touch targets ≥48dp
- [ ] Spacing: 12/16/24/32
- [ ] AetherCard для групп контента
- [ ] AetherPageReveal для анимации
- [ ] Правильная типографика (headlineLarge → bodyMedium)

### UX

- [ ] Не более 3 действий до цели
- [ ] Понятные labels и hints
- [ ] Empty state обработан
- [ ] Loading state с индикатором
- [ ] Error state с понятным сообщением
- [ ] Success feedback (статус, иконка)
- [ ] Возможность вернуться назад

### Код

- [ ] `flutter analyze` без ошибок
- [ ] Локализация ru + en
- [ ] `initialValue` вместо `value` в dropdowns
- [ ] Нет hardcoded strings
- [ ] Constants для spacing

---

## Миграция со старого дизайна

### Breaking changes

1. **New Campaign**: Полностью новый wizard интерфейс
2. **Home**: Feature chips перемещены выше кнопок
3. **Saves**: Empty state с кнопкой, новый дизайн карточки
4. **Settings**: Max-width уменьшен на 30%
5. **Chat**: Suggestion chips вынесены из ListView

### Deprecated

- `value` в `DropdownButtonFormField` → используйте `initialValue`

---

## Ссылки

- **Исходный план**: `.cursor/plans/ui_ux_improvements_all_screens_*.plan.md`
- **Правила проекта**: `.cursorrules`, `.specify/memory/`
- **Aether Design System**: `lib/src/app/aether_shell.dart`
- **Локализация**: `lib/src/app/app_localizations.dart`

---

**Дата обновления**: Март 2026  
**Версия**: 1.0
