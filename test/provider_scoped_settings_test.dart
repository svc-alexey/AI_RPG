import 'dart:io';

import 'package:ai_prg/src/core/data/isar/app_database.dart';
import 'package:ai_prg/src/core/models/ai_settings.dart';
import 'package:ai_prg/src/core/repositories/settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Provider-scoped AI settings', () {
    test('OpenRouter -> DeepSeek -> back: both profiles stay intact', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final _TestSettingsStorage storage = _TestSettingsStorage.create();
      addTearDown(storage.dispose);

      final SettingsRepository repo = storage.repository;

      final ProviderScopedSettings initial = await repo
          .loadProviderScopedSettings();
      expect(initial.activeProvider, AiProviderType.lmStudio);

      final ProviderScopedSettings openRouter = initial.copyWith(
        activeProvider: AiProviderType.openRouter,
        profiles: Map<AiProviderType, ProviderProfile>.from(initial.profiles)
          ..[AiProviderType.openRouter] = const ProviderProfile(
            baseUrl: 'https://openrouter.ai/api/v1',
            model: 'anthropic/claude-3',
            apiKey: 'openrouter-key-123',
            timeoutSeconds: 120,
            runtimeSettings: ModelRuntimeSettings(
              maxResponseTokens: 320,
              contextWindowSize: 2048,
              profile: ModelRuntimeProfile.custom,
            ),
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
            runtimeSettings: ModelRuntimeSettings.smartPreset,
          ),
      );
      await repo.saveProviderScopedSettings(deepSeek);

      final ProviderScopedSettings backToOpenRouter = deepSeek.copyWith(
        activeProvider: AiProviderType.openRouter,
      );
      await repo.saveProviderScopedSettings(backToOpenRouter);

      final ProviderScopedSettings loaded = await repo
          .loadProviderScopedSettings();

      expect(loaded.activeProvider, AiProviderType.openRouter);

      final ProviderProfile openRouterProfile = loaded.profileFor(
        AiProviderType.openRouter,
      );
      expect(openRouterProfile.baseUrl, 'https://openrouter.ai/api/v1');
      expect(openRouterProfile.model, 'anthropic/claude-3');
      expect(openRouterProfile.apiKey, 'openrouter-key-123');
      expect(openRouterProfile.timeoutSeconds, 120);
      expect(openRouterProfile.runtimeSettings.maxResponseTokens, 320);
      expect(openRouterProfile.runtimeSettings.contextWindowSize, 2048);
      expect(
        openRouterProfile.runtimeSettings.profile,
        ModelRuntimeProfile.custom,
      );

      final ProviderProfile deepSeekProfile = loaded.profileFor(
        AiProviderType.deepSeek,
      );
      expect(deepSeekProfile.baseUrl, 'https://api.deepseek.com/v1');
      expect(deepSeekProfile.model, 'deepseek-chat');
      expect(deepSeekProfile.apiKey, 'deepseek-key-456');
      expect(deepSeekProfile.timeoutSeconds, 90);
      expect(
        deepSeekProfile.runtimeSettings.profile,
        ModelRuntimeProfile.smart,
      );
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

      final ProviderScopedSettings migrated = ProviderScopedSettings.fromJson(
        legacy,
      );

      expect(migrated.activeProvider, AiProviderType.openRouter);
      expect(migrated.fastResponses, false);

      final ProviderProfile openRouterProfile = migrated.profileFor(
        AiProviderType.openRouter,
      );
      expect(openRouterProfile.baseUrl, 'https://openrouter.ai/api/v1');
      expect(openRouterProfile.model, 'old-model');
      expect(openRouterProfile.apiKey, 'legacy-key');
      expect(openRouterProfile.timeoutSeconds, 90);
      expect(
        openRouterProfile.runtimeSettings.profile,
        ModelRuntimeSettings.defaultsFor(AiProviderType.openRouter).profile,
      );

      final ProviderProfile lmProfile = migrated.profileFor(
        AiProviderType.lmStudio,
      );
      expect(
        lmProfile.baseUrl,
        AiSettings.defaultBaseUrlFor(AiProviderType.lmStudio),
      );
      expect(lmProfile.model, '');
    });
  });
}

class _TestSettingsStorage {
  _TestSettingsStorage._(this.directory, this.database, this.repository);

  factory _TestSettingsStorage.create() {
    final Directory directory = Directory.systemTemp.createTempSync(
      'ai_prg_settings_test_',
    );
    final AppDatabase database = AppDatabase(
      directoryPath: directory.path,
      name: 'settings_${DateTime.now().microsecondsSinceEpoch}',
    );
    final SettingsRepository repository = SettingsRepository(
      database: database,
    );
    return _TestSettingsStorage._(directory, database, repository);
  }

  final Directory directory;
  final AppDatabase database;
  final SettingsRepository repository;

  Future<void> dispose() async {
    await database.close(deleteFromDisk: true);
    if (directory.existsSync()) {
      directory.deleteSync(recursive: true);
    }
  }
}
