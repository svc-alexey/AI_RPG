import 'dart:math';

import 'package:ai_prg/src/core/data/character_templates.dart';
import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';

/// Builds character prompt fragments for AI context.
class CharacterPromptBuilder {
  const CharacterPromptBuilder();

  static final Random _random = Random();

  /// Builds a prompt fragment from `CharacterProfile`.
  /// If `profile.promptFragment` is non-empty, returns it.
  /// Otherwise generates from profile fields.
  String buildPrompt({
    required final CharacterProfile profile,
    required final CampaignSetting setting,
    required final AppLanguage language,
  }) {
    if (profile.promptFragment.trim().isNotEmpty) {
      return profile.promptFragment.trim();
    }

    final List<String> parts = <String>[];

    if (profile.name.isNotEmpty) {
      parts.add(_label('name', language) + profile.name);
    }
    if (profile.race.isNotEmpty) {
      final String raceLabel = _raceLabel(profile.race, setting, language);
      parts.add(_label('race', language) + raceLabel);
    }
    parts.addAll(<String>[
      _label('class', language) + _classLabel(profile.characterClass, language),
      _label('gender', language) + _genderLabel(profile.gender, language),
    ]);
    if (profile.personality.isNotEmpty) {
      parts.add(_label('personality', language) + profile.personality);
    }
    if (profile.skills.isNotEmpty) {
      parts.add(_label('skills', language) + profile.skills.join(', '));
    }
    if (profile.perks.isNotEmpty) {
      parts.add(_label('perks', language) + profile.perks.join(', '));
    }

    return parts.join('. ');
  }

  String _label(final String key, final AppLanguage language) =>
      switch ((key, language)) {
        ('name', AppLanguage.ru) => 'Персонаж: ',
        ('name', AppLanguage.en) => 'Character: ',
        ('race', AppLanguage.ru) => 'Раса: ',
        ('race', AppLanguage.en) => 'Race: ',
        ('class', AppLanguage.ru) => 'Класс: ',
        ('class', AppLanguage.en) => 'Class: ',
        ('gender', AppLanguage.ru) => 'Пол: ',
        ('gender', AppLanguage.en) => 'Gender: ',
        ('personality', AppLanguage.ru) => 'Характер: ',
        ('personality', AppLanguage.en) => 'Personality: ',
        ('skills', AppLanguage.ru) => 'Навыки: ',
        ('skills', AppLanguage.en) => 'Skills: ',
        ('perks', AppLanguage.ru) => 'Особенности: ',
        ('perks', AppLanguage.en) => 'Perks: ',
        _ => '',
      };

  String _classLabel(final CharacterClass c, final AppLanguage language) =>
      switch ((c, language)) {
        (CharacterClass.warrior, AppLanguage.ru) => 'воин',
        (CharacterClass.warrior, AppLanguage.en) => 'warrior',
        (CharacterClass.mage, AppLanguage.ru) => 'маг',
        (CharacterClass.mage, AppLanguage.en) => 'mage',
        (CharacterClass.rogue, AppLanguage.ru) => 'плут',
        (CharacterClass.rogue, AppLanguage.en) => 'rogue',
        (CharacterClass.detective, AppLanguage.ru) => 'детектив',
        (CharacterClass.detective, AppLanguage.en) => 'detective',
        (CharacterClass.journalist, AppLanguage.ru) => 'журналист',
        (CharacterClass.journalist, AppLanguage.en) => 'journalist',
        (CharacterClass.smuggler, AppLanguage.ru) => 'контрабандист',
        (CharacterClass.smuggler, AppLanguage.en) => 'smuggler',
        (CharacterClass.engineer, AppLanguage.ru) => 'инженер',
        (CharacterClass.engineer, AppLanguage.en) => 'engineer',
        (CharacterClass.pilot, AppLanguage.ru) => 'пилот',
        (CharacterClass.pilot, AppLanguage.en) => 'pilot',
        (CharacterClass.medic, AppLanguage.ru) => 'медик',
        (CharacterClass.medic, AppLanguage.en) => 'medic',
      };

  String _genderLabel(final CharacterGender g, final AppLanguage language) =>
      switch ((g, language)) {
        (CharacterGender.male, AppLanguage.ru) => 'мужской',
        (CharacterGender.male, AppLanguage.en) => 'male',
        (CharacterGender.female, AppLanguage.ru) => 'женский',
        (CharacterGender.female, AppLanguage.en) => 'female',
        (CharacterGender.other, AppLanguage.ru) => 'другой',
        (CharacterGender.other, AppLanguage.en) => 'other',
      };

