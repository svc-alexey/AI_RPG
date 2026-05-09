import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:ai_prg/src/core/models/symmetry_models.dart';
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

  String get appTitle => brandName;

  String get brandName => switch (language) {
    AppLanguage.ru => 'Стирая Грань',
    AppLanguage.en => 'Beyond the Verge',
  };

  String get brandNameLine1 => switch (language) {
    AppLanguage.ru => 'Стирая',
    AppLanguage.en => 'Beyond the',
  };

  String get brandNameLine2 => switch (language) {
    AppLanguage.ru => 'Грань',
    AppLanguage.en => 'Verge',
  };

  String get homeTagline => switch (language) {
    AppLanguage.ru => 'Нарративная RPG с ИИ',
    AppLanguage.en => 'Narrative AI RPG',
  };

  String get homePrimaryCardSubtitle => switch (language) {
    AppLanguage.ru =>
      'ИИ станет вашим рассказчиком в мире, который помнит каждое решение',
    AppLanguage.en =>
      'AI becomes your narrator in a world that remembers every choice',
  };

  /// Заголовок на bento-карточке (шире, чем подпись кнопки).
  String get homeBentoPrimaryTitle => switch (language) {
    AppLanguage.ru => 'Начать новую историю',
    AppLanguage.en => 'Start a new story',
  };

  /// Строка-действие под текстом на основной карточке.
  String get homeBentoPrimaryLink => switch (language) {
    AppLanguage.ru => 'Создать кампанию',
    AppLanguage.en => 'Create a campaign',
  };

  String get homeSecondaryCardSubtitle => switch (language) {
    AppLanguage.ru => 'Вернуться в сохранённый мир',
    AppLanguage.en => 'Return to a saved world',
  };

  String get homeLoginCardSubtitle => switch (language) {
    AppLanguage.ru => 'Войти в аккаунт',
    AppLanguage.en => 'Sign in to your account',
  };

  String homeSignedInCardSubtitle(final String name) => switch (language) {
    AppLanguage.ru => 'Вы вошли как $name',
    AppLanguage.en => 'Signed in as $name',
  };

  String get homeHeroTitle => switch (language) {
    AppLanguage.ru => 'История отвечает на твой выбор',
    AppLanguage.en => 'Where choice reshapes the story',
  };

  String get homeDescription => switch (language) {
    AppLanguage.ru =>
      'Нарративная ролевая игра, где ИИ ведет сцену, а мир помнит последствия.',
    AppLanguage.en =>
      'A narrative RPG where AI guides the scene and the world remembers what you do.',
  };

  String get homePrimaryCta => switch (language) {
    AppLanguage.ru => 'Играть',
    AppLanguage.en => 'Play',
  };

  String get homeSecondaryCta => switch (language) {
    AppLanguage.ru => 'Продолжить',
    AppLanguage.en => 'Continue',
  };

  String get homeHowItWorksCta => switch (language) {
    AppLanguage.ru => 'Как это работает',
    AppLanguage.en => 'How it works',
  };

  String get homeContinueSavesCta => switch (language) {
    AppLanguage.ru => 'Открыть сохранения',
    AppLanguage.en => 'Open saves',
  };

  String get homeTeaserEyebrow => switch (language) {
    AppLanguage.ru => 'Нарративная и ролевая игра',
    AppLanguage.en => 'Narrative roleplaying experience',
  };

  String get homeTeaserLead => switch (language) {
    AppLanguage.ru => 'История отвечает на твой выбор',
    AppLanguage.en => 'The story answers your choice',
  };

  String get homeTeaserNarratorName => switch (language) {
    AppLanguage.ru => 'AI Master Avatar',
    AppLanguage.en => 'AI Master Avatar',
  };

  String get homeTeaserPrompt => switch (language) {
    AppLanguage.ru =>
      'Вы стоите на пороге древнего зала. За гранью тумана слышен шепот. Что сделаете?',
    AppLanguage.en =>
      'You stand at the threshold of an ancient hall. Beyond the mist, something whispers. What do you do?',
  };

  String get homeTeaserReply => switch (language) {
    AppLanguage.ru =>
      'Ваш выбор эхом расходится по залу: история уже подстраивает мир, опасности и союзников под следующий шаг.',
    AppLanguage.en =>
      'Your choice rolls through the hall: the story is already reshaping the world, its dangers, and its allies around your next move.',
  };

  String get homeTeaserInputHint => switch (language) {
    AppLanguage.ru => 'Напиши свой ответ...',
    AppLanguage.en => 'Write your answer...',
  };

  String get homeTeaserSendCta => switch (language) {
    AppLanguage.ru => 'Ответить',
    AppLanguage.en => 'Respond',
  };

  String get homeGalleryTitle => switch (language) {
    AppLanguage.ru => 'Исследуйте бесконечные миры',
    AppLanguage.en => 'Explore endless worlds',
  };

  String get homeGalleryDescription => switch (language) {
    AppLanguage.ru =>
      'Скролл раскрывает новые жанры и атмосферу: выберите вайб истории еще до первой сцены.',
    AppLanguage.en =>
      'Scroll deeper to uncover new genres and moods before your first scene even begins.',
  };

  String get homeWorldCyberNoirTitle => switch (language) {
    AppLanguage.ru => 'Кибер-нуар',
    AppLanguage.en => 'Cyber-noir',
  };

  String get homeWorldCyberNoirDescription => switch (language) {
    AppLanguage.ru =>
      'Дождливые мегаполисы, взломанные импланты и расследования, где каждая улика пахнет неоном и предательством.',
    AppLanguage.en =>
      'Rain-soaked megacities, compromised implants, and investigations where every clue smells like neon and betrayal.',
  };

  List<String> get homeWorldCyberNoirTags => switch (language) {
    AppLanguage.ru => const <String>['#CYBERPUNK', '#MYSTERY', '#AI'],
    AppLanguage.en => const <String>['#CYBERPUNK', '#MYSTERY', '#AI'],
  };

  String get homeWorldDarkFantasyTitle => switch (language) {
    AppLanguage.ru => 'Темное фэнтези',
    AppLanguage.en => 'Dark fantasy',
  };

  String get homeWorldDarkFantasyDescription => switch (language) {
    AppLanguage.ru =>
      'Проклятые замки, древняя магия и тяжелые решения, где цена силы чувствуется в каждом выборе героя.',
    AppLanguage.en =>
      'Cursed keeps, ancient magic, and hard decisions where the cost of power stains every choice your hero makes.',
  };

  List<String> get homeWorldDarkFantasyTags => switch (language) {
    AppLanguage.ru => const <String>['#FANTASY', '#RPG', '#CURSE'],
    AppLanguage.en => const <String>['#FANTASY', '#RPG', '#CURSE'],
  };

  String get homeWorldRomanceTitle => switch (language) {
    AppLanguage.ru => 'Романтический роман',
    AppLanguage.en => 'Romantic novel',
  };

  String get homeWorldRomanceDescription => switch (language) {
    AppLanguage.ru =>
      'Письма, тайные встречи и выбор между страстью, репутацией и судьбой в мире мягкого света и больших чувств.',
    AppLanguage.en =>
      'Letters, secret meetings, and choices between passion, reputation, and destiny in a world of soft light and dangerous feelings.',
  };

  List<String> get homeWorldRomanceTags => switch (language) {
    AppLanguage.ru => const <String>['#ROMANCE', '#DRAMA', '#CHOICE'],
    AppLanguage.en => const <String>['#ROMANCE', '#DRAMA', '#CHOICE'],
  };

  String get homeTechTitle => switch (language) {
    AppLanguage.ru => 'Как история оживает',
    AppLanguage.en => 'How the story comes alive',
  };

  String get homeTechDescription => switch (language) {
    AppLanguage.ru =>
      'Лендинг ведет к игре тем же языком, что и сама система: один рассказчик, память о решениях и быстрый вход в новую кампанию.',
    AppLanguage.en =>
      'The landing speaks the same language as the game itself: one narrator, persistent consequences, and a fast path into a new campaign.',
  };

  String get homeTechNarratorTitle => switch (language) {
    AppLanguage.ru => 'Живой рассказчик',
    AppLanguage.en => 'Living narrator',
  };

  String get homeTechNarratorDescription => switch (language) {
    AppLanguage.ru =>
      'ИИ ведет сцену как мастер игры: описывает обстановку, подбрасывает риск и подхватывает ваш стиль ответа.',
    AppLanguage.en =>
      'AI carries the scene like a game master: describing the room, escalating the tension, and matching your voice.',
  };

  String get homeTechMemoryTitle => switch (language) {
    AppLanguage.ru => 'Память о выборе',
    AppLanguage.en => 'Memory of choice',
  };

  String get homeTechMemoryDescription => switch (language) {
    AppLanguage.ru =>
      'Последствия не исчезают после одной реплики: союзники, улики, ресурсы и сюжетные модули меняются вместе с вами.',
    AppLanguage.en =>
      'Consequences do not vanish after one line: allies, clues, resources, and story modules shift along with you.',
  };

  String get homeTechStartTitle => switch (language) {
    AppLanguage.ru => 'Быстрый старт',
    AppLanguage.en => 'Fast start',
  };

  String get homeTechStartDescription => switch (language) {
    AppLanguage.ru =>
      'Выбираете сеттинг, задаете тон истории и сразу попадаете в игровой чат без лишних экранов и подготовки.',
    AppLanguage.en =>
      'Choose a setting, set the tone, and drop straight into the game chat without extra setup friction.',
  };

  String get homeFinalCtaTitle => switch (language) {
    AppLanguage.ru => 'Откройте первую сцену за минуту',
    AppLanguage.en => 'Open your first scene in a minute',
  };

  String get homeFinalCtaDescription => switch (language) {
    AppLanguage.ru =>
      'Запускайте новую историю, возвращайтесь в сохраненный мир и дайте рассказчику сразу ответить на ваш первый шаг.',
    AppLanguage.en =>
      'Launch a new story, return to a saved world, and let the narrator answer your very first move right away.',
  };

  String get youLabel => switch (language) {
    AppLanguage.ru => 'Вы',
    AppLanguage.en => 'You',
  };

  String get chatNarratorLabel => switch (language) {
    AppLanguage.ru => 'Рассказчик',
    AppLanguage.en => 'Narrator',
  };

  String get chatInputLabel => switch (language) {
    AppLanguage.ru => 'Ввод сообщения',
    AppLanguage.en => 'Message input',
  };

  String get chatSidebarToggle => switch (language) {
    AppLanguage.ru => 'Боковая панель',
    AppLanguage.en => 'Sidebar',
  };

  String get homeTertiaryCta => switch (language) {
    AppLanguage.ru => 'Настройки',
    AppLanguage.en => 'Settings',
  };

  String get homeNewGameTitle => switch (language) {
    AppLanguage.ru => 'Новая игра',
    AppLanguage.en => 'New Game',
  };

  String get appLoadingTitle => switch (language) {
    AppLanguage.ru => 'Приложение загружается, подождите',
    AppLanguage.en => 'The app is loading, please wait',
  };

  List<String> get appLoadingStages => switch (language) {
    AppLanguage.ru => const <String>[
      'Подготавливаем запуск',
      'Загружаем движок истории',
      'Запускаем приложение',
      'Готовим мир и настройки',
    ],
    AppLanguage.en => const <String>[
      'Preparing the launch',
      'Loading the story engine',
      'Starting the application',
      'Warming up your world and settings',
    ],
  };

  String get appLoadingEtaShort => switch (language) {
    AppLanguage.ru => 'Обычно это занимает несколько секунд',
    AppLanguage.en => 'This usually takes a few seconds',
  };

  String get appLoadingSlow => switch (language) {
    AppLanguage.ru =>
      'Запуск идет дольше обычного. Еще немного, мы почти на месте.',
    AppLanguage.en =>
      'Startup is taking a bit longer than usual. Hang on, we are almost there.',
  };

  String get appLoadingRetry => switch (language) {
    AppLanguage.ru => 'Не удалось запустить приложение. Попробуйте еще раз.',
    AppLanguage.en => 'The app could not start. Please try again.',
  };

  List<String> get appLoadingFlavorLines => switch (language) {
    AppLanguage.ru => const <String>[
      'Загружаем миры',
      'Собираем ИИ-модели',
      'Разворачиваем сюжетные узлы',
      'Настраиваем атмосферу приключения',
      'Полируем первый ход героя',
    ],
    AppLanguage.en => const <String>[
      'Loading new worlds',
      'Assembling the AI models',
      'Threading story branches together',
      'Tuning the mood of the adventure',
      'Polishing your first move',
    ],
  };

  String get newCampaign => switch (language) {
    AppLanguage.ru => 'Новая кампания',
    AppLanguage.en => 'New Campaign',
  };

  String get worldCreationTitle => switch (language) {
    AppLanguage.ru => 'Создание мира',
    AppLanguage.en => 'World creation',
  };

  String get chooseGenreWizardTitle => switch (language) {
    AppLanguage.ru => 'Выберите жанр',
    AppLanguage.en => 'Choose a genre',
  };

  String get chooseSettingWizardTitle => switch (language) {
    AppLanguage.ru => 'Выберите сеттинг',
    AppLanguage.en => 'Choose a setting',
  };

  String get saves => switch (language) {
    AppLanguage.ru => 'Сохранения',
    AppLanguage.en => 'Saves',
  };

  String get aiSettings => switch (language) {
    AppLanguage.ru => 'Настройки',
    AppLanguage.en => 'Settings',
  };

  String get whatsIncluded => switch (language) {
    AppLanguage.ru => 'Что уже есть',
    AppLanguage.en => 'What Is Included',
  };

  List<String> get homeFeatureLines => switch (language) {
    AppLanguage.ru => const <String>[
      'Живой рассказчик',
      'Выбор с последствиями',
      'Миры на грани жанров',
    ],
    AppLanguage.en => const <String>[
      'Living narrator',
      'Choices that leave a mark',
      'Worlds beyond a single genre',
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
    AppLanguage.ru =>
      '\u041e\u043f\u0438\u0448\u0438 \u0437\u0430\u0432\u044f\u0437\u043a\u0443 \u0438\u043b\u0438 \u0436\u0435\u043b\u0430\u0435\u043c\u0443\u044e \u0438\u0441\u0442\u043e\u0440\u0438\u044e',
    AppLanguage.en => 'Describe the story you want to play',
  };

  String get storyWishHint => switch (language) {
    AppLanguage.ru =>
      '\u041d\u0430\u043f\u0440\u0438\u043c\u0435\u0440: \u043c\u0440\u0430\u0447\u043d\u044b\u0439 \u0434\u0435\u0442\u0435\u043a\u0442\u0438\u0432 \u0443 \u043c\u043e\u0440\u044f, \u043f\u043e\u0445\u043e\u0434 \u0447\u0435\u0440\u0435\u0437 \u043f\u0440\u043e\u043a\u043b\u044f\u0442\u044b\u0439 \u043b\u0435\u0441 \u0438\u043b\u0438 \u043f\u0435\u0440\u0432\u044b\u0439 \u043a\u043e\u043d\u0442\u0430\u043a\u0442 \u0441 \u0447\u0443\u0436\u043e\u0439 \u0446\u0438\u0432\u0438\u043b\u0438\u0437\u0430\u0446\u0438\u0435\u0439...',
    AppLanguage.en =>
      'For example: a grim harbor mystery, a cursed forest expedition, or first contact with an alien civilization...',
  };

  String get generatePrompts => switch (language) {
    AppLanguage.ru =>
      '\u0421\u0433\u0435\u043d\u0435\u0440\u0438\u0440\u043e\u0432\u0430\u0442\u044c \u043f\u0440\u043e\u043c\u043f\u0442',
    AppLanguage.en => 'Generate prompt',
  };

  String get generatingPrompts => switch (language) {
    AppLanguage.ru =>
      '\u0413\u0435\u043d\u0435\u0440\u0430\u0446\u0438\u044f...',
    AppLanguage.en => 'Generating...',
  };

  String get customStoryPromptTitle => switch (language) {
    AppLanguage.ru =>
      '\u041f\u0440\u043e\u043c\u043f\u0442 \u0438\u0441\u0442\u043e\u0440\u0438\u0438',
    AppLanguage.en => 'Story prompt',
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
        (AppLanguage.ru, CharacterClass.unspecified) => 'Без класса',
        (AppLanguage.en, CharacterClass.warrior) => 'Warrior',
        (AppLanguage.en, CharacterClass.mage) => 'Mage',
        (AppLanguage.en, CharacterClass.rogue) => 'Rogue',
        (AppLanguage.en, CharacterClass.detective) => 'Detective',
        (AppLanguage.en, CharacterClass.journalist) => 'Journalist',
        (AppLanguage.en, CharacterClass.smuggler) => 'Smuggler',
        (AppLanguage.en, CharacterClass.engineer) => 'Engineer',
        (AppLanguage.en, CharacterClass.pilot) => 'Pilot',
        (AppLanguage.en, CharacterClass.medic) => 'Medic',
        (AppLanguage.en, CharacterClass.unspecified) => 'No class',
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

  String settingLabel(final CampaignSetting value) => switch ((
    language,
    value,
  )) {
    (AppLanguage.ru, CampaignSetting.romantasy) => 'Романтическое фэнтези',
    (AppLanguage.ru, CampaignSetting.cozyFantasy) => 'Уютное фэнтези',
    (AppLanguage.ru, CampaignSetting.darkAcademia) => 'Тёмная академия',
    (AppLanguage.ru, CampaignSetting.postApocalypse) => 'Постапокалипсис',
    (AppLanguage.ru, CampaignSetting.litRpgProgression) => 'ЛитРПГ',
    (AppLanguage.ru, CampaignSetting.grimdarkFantasy) => 'Гримдарк',
    (AppLanguage.ru, CampaignSetting.nearFutureSciFi) => 'НФ близкого будущего',
    (AppLanguage.ru, CampaignSetting.horrorWeird) => 'Хоррор',
    (AppLanguage.ru, CampaignSetting.cozyCrime) => 'Уютный детектив',
    (AppLanguage.ru, CampaignSetting.altHistorySecret) => 'Альт-история',
    (AppLanguage.en, CampaignSetting.romantasy) => 'Romantasy',
    (AppLanguage.en, CampaignSetting.cozyFantasy) => 'Cozy fantasy',
    (AppLanguage.en, CampaignSetting.darkAcademia) => 'Dark academia',
    (AppLanguage.en, CampaignSetting.postApocalypse) => 'Post-apocalypse',
    (AppLanguage.en, CampaignSetting.litRpgProgression) => 'LitRPG',
    (AppLanguage.en, CampaignSetting.grimdarkFantasy) => 'Grimdark',
    (AppLanguage.en, CampaignSetting.nearFutureSciFi) => 'Near-future SF',
    (AppLanguage.en, CampaignSetting.horrorWeird) => 'Horror',
    (AppLanguage.en, CampaignSetting.cozyCrime) => 'Cozy crime',
    (AppLanguage.en, CampaignSetting.altHistorySecret) => 'Alt history',
  };

  String get literaryGenreTitle => switch (language) {
    AppLanguage.ru => 'Литературный жанр',
    AppLanguage.en => 'Literary genre',
  };

  String literaryGenreLabel(final LiteraryGenre value) => switch ((
    language,
    value,
  )) {
    (AppLanguage.ru, LiteraryGenre.romance) => 'Романтика',
    (AppLanguage.ru, LiteraryGenre.romantasyGenre) => 'Романтическое фэнтези',
    (AppLanguage.ru, LiteraryGenre.fantasyGenre) => 'Фэнтези',
    (AppLanguage.ru, LiteraryGenre.psychologicalThriller) => 'Триллер',
    (AppLanguage.ru, LiteraryGenre.mysteryCrime) => 'Детектив',
    (AppLanguage.ru, LiteraryGenre.horrorGenre) => 'Хоррор',
    (AppLanguage.ru, LiteraryGenre.youngAdult) => 'Подростковая литература',
    (AppLanguage.ru, LiteraryGenre.speculativeFiction) => 'Научная фантастика',
    (AppLanguage.ru, LiteraryGenre.darkAcademiaGenre) => 'Тёмная академия',
    (AppLanguage.ru, LiteraryGenre.cozyFeelGood) => 'Уютное',
    (AppLanguage.en, LiteraryGenre.romance) => 'Romance',
    (AppLanguage.en, LiteraryGenre.romantasyGenre) => 'Romantasy',
    (AppLanguage.en, LiteraryGenre.fantasyGenre) => 'Fantasy',
    (AppLanguage.en, LiteraryGenre.psychologicalThriller) =>
      'Psychological thriller',
    (AppLanguage.en, LiteraryGenre.mysteryCrime) => 'Mystery / crime',
    (AppLanguage.en, LiteraryGenre.horrorGenre) => 'Horror',
    (AppLanguage.en, LiteraryGenre.youngAdult) => 'Young Adult',
    (AppLanguage.en, LiteraryGenre.speculativeFiction) => 'Speculative fiction',
    (AppLanguage.en, LiteraryGenre.darkAcademiaGenre) => 'Dark academia',
    (AppLanguage.en, LiteraryGenre.cozyFeelGood) => 'Cozy / feel-good',
  };

  String settingDescription(CampaignSetting value) => switch ((language, value)) {
    (AppLanguage.ru, CampaignSetting.romantasy) =>
      'Романтика и магия переплетаются в мире, где любовь движет сюжетом, а судьба '
      'героев решается в тени древних пророчеств. Идеально для историй о запретной '
      'любви, политических браках и магических клятвах.',
    (AppLanguage.ru, CampaignSetting.cozyFantasy) =>
      'Тёплый, уютный мир без эпических угроз. Магия здесь — часть повседневности: '
      'зелья варят на кухне, а главные испытания — наладить быт и помочь соседям. '
      'Никакого конца света, только маленькие радости.',
    (AppLanguage.ru, CampaignSetting.darkAcademia) =>
      'Мир тайных библиотек, древних манускриптов и интеллектуальных заговоров. '
      'Знание — власть, и студенты академии готовы на всё ради forbidden knowledge. '
      'Атмосфера готических университетов и опасных открытий.',
    (AppLanguage.ru, CampaignSetting.postApocalypse) =>
      'Мир после катастрофы: руины цивилизации, борьба за ресурсы, мутанты и '
      'выжившие. Каждый день — испытание. В центре сюжета: что остаётся человеческого, '
      'когда всё рухнуло.',
    (AppLanguage.ru, CampaignSetting.litRpgProgression) =>
      'Мир, работающий по законам RPG: уровни, характеристики, интерфейс системы. '
      'Герой видит цифры своего прогресса и осознанно прокачивается. Для любителей '
      'жанра LitRPG и progression fantasy.',
    (AppLanguage.ru, CampaignSetting.grimdarkFantasy) =>
      'Мрачное фэнтези без компромиссов. Мир жесток, мораль сера, герои умирают. '
      'Никаких «добро побеждает» — только выживание, предательство и тяжёлые выборы. '
      'В духе Dark Souls и книг Аберкромби.',
    (AppLanguage.ru, CampaignSetting.nearFutureSciFi) =>
      'Близкое будущее: 2080-2150 годы. Кибернетика, корпорации-государства, '
      'колонизация солнечной системы. Технологии узнаваемы, но изменены. Фокус на '
      'социальных и этических последствиях прогресса.',
    (AppLanguage.ru, CampaignSetting.horrorWeird) =>
      'Хоррор и сверхъестественное: от лавкрафтианского ужаса до психологического '
      'триллера. Реальность ненадёжна, рассудок под угрозой, а древние силы '
      'безразличны к человеку.',
    (AppLanguage.ru, CampaignSetting.cozyCrime) =>
      'Детектив в уютном антураже: маленький городок, очаровательные персонажи, '
      'преступление которое раскрывается через разговоры и наблюдение а не насилие. '
      'В духе Агаты Кристи и современных cozy mystery.',
    (AppLanguage.ru, CampaignSetting.altHistorySecret) =>
      'Альтернативная история с элементами тайного общества или заговора. Мир похож '
      'на наш, но ключевое историческое событие пошло иначе. Герой раскрывает '
      'скрытую правду о том, как устроен мир.',
    // English descriptions
    (AppLanguage.en, CampaignSetting.romantasy) =>
      'Romance and magic intertwine in a world where love drives the plot and '
      'destinies are decided beneath ancient prophecies. Perfect for forbidden '
      'love, political marriages, and magical vows.',
    (AppLanguage.en, CampaignSetting.cozyFantasy) =>
      'A warm, gentle world without epic threats. Magic is part of everyday life: '
      'potions brewed in the kitchen, quests about helping neighbors. No end of '
      'the world — just small joys.',
    (AppLanguage.en, CampaignSetting.darkAcademia) =>
      'A world of hidden libraries, ancient manuscripts, and intellectual conspiracy. '
      'Knowledge is power, and academy students will do anything for forbidden texts. '
      'Gothic university atmosphere and dangerous discoveries.',
    (AppLanguage.en, CampaignSetting.postApocalypse) =>
      'A world after collapse: ruins of civilization, resource wars, mutants and '
      'survivors. Every day is a trial. At the center: what remains human when '
      'everything falls apart.',
    (AppLanguage.en, CampaignSetting.litRpgProgression) =>
      'A world that runs on RPG rules: levels, stats, system interface. The hero '
      'sees the numbers and consciously progresses. For fans of LitRPG and '
      'progression fantasy.',
    (AppLanguage.en, CampaignSetting.grimdarkFantasy) =>
      'Dark fantasy without compromise. The world is cruel, morality is gray, '
      'heroes die. No "good prevails" — only survival, betrayal, and hard choices. '
      'In the spirit of Dark Souls and Abercrombie.',
    (AppLanguage.en, CampaignSetting.nearFutureSciFi) =>
      'Near future: 2080-2150. Cybernetics, corporate-states, solar system '
      'colonization. Technology is recognizable but transformed. Focus on social '
      'and ethical consequences of progress.',
    (AppLanguage.en, CampaignSetting.horrorWeird) =>
      'Horror and the supernatural: from Lovecraftian dread to psychological '
      'thriller. Reality is unreliable, sanity is threatened, and ancient forces '
      'are indifferent to humanity.',
    (AppLanguage.en, CampaignSetting.cozyCrime) =>
      'A mystery in a cozy setting: small town, charming characters, a crime '
      'solved through conversation and observation rather than violence. '
      'In the spirit of Agatha Christie and modern cozy mysteries.',
    (AppLanguage.en, CampaignSetting.altHistorySecret) =>
      'Alternate history with secret society or conspiracy elements. The world '
      'looks like ours, but a key historical event went differently. The hero '
      'uncovers hidden truths about how the world really works.',
  };

  String literaryGenreDescription(LiteraryGenre value) => switch ((language, value)) {
    (AppLanguage.ru, LiteraryGenre.romance) =>
      'В центре сюжета — отношения между персонажами. Эмоциональная близость, '
      'конфликты, притяжение и выбор между долгом и чувством.',
    (AppLanguage.ru, LiteraryGenre.romantasyGenre) =>
      'Гибрид романтики и фэнтези: магический мир, где любовная линия так же '
      'важна как эпический сюжет. В духе книг Сары Маас и Ребекки Яррос.',
    (AppLanguage.ru, LiteraryGenre.fantasyGenre) =>
      'Классическое фэнтези: магия, другие миры, героическое приключение. '
      'От высокой эпики до городского фэнтези.',
    (AppLanguage.ru, LiteraryGenre.psychologicalThriller) =>
      'Напряжённая история с фокусом на внутреннем мире героя. Манипуляции, '
      'ненадёжный рассказчик, игра с восприятием реальности.',
    (AppLanguage.ru, LiteraryGenre.mysteryCrime) =>
      'Детектив или криминальная драма: расследование, улики, неожиданные '
      'повороты. Герой распутывает клубок тайн.',
    (AppLanguage.ru, LiteraryGenre.horrorGenre) =>
      'История, цель которой — вызвать страх и напряжение. Сверхъестественное, '
      'неизвестное, угроза рассудку или жизни.',
    (AppLanguage.ru, LiteraryGenre.youngAdult) =>
      'История взросления: молодой герой сталкивается с вызовами, находит себя '
      'и своё место в мире. Эмоционально интенсивно, темп быстрый.',
    (AppLanguage.ru, LiteraryGenre.speculativeFiction) =>
      'Научная фантастика и спекулятивная проза: что будет если технология X '
      'изменит общество? Исследование идей через историю.',
    (AppLanguage.ru, LiteraryGenre.darkAcademiaGenre) =>
      'Эстетика академической среды с тёмным оттенком: тайные общества, '
      'запретные знания, соперничество студентов и профессоров.',
    (AppLanguage.ru, LiteraryGenre.cozyFeelGood) =>
      'Уютная история с низкими ставками. Персонажи и их маленький мир — '
      'главная ценность. Читатель/игрок чувствует тепло и безопасность.',
    // English descriptions
    (AppLanguage.en, LiteraryGenre.romance) =>
      'Relationships are at the heart of the story: emotional intimacy, '
      'conflicts, attraction, and the choice between duty and feeling.',
    (AppLanguage.en, LiteraryGenre.romantasyGenre) =>
      'A romance-fantasy hybrid: a magical world where the love story matters '
      'as much as the epic plot. In the spirit of Sarah J. Maas and Rebecca Yarros.',
    (AppLanguage.en, LiteraryGenre.fantasyGenre) =>
      'Classic fantasy: magic, other worlds, heroic adventure. From high epic '
      'to urban fantasy.',
    (AppLanguage.en, LiteraryGenre.psychologicalThriller) =>
      'A tense story focused on the inner world of the protagonist. Manipulation, '
      'unreliable narrator, playing with perception of reality.',
    (AppLanguage.en, LiteraryGenre.mysteryCrime) =>
      'Detective or crime drama: investigation, clues, unexpected twists. The '
      'hero unravels a web of secrets.',
    (AppLanguage.en, LiteraryGenre.horrorGenre) =>
      'A story designed to evoke fear and tension. The supernatural, the unknown, '
      'a threat to sanity or life.',
    (AppLanguage.en, LiteraryGenre.youngAdult) =>
      'A coming-of-age story: a young hero faces challenges, finds themselves '
      'and their place in the world. Emotionally intense, fast-paced.',
    (AppLanguage.en, LiteraryGenre.speculativeFiction) =>
      'Science fiction and speculative fiction: what if technology X changed '
      'society? Exploring ideas through story.',
    (AppLanguage.en, LiteraryGenre.darkAcademiaGenre) =>
      'Academic aesthetic with a dark edge: secret societies, forbidden knowledge, '
      'rivalry among students and professors.',
    (AppLanguage.en, LiteraryGenre.cozyFeelGood) =>
      'A cozy, low-stakes story. Characters and their small world matter most. '
      'The reader/player feels warmth and safety.',
  };

  String get randomGenreButton => switch (language) {
    AppLanguage.ru => 'Случайный жанр',
    AppLanguage.en => 'Random genre',
  };

  String get randomSettingButton => switch (language) {
    AppLanguage.ru => 'Случайный сеттинг',
    AppLanguage.en => 'Random setting',
  };

  String get quickStartAiBlurb => switch (language) {
    AppLanguage.ru =>
      'ИИ подберёт случайный сеттинг и жанр и сгенерирует старт истории. Можно использовать локальные настройки AI или серверный ключ.',
    AppLanguage.en =>
      'AI picks a random setting and genre and writes your opening. You can use local AI settings or a server-side key.',
  };

  String get promptGenerationFailed => switch (language) {
    AppLanguage.ru =>
      'Не удалось сгенерировать начало истории. Проверьте AI и попробуйте снова.',
    AppLanguage.en =>
      'Could not generate the story start. Check AI settings and try again.',
  };

  String get promptGenerationFailedWeb => switch (language) {
    AppLanguage.ru =>
      'Не удалось получить ответ от нейросети через сервер игры. Обычно причина в одном из трёх: вы не вошли в аккаунт, сервер игры недоступен или неверно указаны URL / модель / API-ключ.',
    AppLanguage.en =>
      'Could not reach the model through the game server. Usually this means one of three things: you are not signed in, the game server is unavailable, or the URL / model / API key is wrong.',
  };

  String get settingsWebAiCorsHint => switch (language) {
    AppLanguage.ru =>
      'Теперь в веб-версии приложение обращается к нейросети через сервер игры, а не напрямую из браузера. Здесь нужно указать данные вашей модели, а для проверки и генерации сначала войти в аккаунт.',
    AppLanguage.en =>
      'In the web version the app now talks to the model through the game server instead of directly from the browser. Enter your model settings here, and sign in before testing or generating.',
  };

  String get quickStartNeedsAi => switch (language) {
    AppLanguage.ru =>
      'Настройте AI в параметрах, чтобы использовать быстрый старт.',
    AppLanguage.en => 'Configure AI in settings to use quick start.',
  };

  String get storyPromptHelp => switch (language) {
    AppLanguage.ru =>
      'Инструкция для рассказчика: тон, конфликт, что важно в мире. Можно править после генерации ИИ.',
    AppLanguage.en =>
      'Instructions for the narrator: tone, conflict, what matters. You can edit after AI generation.',
  };

  String get characterPromptHelp => switch (language) {
    AppLanguage.ru =>
      'Кратко кто герой для модели: роль, мотивация, границы характера.',
    AppLanguage.en =>
      'Short protagonist briefing for the model: role, drive, boundaries.',
  };

  String get storyPromptRequired => switch (language) {
    AppLanguage.ru =>
      'Введите или сгенерируйте промпт истории перед созданием.',
    AppLanguage.en => 'Enter or generate a story prompt before creating.',
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

  String get storyLibraryTitle => switch (language) {
    AppLanguage.ru => 'Библиотека миров',
    AppLanguage.en => 'World library',
  };

  String get storyLibraryTabMaster => switch (language) {
    AppLanguage.ru => 'Миры от мастера',
    AppLanguage.en => 'Master worlds',
  };

  String get storyLibraryTabCommunity => switch (language) {
    AppLanguage.ru => 'Миры пользователей',
    AppLanguage.en => 'Community worlds',
  };

  String get storyLibrarySearchHint => switch (language) {
    AppLanguage.ru => 'Поиск историй…',
    AppLanguage.en => 'Search stories…',
  };

  String get storyLibraryCreateYourStory => switch (language) {
    AppLanguage.ru => 'Создай свою историю',
    AppLanguage.en => 'Create your story',
  };

  String get storyLibraryGenresFilter => switch (language) {
    AppLanguage.ru => 'Жанры',
    AppLanguage.en => 'Genres',
  };

  String get storyLibraryAllGenres => switch (language) {
    AppLanguage.ru => 'Все жанры',
    AppLanguage.en => 'All genres',
  };

  String get storyLibraryLoadFailed => switch (language) {
    AppLanguage.ru => 'Не удалось загрузить библиотеку.',
    AppLanguage.en => 'Failed to load the library.',
  };

  String get storyLibraryEmptyCatalog => switch (language) {
    AppLanguage.ru => 'Пока нет опубликованных историй в этом разделе.',
    AppLanguage.en => 'No published stories in this section yet.',
  };

  String get storyLibraryEmptyCatalogSubtitle => switch (language) {
    AppLanguage.ru => 'Здесь появятся доступные сюжеты для новых кампаний',
    AppLanguage.en => 'Available story templates for new campaigns will appear here',
  };

  String get storyLibraryNoSearchResults => switch (language) {
    AppLanguage.ru => 'Ничего не найдено.',
    AppLanguage.en => 'No results found.',
  };

  String storyTemplateAuthorLine(final String name) => switch (language) {
    AppLanguage.ru => 'Автор: $name',
    AppLanguage.en => 'Author: $name',
  };

  String get storyTemplateStartCampaign => switch (language) {
    AppLanguage.ru => 'Начать кампанию',
    AppLanguage.en => 'Start campaign',
  };

  String get storyTemplateLengthTitle => switch (language) {
    AppLanguage.ru => 'Какой формат запустить?',
    AppLanguage.en => 'Which format do you want?',
  };

  String get storyTemplateSelectedLabel => switch (language) {
    AppLanguage.ru => 'Выбранная история',
    AppLanguage.en => 'Selected story',
  };

  String get storyTemplateSelectedFallbackTitle => switch (language) {
    AppLanguage.ru => 'История из библиотеки',
    AppLanguage.en => 'Story from the library',
  };

  String get storyTemplateShortStoryDesc => switch (language) {
    AppLanguage.ru =>
      'Быстрый старт: выберите имя и пол героя, затем сразу начните сцену.',
    AppLanguage.en =>
      'Quick start: choose hero name and gender, then jump into the scene.',
  };

  String get storyTemplateLongCampaignDesc => switch (language) {
    AppLanguage.ru =>
      'Пошаговая настройка: персонаж, промпт истории и финальная проверка.',
    AppLanguage.en =>
      'Step-by-step setup: character, story prompt, and final review.',
  };

  String get storyTemplateLike => switch (language) {
    AppLanguage.ru => 'Нравится',
    AppLanguage.en => 'Like',
  };

  String get storyTemplateShare => switch (language) {
    AppLanguage.ru => 'Поделиться',
    AppLanguage.en => 'Share',
  };

  String get storyTemplateNarrativeEyebrow => switch (language) {
    AppLanguage.ru => 'НАРРАТИВНАЯ RPG',
    AppLanguage.en => 'NARRATIVE RPG',
  };

  String get storyTemplateViewsLabel => switch (language) {
    AppLanguage.ru => 'Просмотры',
    AppLanguage.en => 'Views',
  };

  String get storyTemplateLikesLabel => switch (language) {
    AppLanguage.ru => 'Лайки',
    AppLanguage.en => 'Likes',
  };

  String get storyTemplatePlaysLabel => switch (language) {
    AppLanguage.ru => 'Прохождения',
    AppLanguage.en => 'Plays',
  };

  String get homeStoryLibraryTitle => switch (language) {
    AppLanguage.ru => 'Библиотека миров',
    AppLanguage.en => 'World library',
  };

  String get homeStoryLibrarySubtitle => switch (language) {
    AppLanguage.ru => 'Готовые истории и миры от мастера и сообщества',
    AppLanguage.en =>
      'Ready-made stories and worlds from masters and the community',
  };

  String get storyTemplateShareCopied => switch (language) {
    AppLanguage.ru => 'Описание скопировано в буфер обмена.',
    AppLanguage.en => 'Description copied to clipboard.',
  };

  String get storyAdminTitle => switch (language) {
    AppLanguage.ru => 'Управление библиотекой историй',
    AppLanguage.en => 'Story library admin',
  };

  String get storyAdminMenuSubtitle => switch (language) {
    AppLanguage.ru => 'Создание и редактирование карточек (только админ)',
    AppLanguage.en => 'Create and edit story cards (admin only)',
  };

  String get storyAdminCreate => switch (language) {
    AppLanguage.ru => 'Новая карточка',
    AppLanguage.en => 'New card',
  };

  String get storyAdminEdit => switch (language) {
    AppLanguage.ru => 'Редактировать',
    AppLanguage.en => 'Edit',
  };

  String get storyAdminDelete => switch (language) {
    AppLanguage.ru => 'Удалить',
    AppLanguage.en => 'Delete',
  };

  String get storyAdminDeleteConfirm => switch (language) {
    AppLanguage.ru => 'Удалить эту карточку?',
    AppLanguage.en => 'Delete this story card?',
  };

  String get storyAdminDeleted => switch (language) {
    AppLanguage.ru => 'Карточка удалена.',
    AppLanguage.en => 'Story card deleted.',
  };

  String get storyAdminSave => switch (language) {
    AppLanguage.ru => 'Сохранить',
    AppLanguage.en => 'Save',
  };

  String get storyAdminFieldPrompt => switch (language) {
    AppLanguage.ru => 'Промпт для ИИ (сюжет)',
    AppLanguage.en => 'AI story prompt',
  };

  String get storyAdminFieldCampaignTitle => switch (language) {
    AppLanguage.ru => 'Название кампании',
    AppLanguage.en => 'Campaign title',
  };

  String get storyAdminFieldObjectiveHint => switch (language) {
    AppLanguage.ru => 'Начальная цель',
    AppLanguage.en => 'Starting objective',
  };

  String get storyAdminFieldCharacterPrompt => switch (language) {
    AppLanguage.ru => 'Промпт персонажа',
    AppLanguage.en => 'Character prompt',
  };

  String get storyAdminFieldCharacterName => switch (language) {
    AppLanguage.ru => 'Имя персонажа',
    AppLanguage.en => 'Character name',
  };

  String get storyAdminFieldCharacterGender => switch (language) {
    AppLanguage.ru => 'Пол персонажа',
    AppLanguage.en => 'Character gender',
  };

  String get storyAdminFieldCharacterRace => switch (language) {
    AppLanguage.ru => 'Раса / происхождение',
    AppLanguage.en => 'Race / origin',
  };

  String get storyAdminFieldCharacterClass => switch (language) {
    AppLanguage.ru => 'Класс персонажа',
    AppLanguage.en => 'Character class',
  };

  String get storyAdminFieldCharacterPersonality => switch (language) {
    AppLanguage.ru => 'Характер персонажа',
    AppLanguage.en => 'Character personality',
  };

  String get storyAdminFieldCharacterSkills => switch (language) {
    AppLanguage.ru => 'Навыки через запятую',
    AppLanguage.en => 'Skills, comma-separated',
  };

  String get storyAdminFieldCharacterPerks => switch (language) {
    AppLanguage.ru => 'Особенности через запятую',
    AppLanguage.en => 'Perks, comma-separated',
  };

  String get storyAdminOptionalNone => switch (language) {
    AppLanguage.ru => 'Не указывать',
    AppLanguage.en => 'Do not set',
  };

  String get storyAdminImportFile => switch (language) {
    AppLanguage.ru => 'Загрузить JSON',
    AppLanguage.en => 'Upload JSON',
  };

  String get storyAdminImportPaste => switch (language) {
    AppLanguage.ru => 'Вставить JSON',
    AppLanguage.en => 'Paste JSON',
  };

  String get storyAdminImportPasteTitle => switch (language) {
    AppLanguage.ru => 'Импорт структуры кампании',
    AppLanguage.en => 'Import campaign structure',
  };

  String get storyAdminImportPasteHint => switch (language) {
    AppLanguage.ru => '{"story_prompt": "..."}',
    AppLanguage.en => '{"story_prompt": "..."}',
  };

  String get storyAdminImportApply => switch (language) {
    AppLanguage.ru => 'Заполнить',
    AppLanguage.en => 'Apply',
  };

  String get storyAdminImportOverwriteTitle => switch (language) {
    AppLanguage.ru => 'Заполнить поля из JSON?',
    AppLanguage.en => 'Fill fields from JSON?',
  };

  String get storyAdminImportOverwriteBody => switch (language) {
    AppLanguage.ru =>
      'В форме уже есть данные. Импорт заменит совпадающие заполненные поля.',
    AppLanguage.en =>
      'The form already has data. Import will replace matching filled fields.',
  };

  String get storyAdminImportInvalidJson => switch (language) {
    AppLanguage.ru => 'Некорректный JSON для импорта.',
    AppLanguage.en => 'Invalid import JSON.',
  };

  String get storyAdminImportApplied => switch (language) {
    AppLanguage.ru => 'Поля заполнены из JSON.',
    AppLanguage.en => 'Fields filled from JSON.',
  };

  String get storyAdminFieldSetting => switch (language) {
    AppLanguage.ru => 'Сеттинг (код, напр. grimdarkFantasy)',
    AppLanguage.en => 'Setting code (e.g. grimdarkFantasy)',
  };

  String get storyAdminFieldTags => switch (language) {
    AppLanguage.ru => 'Теги через запятую',
    AppLanguage.en => 'Tags, comma-separated',
  };

  String get storyAdminFieldCoverUrl => switch (language) {
    AppLanguage.ru => 'URL обложки',
    AppLanguage.en => 'Cover image URL',
  };

  String get storyAdminCoverChooseFile => switch (language) {
    AppLanguage.ru => 'Выбрать файл обложки',
    AppLanguage.en => 'Choose cover image file',
  };

  String get storyAdminCoverRemove => switch (language) {
    AppLanguage.ru => 'Убрать обложку',
    AppLanguage.en => 'Remove cover',
  };

  String get storyAdminCoverTooLarge => switch (language) {
    AppLanguage.ru => 'Файл слишком большой (макс. 6 МБ).',
    AppLanguage.en => 'File is too large (max 6 MB).',
  };

  String get storyAdminCoverReadFailed => switch (language) {
    AppLanguage.ru => 'Не удалось прочитать файл обложки.',
    AppLanguage.en => 'Could not read the cover image file.',
  };

  String get storyAdminFieldLiteraryGenre => switch (language) {
    AppLanguage.ru => 'Литературный жанр',
    AppLanguage.en => 'Literary genre',
  };

  String get storyAdminLiteraryGenreNone => switch (language) {
    AppLanguage.ru => 'Не указан',
    AppLanguage.en => 'Not set',
  };

  String get storyAdminPublic => switch (language) {
    AppLanguage.ru => 'Публичная',
    AppLanguage.en => 'Public',
  };

  String get storyAdminPrivate => switch (language) {
    AppLanguage.ru => 'Не в каталоге',
    AppLanguage.en => 'Not listed',
  };

  String get storyAdminMasterCurated => switch (language) {
    AppLanguage.ru => 'Каталог мастера',
    AppLanguage.en => 'Master catalog',
  };

  String get storyAdminAccessDenied => switch (language) {
    AppLanguage.ru => 'Нужны права администратора.',
    AppLanguage.en => 'Administrator access required.',
  };

  String get storyAdminFieldTitle => switch (language) {
    AppLanguage.ru => 'Заголовок',
    AppLanguage.en => 'Title',
  };

  String get storyAdminFieldSummary => switch (language) {
    AppLanguage.ru => 'Краткое описание',
    AppLanguage.en => 'Summary',
  };

  String get storyAdminMetadataJson => switch (language) {
    AppLanguage.ru => 'Метаданные (JSON)',
    AppLanguage.en => 'Metadata (JSON)',
  };

  String get storyAdminInvalidMetadata => switch (language) {
    AppLanguage.ru => 'Некорректный JSON в метаданных.',
    AppLanguage.en => 'Invalid metadata JSON.',
  };

  String get storyAdminSaved => switch (language) {
    AppLanguage.ru => 'Карточка сохранена.',
    AppLanguage.en => 'Story card saved.',
  };

  String get storyAdminFillTitlePrompt => switch (language) {
    AppLanguage.ru => 'Укажите заголовок и промпт для ИИ.',
    AppLanguage.en => 'Enter a title and AI story prompt.',
  };

  String get storyAdminFillPrompt => switch (language) {
    AppLanguage.ru => 'Укажите промпт для ИИ.',
    AppLanguage.en => 'Enter an AI story prompt.',
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

  String get savesShareToLibraryTooltip => switch (language) {
    AppLanguage.ru => 'Опубликовать мир в библиотеке (пользовательские миры)',
    AppLanguage.en => 'Publish world to the community library',
  };

  String get savesShareToLibrarySuccess => switch (language) {
    AppLanguage.ru => 'Мир отправлен в библиотеку.',
    AppLanguage.en => 'World published to the library.',
  };

  String get savesShareRequiresAccount => switch (language) {
    AppLanguage.ru => 'Войдите в аккаунт, чтобы опубликовать мир в библиотеке.',
    AppLanguage.en => 'Sign in to publish a world to the library.',
  };

  String get savesShareMissingPrompt => switch (language) {
    AppLanguage.ru => 'В этой кампании нет текста промпта для публикации.',
    AppLanguage.en => 'This campaign has no story prompt to publish.',
  };

  String get savesPublishToLibrary => switch (language) {
    AppLanguage.ru => 'В библиотеку',
    AppLanguage.en => 'Publish',
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

  String get settingsTooltip => switch (language) {
    AppLanguage.ru => 'Настройки',
    AppLanguage.en => 'Settings',
  };

  String get mapTooltip => switch (language) {
    AppLanguage.ru => 'Карта мира',
    AppLanguage.en => 'World map',
  };

  String get menuTooltip => switch (language) {
    AppLanguage.ru => 'Меню',
    AppLanguage.en => 'Menu',
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

  String get activeSystemsTitle => switch (language) {
    AppLanguage.ru => 'Активные системы',
    AppLanguage.en => 'Active Systems',
  };

  String get portraitPlaceholderLabel => switch (language) {
    AppLanguage.ru => 'Портрет героя',
    AppLanguage.en => 'Hero portrait',
  };

  String get portraitAiHint => switch (language) {
    AppLanguage.ru => 'В будущем здесь появится сгенерированный ИИ-портрет.',
    AppLanguage.en =>
      'An AI-generated portrait will appear here in a future update.',
  };

  String get portraitAiReadyHint => switch (language) {
    AppLanguage.ru => 'Портрет сгенерирован на основе истории и персонажа.',
    AppLanguage.en => 'Portrait generated from the story and character.',
  };

  String get portraitAutoGenerateHint => switch (language) {
    AppLanguage.ru => 'Автоматическая генерация портрета временно отключена.',
    AppLanguage.en => 'Automatic portrait generation is currently disabled.',
  };

  String campaignModuleLabel(final CampaignModule value) =>
      switch ((language, value)) {
        (AppLanguage.ru, CampaignModule.inventory) => 'Инвентарь',
        (AppLanguage.ru, CampaignModule.companions) => 'Спутники',
        (AppLanguage.ru, CampaignModule.notes) => 'Заметки',
        (AppLanguage.ru, CampaignModule.vitality) => 'Живучесть',
        (AppLanguage.ru, CampaignModule.resources) => 'Ресурсы',
        (AppLanguage.ru, CampaignModule.progression) => 'Прогресс',
        (AppLanguage.ru, CampaignModule.checks) => 'Проверки',
        (AppLanguage.en, CampaignModule.inventory) => 'Inventory',
        (AppLanguage.en, CampaignModule.companions) => 'Companions',
        (AppLanguage.en, CampaignModule.notes) => 'Notes',
        (AppLanguage.en, CampaignModule.vitality) => 'Vitality',
        (AppLanguage.en, CampaignModule.resources) => 'Resources',
        (AppLanguage.en, CampaignModule.progression) => 'Progression',
        (AppLanguage.en, CampaignModule.checks) => 'Checks',
      };

  String campaignModuleReasonLabel(final String reason) {
    if (reason.startsWith('preset:')) {
      return switch (language) {
        AppLanguage.ru => 'Активно по сеттингу',
        AppLanguage.en => 'Enabled by setting',
      };
    }
    if (reason.startsWith('prompt:')) {
      return switch (language) {
        AppLanguage.ru => 'Активно по prompt',
        AppLanguage.en => 'Enabled by prompt',
      };
    }
    if (reason.startsWith('story_unlocked:')) {
      return switch (language) {
        AppLanguage.ru => 'Открыто по ходу истории',
        AppLanguage.en => 'Unlocked by story',
      };
    }
    if (reason.startsWith('legacy_')) {
      return switch (language) {
        AppLanguage.ru => 'Активировано из старого сохранения',
        AppLanguage.en => 'Activated from legacy save',
      };
    }
    return switch (language) {
      AppLanguage.ru => 'Активная система',
      AppLanguage.en => 'Active system',
    };
  }

  String campaignModuleTooltip(CampaignModule value) => switch ((language, value)) {
    (AppLanguage.ru, CampaignModule.inventory) =>
      'Предметы, которые герой находит в мире. Можно использовать в проверках, '
      'торговле и для улучшения характеристик.',
    (AppLanguage.ru, CampaignModule.vitality) =>
      'Здоровье, энергия и базовые характеристики героя. Определяют физические '
      'и ментальные возможности в сражениях и испытаниях.',
    (AppLanguage.ru, CampaignModule.companions) =>
      'Спутники, которые путешествуют с героем. Каждый имеет характер, отношение '
      'к герою и может помочь в приключениях.',
    (AppLanguage.ru, CampaignModule.notes) =>
      'Заметки, улики и наблюдения героя. Автоматически пополняются при '
      'расследованиях и важных открытиях.',
    (AppLanguage.ru, CampaignModule.resources) =>
      'Ресурсы: деньги, топливо, припасы. Расходуются на путешествия, '
      'покупки и улучшения.',
    (AppLanguage.ru, CampaignModule.progression) =>
      'Прогресс героя: уровень, опыт, навыки. Растёт с приключениями, '
      'открывает новые возможности.',
    (AppLanguage.ru, CampaignModule.checks) =>
      'Проверки навыков: броски кубиков, тесты характеристик. Используются '
      'для определения исхода сложных действий.',
    (AppLanguage.en, CampaignModule.inventory) =>
      'Items the hero finds in the world. Can be used in checks, '
      'trading, and to improve stats.',
    (AppLanguage.en, CampaignModule.vitality) =>
      'Health, energy, and core stats. Determine the hero\'s physical '
      'and mental capabilities in combat and trials.',
    (AppLanguage.en, CampaignModule.companions) =>
      'Companions who travel with the hero. Each has a personality, relationship '
      'to the hero, and can help on adventures.',
    (AppLanguage.en, CampaignModule.notes) =>
      'Notes, clues, and observations. Automatically populated during '
      'investigations and important discoveries.',
    (AppLanguage.en, CampaignModule.resources) =>
      'Resources: money, fuel, supplies. Spent on travel, '
      'purchases, and upgrades.',
    (AppLanguage.en, CampaignModule.progression) =>
      'Hero progression: level, experience, skills. Grows with adventures, '
      'unlocks new abilities.',
    (AppLanguage.en, CampaignModule.checks) =>
      'Skill checks: dice rolls, stat tests. Used to determine '
      'the outcome of challenging actions.',
  };

  String get newlyUnlockedLabel => switch (language) {
    AppLanguage.ru => 'Новое',
    AppLanguage.en => 'New',
  };

  String get updatedLabel => switch (language) {
    AppLanguage.ru => 'Обновлено',
    AppLanguage.en => 'Updated',
  };

  String get nothingTrackedYet => switch (language) {
    AppLanguage.ru => 'Пока пусто',
    AppLanguage.en => 'Nothing tracked yet',
  };

  String progressionLabel(
    final CampaignProgression progression,
  ) => switch (language) {
    AppLanguage.ru =>
      'Уровень ${progression.level} • Опыт ${progression.experience}${progression.rank.trim().isEmpty ? '' : ' • ${progression.rank}'}',
    AppLanguage.en =>
      'Level ${progression.level} • XP ${progression.experience}${progression.rank.trim().isEmpty ? '' : ' • ${progression.rank}'}',
  };

  String campaignCheckLabel(final CampaignCheck check) {
    if (check.summary.trim().isNotEmpty) {
      return check.summary;
    }

    final String outcome = switch ((language, check.outcome)) {
      (AppLanguage.ru, CampaignCheckOutcome.success) => 'успех',
      (AppLanguage.ru, CampaignCheckOutcome.failure) => 'провал',
      (AppLanguage.ru, CampaignCheckOutcome.mixed) => 'частичный успех',
      (AppLanguage.ru, CampaignCheckOutcome.unknown) => 'результат',
      (AppLanguage.en, CampaignCheckOutcome.success) => 'success',
      (AppLanguage.en, CampaignCheckOutcome.failure) => 'failure',
      (AppLanguage.en, CampaignCheckOutcome.mixed) => 'partial success',
      (AppLanguage.en, CampaignCheckOutcome.unknown) => 'result',
    };

    final List<String> details = <String>[
      if (check.total != null && check.difficulty != null)
        '${check.total} vs DC ${check.difficulty}',
      if (check.total != null && check.difficulty == null)
        language == AppLanguage.ru
            ? 'итог ${check.total}'
            : 'total ${check.total}',
    ];

    if (details.isEmpty) {
      return '${check.label}: $outcome';
    }
    return '${check.label}: $outcome (${details.join(', ')})';
  }

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

  String get generatingPortrait => switch (language) {
    AppLanguage.ru => 'Генерируется портрет...',
    AppLanguage.en => 'Generating portrait...',
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
    AppLanguage.ru => 'Без подтверждения ИИ избегает сексуального контента.',
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
    AppLanguage.ru => 'OpenAI-compatible endpoint',
    AppLanguage.en => 'OpenAI-compatible endpoint',
  };

  String get aiSettingsDescription => switch (language) {
    AppLanguage.ru =>
      'Настройте любой OpenAI-compatible endpoint, модель и API-ключ, если он нужен.',
    AppLanguage.en =>
      'Configure any OpenAI-compatible endpoint, model, and API key if needed.',
  };

  String get openAiCompatible => switch (language) {
    AppLanguage.ru => 'Совместимый с OpenAI',
    AppLanguage.en => 'OpenAI Compatible',
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
    AppLanguage.ru => 'Оставьте пустым, если endpoint не требует ключ',
    AppLanguage.en => 'Leave empty if the endpoint does not require a key',
  };

  String get showApiKey => switch (language) {
    AppLanguage.ru => 'Показать ключ',
    AppLanguage.en => 'Show key',
  };

  String get hideApiKey => switch (language) {
    AppLanguage.ru => 'Скрыть ключ',
    AppLanguage.en => 'Hide key',
  };

  String get apiKeyBuildTimeHiddenHint => switch (language) {
    AppLanguage.ru =>
      'Ключ из сборки (dart-define) здесь не показывается. Чтобы хранить ключ '
          'на этом устройстве — введите его и нажмите «Сохранить».',
    AppLanguage.en =>
      'Build-time API keys are not shown here. Enter a key and tap Save to '
          'store it on this device.',
  };

  String get endpointBuildDefaultsHint => switch (language) {
    AppLanguage.ru =>
      'Пустые поля URL и модели: подставляются значения из сборки (не '
          'отображаются). Свой endpoint и модель — введите и нажмите «Сохранить».',
    AppLanguage.en =>
      'Empty URL or model: compile-time defaults apply (not shown). Enter '
          'your own and tap Save to store them on this device.',
  };

  String get timeoutSeconds => switch (language) {
    AppLanguage.ru => 'Таймаут в секундах',
    AppLanguage.en => 'Timeout in Seconds',
  };

  String get saveSettings => switch (language) {
    AppLanguage.ru => 'Сохранить настройки',
    AppLanguage.en => 'Save Settings',
  };

  String get checkConnection => switch (language) {
    AppLanguage.ru => 'Проверить подключение',
    AppLanguage.en => 'Check Connection',
  };

  String get settingsSaved => switch (language) {
    AppLanguage.ru => 'Настройки сохранены.',
    AppLanguage.en => 'Settings saved.',
  };

  String get connectionOk => switch (language) {
    AppLanguage.ru => 'Подключение успешно.',
    AppLanguage.en => 'Connection successful.',
  };

  String get symmetryBackendReachableLoginHint => switch (language) {
    AppLanguage.ru =>
      'Сервер игры доступен. Настройки сохранены локально, но чтобы проверить нейросеть, сначала войдите в аккаунт.',
    AppLanguage.en =>
      'The game server is reachable. Your settings are stored locally, but sign in first to check the AI provider.',
  };

  String connectionFailed(final Object error) => switch (language) {
    AppLanguage.ru =>
      'Не удалось проверить подключение: ${symmetryFriendlyError(error)}',
    AppLanguage.en =>
      'Failed to check connection: ${symmetryFriendlyError(error)}',
  };

  String connectionFailedForUrl(
    final String url,
    final Object error,
  ) => switch (language) {
    AppLanguage.ru =>
      'Не удалось проверить подключение к $url: ${symmetryFriendlyError(error)}',
    AppLanguage.en =>
      'Failed to check connection to $url: ${symmetryFriendlyError(error)}',
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

  String get worldRumorsTitle => switch (language) {
    AppLanguage.ru => 'Слухи мира',
    AppLanguage.en => 'World Rumors',
  };

  String get worldRumorsEmpty => switch (language) {
    AppLanguage.ru => 'Пока мир не принёс новых слухов.',
    AppLanguage.en => 'The world has not brought new rumors yet.',
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
    AppLanguage.ru =>
      '\u041d\u0430\u043f\u0438\u0448\u0438 \u0441\u0432\u043e\u044e \u0438\u0434\u0435\u044e, \u0430 \u0435\u0441\u043b\u0438 \u043e\u0441\u0442\u0430\u0432\u0438\u0448\u044c \u043f\u043e\u043b\u0435 \u043f\u0443\u0441\u0442\u044b\u043c, \u043c\u044b \u043f\u0440\u0438\u0434\u0443\u043c\u0430\u0435\u043c \u043d\u0435\u043e\u0436\u0438\u0434\u0430\u043d\u043d\u0443\u044e \u0437\u0430\u0432\u044f\u0437\u043a\u0443.',
    AppLanguage.en =>
      'Write your idea, or leave it empty and we will come up with a fresh story hook for you.',
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

  String get authTitle => switch (language) {
    AppLanguage.ru => 'Вход',
    AppLanguage.en => 'Sign in',
  };

  String get authContinueWithYandexAction => switch (language) {
    AppLanguage.ru => 'Войти через Яндекс',
    AppLanguage.en => 'Continue with Yandex',
  };

  String get authContinueWithEmailHint => switch (language) {
    AppLanguage.ru => 'или войдите по email и паролю',
    AppLanguage.en => 'or sign in with email and password',
  };

  String get authYandexProcessing => switch (language) {
    AppLanguage.ru => 'Завершаем вход через Яндекс...',
    AppLanguage.en => 'Finishing Yandex sign-in...',
  };

  // --- Email verification ---
  String get authEmailVerificationTitle => switch (language) {
    AppLanguage.ru => 'Подтвердите email',
    AppLanguage.en => 'Verify your email',
  };

  String authEmailVerificationMessage(final String email) => switch (language) {
    AppLanguage.ru =>
        'Мы отправили письмо на $email. Перейдите по ссылке в письме, чтобы подтвердить адрес.',
    AppLanguage.en =>
        'We sent an email to $email. Click the link in the email to verify your address.',
  };

  String get authEmailVerificationResendAction => switch (language) {
    AppLanguage.ru => 'Отправить ещё раз',
    AppLanguage.en => 'Resend email',
  };

  String get authEmailVerificationCheckAction => switch (language) {
    AppLanguage.ru => 'Проверить статус',
    AppLanguage.en => 'Check status',
  };

  String get authEmailVerificationResendSuccess => switch (language) {
    AppLanguage.ru => 'Письмо отправлено. Проверьте почту.',
    AppLanguage.en => 'Verification email sent. Check your inbox.',
  };

  String get authEmailVerificationResendTooSoon => switch (language) {
    AppLanguage.ru => 'Подождите минуту перед повторной отправкой.',
    AppLanguage.en => 'Please wait a minute before resending.',
  };

  String get authEmailVerificationSuccess => switch (language) {
    AppLanguage.ru => 'Email подтверждён!',
    AppLanguage.en => 'Email verified!',
  };

  String get authEmailVerifiedSuccessMessage => switch (language) {
    AppLanguage.ru => 'Ваша почта успешно подтверждена. Добро пожаловать в Стирая Грань!',
    AppLanguage.en => 'Your email has been verified. Welcome to Beyond The Verge!',
  };

  String get authEmailVerifiedSuccessAction => switch (language) {
    AppLanguage.ru => 'Продолжить',
    AppLanguage.en => 'Continue',
  };

  String get authEmailVerificationChecking => switch (language) {
    AppLanguage.ru => 'Проверяем статус...',
    AppLanguage.en => 'Checking status...',
  };

  String get authAlreadySignedInHint => switch (language) {
    AppLanguage.ru => 'Вы уже вошли в аккаунт.',
    AppLanguage.en => 'You are already signed in.',
  };

  String get closeAction => switch (language) {
    AppLanguage.ru => 'Закрыть',
    AppLanguage.en => 'Close',
  };

  String get serverAddressLabel => switch (language) {
    AppLanguage.ru => 'Адрес сервера',
    AppLanguage.en => 'Server address',
  };

  String get accountTitle => switch (language) {
    AppLanguage.ru => 'Аккаунт',
    AppLanguage.en => 'Account',
  };

  String get accountSignedOutDescription => switch (language) {
    AppLanguage.ru => 'Вы не вошли в аккаунт.',
    AppLanguage.en => 'You are not signed in.',
  };

  // --- Email verification status in settings ---
  String get settingsEmailStatusTitle => switch (language) {
    AppLanguage.ru => 'Подтверждение email',
    AppLanguage.en => 'Email Verification',
  };

  String get settingsEmailStatusNotVerified => switch (language) {
    AppLanguage.ru => 'Не подтверждён',
    AppLanguage.en => 'Not verified',
  };

  String get settingsEmailStatusExpired => switch (language) {
    AppLanguage.ru => 'Срок подтверждения истёк',
    AppLanguage.en => 'Verification expired',
  };

  String get settingsEmailStatusVerified => switch (language) {
    AppLanguage.ru => 'Подтверждён',
    AppLanguage.en => 'Verified',
  };

  String get settingsEmailResendAction => switch (language) {
    AppLanguage.ru => 'Отправить письмо повторно',
    AppLanguage.en => 'Resend verification email',
  };

  String get settingsEmailSendNewAction => switch (language) {
    AppLanguage.ru => 'Отправить новое письмо',
    AppLanguage.en => 'Send new email',
  };

  String get legalInfoTitle => switch (language) {
    AppLanguage.ru => 'Правовая информация',
    AppLanguage.en => 'Legal Information',
  };

  String get legalOfferShort => switch (language) {
    AppLanguage.ru => 'Оферта',
    AppLanguage.en => 'Offer',
  };

  String get legalPrivacyShort => switch (language) {
    AppLanguage.ru => 'Конфиденциальность',
    AppLanguage.en => 'Privacy',
  };

  String get legalConsentShort => switch (language) {
    AppLanguage.ru => 'Согласие на ПД',
    AppLanguage.en => 'Data Consent',
  };

  String get legalRefundsShort => switch (language) {
    AppLanguage.ru => 'Возврат',
    AppLanguage.en => 'Refunds',
  };

  String get legalContactsShort => switch (language) {
    AppLanguage.ru => 'Контакты',
    AppLanguage.en => 'Contacts',
  };

  String get legalPricingShort => switch (language) {
    AppLanguage.ru => 'Цены',
    AppLanguage.en => 'Pricing',
  };

  String get personalModelTitle => switch (language) {
    AppLanguage.ru => 'Своя ИИ-модель',
    AppLanguage.en => 'Your AI model',
  };

  String get personalModelHint => switch (language) {
    AppLanguage.ru =>
      'Вы можете ввести свой ключ от ИИ-модели для генерации кампании. Ваш ключ хранится только локально.',
    AppLanguage.en =>
      'You can enter your own AI model key for campaign generation. Your key is stored only locally.',
  };

  String get emailLabel => switch (language) {
    AppLanguage.ru => 'Email',
    AppLanguage.en => 'Email',
  };

  String get passwordLabel => switch (language) {
    AppLanguage.ru => 'Пароль',
    AppLanguage.en => 'Password',
  };

  String get displayNameLabel => switch (language) {
    AppLanguage.ru => 'Отображаемое имя',
    AppLanguage.en => 'Display name',
  };

  String get authEmailRequired => switch (language) {
    AppLanguage.ru => 'Введите email.',
    AppLanguage.en => 'Enter your email.',
  };

  String get authEmailInvalid => switch (language) {
    AppLanguage.ru => 'Введите корректный email.',
    AppLanguage.en => 'Enter a valid email.',
  };

  String get authPasswordRequired => switch (language) {
    AppLanguage.ru => 'Введите пароль.',
    AppLanguage.en => 'Enter your password.',
  };

  String get authPasswordTooShort => switch (language) {
    AppLanguage.ru => 'Пароль должен быть не короче 8 символов.',
    AppLanguage.en => 'Password must be at least 8 characters long.',
  };

  String get authDisplayNameTooLong => switch (language) {
    AppLanguage.ru => 'Отображаемое имя слишком длинное.',
    AppLanguage.en => 'Display name is too long.',
  };

  String get loginAction => switch (language) {
    AppLanguage.ru => 'Войти',
    AppLanguage.en => 'Log In',
  };

  String get registerAction => switch (language) {
    AppLanguage.ru => 'Зарегистрироваться',
    AppLanguage.en => 'Register',
  };

  String get switchToRegisterAction => switch (language) {
    AppLanguage.ru => 'Нет аккаунта? Зарегистрироваться',
    AppLanguage.en => 'No account? Register',
  };

  String get switchToLoginAction => switch (language) {
    AppLanguage.ru => 'Уже есть аккаунт? Войти',
    AppLanguage.en => 'Already have an account? Log in',
  };

  String authLoginFailed(final Object error) => switch (language) {
    AppLanguage.ru => 'Не удалось войти: ${symmetryFriendlyError(error)}',
    AppLanguage.en => 'Login failed: ${symmetryFriendlyError(error)}',
  };

  String authRegisterFailed(final Object error) => switch (language) {
    AppLanguage.ru =>
      'Не удалось зарегистрироваться: ${symmetryFriendlyError(error)}',
    AppLanguage.en => 'Registration failed: ${symmetryFriendlyError(error)}',
  };

  String authYandexFailed(final Object error) => switch (language) {
    AppLanguage.ru =>
      'Не удалось войти через Яндекс: ${symmetryFriendlyError(error)}',
    AppLanguage.en => 'Yandex sign-in failed: ${symmetryFriendlyError(error)}',
  };

  String get authEmailTaken => switch (language) {
    AppLanguage.ru => 'Этот email уже зарегистрирован.',
    AppLanguage.en => 'This email is already registered.',
  };

  String get authInvalidLogin => switch (language) {
    AppLanguage.ru => 'Неверный email или пароль.',
    AppLanguage.en => 'Invalid email or password.',
  };

  String get authRegisterValidationFailed => switch (language) {
    AppLanguage.ru =>
      'Проверьте email и пароль: пароль должен быть не короче 8 символов.',
    AppLanguage.en =>
      'Check your email and password: the password must be at least 8 characters long.',
  };

  String get authLoginValidationFailed => switch (language) {
    AppLanguage.ru =>
      'Проверьте email и пароль: пароль должен быть не короче 8 символов.',
    AppLanguage.en =>
      'Check your email and password: the password must be at least 8 characters long.',
  };

  String get authBackendUnavailable => switch (language) {
    AppLanguage.ru =>
      'Сервер игры сейчас недоступен. Проверьте адрес сервера и попробуйте ещё раз.',
    AppLanguage.en =>
      'The game server is currently unavailable. Check the server URL and try again.',
  };

  String symmetryFriendlyError(final Object error) {
    if (error is SymmetryApiException) {
      if (error.hasValidationErrors) {
        return _validationFriendlyError(error.validationErrors);
      }
      final String? detail = error.detailCode;
      if (detail != null && detail.isNotEmpty) {
        return _detailFriendlyError(detail);
      }
      return _statusFriendlyError(error.statusCode);
    }
    if (error is StateError) {
      final String raw = error.toString();
      if (raw.contains('symmetry_session_required')) {
        return switch (language) {
          AppLanguage.ru => 'Сначала войдите в аккаунт.',
          AppLanguage.en => 'Sign in first.',
        };
      }
      if (raw.contains('symmetry_unreachable')) {
        return authBackendUnavailable;
      }
      if (raw.contains('symmetry_invalid_response')) {
        return switch (language) {
          AppLanguage.ru => 'Сервер игры вернул неожиданный ответ.',
          AppLanguage.en => 'The game server returned an unexpected response.',
        };
      }
    }
    final String raw = error.toString().toLowerCase();
    if (raw.contains('xmlhttprequest error') ||
        raw.contains('clientexception') ||
        raw.contains('socketexception') ||
        raw.contains('connection refused') ||
        raw.contains('failed host lookup') ||
        raw.contains('connection closed before full header was received')) {
      return authBackendUnavailable;
    }
    if (raw.contains('timeout')) {
      return switch (language) {
        AppLanguage.ru =>
          'Сервер игры отвечает слишком долго. Попробуйте ещё раз.',
        AppLanguage.en =>
          'The game server is taking too long to respond. Please try again.',
      };
    }
    return switch (language) {
      AppLanguage.ru => 'Произошла непредвиденная ошибка.',
      AppLanguage.en => 'An unexpected error occurred.',
    };
  }

  String _detailFriendlyError(final String detail) => switch (detail) {
    'email_taken' => authEmailTaken,
    'invalid_login' => authInvalidLogin,
    'invalid_refresh_token' => switch (language) {
      AppLanguage.ru => 'Сессия истекла. Войдите снова.',
      AppLanguage.en => 'Your session has expired. Sign in again.',
    },
    'authentication_required' => switch (language) {
      AppLanguage.ru => 'Сначала войдите в аккаунт.',
      AppLanguage.en => 'Sign in first.',
    },
    'user_not_found' => switch (language) {
      AppLanguage.ru => 'Пользователь не найден.',
      AppLanguage.en => 'User not found.',
    },
    'missing_provider_credentials' => switch (language) {
      AppLanguage.ru =>
        'Укажите данные AI-провайдера или настройте серверный ключ.',
      AppLanguage.en =>
        'Provide AI provider credentials or configure a server-side key.',
    },
    'provider_connection_failed' => switch (language) {
      AppLanguage.ru =>
        'Не удалось подключиться к AI-провайдеру. Проверьте URL, модель и API-ключ.',
      AppLanguage.en =>
        'Could not connect to the AI provider. Check the URL, model, and API key.',
    },
    'provider_auth_failed' => switch (language) {
      AppLanguage.ru =>
        'AI-провайдер отклонил авторизацию. Проверьте API-ключ и доступ к модели.',
      AppLanguage.en =>
        'The AI provider rejected authorization. Check the API key and model access.',
    },
    'provider_rate_limited' => switch (language) {
      AppLanguage.ru =>
        'У AI-провайдера временно исчерпан лимит запросов. Попробуйте чуть позже.',
      AppLanguage.en =>
        'The AI provider rate limit has been reached. Please try again later.',
    },
    'campaign_not_found' => switch (language) {
      AppLanguage.ru => 'Кампания не найдена.',
      AppLanguage.en => 'Campaign not found.',
    },
    'snapshot_not_found' => switch (language) {
      AppLanguage.ru => 'Снимок кампании не найден.',
      AppLanguage.en => 'Campaign snapshot not found.',
    },
    'campaign_runtime_not_found' => switch (language) {
      AppLanguage.ru => 'Не удалось загрузить состояние кампании.',
      AppLanguage.en => 'Could not load the campaign state.',
    },
    'story_template_not_found' => switch (language) {
      AppLanguage.ru => 'Шаблон истории не найден.',
      AppLanguage.en => 'Story template not found.',
    },
    'missing_code' => switch (language) {
      AppLanguage.ru => 'Не получен код авторизации.',
      AppLanguage.en => 'Authorization code is missing.',
    },
    'missing_yandex_state' => switch (language) {
      AppLanguage.ru => 'Не получено состояние OAuth-сессии Яндекса.',
      AppLanguage.en => 'Yandex OAuth state is missing.',
    },
    'invalid_yandex_state' => switch (language) {
      AppLanguage.ru => 'Сессия входа через Яндекс устарела или повреждена.',
      AppLanguage.en => 'The Yandex sign-in session is expired or invalid.',
    },
    'expired_yandex_state' => switch (language) {
      AppLanguage.ru =>
        'Сессия входа через Яндекс истекла. Начните вход заново.',
      AppLanguage.en => 'The Yandex sign-in session has expired. Start again.',
    },
    'invalid_yandex_profile' => switch (language) {
      AppLanguage.ru => 'Yandex вернул неполный профиль пользователя.',
      AppLanguage.en => 'Yandex returned an incomplete user profile.',
    },
    'missing_yandex_handoff' => switch (language) {
      AppLanguage.ru => 'Сервер не передал результат входа через Яндекс.',
      AppLanguage.en => 'The server did not return a Yandex sign-in result.',
    },
    'invalid_yandex_handoff' => switch (language) {
      AppLanguage.ru =>
        'Ссылка завершения входа через Яндекс уже недействительна.',
      AppLanguage.en =>
        'This Yandex sign-in completion link is no longer valid.',
    },
    'expired_yandex_handoff' => switch (language) {
      AppLanguage.ru =>
        'Срок завершения входа через Яндекс истёк. Попробуйте снова.',
      AppLanguage.en =>
        'The Yandex sign-in completion has expired. Please try again.',
    },
    'yandex_oauth_not_configured' => switch (language) {
      AppLanguage.ru => 'Вход через Yandex пока не настроен.',
      AppLanguage.en => 'Yandex sign-in is not configured yet.',
    },
    'web_public_origin_not_configured' => switch (language) {
      AppLanguage.ru =>
        'Сервер не настроен для возврата в веб-приложение. Проверьте SYMMETRY_WEB_PUBLIC_ORIGIN.',
      AppLanguage.en =>
        'The server cannot return users to the web app. Check SYMMETRY_WEB_PUBLIC_ORIGIN.',
    },
    'invalid_yandex_redirect_uri' => switch (language) {
      AppLanguage.ru =>
        'Адрес возврата OAuth не совпадает с настройками сервера. Проверьте SYMMETRY_YANDEX_REDIRECT_URI.',
      AppLanguage.en =>
        'OAuth redirect URI does not match server settings. Check SYMMETRY_YANDEX_REDIRECT_URI.',
    },
    'legacy_yandex_callback_flow' => switch (language) {
      AppLanguage.ru =>
        'В браузер вернулся устаревший OAuth callback. Обновите callback URL Яндекса на backend `/v1/auth/yandex/callback`.',
      AppLanguage.en =>
        'The browser returned to a legacy OAuth callback. Update the Yandex callback URL to backend `/v1/auth/yandex/callback`.',
    },
    // --- Email verification errors ---
    'email_not_verified' => switch (language) {
      AppLanguage.ru => 'Сначала подтвердите email. Проверьте почту.',
      AppLanguage.en => 'Verify your email first. Check your inbox.',
    },
    'invalid_verification_token' => switch (language) {
      AppLanguage.ru => 'Неверная или уже использованная ссылка подтверждения.',
      AppLanguage.en => 'Invalid or already used verification link.',
    },
    'expired_verification_token' => switch (language) {
      AppLanguage.ru => 'Ссылка подтверждения истекла. Запросите новую.',
      AppLanguage.en => 'Verification link has expired. Request a new one.',
    },
    'verification_token_already_used' => switch (language) {
      AppLanguage.ru => 'Эта ссылка уже была использована.',
      AppLanguage.en => 'This link has already been used.',
    },
    'resend_too_soon' => switch (language) {
      AppLanguage.ru => 'Подождите минуту перед повторной отправкой.',
      AppLanguage.en => 'Please wait a minute before resending.',
    },
    'already_verified' => switch (language) {
      AppLanguage.ru => 'Email уже подтверждён.',
      AppLanguage.en => 'Email already verified.',
    },
    _ => _statusFriendlyError(null),
  };

  String _statusFriendlyError(final int? statusCode) => switch (statusCode) {
    400 => switch (language) {
      AppLanguage.ru => 'Запрос заполнен некорректно.',
      AppLanguage.en => 'The request is invalid.',
    },
    401 => switch (language) {
      AppLanguage.ru => 'Требуется вход в аккаунт.',
      AppLanguage.en => 'Sign-in is required.',
    },
    404 => switch (language) {
      AppLanguage.ru => 'Запрошенные данные не найдены.',
      AppLanguage.en => 'The requested data was not found.',
    },
    409 => switch (language) {
      AppLanguage.ru => 'Такой объект уже существует.',
      AppLanguage.en => 'This item already exists.',
    },
    422 => switch (language) {
      AppLanguage.ru => 'Некоторые поля заполнены неверно.',
      AppLanguage.en => 'Some fields are invalid.',
    },
    502 => switch (language) {
      AppLanguage.ru => 'Внешний AI-сервис сейчас недоступен.',
      AppLanguage.en => 'The external AI service is currently unavailable.',
    },
    _ => switch (language) {
      AppLanguage.ru => 'Произошла ошибка на стороне сервиса.',
      AppLanguage.en => 'A service error occurred.',
    },
  };

  String _validationFriendlyError(final List<String> errors) {
    final String joined = errors.join(' | ').toLowerCase();
    if (joined.contains('password') && joined.contains('at least 8')) {
      return authPasswordTooShort;
    }
    if (joined.contains('email')) {
      return authEmailInvalid;
    }
    if (joined.contains('display_name')) {
      return authDisplayNameTooLong;
    }
    return switch (language) {
      AppLanguage.ru => 'Некоторые поля заполнены неверно.',
      AppLanguage.en => 'Some fields are invalid.',
    };
  }

  String get signOutAction => switch (language) {
    AppLanguage.ru => 'Выйти из аккаунта',
    AppLanguage.en => 'Sign out',
  };

  String get signOutShortAction => switch (language) {
    AppLanguage.ru => 'Выйти',
    AppLanguage.en => 'Sign out',
  };

  String get signedOutStatus => switch (language) {
    AppLanguage.ru => 'Сессия завершена.',
    AppLanguage.en => 'Signed out.',
  };

  String get updateAvailableTitle => switch (language) {
    AppLanguage.ru => 'Доступно обновление',
    AppLanguage.en => 'Update available',
  };

  String get updateRequiredTitle => switch (language) {
    AppLanguage.ru => 'Требуется обновление',
    AppLanguage.en => 'Update required',
  };

  String updateAvailableBody(final String version) => switch (language) {
    AppLanguage.ru =>
      'Доступна версия $version. Можно обновиться сейчас или продолжить позже.',
    AppLanguage.en =>
      'Version $version is available. You can update now or continue later.',
  };

  String updateRequiredBody(final String version) => switch (language) {
    AppLanguage.ru =>
      'Для продолжения нужна версия $version. Обновите приложение или перезагрузите страницу.',
    AppLanguage.en =>
      'Version $version is required to continue. Update the app or reload the page.',
  };

  String get updateLaterAction => switch (language) {
    AppLanguage.ru => 'Позже',
    AppLanguage.en => 'Later',
  };

  String get updateNowAction => switch (language) {
    AppLanguage.ru => 'Обновить',
    AppLanguage.en => 'Update',
  };

  String get reloadNowAction => switch (language) {
    AppLanguage.ru => 'Перезагрузить',
    AppLanguage.en => 'Reload',
  };

  String get updateUnknownVersion => switch (language) {
    AppLanguage.ru => 'новая версия',
    AppLanguage.en => 'a newer version',
  };

  // ── Billing ─────────────────────────────────────────────────

  String get billingTitle => switch (language) {
    AppLanguage.ru => 'Токены и подписки',
    AppLanguage.en => 'Tokens & Subscriptions',
  };

  String get billingAvailableEssence => switch (language) {
    AppLanguage.ru => 'Доступная эссенция',
    AppLanguage.en => 'Available Essence',
  };

  String get billingAcquireEssence => switch (language) {
    AppLanguage.ru => 'Приобрести эссенцию',
    AppLanguage.en => 'Acquire Essence',
  };

  String billingEssenceLow(final int remaining) => switch (language) {
    AppLanguage.ru => 'Эссенция на исходе — осталось $remaining',
    AppLanguage.en => 'Essence running low — $remaining remaining',
  };

  String get billingWelcomePermanent => switch (language) {
    AppLanguage.ru => 'приветственные',
    AppLanguage.en => 'welcome',
  };

  String get billingMonthly => switch (language) {
    AppLanguage.ru => 'за месяц',
    AppLanguage.en => 'monthly',
  };

  String get billingPermanent => switch (language) {
    AppLanguage.ru => 'постоянные',
    AppLanguage.en => 'permanent',
  };

  String get billingPack10mTitle => switch (language) {
    AppLanguage.ru => 'Коробка с эссенциями',
    AppLanguage.en => 'Essence Crate',
  };

  String get billingPack10mDesc => switch (language) {
    AppLanguage.ru => 'Единоразово. 10M токенов.',
    AppLanguage.en => 'One-time. 10M tokens.',
  };

  String get billingPack100mTitle => switch (language) {
    AppLanguage.ru => 'Геройский запас',
    AppLanguage.en => 'Hero Stash',
  };

  String get billingPack100mDesc => switch (language) {
    AppLanguage.ru => 'Единоразово. 100M токенов.',
    AppLanguage.en => 'One-time. 100M tokens.',
  };

  String get billingSubscribeAction => switch (language) {
    AppLanguage.ru => 'Подписаться',
    AppLanguage.en => 'Subscribe',
  };

  String get billingBuyAction => switch (language) {
    AppLanguage.ru => 'Купить',
    AppLanguage.en => 'Buy',
  };

  String get billingWelcomeClaimError => switch (language) {
    AppLanguage.ru => 'Не удалось получить приветственный пакет',
    AppLanguage.en => 'Failed to claim welcome pack',
  };

  String get billingWelcomeClaimed => switch (language) {
    AppLanguage.ru => 'Приветственный пакет — получен',
    AppLanguage.en => 'Welcome Pack — Claimed',
  };

  String get billingWelcomeClaimedDesc => switch (language) {
    AppLanguage.ru => '1 000 000 токенов начислено',
    AppLanguage.en => '1,000,000 tokens granted',
  };

  String get billingAgreementLabel => switch (language) {
    AppLanguage.ru => 'Принимаю условия ',
    AppLanguage.en => 'I accept the ',
  };

  String get billingAgreementAnd => switch (language) {
    AppLanguage.ru => ' и ',
    AppLanguage.en => ' and ',
  };

  String get billingOfferLink => switch (language) {
    AppLanguage.ru => 'Оферты',
    AppLanguage.en => 'Offer',
  };

  String get billingPrivacyLink => switch (language) {
    AppLanguage.ru => 'Политики конфиденциальности',
    AppLanguage.en => 'Privacy Policy',
  };

  String billingPayLabel(final String price) => switch (language) {
    AppLanguage.ru => 'Оплатить $price',
    AppLanguage.en => 'Pay $price',
  };

  String get billingPaymentFailed => switch (language) {
    AppLanguage.ru => 'Оплата не прошла',
    AppLanguage.en => 'Payment failed',
  };

  String get billingTryAgain => switch (language) {
    AppLanguage.ru => 'Попробовать снова',
    AppLanguage.en => 'Try again',
  };

  String get billingRedirecting => switch (language) {
    AppLanguage.ru => 'Перенаправляем в YooKassa…',
    AppLanguage.en => 'Redirecting to YooKassa…',
  };

  String get billingConfirming => switch (language) {
    AppLanguage.ru => 'Подтверждаем…',
    AppLanguage.en => 'Confirming…',
  };

  String get billingBalanceUnavailable => switch (language) {
    AppLanguage.ru => 'Баланс недоступен',
    AppLanguage.en => 'Balance unavailable',
  };

  String get billingRetry => switch (language) {
    AppLanguage.ru => 'Повторить',
    AppLanguage.en => 'Retry',
  };

  String get billingPaywallTitle => switch (language) {
    AppLanguage.ru => 'Недостаточно эссенции',
    AppLanguage.en => 'Not Enough Essence',
  };

  String billingPaywallBody(final String? campaignName) => switch (language) {
    AppLanguage.ru => campaignName != null
        ? 'Ваша эссенция иссякла посреди пути в «$campaignName». Приобретите токены, чтобы продолжить.'
        : 'Ваши запасы исчерпаны. Приобретите токены, чтобы продолжить путешествие.',
    AppLanguage.en => campaignName != null
        ? 'Your essence fades mid-journey in "$campaignName". Acquire more tokens to continue.'
        : 'Your arcane reserves are depleted. Acquire more tokens to continue your journey.',
  };

  String get billingBuyTokensAction => switch (language) {
    AppLanguage.ru => 'Купить токены',
    AppLanguage.en => 'Buy Tokens',
  };

  String get billingNotNowAction => switch (language) {
    AppLanguage.ru => 'Не сейчас',
    AppLanguage.en => 'Not Now',
  };

  String get billingGuestRegisterTitle => switch (language) {
    AppLanguage.ru => 'Зарегистрируйтесь, чтобы продолжить',
    AppLanguage.en => 'Register to Continue',
  };

  String get billingGuestRegisterBody => switch (language) {
    AppLanguage.ru =>
        'Вы использовали 5 бесплатных ходов. Зарегистрируйтесь и получите 1 000 000 бесплатных токенов для продолжения!',
    AppLanguage.en =>
        'You\'ve used 5 free turns. Register now to get 1,000,000 free tokens and continue your adventure!',
  };

  String get billingGuestRegisterAction => switch (language) {
    AppLanguage.ru => 'Зарегистрироваться и получить 1M токенов',
    AppLanguage.en => 'Register & Get 1M Tokens',
  };

  String get billingFooterOffer => switch (language) {
    AppLanguage.ru => 'Оферта',
    AppLanguage.en => 'Offer',
  };

  String get billingFooterPrivacy => switch (language) {
    AppLanguage.ru => 'Конфиденциальность',
    AppLanguage.en => 'Privacy',
  };

  String get billingFooterSupport => switch (language) {
    AppLanguage.ru => 'Поддержка',
    AppLanguage.en => 'Support',
  };

  String get billingFooterRefunds => switch (language) {
    AppLanguage.ru => 'Возвраты',
    AppLanguage.en => 'Refunds',
  };

  String get billingFooterPricing => switch (language) {
    AppLanguage.ru => 'Цены',
    AppLanguage.en => 'Pricing',
  };

  String get billingGuestLoginToBuy => switch (language) {
    AppLanguage.ru => 'Войдите для покупки',
    AppLanguage.en => 'Login to purchase',
  };

  String get billingGuestBalanceHint => switch (language) {
    AppLanguage.ru => 'Доступно после авторизации',
    AppLanguage.en => 'Available after login',
  };

  String get billingGuestCatalogError => switch (language) {
    AppLanguage.ru => 'Не удалось загрузить цены',
    AppLanguage.en => 'Failed to load prices',
  };

  String get billingChronicleTitle => switch (language) {
    AppLanguage.ru => 'История',
    AppLanguage.en => 'Chronicle',
  };

  String get billingChronicleEmpty => switch (language) {
    AppLanguage.ru => 'Пока нет транзакций',
    AppLanguage.en => 'No transactions yet',
  };

  String get billingChronicleEmptyDesc => switch (language) {
    AppLanguage.ru => 'Ваше путешествие начинается здесь',
    AppLanguage.en => 'Your journey begins here',
  };

  String get billingChronicleHistoryUnavailable => switch (language) {
    AppLanguage.ru => 'История недоступна',
    AppLanguage.en => 'History unavailable',
  };

  String get billingChronicleTurn => switch (language) {
    AppLanguage.ru => 'Ход',
    AppLanguage.en => 'Turn',
  };

  String get billingChroniclePurchase => switch (language) {
    AppLanguage.ru => 'Покупка',
    AppLanguage.en => 'Purchase',
  };

  String get billingChronicleWelcomeGrant => switch (language) {
    AppLanguage.ru => 'Приветственный грант',
    AppLanguage.en => 'Welcome grant',
  };

  String get billingChronicleSubscriptionRenewal => switch (language) {
    AppLanguage.ru => 'Продление подписки',
    AppLanguage.en => 'Subscription renewal',
  };

  String get billingOfflineBanner => switch (language) {
    AppLanguage.ru => 'Нет соединения — показаны кэшированные данные',
    AppLanguage.en => 'No connection — showing cached data',
  };

  String get billingStillProcessing => switch (language) {
    AppLanguage.ru => 'Платёж обрабатывается',
    AppLanguage.en => 'Payment processing',
  };

  String get billingCheckAgain => switch (language) {
    AppLanguage.ru => 'Проверить снова',
    AppLanguage.en => 'Check again',
  };

  String chatLowEssenceWarning(final int remaining) => switch (language) {
    AppLanguage.ru => 'Эссенция на исходе — осталось $remaining',
    AppLanguage.en => 'Essence running low — $remaining remaining',
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
