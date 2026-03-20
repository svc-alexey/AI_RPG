import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:flutter/widgets.dart';

class AppLocalizations {
  const AppLocalizations(this.language);

  final AppLanguage language;

  static AppLocalizations of(final BuildContext context) {
    final AppLocalizationsScope? scope = context
        .dependOnInheritedWidgetOfExactType<AppLocalizationsScope>();
    assert(scope != null, 'AppLocalizationsScope is missing in widget tree.');
    return scope!.localizations;
  }

  String get appTitle => switch (language) {
    AppLanguage.ru => 'ИИ RPG',
    AppLanguage.en => 'AI RPG',
  };

  String get homeDescription => switch (language) {
    AppLanguage.ru =>
      'Минимальный desktop-first клиент: чат, настройки провайдера, локальные сохранения и интеграция с LM Studio.',
    AppLanguage.en =>
      'A minimal desktop-first client with chat, provider settings, local saves, and LM Studio integration.',
  };

  String get newCampaign => switch (language) {
    AppLanguage.ru => 'Новая кампания',
    AppLanguage.en => 'New Campaign',
  };

  String get saves => switch (language) {
    AppLanguage.ru => 'Сохранения',
    AppLanguage.en => 'Saves',
  };

  String get aiSettings => switch (language) {
    AppLanguage.ru => 'Настройки ИИ',
    AppLanguage.en => 'AI Settings',
  };

  String get whatsIncluded => switch (language) {
    AppLanguage.ru => 'Что уже есть',
    AppLanguage.en => 'What Is Included',
  };

  List<String> get homeFeatureLines => switch (language) {
    AppLanguage.ru => const <String>[
      'Локальная история кампаний',
      'Один полный игровой ход через ИИ',
      'Демо-режим без модели',
      'Совместимый с OpenAI endpoint для LM Studio',
    ],
    AppLanguage.en => const <String>[
      'Local campaign history',
      'One complete AI-driven turn',
      'Demo mode without a model',
      'OpenAI-compatible endpoint for LM Studio',
    ],
  };

  String get buildScenarioTitle => switch (language) {
    AppLanguage.ru => 'Соберем первый рабочий сценарий',
    AppLanguage.en => 'Let us set up the first playable scenario',
  };

  String get buildScenarioDescription => switch (language) {
    AppLanguage.ru =>
      'Выбираем сеттинг, режим и имя героя. После создания сразу откроется игровой чат.',
    AppLanguage.en =>
      'Choose a setting, mode, and hero name. The game chat opens right after creation.',
  };

  String get heroName => switch (language) {
    AppLanguage.ru => 'Имя героя',
    AppLanguage.en => 'Hero Name',
  };

  String get heroNameHint => switch (language) {
    AppLanguage.ru => 'Мира, Ясень, Грач...',
    AppLanguage.en => 'Mira, Ash, Raven...',
  };

  String get settingTitle => switch (language) {
    AppLanguage.ru => 'Сеттинг',
    AppLanguage.en => 'Setting',
  };

  String get storyModeTitle => switch (language) {
    AppLanguage.ru => 'Режим истории',
    AppLanguage.en => 'Story Mode',
  };

  String get difficultyTitle => switch (language) {
    AppLanguage.ru => 'Сложность',
    AppLanguage.en => 'Difficulty',
  };

  String get createCampaignButton => switch (language) {
    AppLanguage.ru => 'Создать кампанию',
    AppLanguage.en => 'Create Campaign',
  };

  String get storyWishTitle => switch (language) {
    AppLanguage.ru => 'Опиши, какую историю хочешь',
    AppLanguage.en => 'Describe the story you want',
  };

  String get storyWishHint => switch (language) {
    AppLanguage.ru =>
      'Например: мрачный детектив в стиле нуар, эпическое фэнтези с драконами...',
    AppLanguage.en => 'E.g.: dark detective noir, epic fantasy with dragons...',
  };

  String get insertTextPrompt => switch (language) {
    AppLanguage.ru => 'Подставить текст',
    AppLanguage.en => 'Insert text',
  };

  String get generatePrompts => switch (language) {
    AppLanguage.ru => 'Сгенерировать промпты',
    AppLanguage.en => 'Generate prompts',
  };