  String _raceLabel(
    final String raceId,
    final CampaignSetting setting,
    final AppLanguage language,
  ) => switch ((raceId, setting, language)) {
    ('human', _, AppLanguage.ru) => 'человек',
    ('human', _, AppLanguage.en) => 'human',
    ('elf', _, AppLanguage.ru) => 'эльф',
    ('elf', _, AppLanguage.en) => 'elf',
    ('dwarf', _, AppLanguage.ru) => 'дварф',
    ('dwarf', _, AppLanguage.en) => 'dwarf',
    ('orc', _, AppLanguage.ru) => 'орк',
    ('orc', _, AppLanguage.en) => 'orc',
    ('outsider', _, AppLanguage.ru) => 'приезжий',
    ('outsider', _, AppLanguage.en) => 'outsider',
    ('local', _, AppLanguage.ru) => 'местный',
    ('local', _, AppLanguage.en) => 'local',
    ('android', _, AppLanguage.ru) => 'андроид',
    ('android', _, AppLanguage.en) => 'android',
    ('alien', _, AppLanguage.ru) => 'инопланетянин',
    ('alien', _, AppLanguage.en) => 'alien',
    ('augmented', _, AppLanguage.ru) => 'аугментированный',
    ('augmented', _, AppLanguage.en) => 'augmented',
    _ => raceId,
  };

  String _personalityLabel(final String id, final AppLanguage language) =>
      switch ((id, language)) {
        ('cautious', AppLanguage.ru) => 'осторожный',
        ('cautious', AppLanguage.en) => 'cautious',
        ('bold', AppLanguage.ru) => 'смелый',
        ('bold', AppLanguage.en) => 'bold',
        ('sarcastic', AppLanguage.ru) => 'саркастичный',
        ('sarcastic', AppLanguage.en) => 'sarcastic',
        ('empathetic', AppLanguage.ru) => 'эмпатичный',
        ('empathetic', AppLanguage.en) => 'empathetic',
        ('calculating', AppLanguage.ru) => 'расчётливый',
        ('calculating', AppLanguage.en) => 'calculating',
        ('impulsive', AppLanguage.ru) => 'импульсивный',
        ('impulsive', AppLanguage.en) => 'impulsive',
        ('stoic', AppLanguage.ru) => 'стоик',
        ('stoic', AppLanguage.en) => 'stoic',
        ('curious', AppLanguage.ru) => 'любопытный',
        ('curious', AppLanguage.en) => 'curious',
        _ => id,
      };

  /// Generates a random CharacterProfile for the given setting.
  CharacterProfile randomProfile({
    required final CampaignSetting setting,
    required final AppLanguage language,
    required final String baseName,
  }) {
    final List<CharacterClass> classes =
        classesBySetting[setting] ?? <CharacterClass>[CharacterClass.warrior];
    final List<String> races = racesBySetting[setting] ?? <String>['human'];
    final CharacterClass charClass = classes[_random.nextInt(classes.length)];
    final String raceId = races[_random.nextInt(races.length)];
    final CharacterGender gender =
        CharacterGender.values[_random.nextInt(CharacterGender.values.length)];
    final String personalityId =
        personalityTemplates[_random.nextInt(personalityTemplates.length)];

    final String personalityLabel = _personalityLabel(personalityId, language);
    final String classLabel = _classLabel(charClass, language);

    final List<String> defaultSkills = _defaultSkillsForClass(
      charClass,
      language,
    );
    final List<String> defaultPerks = _defaultPerksForClass(
      charClass,
      setting,
      language,
    );

    final String promptFragment = _buildRandomPromptFragment(
      name: baseName.isEmpty ? _defaultName(language) : baseName,
      race: _raceLabel(raceId, setting, language),
      characterClass: classLabel,
      gender: _genderLabel(gender, language),
      personality: personalityLabel,
      skills: defaultSkills,
      perks: defaultPerks,
      language: language,
    );

    return CharacterProfile(
      name: baseName.isEmpty ? _defaultName(language) : baseName,
      gender: gender,
      race: raceId,
      characterClass: charClass,
      skills: defaultSkills,
      personality: personalityLabel,
      perks: defaultPerks,
      promptFragment: promptFragment,
    );
  }

  String _defaultName(final AppLanguage language) => switch (language) {
    AppLanguage.ru => 'Странник',
    AppLanguage.en => 'Wayfarer',
  };

