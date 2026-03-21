import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:ai_prg/src/core/services/character_portrait_prompt_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'CharacterPortraitPromptBuilder includes story and character details',
    () {
      const CharacterPortraitPromptBuilder builder =
          CharacterPortraitPromptBuilder();

      final String prompt = builder.build(
        language: AppLanguage.en,
        setting: CampaignSetting.detective,
        storyPrompt: 'A stormbound city mystery with occult undertones.',
        character: const CharacterProfile(
          name: 'Iris',
          gender: CharacterGender.female,
          race: 'human',
          characterClass: CharacterClass.detective,
          skills: <String>[],
          personality: 'calm, observant, relentless',
          perks: <String>[],
          promptFragment: 'long dark coat, sharp gaze',
        ),
      );

      expect(prompt, contains('stormbound city mystery'));
      expect(prompt, contains('Iris'));
      expect(prompt, contains('detective'));
      expect(prompt, contains('long dark coat'));
      expect(prompt, contains('observant'));
    },
  );
}