  String get generatingPrompts => switch (language) {
    AppLanguage.ru => 'Генерация...',
    AppLanguage.en => 'Generating...',
  };

  String get customStoryPromptTitle => switch (language) {
    AppLanguage.ru => 'Промпт истории (редактируемый)',
    AppLanguage.en => 'Story prompt (editable)',
  };

  String get characterSectionTitle => switch (language) {
    AppLanguage.ru => 'Персонаж',
    AppLanguage.en => 'Character',
  };

  String get characterClassTitle => switch (language) {
    AppLanguage.ru => 'Класс',
    AppLanguage.en => 'Class',
  };

  String get characterRaceTitle => switch (language) {
    AppLanguage.ru => 'Раса',
    AppLanguage.en => 'Race',
  };

  String get characterGenderTitle => switch (language) {
    AppLanguage.ru => 'Пол',
    AppLanguage.en => 'Gender',
  };

  String get characterPersonalityTitle => switch (language) {
    AppLanguage.ru => 'Характер',
    AppLanguage.en => 'Personality',
  };

  String get characterSkillsTitle => switch (language) {
    AppLanguage.ru => 'Навыки',
    AppLanguage.en => 'Skills',
  };

  String get characterPerksTitle => switch (language) {
    AppLanguage.ru => 'Плюшки',
    AppLanguage.en => 'Perks',
  };

  String get addPerk => switch (language) {
    AppLanguage.ru => 'Добавить плюшку',
    AppLanguage.en => 'Add perk',
  };

  String get addSkill => switch (language) {
    AppLanguage.ru => 'Добавить навык',
    AppLanguage.en => 'Add skill',
  };

  String get randomCharacter => switch (language) {
    AppLanguage.ru => 'Случайный персонаж',
    AppLanguage.en => 'Random character',
  };

  String get editCharacterPrompt => switch (language) {
    AppLanguage.ru => 'Редактировать промпт персонажа',
    AppLanguage.en => 'Edit character prompt',
  };

  String get configureAiFirst => switch (language) {
    AppLanguage.ru =>
      'Настройки ИИ не настроены. Сгенерировать промпты нельзя.',
    AppLanguage.en =>
      'AI settings are not configured. Cannot generate prompts.',
  };

  String characterClassLabel(final CharacterClass value) =>
      switch ((language, value)) {
        (AppLanguage.ru, CharacterClass.warrior) => 'Воин',
        (AppLanguage.ru, CharacterClass.mage) => 'Маг',
        (AppLanguage.ru, CharacterClass.rogue) => 'Плут',
        (AppLanguage.ru, CharacterClass.detective) => 'Детектив',
        (AppLanguage.ru, CharacterClass.journalist) => 'Журналист',
        (AppLanguage.ru, CharacterClass.smuggler) => 'Контрабандист',
        (AppLanguage.ru, CharacterClass.engineer) => 'Инженер',
        (AppLanguage.ru, CharacterClass.pilot) => 'Пилот',
        (AppLanguage.ru, CharacterClass.medic) => 'Медик',
        (AppLanguage.en, CharacterClass.warrior) => 'Warrior',
        (AppLanguage.en, CharacterClass.mage) => 'Mage',
        (AppLanguage.en, CharacterClass.rogue) => 'Rogue',
        (AppLanguage.en, CharacterClass.detective) => 'Detective',
        (AppLanguage.en, CharacterClass.journalist) => 'Journalist',
        (AppLanguage.en, CharacterClass.smuggler) => 'Smuggler',
        (AppLanguage.en, CharacterClass.engineer) => 'Engineer',
        (AppLanguage.en, CharacterClass.pilot) => 'Pilot',
        (AppLanguage.en, CharacterClass.medic) => 'Medic',
      };

  String characterGenderLabel(final CharacterGender value) =>
      switch ((language, value)) {
        (AppLanguage.ru, CharacterGender.male) => 'Мужской',
        (AppLanguage.ru, CharacterGender.female) => 'Женский',
        (AppLanguage.ru, CharacterGender.other) => 'Другой',
        (AppLanguage.en, CharacterGender.male) => 'Male',
        (AppLanguage.en, CharacterGender.female) => 'Female',
        (AppLanguage.en, CharacterGender.other) => 'Other',
      };