  List<String> _defaultSkillsForClass(
    final CharacterClass c,
    final AppLanguage language,
  ) => switch ((c, language)) {
    (CharacterClass.warrior, AppLanguage.ru) => <String>[
      'Ближний бой',
      'Выносливость',
    ],
    (CharacterClass.warrior, AppLanguage.en) => <String>[
      'Melee combat',
      'Endurance',
    ],
    (CharacterClass.mage, AppLanguage.ru) => <String>['Магия', 'Анализ'],
    (CharacterClass.mage, AppLanguage.en) => <String>['Magic', 'Analysis'],
    (CharacterClass.rogue, AppLanguage.ru) => <String>['Скрытность', 'Взлом'],
    (CharacterClass.rogue, AppLanguage.en) => <String>[
      'Stealth',
      'Lockpicking',
    ],
    (CharacterClass.detective, AppLanguage.ru) => <String>[
      'Дедукция',
      'Наблюдательность',
    ],
    (CharacterClass.detective, AppLanguage.en) => <String>[
      'Deduction',
      'Observation',
    ],
    (CharacterClass.journalist, AppLanguage.ru) => <String>[
      'Интервью',
      'Расследование',
    ],
    (CharacterClass.journalist, AppLanguage.en) => <String>[
      'Interview',
      'Investigation',
    ],
    (CharacterClass.smuggler, AppLanguage.ru) => <String>['Контакты', 'Обход'],
    (CharacterClass.smuggler, AppLanguage.en) => <String>['Contacts', 'Bypass'],
    (CharacterClass.engineer, AppLanguage.ru) => <String>[
      'Ремонт',
      'Хакерство',
    ],
    (CharacterClass.engineer, AppLanguage.en) => <String>['Repair', 'Hacking'],
    (CharacterClass.pilot, AppLanguage.ru) => <String>[
      'Пилотирование',
      'Навигация',
    ],
    (CharacterClass.pilot, AppLanguage.en) => <String>[
      'Piloting',
      'Navigation',
    ],
    (CharacterClass.medic, AppLanguage.ru) => <String>[
      'Медицина',
      'Диагностика',
    ],
    (CharacterClass.medic, AppLanguage.en) => <String>[
      'Medicine',
      'Diagnostics',
    ],
  };

  List<String> _defaultPerksForClass(
    final CharacterClass c,
    final CampaignSetting setting,
    final AppLanguage language,
  ) => switch ((c, setting, language)) {
    (CharacterClass.warrior, CampaignSetting.fantasy, AppLanguage.ru) =>
      <String>['Закалённый щит'],
    (CharacterClass.warrior, CampaignSetting.fantasy, AppLanguage.en) =>
      <String>['Tempered shield'],
    (CharacterClass.mage, CampaignSetting.fantasy, AppLanguage.ru) => <String>[
      'Кристалл фокуса',
    ],
    (CharacterClass.mage, CampaignSetting.fantasy, AppLanguage.en) => <String>[
      'Focus crystal',
    ],
    (CharacterClass.rogue, CampaignSetting.fantasy, AppLanguage.ru) => <String>[
      'Набор отмычек',
    ],
    (CharacterClass.rogue, CampaignSetting.fantasy, AppLanguage.en) => <String>[
      'Lockpick set',
    ],
    (CharacterClass.detective, CampaignSetting.detective, AppLanguage.ru) =>
      <String>['Блокнот'],
    (CharacterClass.detective, CampaignSetting.detective, AppLanguage.en) =>
      <String>['Notebook'],
    (CharacterClass.journalist, CampaignSetting.detective, AppLanguage.ru) =>
      <String>['Диктофон'],
    (CharacterClass.journalist, CampaignSetting.detective, AppLanguage.en) =>
      <String>['Recorder'],
    (CharacterClass.smuggler, CampaignSetting.detective, AppLanguage.ru) =>
      <String>['Фальшивые документы'],
    (CharacterClass.smuggler, CampaignSetting.detective, AppLanguage.en) =>
      <String>['Fake papers'],
    (CharacterClass.engineer, CampaignSetting.sciFi, AppLanguage.ru) =>
      <String>['Мультитул'],
    (CharacterClass.engineer, CampaignSetting.sciFi, AppLanguage.en) =>
      <String>['Multitool'],
    (CharacterClass.pilot, CampaignSetting.sciFi, AppLanguage.ru) => <String>[
      'Навигационный чип',
    ],
    (CharacterClass.pilot, CampaignSetting.sciFi, AppLanguage.en) => <String>[
      'Nav chip',
    ],
    (CharacterClass.medic, CampaignSetting.sciFi, AppLanguage.ru) => <String>[
      'Медпакет',
    ],
    (CharacterClass.medic, CampaignSetting.sciFi, AppLanguage.en) => <String>[
      'Medkit',
    ],
    _ => <String>[],
  };

  String _buildRandomPromptFragment({
    required final String name,
    required final String race,
    required final String characterClass,
    required final String gender,
    required final String personality,
    required final List<String> skills,
    required final List<String> perks,
    required final AppLanguage language,
  }) {
    final List<String> parts = <String>[
      '$name, $race $characterClass',
      _label('gender', language) + gender,
      _label('personality', language) + personality,
    ];
    if (skills.isNotEmpty) {
      parts.add(_label('skills', language) + skills.join(', '));
    }
    if (perks.isNotEmpty) {
      parts.add(_label('perks', language) + perks.join(', '));
    }
    return parts.join('. ');
  }
}
