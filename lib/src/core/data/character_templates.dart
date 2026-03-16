import 'package:ai_prg/src/core/models/campaign_models.dart';

/// Character classes available per setting.
const Map<CampaignSetting, List<CharacterClass>> classesBySetting = <CampaignSetting, List<CharacterClass>>{
  CampaignSetting.fantasy: <CharacterClass>[
    CharacterClass.warrior,
    CharacterClass.mage,
    CharacterClass.rogue,
  ],
  CampaignSetting.detective: <CharacterClass>[
    CharacterClass.detective,
    CharacterClass.journalist,
    CharacterClass.smuggler,
  ],
  CampaignSetting.sciFi: <CharacterClass>[
    CharacterClass.engineer,
    CharacterClass.pilot,
    CharacterClass.medic,
  ],
};

/// Races per setting. Keys are internal IDs; labels come from localization.
const Map<CampaignSetting, List<String>> racesBySetting = <CampaignSetting, List<String>>{
  CampaignSetting.fantasy: <String>['human', 'elf', 'dwarf', 'orc'],
  CampaignSetting.detective: <String>['human', 'outsider', 'local'],
  CampaignSetting.sciFi: <String>['human', 'android', 'alien', 'augmented'],
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
