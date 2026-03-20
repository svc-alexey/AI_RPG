import 'dart:math';

import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';

/// Генератор случайных промптов для историй на основе выбранного сеттинга.
class RandomStoryPromptGenerator {
  const RandomStoryPromptGenerator();

  static final Random _random = Random();

  /// Генерирует случайный промпт для истории на основе сеттинга и языка.
  String generateForSetting({
    required CampaignSetting setting,
    required AppLanguage language,
  }) {
    final List<String> prompts = _getPromptsForSetting(setting, language);
    if (prompts.isEmpty) return '';
    return prompts[_random.nextInt(prompts.length)];
  }

  List<String> _getPromptsForSetting(
    CampaignSetting setting,
    AppLanguage language,
  ) => switch ((setting, language)) {
    (CampaignSetting.fantasy, AppLanguage.ru) => _fantasyPromptsRu,
    (CampaignSetting.fantasy, AppLanguage.en) => _fantasyPromptsEn,
    (CampaignSetting.detective, AppLanguage.ru) => _detectivePromptsRu,
    (CampaignSetting.detective, AppLanguage.en) => _detectivePromptsEn,
    (CampaignSetting.sciFi, AppLanguage.ru) => _sciFiPromptsRu,
    (CampaignSetting.sciFi, AppLanguage.en) => _sciFiPromptsEn,
  };

  // Fantasy prompts - Russian
  static final List<String> _fantasyPromptsRu = <String>[
    '''Создай тёмное фэнтези с мрачной атмосферой. История о древних проклятиях, забытых богах и опасной магии. Тон серьёзный, с элементами ужаса. Мир находится на грани катастрофы. Персонажи сталкиваются с моральными дилеммами и непростыми выборами.''',

    '''Приключение в стиле классического dungeon crawl. Исследование древних подземелий, полных ловушек, монстров и сокровищ. Атмосфера таинственная, с элементами открытий. Акцент на тактические решения и находчивость героя.''',

    '''Эпическая сага о противостоянии древнему злу. Масштабная история с союзниками, предательствами и великими битвами. Героический тон, вдохновение от Толкина. Судьба мира висит на волоске.''',

    '''История о магической академии и запретных знаниях. Интриги между учениками и преподавателями, опасные эксперименты с магией. Атмосфера загадки и опасности. Не всё то, чем кажется на первый взгляд.''',

    '''Мир, где магия постепенно угасает. История о последних магах, пытающихся сохранить древние знания. Меланхоличный тон, элементы ностальгии. Конфликт между старым миром магии и новым миром технологий.''',

    '''Приключение в духе мрачных сказок. Заколдованные леса, проклятые замки, опасные фейри. Атмосфера готического хоррора. Каждая встреча таит в себе подвох. Магия имеет цену.''',

    '''История о восстании против тиранической империи. Революционный сюжет с элементами войны и политических интриг. Героизм простых людей против могущественных магов. Атмосфера надежды среди отчаяния.''',
  ];

  // Fantasy prompts - English
  static final List<String> _fantasyPromptsEn = <String>[
    '''Create a dark fantasy with a grim atmosphere. A story about ancient curses, forgotten gods, and dangerous magic. Serious tone with horror elements. The world is on the brink of catastrophe. Characters face moral dilemmas and difficult choices.''',

    '''An adventure in classic dungeon crawl style. Exploring ancient dungeons full of traps, monsters, and treasures. Mysterious atmosphere with elements of discovery. Focus on tactical decisions and hero's resourcefulness.''',

    '''An epic saga about confronting ancient evil. A grand story with allies, betrayals, and great battles. Heroic tone inspired by Tolkien. The fate of the world hangs by a thread.''',

    '''A story about a magical academy and forbidden knowledge. Intrigue among students and teachers, dangerous magical experiments. Atmosphere of mystery and danger. Not everything is as it seems.''',

    '''A world where magic is gradually fading. A story about the last mages trying to preserve ancient knowledge. Melancholic tone with elements of nostalgia. Conflict between the old world of magic and the new world of technology.''',

    '''An adventure in the spirit of dark fairy tales. Enchanted forests, cursed castles, dangerous fae. Gothic horror atmosphere. Every encounter hides a catch. Magic has a price.''',

    '''A story about rebellion against a tyrannical empire. Revolutionary plot with elements of war and political intrigue. Heroism of common people against powerful mages. Atmosphere of hope amid despair.''',
  ];

  // Detective prompts - Russian
  static final List<String> _detectivePromptsRu = <String>[
    '''Нуар-детектив в мрачном городе. Коррупция, преступные синдикаты, морально серые персонажи. Атмосфера киношного нуара 40-х годов. Каждая зацепка ведёт в ещё более тёмные закоулки. Дождливые улицы, неоновые вывески, опасность на каждом шагу.''',

    '''Расследование серии загадочных исчезновений в небольшом городе. Классический детектив с элементами мистики. Каждое исчезновение связано странными совпадениями. Местные жители что-то скрывают. Тайна уходит корнями в прошлое города.''',

    '''Детектив в стиле Агаты Кристи. Закрытая локация (особняк, отель, поезд), ограниченный круг подозреваемых. Интеллектуальная головоломка, логические загадки. Каждый имеет мотив и алиби. Раскрытие через дедукцию.''',

    '''Киберпанк-детектив в мегаполисе будущего. Расследование корпоративных преступлений, хакеры, искусственный интеллект. Неоновые улицы, дополненная реальность, технологический нуар. Граница между человеком и машиной размыта.''',

    '''Детектив с элементами ужаса и сверхъестественного. Расследование убийства с ритуальными элементами. Оккультные символы, древние проклятия. Рациональный сыщик сталкивается с иррациональным. Атмосфера нарастающего ужаса.''',

    '''Криминальная драма о внутреннем расследовании в полиции. Коррупция в высших эшелонах, опасная игра. Герой не знает, кому можно доверять. Моральные дилеммы, предательство союзников. Система против одиночки.''',

    '''Ретро-детектив в стиле 20-х годов. Контрабанда, подпольные казино, организованная преступность. Стильная атмосфера эпохи джаза и сухого закона. Харизматичные злодеи и роковые женщины.''',
  ];

