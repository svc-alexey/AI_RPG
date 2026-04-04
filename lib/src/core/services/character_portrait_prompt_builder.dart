import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';

/// Ready for when `OpenAiCompatibleAiClient.generateCharacterPortrait` is implemented.
/// Not referenced from production flow until an image provider exists (see tests).
class CharacterPortraitPromptBuilder {
  const CharacterPortraitPromptBuilder();

  String build({
    required final AppLanguage language,
    required final CampaignSetting setting,
    required final String storyPrompt,
    required final CharacterProfile character,
  }) {
    final String settingLabel = switch (setting) {
      CampaignSetting.fantasy => 'fantasy',
      CampaignSetting.detective => 'detective noir',
      CampaignSetting.sciFi => 'science fiction',
    };
    final String gender = switch (character.gender) {
      CharacterGender.male => 'male',
      CharacterGender.female => 'female',
      CharacterGender.other => 'androgynous',
    };
    final String personality = character.personality.trim();
    final String fragment = character.promptFragment.trim();
    final String story = storyPrompt.trim();

    final List<String> details = <String>[
      '${character.name}, a $gender ${character.race} ${character.characterClass.name}',
      'cinematic character portrait',
      '$settingLabel atmosphere',
      'head and shoulders composition',
      'high detail digital illustration',
    ];

    if (personality.isNotEmpty) {
      details.add('personality: $personality');
    }
    if (fragment.isNotEmpty) {
      details.add('character details: $fragment');
    }
    if (story.isNotEmpty) {
      details.add('story context: $story');
    }

    final String basePrompt = details.join(', ');
    return switch (language) {
      AppLanguage.ru =>
        '$basePrompt, expressive lighting, no text, no watermark',
      AppLanguage.en =>
        '$basePrompt, expressive lighting, no text, no watermark',
    };
  }
}