  String raceLabel(final String raceId, final CampaignSetting setting) =>
      switch ((language, raceId, setting)) {
        (AppLanguage.ru, 'human', _) => 'Человек',
        (AppLanguage.ru, 'elf', _) => 'Эльф',
        (AppLanguage.ru, 'dwarf', _) => 'Дварф',
        (AppLanguage.ru, 'orc', _) => 'Орк',
        (AppLanguage.ru, 'outsider', _) => 'Приезжий',
        (AppLanguage.ru, 'local', _) => 'Местный',
        (AppLanguage.ru, 'android', _) => 'Андроид',
        (AppLanguage.ru, 'alien', _) => 'Инопланетянин',
        (AppLanguage.ru, 'augmented', _) => 'Аугментированный',
        (AppLanguage.en, 'human', _) => 'Human',
        (AppLanguage.en, 'elf', _) => 'Elf',
        (AppLanguage.en, 'dwarf', _) => 'Dwarf',
        (AppLanguage.en, 'orc', _) => 'Orc',
        (AppLanguage.en, 'outsider', _) => 'Outsider',
        (AppLanguage.en, 'local', _) => 'Local',
        (AppLanguage.en, 'android', _) => 'Android',
        (AppLanguage.en, 'alien', _) => 'Alien',
        (AppLanguage.en, 'augmented', _) => 'Augmented',
        _ => raceId,
      };

  String settingLabel(final CampaignSetting value) =>
      switch ((language, value)) {
        (AppLanguage.ru, CampaignSetting.fantasy) => 'Фэнтези',
        (AppLanguage.ru, CampaignSetting.detective) => 'Детектив',
        (AppLanguage.ru, CampaignSetting.sciFi) => 'Sci-fi',
        (AppLanguage.en, CampaignSetting.fantasy) => 'Fantasy',
        (AppLanguage.en, CampaignSetting.detective) => 'Detective',
        (AppLanguage.en, CampaignSetting.sciFi) => 'Sci-fi',
      };

  String storyModeLabel(final StoryMode value) => switch ((language, value)) {
    (AppLanguage.ru, StoryMode.shortStory) => 'Короткая история',
    (AppLanguage.ru, StoryMode.longCampaign) => 'Длинная кампания',
    (AppLanguage.en, StoryMode.shortStory) => 'Short Story',
    (AppLanguage.en, StoryMode.longCampaign) => 'Long Campaign',
  };

  String difficultyLabel(final DifficultyLevel value) =>
      switch ((language, value)) {
        (AppLanguage.ru, DifficultyLevel.easy) => 'Легко',
        (AppLanguage.ru, DifficultyLevel.medium) => 'Нормально',
        (AppLanguage.ru, DifficultyLevel.hardcore) => 'Хардкор',
        (AppLanguage.en, DifficultyLevel.easy) => 'Easy',
        (AppLanguage.en, DifficultyLevel.medium) => 'Normal',
        (AppLanguage.en, DifficultyLevel.hardcore) => 'Hardcore',
      };

  String get savedCampaigns => switch (language) {
    AppLanguage.ru => 'Сохраненные кампании',
    AppLanguage.en => 'Saved Campaigns',
  };

  String get noSavesYet => switch (language) {
    AppLanguage.ru =>
      'Пока нет сохранений. Создай новую кампанию на главном экране.',
    AppLanguage.en =>
      'There are no saves yet. Create a new campaign from the home screen.',
  };

  String get savesOpenFailed => switch (language) {
    AppLanguage.ru => 'Не удалось открыть сохранения.',
    AppLanguage.en => 'Failed to open saves.',
  };

  String get loadCampaignAction => switch (language) {
    AppLanguage.ru => 'Загрузить',
    AppLanguage.en => 'Load',
  };

  String saveSubtitle(final CampaignState campaign) => switch (language) {
    AppLanguage.ru => '${campaign.location} • ход ${campaign.turnNumber}',
    AppLanguage.en => '${campaign.location} • turn ${campaign.turnNumber}',
  };

