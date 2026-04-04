import 'package:ai_prg/src/core/models/campaign_models.dart';

/// Character classes available per world setting (grouped by vibe).
/// Empty list = no class step in new-game wizard (profile uses [CharacterClass.unspecified]).
const Map<CampaignSetting, List<CharacterClass>> classesBySetting =
    <CampaignSetting, List<CharacterClass>>{
      CampaignSetting.romantasy: <CharacterClass>[],
      CampaignSetting.cozyFantasy: <CharacterClass>[],
      CampaignSetting.darkAcademia: <CharacterClass>[],
      CampaignSetting.grimdarkFantasy: <CharacterClass>[
        CharacterClass.warrior,
        CharacterClass.mage,
        CharacterClass.rogue,
      ],
      CampaignSetting.litRpgProgression: <CharacterClass>[
        CharacterClass.warrior,
        CharacterClass.mage,
        CharacterClass.rogue,
      ],
      CampaignSetting.horrorWeird: <CharacterClass>[],
      CampaignSetting.altHistorySecret: <CharacterClass>[],
      CampaignSetting.cozyCrime: <CharacterClass>[
        CharacterClass.detective,
        CharacterClass.journalist,
        CharacterClass.smuggler,
      ],
      CampaignSetting.postApocalypse: <CharacterClass>[
        CharacterClass.engineer,
        CharacterClass.pilot,
        CharacterClass.medic,
      ],
      CampaignSetting.nearFutureSciFi: <CharacterClass>[
        CharacterClass.engineer,
        CharacterClass.pilot,
        CharacterClass.medic,
      ],
    };

/// New-game wizard shows a class dropdown only when the setting defines classes.
bool settingUsesCharacterClass(final CampaignSetting setting) =>
    classesBySetting[setting]!.isNotEmpty;

/// Races per setting. Keys are internal IDs; labels come from localization.
const Map<CampaignSetting, List<String>> racesBySetting =
    <CampaignSetting, List<String>>{
      CampaignSetting.romantasy: <String>['human', 'elf', 'dwarf', 'orc'],
      CampaignSetting.cozyFantasy: <String>['human', 'elf', 'dwarf', 'orc'],
      CampaignSetting.darkAcademia: <String>['human', 'elf', 'dwarf', 'orc'],
      CampaignSetting.grimdarkFantasy: <String>[
        'human',
        'elf',
        'dwarf',
        'orc',
      ],
      CampaignSetting.litRpgProgression: <String>[
        'human',
        'elf',
        'dwarf',
        'orc',
      ],
      CampaignSetting.horrorWeird: <String>['human', 'outsider', 'local'],
      CampaignSetting.altHistorySecret: <String>['human', 'outsider', 'local'],
      CampaignSetting.cozyCrime: <String>['human', 'outsider', 'local'],
      CampaignSetting.postApocalypse: <String>[
        'human',
        'android',
        'alien',
        'augmented',
      ],
      CampaignSetting.nearFutureSciFi: <String>[
        'human',
        'android',
        'alien',
        'augmented',
      ],
    };

/// Personality templates for random generation. Keys are internal IDs.
const List<String> personalityTemplates = <String>[
  'cautious',
  'bold',
  'sarcastic',
  'empathetic',
  'calculating',
  'impulsive',
  'stoic',
  'curious',
];
