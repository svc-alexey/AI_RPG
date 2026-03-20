import 'dart:convert';
import 'dart:io';

import 'package:ai_prg/src/app/app.dart';
import 'package:ai_prg/src/app/app_localizations.dart';
import 'package:ai_prg/src/app/app_providers.dart';
import 'package:ai_prg/src/core/data/isar/app_database.dart';
import 'package:ai_prg/src/core/models/ai_settings.dart';
import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:ai_prg/src/core/repositories/campaign_repository.dart';
import 'package:ai_prg/src/core/repositories/settings_repository.dart';
import 'package:ai_prg/src/core/services/ai_client.dart';
import 'package:ai_prg/src/core/services/ai_service_factory.dart';
import 'package:ai_prg/src/core/services/game_engine.dart';
import 'package:ai_prg/src/features/chat/presentation/chat_screen.dart';
import 'package:ai_prg/src/features/home/presentation/home_screen.dart';
import 'package:ai_prg/src/features/new_game/presentation/new_game_screen.dart';
import 'package:ai_prg/src/features/saves/presentation/saves_screen.dart';
import 'package:ai_prg/src/features/settings/presentation/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const AppLocalizations english = AppLocalizations(AppLanguage.en);

  testWidgets('App opens on the home screen', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final _TestStorageBundle storage = _TestStorageBundle.create();
    addTearDown(storage.dispose);

    await tester.pumpWidget(
      AiRpgApp(
        database: storage.database,
        settingsRepository: storage.settingsRepository,
        campaignRepository: storage.campaignRepository,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('AETHERIS'), findsOneWidget);
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('Home screen shows saves entry point', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final _TestStorageBundle storage = _TestStorageBundle.create();
    addTearDown(storage.dispose);

    await tester.pumpWidget(
      _buildScopedApp(
        const HomeScreen(),
        storage: storage,
        language: AppLanguage.en,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(english.saves), findsWidgets);
  });

  testWidgets('New campaign opens gameplay chat', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final _TestStorageBundle storage = _TestStorageBundle.create();
    addTearDown(storage.dispose);

    await tester.binding.setSurfaceSize(const Size(1200, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _buildScopedApp(
        const NewGameScreen(),
        storage: storage,
        language: AppLanguage.en,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(english.quickStart));
    await tester.pumpAndSettle();

    await tester.tap(find.text(english.startAdventure));
    await tester.pumpAndSettle();

    expect(find.byType(ChatScreen), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('Saves screen shows empty state', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final _TestStorageBundle storage = _TestStorageBundle.create();
    addTearDown(storage.dispose);

    await tester.pumpWidget(
      _buildScopedApp(
        const SavesScreen(),
        storage: storage,
        language: AppLanguage.en,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(english.noSavesYet), findsOneWidget);
  });

  testWidgets('Saves screen opens migrated legacy campaign', (tester) async {
    final CampaignState campaign = _sampleCampaign();
    SharedPreferences.setMockInitialValues(<String, Object>{
      'campaign.ids': <String>[campaign.id],
      'campaign.${campaign.id}': jsonEncode(campaign.toJson()),
    });
    final _TestStorageBundle storage = _TestStorageBundle.create();
    addTearDown(storage.dispose);

    await tester.pumpWidget(
      _buildScopedApp(
        const SavesScreen(),
        storage: storage,
        language: AppLanguage.en,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(campaign.title), findsOneWidget);

    final Finder openButton = find.ancestor(
      of: find.text(english.loadCampaignAction),
      matching: find.byType(GestureDetector),
    );
    await tester.tap(openButton.first, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.byType(ChatScreen), findsOneWidget);
    expect(find.text(campaign.title), findsOneWidget);
    expect(find.textContaining('Location:'), findsOneWidget);
    expect(find.textContaining(campaign.location), findsOneWidget);
  });

  testWidgets('Gameplay chat saves campaign via save button', (tester) async {
    final CampaignState campaign = _sampleCampaign();
    SharedPreferences.setMockInitialValues(<String, Object>{
      'campaign.ids': <String>[campaign.id],
      'campaign.${campaign.id}': jsonEncode(campaign.toJson()),
    });
    final _TestStorageBundle storage = _TestStorageBundle.create();
    addTearDown(storage.dispose);

    await tester.pumpWidget(
      _buildScopedApp(
        ChatScreen(campaignId: campaign.id),
        storage: storage,
        language: AppLanguage.en,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip(english.saveTooltip));
    await tester.pumpAndSettle();

    expect(find.text(english.campaignSaved), findsOneWidget);

    final CampaignState? saved = await storage.campaignRepository.loadCampaign(
      campaign.id,
    );
    expect(saved, isNotNull);
    expect(saved?.title, campaign.title);
  });

  testWidgets('Without configured model, turn runs in demo mode', (
    tester,
  ) async {
    final CampaignState campaign = _sampleCampaign();
    SharedPreferences.setMockInitialValues(<String, Object>{
      'campaign.ids': <String>[campaign.id],
      'campaign.${campaign.id}': jsonEncode(campaign.toJson()),
    });
    final _TestStorageBundle storage = _TestStorageBundle.create();
    addTearDown(storage.dispose);

    await tester.pumpWidget(
      _buildScopedApp(
        ChatScreen(campaignId: campaign.id),
        storage: storage,
        language: AppLanguage.en,
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Step toward the tower');
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pumpAndSettle();

    expect(find.textContaining('in demo mode'), findsAtLeastNWidgets(1));

    final CampaignState? saved = await storage.campaignRepository.loadCampaign(
      campaign.id,
    );
    expect(saved, isNotNull);
    expect(
      saved?.messages.any(
        (final item) => item.text.contains('Step toward the tower'),
      ),
      isTrue,
    );
  });

  testWidgets('Gameplay chat shows recoverable AI error and stays alive', (
    tester,
  ) async {
    final CampaignState campaign = _sampleCampaign();
    SharedPreferences.setMockInitialValues(<String, Object>{
      'campaign.ids': <String>[campaign.id],
      'campaign.${campaign.id}': jsonEncode(campaign.toJson()),
    });
    final _TestStorageBundle storage = _TestStorageBundle.create();
    addTearDown(storage.dispose);

    await tester.pumpWidget(
      _buildScopedApp(
        ChatScreen(campaignId: campaign.id),
        storage: storage,
        language: AppLanguage.en,
        settingsRepository: _FakeSettingsRepository(
          const _ConfiguredAiSettings(),
        ),
        aiServiceFactory: const _FakeAiServiceFactory(
          _ThrowingAiClient(
            AiTurnException(
              userMessage: 'Could not connect to the AI endpoint.',
              rawResponse: '503 Service Unavailable',
              recoverable: true,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Open the sealed gate');
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Could not connect to the AI endpoint.'), findsWidgets);

    final CampaignState? saved = await storage.campaignRepository.loadCampaign(
      campaign.id,
    );
    expect(saved, isNotNull);
    final String allTexts = saved!.messages
        .map((final item) => item.text)
        .join('\n');
    expect(allTexts, contains('Could not connect to the AI endpoint.'));
    expect(allTexts, contains('Technical note: the raw model response'));
  });

  testWidgets(
    'Gameplay chat renders streamed narration before turn completes',
    (tester) async {
      final CampaignState campaign = _sampleCampaign();
      SharedPreferences.setMockInitialValues(<String, Object>{
        'campaign.ids': <String>[campaign.id],
        'campaign.${campaign.id}': jsonEncode(campaign.toJson()),
      });
      final _TestStorageBundle storage = _TestStorageBundle.create();
      addTearDown(storage.dispose);

      await tester.pumpWidget(
        _buildScopedApp(
          ChatScreen(campaignId: campaign.id),
          storage: storage,
          language: AppLanguage.en,
          settingsRepository: _FakeSettingsRepository(
            const _ConfiguredAiSettings(),
          ),
          aiServiceFactory: const _FakeAiServiceFactory(_StreamingAiClient()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Open the ancient gate');
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 20));

      expect(find.textContaining('The gate groans'), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.textContaining('cold dust spills out'), findsOneWidget);
    },
  );

  testWidgets('Settings screen opens and shows core controls', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final _TestStorageBundle storage = _TestStorageBundle.create();
    addTearDown(storage.dispose);

    await tester.pumpWidget(
      _buildScopedApp(
        const SettingsScreen(),
        storage: storage,
        language: AppLanguage.en,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('LM Studio'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text(english.maxResponseTokens),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text(english.maxResponseTokens), findsOneWidget);
    expect(find.text(english.contextWindowSize), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text(english.saveSettings),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text(english.saveSettings), findsOneWidget);
    expect(find.byType(OutlinedButton), findsWidgets);
  });

  testWidgets('Narrow gameplay layout keeps drawer and focused chat area', (
    tester,
  ) async {
    final CampaignState campaign = _sampleCampaign();
    SharedPreferences.setMockInitialValues(<String, Object>{
      'campaign.ids': <String>[campaign.id],
      'campaign.${campaign.id}': jsonEncode(campaign.toJson()),
    });
    final _TestStorageBundle storage = _TestStorageBundle.create();
    addTearDown(storage.dispose);

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(360, 640)),
        child: _buildScopedApp(
          ChatScreen(campaignId: campaign.id),
          storage: storage,
          language: AppLanguage.en,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.menu), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(Icons.send_rounded), findsOneWidget);
  });
}

Widget _buildScopedApp(
  final Widget home, {
  required final _TestStorageBundle storage,
  required final AppLanguage language,
  final SettingsRepository? settingsRepository,
  final CampaignRepository? campaignRepository,
  final AiServiceFactory? aiServiceFactory,
  final GameEngine? gameEngine,
}) {
  final SettingsRepository resolvedSettingsRepository =
      settingsRepository ?? storage.settingsRepository;
  final CampaignRepository resolvedCampaignRepository =
      campaignRepository ?? storage.campaignRepository;
  final AiServiceFactory resolvedAiServiceFactory =
      aiServiceFactory ?? const AiServiceFactory();
  final GameEngine resolvedGameEngine = gameEngine ?? const GameEngine();
  final ValueNotifier<AppLanguage> appLanguageListenable =
      ValueNotifier<AppLanguage>(language);

  return ProviderScope(
    overrides: buildAppProviderOverrides(
      settingsRepository: resolvedSettingsRepository,
      campaignRepository: resolvedCampaignRepository,
      aiServiceFactory: resolvedAiServiceFactory,
      gameEngine: resolvedGameEngine,
      appLanguageListenable: appLanguageListenable,
    ),
    child: AppLocalizationsScope(
      localizations: AppLocalizations(language),
      child: MaterialApp(home: home),
    ),
  );
}

class _FakeSettingsRepository extends SettingsRepository {
  _FakeSettingsRepository(this._settings);

  final AiSettings _settings;

  @override
  Future<AiSettings> loadAiSettings() async => _settings;
}

class _FakeAiServiceFactory extends AiServiceFactory {
  const _FakeAiServiceFactory(this._client);

  final AiClient _client;

  @override
  AiClient create(final AiSettings settings) => _client;
}

class _ThrowingAiClient implements AiClient {
  const _ThrowingAiClient(this._error);

  final AiTurnException _error;

  @override
  Future<void> checkConnection({required final AiSettings settings}) async {}

  @override
  Future<TurnResult> generateTurn({
    required final AiSettings settings,
    required final AppLanguage language,
    required final CampaignState state,
    required final String playerAction,
    required final bool suggestionsOnly,
    final NarrationDeltaCallback? onNarrationDelta,
    final CancelToken? cancelToken,
  }) async {
    throw _error;
  }

  @override
  Future<GeneratedPrompts> generatePromptsFromStoryWish({
    required final AiSettings settings,
    required final AppLanguage language,
    required final String storyWish,
    required final CampaignSetting setting,
    final CancelToken? cancelToken,
  }) async => const GeneratedPrompts(storyPrompt: '', characterPrompt: '');
}

class _StreamingAiClient implements AiClient {
  const _StreamingAiClient();

  @override
  Future<void> checkConnection({required final AiSettings settings}) async {}

  @override
  Future<TurnResult> generateTurn({
    required final AiSettings settings,
    required final AppLanguage language,
    required final CampaignState state,
    required final String playerAction,
    required final bool suggestionsOnly,
    final NarrationDeltaCallback? onNarrationDelta,
    final CancelToken? cancelToken,
  }) async {
    onNarrationDelta?.call('The gate groans open');
    await Future<void>.delayed(const Duration(milliseconds: 30));
    onNarrationDelta?.call(
      'The gate groans open and cold dust spills out across the floor.',
    );
    await Future<void>.delayed(const Duration(milliseconds: 30));

    return const TurnResult(
      narration:
          'The gate groans open and cold dust spills out across the floor.',
      choices: <String>['Step inside', 'Wait', 'Call out'],
      stateChanges: StateChanges.empty(),
      memoryEntry: 'The sealed gate was opened.',
    );
  }

  @override
  Future<GeneratedPrompts> generatePromptsFromStoryWish({
    required final AiSettings settings,
    required final AppLanguage language,
    required final String storyWish,
    required final CampaignSetting setting,
    final CancelToken? cancelToken,
  }) async => const GeneratedPrompts(storyPrompt: '', characterPrompt: '');
}

class _ConfiguredAiSettings extends AiSettings {
  const _ConfiguredAiSettings()
    : super(
        provider: AiProviderType.openAiCompatible,
        baseUrl: 'http://127.0.0.1:9999/v1',
        model: 'test-model',
        apiKey: 'test-key',
        timeoutSeconds: 15,
        fastResponses: false,
        runtimeSettings: ModelRuntimeSettings.smartPreset,
      );
}

CampaignState _sampleCampaign() => CampaignState(
  id: 'campaign-1',
  schemaVersion: 3,
  title: 'The Amber Road',
  setting: CampaignSetting.fantasy,
  mode: StoryMode.longCampaign,
  difficulty: DifficultyLevel.medium,
  character: const CharacterStats(
    name: 'Mira',
    hp: 10,
    maxHp: 12,
    energy: 7,
    maxEnergy: 8,
    might: 2,
    wit: 3,
    spirit: 4,
  ),
  location: 'Old forest road',
  objective: 'Reach the ruined tower before dusk',
  turnNumber: 3,
  memory: const CampaignMemory(
    rollingSummary: 'Mira followed the caravan trail into the woods.',
    activeGoal: 'Find the tower entrance',
    activeSituation: 'A storm is gathering above the tree line.',
    recentTurns: <RecentTurnSummary>[
      RecentTurnSummary(
        playerAction: 'Inspect the tracks',
        outcome: 'Fresh boot prints lead east',
        stateHint: 'Possible ambush nearby',
      ),
    ],
  ),
  modules: const <CampaignModuleState>[
    CampaignModuleState(
      module: CampaignModule.inventory,
      isActive: true,
      activationReason: 'test',
    ),
    CampaignModuleState(
      module: CampaignModule.notes,
      isActive: true,
      activationReason: 'test',
    ),
    CampaignModuleState(
      module: CampaignModule.vitality,
      isActive: true,
      activationReason: 'test',
    ),
  ],
  inventory: const <String>['Lantern', 'Map'],
  companions: const <CampaignCompanion>[],
  notes: const <String>['Follow the caravan trail'],
  resources: const <CampaignResource>[],
  progression: null,
  messages: <ChatMessage>[
    ChatMessage(
      id: 'm1',
      role: ChatRole.narrator,
      text: 'The road narrows between ancient pines.',
      createdAt: DateTime(2026, 3, 15, 12),
    ),
  ],
  choices: const <String>['Scout ahead', 'Light the lantern'],
  updatedAt: DateTime(2026, 3, 15, 12, 30),
);

class _TestStorageBundle {
  _TestStorageBundle._(
    this.directory,
    this.database,
    this.settingsRepository,
    this.campaignRepository,
  );

  factory _TestStorageBundle.create() {
    final Directory directory = Directory.systemTemp.createTempSync(
      'ai_prg_widget_test_',
    );
    final AppDatabase database = AppDatabase(
      directoryPath: directory.path,
      name: 'widget_${DateTime.now().microsecondsSinceEpoch}',
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