  // Detective prompts - English
  static final List<String> _detectivePromptsEn = <String>[
    '''Film noir detective in a grim city. Corruption, crime syndicates, morally gray characters. Atmosphere of 1940s film noir. Every lead takes you into even darker alleys. Rainy streets, neon signs, danger at every turn.''',

    '''Investigation of a series of mysterious disappearances in a small town. Classic detective story with mystical elements. Each disappearance linked by strange coincidences. Locals are hiding something. The mystery has roots in the town's past.''',

    '''Detective in the style of Agatha Christie. Closed location (mansion, hotel, train), limited circle of suspects. Intellectual puzzle, logical mysteries. Everyone has motive and alibi. Solution through deduction.''',

    '''Cyberpunk detective in a future metropolis. Investigation of corporate crimes, hackers, artificial intelligence. Neon streets, augmented reality, technological noir. The line between human and machine is blurred.''',

    '''Detective with horror and supernatural elements. Investigation of a murder with ritual elements. Occult symbols, ancient curses. A rational detective faces the irrational. Atmosphere of growing dread.''',

    '''Crime drama about internal affairs investigation in the police. Corruption in high ranks, dangerous game. The hero doesn't know whom to trust. Moral dilemmas, betrayal by allies. The system against a lone wolf.''',

    '''Retro detective in 1920s style. Smuggling, underground casinos, organized crime. Stylish atmosphere of the jazz age and prohibition. Charismatic villains and femme fatales.''',
  ];

  // Sci-Fi prompts - Russian
  static final List<String> _sciFiPromptsRu = <String>[
    '''Космический триллер на заброшенной орбитальной станции. Изоляция, неисправное оборудование, загадочные происшествия. Атмосфера клаустрофобии и паранойи. Что-то пошло не так. Выживание в ограниченном пространстве.''',

    '''Первый контакт с инопланетной цивилизацией. Дипломатическая миссия, культурные различия, языковой барьер. Научно-фантастический тон в духе Лема. Попытка понимания truly alien разума. Не военный конфликт, а интеллектуальная задача.''',

    '''Постапокалипсис после восстания машин. Выжившие люди в руинах цивилизации. Партизанская война против роботов. Мрачная атмосфера безнадёжности с проблесками надежды. Поиск способа отключить центральный ИИ.''',

    '''Колонизация далёкой планеты с враждебной средой. Выживание в экстремальных условиях, адаптация к чужому миру. Конфликты среди колонистов. Планета таит опасные секреты. Элементы body horror.''',

    '''Киберпанк с корпоративными интригами. Мегакорпорации управляют миром, киборги и хакеры. Шпионаж, информационные войны. Социальное неравенство, трущобы и небоскрёбы. Восстание против системы.''',

    '''Космическая опера в духе классической НФ. Межзвёздные путешествия, дипломатия между видами, древние артефакты. Оптимистичный тон, чувство wonder. Галактическая федерация и угроза из неизведанного космоса.''',

    '''Научный триллер о запретном эксперименте. Генная инженерия, игра с основами жизни. Этические дилеммы учёных. Что-то вырвалось из-под контроля. Последствия необратимы. Атмосфера напряжения и ужаса.''',
  ];

  // Sci-Fi prompts - English
  static final List<String> _sciFiPromptsEn = <String>[
    '''Space thriller on an abandoned orbital station. Isolation, malfunctioning equipment, mysterious incidents. Atmosphere of claustrophobia and paranoia. Something went wrong. Survival in confined space.''',

    '''First contact with an alien civilization. Diplomatic mission, cultural differences, language barrier. Science fiction tone in the spirit of Lem. Attempt to understand a truly alien mind. Not military conflict, but an intellectual challenge.''',

    '''Post-apocalypse after robot uprising. Human survivors in the ruins of civilization. Guerrilla warfare against robots. Grim atmosphere of hopelessness with glimpses of hope. Search for a way to shut down the central AI.''',

    '''Colonization of a distant planet with hostile environment. Survival in extreme conditions, adaptation to an alien world. Conflicts among colonists. The planet hides dangerous secrets. Body horror elements.''',

    '''Cyberpunk with corporate intrigue. Megacorporations rule the world, cyborgs and hackers. Espionage, information warfare. Social inequality, slums and skyscrapers. Rebellion against the system.''',

    '''Space opera in the spirit of classic SF. Interstellar travel, diplomacy between species, ancient artifacts. Optimistic tone, sense of wonder. Galactic federation and threat from unknown space.''',

    '''Scientific thriller about a forbidden experiment. Genetic engineering, playing with the foundations of life. Ethical dilemmas of scientists. Something broke free from control. Consequences are irreversible. Atmosphere of tension and horror.''',
  ];
}
