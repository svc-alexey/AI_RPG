import 'package:ai_prg/src/core/models/ai_settings.dart';
import 'package:ai_prg/src/core/repositories/settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Provider-scoped AI settings', () {
    test('OpenRouter -> DeepSeek -> back: both profiles stay intact', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});

      final SettingsRepository repo = SettingsRepository();

      final ProviderScopedSettings initial = await repo.loadProviderScopedSettings();
      expect(initial.activeProvider, AiProviderType.lmStudio);

      final ProviderScopedSettings openRouter = initial.copyWith(
        activeProvider: AiProviderType.openRouter,
        profiles: Map<AiProviderType, ProviderProfile>.from(initial.profiles)
          ..[AiProviderType.openRouter] = const ProviderProfile(
            baseUrl: 'https://openrouter.ai/api/v1',
            model: 'anthropic/claude-3',
            apiKey: 'openrouter-key-123',
            timeoutSeconds: 120,
          ),
      );
      await repo.saveProviderScopedSettings(openRouter);

      final ProviderScopedSettings deepSeek = openRouter.copyWith(
        activeProvider: AiProviderType.deepSeek,
        profiles: Map<AiProviderType, ProviderProfile>.from(openRouter.profiles)
          ..[AiProviderType.deepSeek] = const ProviderProfile(
            baseUrl: 'https://api.deepseek.com/v1',
            model: 'deepseek-chat',
            apiKey: 'deepseek-key-456',
            timeoutSeconds: 90,
          ),
      );
      await repo.saveProviderScopedSettings(deepSeek);

      final ProviderScopedSettings backToOpenRouter = deepSeek.copyWith(
        activeProvider: AiProviderType.openRouter,
      );
      await repo.saveProviderScopedSettings(backToOpenRouter);

      final ProviderScopedSettings loaded = await repo.loadProviderScopedSettings();

      expect(loaded.activeProvider, AiProviderType.openRouter);

      final ProviderProfile openRouterProfile =
          loaded.profileFor(AiProviderType.openRouter);
      expect(openRouterProfile.baseUrl, 'https://openrouter.ai/api/v1');
      expect(openRouterProfile.model, 'anthropic/claude-3');
      expect(openRouterProfile.apiKey, 'openrouter-key-123');
      expect(openRouterProfile.timeoutSeconds, 120);

      final ProviderProfile deepSeekProfile =
          loaded.profileFor(AiProviderType.deepSeek);
      expect(deepSeekProfile.baseUrl, 'https://api.deepseek.com/v1');
      expect(deepSeekProfile.model, 'deepseek-chat');
      expect(deepSeekProfile.apiKey, 'deepseek-key-456');
      expect(deepSeekProfile.timeoutSeconds, 90);
    });

    test('Legacy JSON migrates to provider-scoped format', () async {
      final Map<String, Object?> legacy = <String, Object?>{
        'provider': 'openRouter',
        'baseUrl': 'https://openrouter.ai/api/v1',
        'model': 'old-model',
        'apiKey': 'legacy-key',
        'timeoutSeconds': 90,
        'fastResponses': false,
      };

      final ProviderScopedSettings migrated =
          ProviderScopedSettings.fromJson(legacy);

      expect(migrated.activeProvider, AiProviderType.openRouter);
      expect(migrated.fastResponses, false);

      final ProviderProfile openRouterProfile =
          migrated.profileFor(AiProviderType.openRouter);
      expect(openRouterProfile.baseUrl, 'https://openrouter.ai/api/v1');
      expect(openRouterProfile.model, 'old-model');
      expect(openRouterProfile.apiKey, 'legacy-key');
      expect(openRouterProfile.timeoutSeconds, 90);

      final ProviderProfile lmProfile =
          migrated.profileFor(AiProviderType.lmStudio);
      expect(lmProfile.baseUrl, AiSettings.defaultBaseUrlFor(AiProviderType.lmStudio));
      expect(lmProfile.model, '');
    });
  });
}
