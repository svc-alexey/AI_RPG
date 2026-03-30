import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:ai_prg/src/core/services/story_prompt_enricher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const StoryPromptEnricher enricher = StoryPromptEnricher();

  test('expands short russian detective wish into vivid prompt', () {
    final GeneratedPrompts result = enricher.expand(
      storyWish: 'Мрачный детектив',
      setting: CampaignSetting.detective,
      language: AppLanguage.ru,
    );

    expect(result.storyPrompt, contains('Мрачный детектив'));
    expect(result.storyPrompt.length, greaterThan(80));
    expect(result.characterPrompt, isNotEmpty);
  });

  test('returns empty prompts for empty wish', () {
    final GeneratedPrompts result = enricher.expand(
      storyWish: '   ',
      setting: CampaignSetting.fantasy,
      language: AppLanguage.ru,
    );

    expect(result.storyPrompt, isEmpty);
    expect(result.characterPrompt, isEmpty);
  });
}