  String get campaignNotFound => switch (language) {
    AppLanguage.ru => 'Кампания не найдена',
    AppLanguage.en => 'Campaign Not Found',
  };

  String get campaignOpenFailed => switch (language) {
    AppLanguage.ru => 'Не удалось открыть кампанию.',
    AppLanguage.en => 'Failed to open the campaign.',
  };

  String get saveTooltip => switch (language) {
    AppLanguage.ru => 'Сохранить',
    AppLanguage.en => 'Save',
  };

  String get campaignInfo => switch (language) {
    AppLanguage.ru => 'Информация о кампании',
    AppLanguage.en => 'Campaign info',
  };

  String get chatInputHint => switch (language) {
    AppLanguage.ru => 'Что делает герой дальше?',
    AppLanguage.en => 'What does the hero do next?',
  };

  String get send => switch (language) {
    AppLanguage.ru => 'Отправить',
    AppLanguage.en => 'Send',
  };

  String get suggest => switch (language) {
    AppLanguage.ru => 'Подсказать',
    AppLanguage.en => 'Suggest',
  };

  String get location => switch (language) {
    AppLanguage.ru => 'Локация',
    AppLanguage.en => 'Location',
  };

  String get objective => switch (language) {
    AppLanguage.ru => 'Цель',
    AppLanguage.en => 'Objective',
  };

  String get turn => switch (language) {
    AppLanguage.ru => 'Ход',
    AppLanguage.en => 'Turn',
  };

  String healthLabel(final CharacterStats character) => switch (language) {
    AppLanguage.ru => 'Здоровье ${character.hp}/${character.maxHp}',
    AppLanguage.en => 'Health ${character.hp}/${character.maxHp}',
  };

  String energyLabel(final CharacterStats character) => switch (language) {
    AppLanguage.ru => 'Энергия ${character.energy}/${character.maxEnergy}',
    AppLanguage.en => 'Energy ${character.energy}/${character.maxEnergy}',
  };

  String statsLabel(final CharacterStats character) => switch (language) {
    AppLanguage.ru =>
      'Сила ${character.might} • Ум ${character.wit} • Дух ${character.spirit}',
    AppLanguage.en =>
      'Might ${character.might} • Wit ${character.wit} • Spirit ${character.spirit}',
  };

  String get inventory => switch (language) {
    AppLanguage.ru => 'Инвентарь',
    AppLanguage.en => 'Inventory',
  };

  String get questLog => switch (language) {
    AppLanguage.ru => 'Журнал задач',
    AppLanguage.en => 'Quest Log',
  };

  String get summary => switch (language) {
    AppLanguage.ru => 'Сводка',
    AppLanguage.en => 'Summary',
  };

  String get campaignSaved => switch (language) {
    AppLanguage.ru => 'Кампания сохранена.',
    AppLanguage.en => 'Campaign saved.',
  };

  String get actionRequired => switch (language) {
    AppLanguage.ru => 'Сначала введи действие героя.',
    AppLanguage.en => 'Enter the hero action first.',
  };

  String suggestionsUpdated(final bool aiConfigured) => switch (language) {
    AppLanguage.ru => 'Варианты действий обновлены.',
    AppLanguage.en => 'Action suggestions updated.',
  };

  String turnCompleted(final bool aiConfigured) => switch (language) {
    AppLanguage.ru =>
      'Ход завершен ${aiConfigured ? 'через ИИ' : 'в демо-режиме'}.',
    AppLanguage.en =>
      'Turn completed ${aiConfigured ? 'through AI' : 'in demo mode'}.',
  };

  String get exitToMainMenu => switch (language) {
    AppLanguage.ru => 'В главное меню',
    AppLanguage.en => 'Exit to main menu',
  };

  String get cancel => switch (language) {
    AppLanguage.ru => 'Отменить',
    AppLanguage.en => 'Cancel',
  };

  String get generationCancelled => switch (language) {
    AppLanguage.ru => 'Генерация отменена',
    AppLanguage.en => 'Generation cancelled',
  };

  String turnError(final Object error) => switch (language) {
    AppLanguage.ru => 'Ошибка хода: $error',
    AppLanguage.en => 'Turn error: $error',
  };

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

