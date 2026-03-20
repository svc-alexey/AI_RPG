import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:ai_prg/src/core/services/random_story_prompt_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RandomStoryPromptGenerator', () {
    const RandomStoryPromptGenerator generator = RandomStoryPromptGenerator();

    test('Генерирует непустой промпт для fantasy на русском', () {
      final String prompt = generator.generateForSetting(
        setting: CampaignSetting.fantasy,
        language: AppLanguage.ru,
      );
      
      expect(prompt, isNotEmpty);
      expect(prompt.length, greaterThan(50));
    });

    test('Генерирует непустой промпт для detective на русском', () {
      final String prompt = generator.generateForSetting(
        setting: CampaignSetting.detective,
        language: AppLanguage.ru,
      );
      
      expect(prompt, isNotEmpty);
      expect(prompt.length, greaterThan(50));
    });

    test('Генерирует непустой промпт для sciFi на русском', () {
      final String prompt = generator.generateForSetting(
        setting: CampaignSetting.sciFi,
        language: AppLanguage.ru,
      );
      
      expect(prompt, isNotEmpty);
      expect(prompt.length, greaterThan(50));
    });

    test('Генерирует непустой промпт для fantasy на английском', () {
      final String prompt = generator.generateForSetting(
        setting: CampaignSetting.fantasy,
        language: AppLanguage.en,
      );
      
      expect(prompt, isNotEmpty);
      expect(prompt.length, greaterThan(50));
    });

    test('Генерирует разные промпты при повторных вызовах', () {
      final Set<String> prompts = <String>{};
      
      for (int i = 0; i < 20; i++) {
        final String prompt = generator.generateForSetting(
          setting: CampaignSetting.fantasy,
          language: AppLanguage.ru,
        );
        prompts.add(prompt);
      }
      
      // Должно быть минимум 3 разных промпта из 20 попыток
      expect(prompts.length, greaterThanOrEqualTo(3));
    });

    test('Все сеттинги и языки поддерживаются', () {
      for (final CampaignSetting setting in CampaignSetting.values) {
        for (final AppLanguage language in AppLanguage.values) {
          final String prompt = generator.generateForSetting(
            setting: setting,
            language: language,
          );
          
          expect(prompt, isNotEmpty, 
            reason: 'Промпт для $setting на $language пустой');
        }
      }
    });
  });
}
