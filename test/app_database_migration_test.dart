import 'dart:convert';
import 'dart:io';

import 'package:ai_prg/src/core/data/isar/app_database.dart';
import 'package:ai_prg/src/core/models/ai_settings.dart';
import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:ai_prg/src/core/repositories/campaign_repository.dart';
import 'package:ai_prg/src/core/repositories/settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'Legacy SharedPreferences migrate on bootstrap without nested txns',
    () async {
      final CampaignState legacyCampaign = CampaignState(
        id: 'legacy-campaign',
        schemaVersion: 1,
        title: 'Legacy Trail',
        setting: CampaignSetting.fantasy,
        mode: StoryMode.longCampaign,
        difficulty: DifficultyLevel.medium,
        character: const CharacterStats(
          name: 'Arin',
          hp: 10,
          maxHp: 12,
          energy: 7,
          maxEnergy: 8,
          might: 3,
          wit: 2,
          spirit: 2,
        ),
        location: 'Old Road',
        objective: 'Reach the watchtower',
        turnNumber: 2,
        memory: const CampaignMemory(
          rollingSummary: 'A storm is gathering.',
          activeGoal: 'Reach the watchtower',
          activeSituation: 'The path is muddy and quiet.',
          recentTurns: <RecentTurnSummary>[],
        ),
        modules: const <CampaignModuleState>[
          CampaignModuleState(
            module: CampaignModule.notes,
            isActive: true,
            activationReason: 'Legacy note log',
          ),
        ],
        inventory: const <String>['Lantern'],
        companions: const <CampaignCompanion>[],
        notes: const <String>['Look for shelter'],
        resources: const <CampaignResource>[],
        progression: null,
        messages: <ChatMessage>[
          ChatMessage(
            id: 'm1',
            role: ChatRole.narrator,
            text: 'Thunder rolls over the hills.',
            createdAt: DateTime(2026, 3, 20, 12),
          ),
        ],
        choices: const <String>['Keep moving', 'Set camp'],
        updatedAt: DateTime(2026, 3, 20, 12, 15),
      );
      final ProviderScopedSettings legacySettings =
          ProviderScopedSettings(
            activeProvider: AiProviderType.openRouter,
            profiles: <AiProviderType, ProviderProfile>{
              for (final AiProviderType provider in AiProviderType.values)
                provider: ProviderProfile.defaultsFor(provider),
            },
            fastResponses: false,
          ).copyWith(
            profiles: <AiProviderType, ProviderProfile>{
              for (final AiProviderType provider in AiProviderType.values)
                provider: provider == AiProviderType.openRouter
                    ? const ProviderProfile(
                        baseUrl: 'https://openrouter.ai/api/v1',
                        model: 'openai/gpt-4.1-mini',
                        apiKey: 'legacy-key',
                        timeoutSeconds: 90,
                        runtimeSettings: ModelRuntimeSettings(
                          maxResponseTokens: 400,
                          contextWindowSize: 4096,
                          profile: ModelRuntimeProfile.custom,
                        ),
                      )
                    : ProviderProfile.defaultsFor(provider),
            },
          );

      SharedPreferences.setMockInitialValues(<String, Object>{
        'campaign.ids': <String>[legacyCampaign.id],
        'campaign.${legacyCampaign.id}': jsonEncode(legacyCampaign.toJson()),
        'settings.ai': jsonEncode(legacySettings.toJson()),
        'settings.app_language': AppLanguage.en.code,
      });

      final _TestStorageBundle storage = _TestStorageBundle.create();
      addTearDown(storage.dispose);

      await storage.database.ensureReady();

      final List<CampaignState> campaigns = await storage.campaignRepository
          .loadAllCampaigns();
      final ProviderScopedSettings migratedSettings = await storage
          .settingsRepository
          .loadProviderScopedSettings();
      final AppLanguage language = await storage.settingsRepository
          .loadAppLanguage();

      expect(campaigns, hasLength(1));
      expect(campaigns.single.id, legacyCampaign.id);
      expect(campaigns.single.title, legacyCampaign.title);
      expect(migratedSettings.activeProvider, AiProviderType.openRouter);
      expect(
        migratedSettings.profileFor(AiProviderType.openRouter).model,
        'openai/gpt-4.1-mini',
      );
      expect(migratedSettings.fastResponses, isFalse);
      expect(language, AppLanguage.en);
    },
  );
}

class _TestStorageBundle {
  _TestStorageBundle._(
    this.directory,
    this.database,
    this.settingsRepository,
    this.campaignRepository,
  );

  factory _TestStorageBundle.create() {
    final Directory directory = Directory.systemTemp.createTempSync(
      'ai_prg_migration_test_',
    );
    final AppDatabase database = AppDatabase(
      directoryPath: directory.path,
      name: 'migration_${DateTime.now().microsecondsSinceEpoch}',
    );
    return _TestStorageBundle._(
      directory,
      database,
      SettingsRepository(database: database),
      CampaignRepository(database: database),
    );
  }

  final Directory directory;
  final AppDatabase database;
  final SettingsRepository settingsRepository;
  final CampaignRepository campaignRepository;

  Future<void> dispose() async {
    await database.close(deleteFromDisk: true);
    if (directory.existsSync()) {
      directory.deleteSync(recursive: true);
    }
  }
}