  String get aiErrorRetryAdvice => switch (language) {
    AppLanguage.ru =>
      'Попробуйте ещё раз. Если проблема повторяется, проверьте настройки ИИ.',
    AppLanguage.en => 'Try again. If the problem persists, check AI settings.',
  };

  String get retryButton => switch (language) {
    AppLanguage.ru => 'Попробовать снова',
    AppLanguage.en => 'Try Again',
  };

  String get delete => switch (language) {
    AppLanguage.ru => 'Удалить',
    AppLanguage.en => 'Delete',
  };

  String get rawModelResponseSaved => switch (language) {
    AppLanguage.ru =>
      'Техническая заметка: сырой ответ модели сохранен для отладки и не был применен к состоянию игры.',
    AppLanguage.en =>
      'Technical note: the raw model response was kept for debugging and was not applied to the game state.',
  };

  String get contentRatingTitle => switch (language) {
    AppLanguage.ru => 'Контент',
    AppLanguage.en => 'Content',
  };

  String get confirm18Plus => switch (language) {
    AppLanguage.ru => 'Подтвердить 18+',
    AppLanguage.en => 'Confirm 18+',
  };

  String get contentRatingSubtitle => switch (language) {
    AppLanguage.ru =>
      'Без подтверждения ИИ избегает сексуального контента. Подходит для общих аудиторий.',
    AppLanguage.en =>
      'Without confirmation, AI avoids sexual content. Suitable for general audiences.',
  };

  String get languageTitle => switch (language) {
    AppLanguage.ru => 'Язык приложения',
    AppLanguage.en => 'App Language',
  };

  String get russian => 'Русский';
  String get english => 'English';

  String get aiSettingsTitle => switch (language) {
    AppLanguage.ru => 'LM Studio и OpenAI-compatible endpoint',
    AppLanguage.en => 'LM Studio and OpenAI-compatible endpoint',
  };

  String get aiSettingsDescription => switch (language) {
    AppLanguage.ru =>
      'Для LM Studio по умолчанию используется http://127.0.0.1:1234/v1. Если локальный сервер LM Studio запущен, приложение само подберет подходящую загруженную модель.',
    AppLanguage.en =>
      'LM Studio uses http://127.0.0.1:1234/v1 by default. If the local LM Studio server is running, the app will pick a suitable loaded model automatically.',
  };

  String get openAiCompatible => switch (language) {
    AppLanguage.ru => 'Совместимый с OpenAI',
    AppLanguage.en => 'OpenAI Compatible',
  };

  String get openRouter => switch (language) {
    AppLanguage.ru => 'OpenRouter',
    AppLanguage.en => 'OpenRouter',
  };

  String get deepSeek => switch (language) {
    AppLanguage.ru => 'DeepSeek',
    AppLanguage.en => 'DeepSeek',
  };

  String get baseUrl => switch (language) {
    AppLanguage.ru => 'Базовый URL',
    AppLanguage.en => 'Base URL',
  };

  String get model => switch (language) {
    AppLanguage.ru => 'Модель',
    AppLanguage.en => 'Model',
  };

  String get apiKey => switch (language) {
    AppLanguage.ru => 'API-ключ',
    AppLanguage.en => 'API Key',
  };

  String get apiKeyHint => switch (language) {
    AppLanguage.ru => 'Для LM Studio обычно не нужен',
    AppLanguage.en => 'Usually not needed for LM Studio',
  };

  String get timeoutSeconds => switch (language) {
    AppLanguage.ru => 'Таймаут в секундах',
    AppLanguage.en => 'Timeout in Seconds',
  };

  String get fastModeTitle => switch (language) {
    AppLanguage.ru => 'Быстрый режим LM Studio',
    AppLanguage.en => 'LM Studio Fast Mode',
  };

  String get fastModeSubtitle => switch (language) {
    AppLanguage.ru =>
      'Добавляет /no_think и строгий JSON-формат для более быстрых ответов.',
    AppLanguage.en =>
      'Adds /no_think and strict JSON formatting for faster responses.',
  };

  String get runtimeControlsTitle => switch (language) {
    AppLanguage.ru => 'Runtime',
    AppLanguage.en => 'Runtime',
  };

  String get runtimeControlsDescription => switch (language) {
    AppLanguage.ru =>
      'Управляйте длиной ответа и примерным размером контекста, который отправляется модели.',
    AppLanguage.en =>
      'Control response length and the approximate amount of context sent to the model.',
  };

  String get runtimeProfileCheap => switch (language) {
    AppLanguage.ru => 'Дёшево',
    AppLanguage.en => 'Cheap',
  };

  String get runtimeProfileFast => switch (language) {
    AppLanguage.ru => 'Быстро',
    AppLanguage.en => 'Fast',
  };

  String get runtimeProfileSmart => switch (language) {
    AppLanguage.ru => 'Умно',
    AppLanguage.en => 'Smart',
  };

  String get runtimeProfileCustom => switch (language) {
    AppLanguage.ru => 'Свои',
    AppLanguage.en => 'Custom',
  };

  String get maxResponseTokens => switch (language) {
    AppLanguage.ru => 'Максимум токенов ответа',
    AppLanguage.en => 'Max Response Tokens',
  };

  String get contextWindowSize => switch (language) {
    AppLanguage.ru => 'Размер окна контекста',
    AppLanguage.en => 'Context Window Size',
  };

  String get saveSettings => switch (language) {
    AppLanguage.ru => 'Сохранить настройки',
    AppLanguage.en => 'Save Settings',
  };

  String get checkConnection => switch (language) {
    AppLanguage.ru => 'Проверить подключение',
    AppLanguage.en => 'Check Connection',
  };

  String get detectModel => switch (language) {
    AppLanguage.ru => 'Подобрать модель автоматически',
    AppLanguage.en => 'Detect Model Automatically',
  };

  String get detectingModel => switch (language) {
    AppLanguage.ru => 'Подбираю модель...',
    AppLanguage.en => 'Detecting model...',
  };

  String get settingsSaved => switch (language) {
    AppLanguage.ru => 'Настройки сохранены.',
    AppLanguage.en => 'Settings saved.',
  };

  String get connectionOk => switch (language) {
    AppLanguage.ru => 'Подключение успешно.',
    AppLanguage.en => 'Connection successful.',
  };

  String connectionFailed(final Object error) => switch (language) {
    AppLanguage.ru => 'Не удалось подключиться: $error',
    AppLanguage.en => 'Connection failed: $error',
  };

  String get noLmStudioModel => switch (language) {
    AppLanguage.ru => 'LM Studio ответил, но подходящая модель не найдена.',
    AppLanguage.en => 'LM Studio responded, but no suitable model was found.',
  };

  String selectedLmStudioModel(final String modelId) => switch (language) {
    AppLanguage.ru => 'Автоматически выбрана модель LM Studio: $modelId',
    AppLanguage.en => 'LM Studio model selected automatically: $modelId',
  };

  String detectLmStudioFailed(final Object error) => switch (language) {
    AppLanguage.ru =>
      'Не удалось автоматически определить модель LM Studio. Убедись, что локальный сервер запущен: $error',
    AppLanguage.en =>
      'Could not detect an LM Studio model automatically. Make sure the local server is running: $error',
  };

  String serverReturned(final int statusCode) => switch (language) {
    AppLanguage.ru => 'сервер вернул $statusCode',
    AppLanguage.en => 'server returned $statusCode',
  };

  String get unexpectedResponseFormat => switch (language) {
    AppLanguage.ru => 'неожиданный формат ответа',
    AppLanguage.en => 'unexpected response format',
  };

  String get aiEndpointConnectionFailed => switch (language) {
    AppLanguage.ru => 'Не удалось подключиться к AI endpoint.',
    AppLanguage.en => 'Could not connect to the AI endpoint.',
  };

  String aiEndpointError(final int statusCode) => switch (language) {
    AppLanguage.ru =>
      'AI endpoint вернул ошибку $statusCode. Состояние кампании не изменено.',
    AppLanguage.en =>
      'The AI endpoint returned error $statusCode. The campaign state was not changed.',
  };

  String get providerUnexpectedFormat => switch (language) {
    AppLanguage.ru =>
      'Провайдер вернул неожиданный формат ответа. Состояние кампании не изменено.',
    AppLanguage.en =>
      'The provider returned an unexpected response format. The campaign state was not changed.',
  };

  String get providerNoChoices => switch (language) {
    AppLanguage.ru =>
      'Провайдер не вернул ни одного варианта ответа. Состояние кампании не изменено.',
    AppLanguage.en =>
      'The provider returned no answer choices. The campaign state was not changed.',
  };

  String get invalidJson => switch (language) {
    AppLanguage.ru =>
      'Модель вернула невалидный JSON. Состояние кампании не изменено.',
    AppLanguage.en =>
      'The model returned invalid JSON. The campaign state was not changed.',
  };

  String get modelDidNotReturnJson => switch (language) {
    AppLanguage.ru =>
      'Модель не вернула JSON в ожидаемом формате. Состояние кампании не изменено.',
    AppLanguage.en =>
      'The model did not return JSON in the expected format. The campaign state was not changed.',
  };
  String get activeGoalTitle => switch (language) {
    AppLanguage.ru => 'Активная цель',
    AppLanguage.en => 'Active Goal',
  };

  String get recentEventsTitle => switch (language) {
    AppLanguage.ru => 'Последние события',
    AppLanguage.en => 'Recent Events',
  };

  // New Campaign Wizard strings
  String get howToStart => switch (language) {
    AppLanguage.ru => 'Как хотите начать?',
    AppLanguage.en => 'How would you like to start?',
  };

  String get quickStart => switch (language) {
    AppLanguage.ru => 'Быстрый старт',
    AppLanguage.en => 'Quick Start',
  };

  String get quickStartDesc => switch (language) {
    AppLanguage.ru => 'Начать играть за 30 секунд',
    AppLanguage.en => 'Start playing in 30 seconds',
  };

  String get customSetup => switch (language) {
    AppLanguage.ru => 'Детальная настройка',
    AppLanguage.en => 'Custom Setup',
  };

  String get customSetupDesc => switch (language) {
    AppLanguage.ru => 'Настроить всё под себя',
    AppLanguage.en => 'Customize everything',
  };

  String stepXOfY(int current, int total) => switch (language) {
    AppLanguage.ru => 'Шаг $current из $total',
    AppLanguage.en => 'Step $current of $total',
  };

  String get startAdventure => switch (language) {
    AppLanguage.ru => 'Начать приключение',
    AppLanguage.en => 'Start Adventure',
  };

  String get nextButton => switch (language) {
    AppLanguage.ru => 'Далее',
    AppLanguage.en => 'Next',
  };

  String get backButton => switch (language) {
    AppLanguage.ru => 'Назад',
    AppLanguage.en => 'Back',
  };

  String get reviewTitle => switch (language) {
    AppLanguage.ru => 'Проверьте настройки',
    AppLanguage.en => 'Review Settings',
  };

  String get readyToStart => switch (language) {
    AppLanguage.ru => 'Всё готово! Нажмите "Создать кампанию" для начала.',
    AppLanguage.en => 'All set! Click "Create Campaign" to begin.',
  };

  String get storyWishOptional => switch (language) {
    AppLanguage.ru => 'Опционально: опишите желаемую историю для генерации',
    AppLanguage.en => 'Optional: describe your desired story for generation',
  };

  String get characterOptional => switch (language) {
    AppLanguage.ru =>
      'Опционально: настройте персонажа или оставьте по умолчанию',
    AppLanguage.en => 'Optional: customize character or leave defaults',
  };

  // Empty state strings
  String get noSavesCreateNew => switch (language) {
    AppLanguage.ru => 'Создайте новую кампанию, чтобы начать приключение',
    AppLanguage.en => 'Create a new campaign to start your adventure',
  };

  String get createNewCampaign => switch (language) {
    AppLanguage.ru => 'Создать новую кампанию',
    AppLanguage.en => 'Create New Campaign',
  };
}

class AppLocalizationsScope extends InheritedWidget {
  const AppLocalizationsScope({
    required this.localizations,
    required super.child,
    super.key,
  });

  final AppLocalizations localizations;

  @override
  bool updateShouldNotify(final AppLocalizationsScope oldWidget) =>
      localizations.language != oldWidget.localizations.language;
}

extension AppLocalizationsBuildContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
