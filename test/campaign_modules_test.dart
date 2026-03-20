import 'package:ai_prg/src/app/app_localizations.dart';
import 'package:ai_prg/src/app/app_providers.dart';
import 'package:ai_prg/src/core/models/ai_settings.dart';
import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:ai_prg/src/core/repositories/campaign_repository.dart';
import 'package:ai_prg/src/core/repositories/settings_repository.dart';
import 'package:ai_prg/src/core/services/ai_client.dart';
import 'package:ai_prg/src/core/services/ai_service_factory.dart';
import 'package:ai_prg/src/core/services/campaign_module_resolver.dart';
import 'package:ai_prg/src/core/services/entity_extraction_service.dart';
import 'package:ai_prg/src/core/services/game_engine.dart';
import 'package:ai_prg/src/features/chat/presentation/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('GameEngine creates detective campaign with note-focused modules', () {
    const GameEngine engine = GameEngine();

    final CampaignState campaign = engine.createCampaign(
      draft: const CampaignDraft(
        setting: CampaignSetting.detective,
        mode: StoryMode.longCampaign,
        difficulty: DifficultyLevel.medium,
        heroName: 'Alex',
      ),
      language: AppLanguage.en,
    );

    expect(campaign.isModuleActive(CampaignModule.notes), isTrue);
    expect(campaign.isModuleActive(CampaignModule.inventory), isFalse);
    expect(campaign.inventory, isEmpty);
    expect(campaign.notes, isNotEmpty);
  });

  test(
    'CampaignModuleResolver activates companions and resources from prompt',
    () {
      const CampaignModuleResolver resolver = CampaignModuleResolver();

      final List<CampaignModuleState> modules = resolver.resolveInitialModules(
        draft: const CampaignDraft(
          setting: CampaignSetting.sciFi,
          mode: StoryMode.longCampaign,
          difficulty: DifficultyLevel.medium,
          heroName: 'Nova',
          storyWish:
              'A spaceship crew hunts for fuel, credits, and a missing ally.',
        ),
      );

      final List<CampaignModule> active = modules
          .where((final item) => item.isActive)
          .map((final item) => item.module)
          .toList();

      expect(active, contains(CampaignModule.resources));
      expect(active, contains(CampaignModule.companions));
    },
  );

  test('CampaignState infers active modules from legacy JSON payloads', () {
    final CampaignState state = CampaignState.fromJson(<String, Object?>{
      'id': 'legacy-1',
      'title': 'Legacy',
      'setting': CampaignSetting.fantasy.name,
      'mode': StoryMode.shortStory.name,
      'difficulty': DifficultyLevel.easy.name,
      'character': const CharacterStats(
        name: 'Mira',
        hp: 10,
        maxHp: 12,
        energy: 7,
        maxEnergy: 8,
        might: 2,
        wit: 3,
        spirit: 4,
      ).toJson(),
      'location': 'Ruins',
      'objective': 'Find the archive',
      'turnNumber': 2,
      'inventory': const <String>['Lantern'],
      'questLog': const <String>['Track the signal'],
      'messages': const <Object?>[],
      'choices': const <String>['Wait'],
      'updatedAt': DateTime(2026, 3, 20).toIso8601String(),
    });

    expect(state.isModuleActive(CampaignModule.inventory), isTrue);
    expect(state.isModuleActive(CampaignModule.notes), isTrue);
    expect(state.isModuleActive(CampaignModule.vitality), isTrue);
  });

  test(
    'CampaignState roundtrip preserves resources, progression, and reasons',
    () {
      final CampaignState state = CampaignState(
        id: 'roundtrip-1',
        schemaVersion: 3,
        title: 'Roundtrip',
        setting: CampaignSetting.sciFi,
        mode: StoryMode.longCampaign,
        difficulty: DifficultyLevel.medium,
        character: const CharacterStats(
          name: 'Nova',
          hp: 12,
          maxHp: 12,
          energy: 8,
          maxEnergy: 8,
          might: 3,
          wit: 3,
          spirit: 2,
        ),
        location: 'Orbital gate',
        objective: 'Leave the system',
        turnNumber: 5,
        memory: const CampaignMemory(
          rollingSummary: 'Nova escaped the checkpoint.',
          activeGoal: 'Reach the gate',
          activeSituation: 'Engines are warming up.',
          recentTurns: <RecentTurnSummary>[],
        ),
        modules: const <CampaignModuleState>[
          CampaignModuleState(
            module: CampaignModule.resources,
            isActive: true,
            activationReason: 'story_unlocked:resources',
          ),
          CampaignModuleState(
            module: CampaignModule.progression,
            isActive: true,
            activationReason: 'prompt:progression',
          ),
        ],
        inventory: const <String>[],
        companions: const <CampaignCompanion>[],
        notes: const <String>[],
        resources: const <CampaignResource>[
          CampaignResource(id: 'credits', label: 'Credits', value: 35),
        ],
        progression: const CampaignProgression(
          level: 2,
          experience: 40,
          rank: 'Runner',
        ),
        messages: const <ChatMessage>[],
        choices: const <String>[],
        updatedAt: DateTime(2026, 3, 20, 12),
      );

      final CampaignState decoded = CampaignState.fromJson(state.toJson());

      expect(decoded.resources.single.value, 35);
      expect(decoded.progression?.level, 2);
      expect(
        decoded.moduleState(CampaignModule.resources)?.activationReason,
        'story_unlocked:resources',
      );
      expect(
        decoded.moduleState(CampaignModule.progression)?.activationReason,
        'prompt:progression',
      );
    },
  );

  test('EntityExtractionService unlocks companions from narration', () {
    const EntityExtractionService service = EntityExtractionService();
    final CampaignState state = CampaignState(
      id: 'camp-1',
      schemaVersion: 3,
      title: 'Ash Harbor',
      setting: CampaignSetting.detective,
      mode: StoryMode.longCampaign,
      difficulty: DifficultyLevel.medium,
      character: const CharacterStats(
        name: 'Iris',
        hp: 12,
        maxHp: 12,
        energy: 8,
        maxEnergy: 8,
        might: 2,
        wit: 4,
        spirit: 3,
      ),
      location: 'Harbor',
      objective: 'Find the witness',
      turnNumber: 2,
      memory: const CampaignMemory(
        rollingSummary: 'Iris is closing in on the witness.',
        activeGoal: 'Reach pier 9',
        activeSituation: 'Rain hides the alleys.',
        recentTurns: <RecentTurnSummary>[],
      ),
      modules: const <CampaignModuleState>[
        CampaignModuleState(
          module: CampaignModule.notes,
          isActive: true,
          activationReason: 'test',
        ),
      ],
      inventory: const <String>[],
      companions: const <CampaignCompanion>[],
      notes: const <String>['Check pier 9'],
      resources: const <CampaignResource>[],
      progression: null,
      messages: const <ChatMessage>[],
      choices: const <String>[],
      updatedAt: DateTime(2026, 3, 20, 10),
    );

    final ReconciliationResult result = service.reconcile(
      state: state,
      result: const TurnResult(
        narration: 'Mara joins you in the alley and agrees to watch your back.',
        choices: <String>['Move'],
        stateChanges: StateChanges.empty(),
        memoryEntry: 'Mara joins you as a trusted ally.',
      ),
      language: AppLanguage.en,
    );

    expect(
      result.modules.any(
        (final item) =>
            item.module == CampaignModule.companions && item.isActive,
      ),
      isTrue,
    );
    expect(result.companions.map((final item) => item.name), contains('Mara'));
    expect(
      result.notifications.any(
        (final item) =>
            item.kind == StateChangeNotificationKind.companionJoined,
      ),
      isTrue,
    );
  });

  test(
    'EntityExtractionService unlocks resources and progression from story',
    () {
      const EntityExtractionService service = EntityExtractionService();
      final CampaignState state = CampaignState(
        id: 'camp-2',
        schemaVersion: 3,
        title: 'Sky Market',
        setting: CampaignSetting.sciFi,
        mode: StoryMode.longCampaign,
        difficulty: DifficultyLevel.medium,
        character: const CharacterStats(
          name: 'Nova',
          hp: 12,
          maxHp: 12,
          energy: 8,
          maxEnergy: 8,
          might: 3,
          wit: 3,
          spirit: 2,
        ),
        location: 'Market',
        objective: 'Buy passage',
        turnNumber: 3,
        memory: const CampaignMemory(
          rollingSummary: 'Nova is bargaining for passage.',
          activeGoal: 'Secure transport',
          activeSituation: 'The broker watches every move.',
          recentTurns: <RecentTurnSummary>[],
        ),
        modules: const <CampaignModuleState>[
          CampaignModuleState(
            module: CampaignModule.notes,
            isActive: true,
            activationReason: 'test',
          ),
        ],
        inventory: const <String>[],
        companions: const <CampaignCompanion>[],
        notes: const <String>[],
        resources: const <CampaignResource>[],
        progression: null,
        messages: const <ChatMessage>[],
        choices: const <String>[],
        updatedAt: DateTime(2026, 3, 20, 11),
      );

      final ReconciliationResult result = service.reconcile(
        state: state,
        result: const TurnResult(
          narration:
              'You gained 15 credits from the broker and reached level 2 after earning 20 XP.',
          choices: <String>['Leave'],
          stateChanges: StateChanges.empty(),
          memoryEntry: 'Credits +15. Level 2. XP +20.',
        ),
        language: AppLanguage.en,
      );

      expect(
        result.modules.any(
          (final item) => item.module == CampaignModule.resources,
        ),
        isTrue,
      );
      expect(
        result.modules.any(
          (final item) => item.module == CampaignModule.progression,
        ),
        isTrue,
      );
      expect(
        result.resources.map((final item) => item.id),
        contains('credits'),
      );
      expect(result.resources.first.value, 15);
      expect(result.progression?.level, 2);
      expect(result.progression?.experience, 20);
    },
  );

  test('EntityExtractionService unlocks checks from story', () {
    const EntityExtractionService service = EntityExtractionService();
    final CampaignState state = CampaignState(
      id: 'camp-checks',
      schemaVersion: 3,
      title: 'Glass Vault',
      setting: CampaignSetting.fantasy,
      mode: StoryMode.longCampaign,
      difficulty: DifficultyLevel.medium,
      character: const CharacterStats(
        name: 'Mira',
        hp: 12,
        maxHp: 12,
        energy: 8,
        maxEnergy: 8,
        might: 3,
        wit: 4,
        spirit: 2,
      ),
      location: 'Vault gate',
      objective: 'Open the vault',
      turnNumber: 3,
      memory: const CampaignMemory(
        rollingSummary: 'Mira reached the vault gate.',
        activeGoal: 'Open the vault',
        activeSituation: 'Ancient wards flicker around the lock.',
        recentTurns: <RecentTurnSummary>[],
      ),
      modules: const <CampaignModuleState>[
        CampaignModuleState(
          module: CampaignModule.notes,
          isActive: true,
          activationReason: 'test',
        ),
      ],
      inventory: const <String>[],
      companions: const <CampaignCompanion>[],
      notes: const <String>[],
      resources: const <CampaignResource>[],
      progression: null,
      messages: const <ChatMessage>[],
      choices: const <String>[],
      updatedAt: DateTime(2026, 3, 20, 12),
    );

    final ReconciliationResult result = service.reconcile(
      state: state,
      result: const TurnResult(
        narration: 'You make a Wit check: 14 vs DC 12 and succeed.',
        choices: <String>['Open the vault'],
        stateChanges: StateChanges.empty(),
        memoryEntry: 'Wit check passed at 14 vs DC 12.',
      ),
      language: AppLanguage.en,
    );

    expect(
      result.modules.any((final item) => item.module == CampaignModule.checks),
      isTrue,
    );
    expect(result.checks, hasLength(1));
    expect(result.checks.single.outcome, CampaignCheckOutcome.success);
    expect(result.checks.single.total, 14);
    expect(result.checks.single.difficulty, 12);
    expect(
      result.notifications.any(
        (final item) => item.kind == StateChangeNotificationKind.checkResolved,
      ),
      isTrue,
    );
  });

  testWidgets('Chat sidebar renders only active modules', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final CampaignState campaign = CampaignState(
      id: 'detective-ui',
      schemaVersion: 3,
      title: 'Quiet Case',
      setting: CampaignSetting.detective,
      mode: StoryMode.longCampaign,
      difficulty: DifficultyLevel.medium,
      character: const CharacterStats(
        name: 'Iris',
        hp: 12,
        maxHp: 12,
        energy: 8,
        maxEnergy: 8,
        might: 2,
        wit: 4,
        spirit: 3,
      ),
      location: 'Harbor district',
      objective: 'Find the witness',
      turnNumber: 4,
      memory: const CampaignMemory(
        rollingSummary: 'Iris followed a paper trail through the harbor.',
        activeGoal: 'Reach the witness before dawn',
        activeSituation: 'Rain and sirens fill the street.',
        recentTurns: <RecentTurnSummary>[],
      ),
      modules: const <CampaignModuleState>[
        CampaignModuleState(
          module: CampaignModule.notes,
          isActive: true,
          activationReason: 'test',
        ),
      ],
      inventory: const <String>[],
      companions: const <CampaignCompanion>[],
      notes: const <String>['Witness changed hideout', 'Check pier 9'],
      resources: const <CampaignResource>[],
      progression: null,
      messages: <ChatMessage>[
        ChatMessage(
          id: 'n1',
          role: ChatRole.narrator,
          text: 'A foghorn moans across the harbor.',
          createdAt: DateTime(2026, 3, 20, 10),
        ),
      ],
      choices: const <String>['Go to pier 9'],
      updatedAt: DateTime(2026, 3, 20, 10, 5),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: buildAppProviderOverrides(
          settingsRepository: _FakeSettingsRepository(),
          campaignRepository: _FakeCampaignRepository(campaign),
          aiServiceFactory: const AiServiceFactory(),
          gameEngine: const GameEngine(),
          appLanguageListenable: ValueNotifier<AppLanguage>(AppLanguage.en),
        ),
        child: const AppLocalizationsScope(
          localizations: AppLocalizations(AppLanguage.en),
          child: MaterialApp(home: ChatScreen(campaignId: 'detective-ui')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Notes'), findsWidgets);
    expect(find.text('Active system'), findsWidgets);
    expect(find.text('Inventory'), findsNothing);
    expect(find.text('Vitality'), findsNothing);
  });

  testWidgets('Chat shows transient state-change overlays after a turn', (
    tester,
  ) async {
    final CampaignState campaign = CampaignState(
      id: 'overlay-campaign',
      schemaVersion: 3,
      title: 'Star Run',
      setting: CampaignSetting.sciFi,
      mode: StoryMode.longCampaign,
      difficulty: DifficultyLevel.medium,
      character: const CharacterStats(
        name: 'Nova',
        hp: 10,
        maxHp: 12,
        energy: 7,
        maxEnergy: 8,
        might: 3,
        wit: 3,
        spirit: 2,
      ),
      location: 'Docking ring',
      objective: 'Reach the shuttle',
      turnNumber: 1,
      memory: const CampaignMemory(
        rollingSummary: 'Nova slipped through the maintenance ring.',
        activeGoal: 'Board the shuttle',
        activeSituation: 'Security drones sweep the corridor.',
        recentTurns: <RecentTurnSummary>[],
      ),
      modules: const <CampaignModuleState>[
        CampaignModuleState(
          module: CampaignModule.notes,
          isActive: true,
          activationReason: 'test',
        ),
      ],
      inventory: const <String>[],
      companions: const <CampaignCompanion>[],
      notes: const <String>['Avoid security drones'],
      resources: const <CampaignResource>[],
      progression: null,
      messages: <ChatMessage>[
        ChatMessage(
          id: 'n1',
          role: ChatRole.narrator,
          text: 'Blue alarm lights ripple through the corridor.',
          createdAt: DateTime(2026, 3, 20, 10),
        ),
      ],
      choices: const <String>[],
      updatedAt: DateTime(2026, 3, 20, 10, 5),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: buildAppProviderOverrides(
          settingsRepository: _FakeConfiguredSettingsRepository(),
          campaignRepository: _MutableCampaignRepository(campaign),
          aiServiceFactory: _FakeAiServiceFactory(const _OverlayAiClient()),
          gameEngine: const GameEngine(),
          appLanguageListenable: ValueNotifier<AppLanguage>(AppLanguage.en),
        ),
        child: const AppLocalizationsScope(
          localizations: AppLocalizations(AppLanguage.en),
          child: MaterialApp(home: ChatScreen(campaignId: 'overlay-campaign')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Grab the toolkit');
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('+ Toolkit'), findsOneWidget);
    expect(find.textContaining('Companion: Mara joins you'), findsOneWidget);
  });

  testWidgets('Chat sidebar briefly highlights modules changed this turn', (
    tester,
  ) async {
    final CampaignState campaign = CampaignState(
      id: 'notes-highlight',
      schemaVersion: 3,
      title: 'Quiet Case',
      setting: CampaignSetting.detective,
      mode: StoryMode.longCampaign,
      difficulty: DifficultyLevel.medium,
      character: const CharacterStats(
        name: 'Iris',
        hp: 12,
        maxHp: 12,
        energy: 8,
        maxEnergy: 8,
        might: 2,
        wit: 4,
        spirit: 3,
      ),
      location: 'Harbor district',
      objective: 'Find the witness',
      turnNumber: 4,
      memory: const CampaignMemory(
        rollingSummary: 'Iris followed the paper trail to the docks.',
        activeGoal: 'Reach the witness before dawn',
        activeSituation: 'Rain and sirens fill the street.',
        recentTurns: <RecentTurnSummary>[],
      ),
      modules: const <CampaignModuleState>[
        CampaignModuleState(
          module: CampaignModule.notes,
          isActive: true,
          activationReason: 'test',
        ),
      ],
      inventory: const <String>[],
      companions: const <CampaignCompanion>[],
      notes: const <String>['Check pier 9'],
      resources: const <CampaignResource>[],
      progression: null,
      messages: <ChatMessage>[
        ChatMessage(
          id: 'n1',
          role: ChatRole.narrator,
          text: 'The harbor is quiet for now.',
          createdAt: DateTime(2026, 3, 20, 10),
        ),
      ],
      choices: const <String>[],
      updatedAt: DateTime(2026, 3, 20, 10, 5),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: buildAppProviderOverrides(
          settingsRepository: _FakeConfiguredSettingsRepository(),
          campaignRepository: _MutableCampaignRepository(campaign),
          aiServiceFactory: _FakeAiServiceFactory(const _NotesOnlyAiClient()),
          gameEngine: const GameEngine(),
          appLanguageListenable: ValueNotifier<AppLanguage>(AppLanguage.en),
        ),
        child: const AppLocalizationsScope(
          localizations: AppLocalizations(AppLanguage.en),
          child: MaterialApp(home: ChatScreen(campaignId: 'notes-highlight')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Inspect the ledger');
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Updated'), findsOneWidget);
    expect(
      find.textContaining('Note: Ledger points to warehouse 12'),
      findsOneWidget,
    );

    await tester.pump(const Duration(seconds: 4));
    expect(find.text('Updated'), findsNothing);
  });

  testWidgets('Chat shows extracted checks in sidebar after a turn', (
    tester,
  ) async {
    final CampaignState campaign = CampaignState(
      id: 'checks-sidebar',
      schemaVersion: 3,
      title: 'Vault Run',
      setting: CampaignSetting.fantasy,
      mode: StoryMode.longCampaign,
      difficulty: DifficultyLevel.medium,
      character: const CharacterStats(
        name: 'Mira',
        hp: 12,
        maxHp: 12,
        energy: 8,
        maxEnergy: 8,
        might: 3,
        wit: 4,
        spirit: 2,
      ),
      location: 'Vault gate',
      objective: 'Open the vault',
      turnNumber: 2,
      memory: const CampaignMemory(
        rollingSummary: 'Mira reached the vault gate.',
        activeGoal: 'Open the vault',
        activeSituation: 'Ancient wards flicker around the lock.',
        recentTurns: <RecentTurnSummary>[],
      ),
      modules: const <CampaignModuleState>[
        CampaignModuleState(
          module: CampaignModule.notes,
          isActive: true,
          activationReason: 'test',
        ),
      ],
      inventory: const <String>[],
      companions: const <CampaignCompanion>[],
      notes: const <String>['The vault needs a precise sequence'],
      resources: const <CampaignResource>[],
      progression: null,
      messages: <ChatMessage>[
        ChatMessage(
          id: 'n1',
          role: ChatRole.narrator,
          text: 'The lock hums with old magic.',
          createdAt: DateTime(2026, 3, 20, 10),
        ),
      ],
      choices: const <String>[],
      updatedAt: DateTime(2026, 3, 20, 10, 5),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: buildAppProviderOverrides(
          settingsRepository: _FakeConfiguredSettingsRepository(),
          campaignRepository: _MutableCampaignRepository(campaign),
          aiServiceFactory: _FakeAiServiceFactory(const _ChecksAiClient()),
          gameEngine: const GameEngine(),
          appLanguageListenable: ValueNotifier<AppLanguage>(AppLanguage.en),
        ),
        child: const AppLocalizationsScope(
          localizations: AppLocalizations(AppLanguage.en),
          child: MaterialApp(home: ChatScreen(campaignId: 'checks-sidebar')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Try the lock');
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Checks'), findsWidgets);
    expect(find.textContaining('Wit check succeeded'), findsWidgets);
  });
}

class _FakeSettingsRepository extends SettingsRepository {
  @override
  Future<AiSettings> loadAiSettings() async => const AiSettings.defaults();
}

class _FakeConfiguredSettingsRepository extends SettingsRepository {
  @override
  Future<AiSettings> loadAiSettings() async => const AiSettings(
    provider: AiProviderType.openAiCompatible,
    baseUrl: 'http://127.0.0.1:1234/v1',
    model: 'test-model',
    apiKey: 'test-key',
    timeoutSeconds: 15,
    fastResponses: false,
    runtimeSettings: ModelRuntimeSettings.smartPreset,
  );
}

class _FakeCampaignRepository extends CampaignRepository {
  _FakeCampaignRepository(this._campaign);

  final CampaignState _campaign;

  @override
  Future<CampaignState?> loadCampaign(final String id) async =>
      id == _campaign.id ? _campaign : null;
}

class _MutableCampaignRepository extends CampaignRepository {
  _MutableCampaignRepository(this._campaign);

  CampaignState _campaign;

  @override
  Future<CampaignState?> loadCampaign(final String id) async =>
      id == _campaign.id ? _campaign : null;

  @override
  Future<void> saveCampaign(final CampaignState campaign) async {
    _campaign = campaign;
  }
}

class _FakeAiServiceFactory extends AiServiceFactory {
  _FakeAiServiceFactory(this._client);

  final AiClient _client;

  @override
  AiClient create(final AiSettings settings) => _client;
}

class _OverlayAiClient implements AiClient {
  const _OverlayAiClient();

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
    const TurnResult result = TurnResult(
      narration: 'Mara joins you as you grab the toolkit from the crate.',
      choices: <String>['Run', 'Hide'],
      stateChanges: StateChanges(
        hpDelta: 0,
        energyDelta: 0,
        inventoryAdd: <String>['Toolkit'],
        inventoryRemove: <String>[],
        questNote: 'Toolkit secured',
        location: '',
      ),
      memoryEntry: 'Mara joins you and the toolkit is secured.',
    );
    onNarrationDelta?.call(result.narration);
    return result;
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

class _NotesOnlyAiClient implements AiClient {
  const _NotesOnlyAiClient();

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
    const TurnResult result = TurnResult(
      narration: 'You spot a fresh entry in the ledger.',
      choices: <String>['Go to warehouse 12'],
      stateChanges: StateChanges(
        hpDelta: 0,
        energyDelta: 0,
        inventoryAdd: <String>[],
        inventoryRemove: <String>[],
        questNote: 'Ledger points to warehouse 12',
        location: '',
      ),
      memoryEntry: 'Clue: Ledger points to warehouse 12.',
    );
    onNarrationDelta?.call(result.narration);
    return result;
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

class _ChecksAiClient implements AiClient {
  const _ChecksAiClient();

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
    const TurnResult result = TurnResult(
      narration: 'You make a Wit check: 14 vs DC 12 and succeed.',
      choices: <String>['Open the vault'],
      stateChanges: StateChanges.empty(),
      memoryEntry: 'Wit check passed at 14 vs DC 12.',
    );
    onNarrationDelta?.call(result.narration);
    return result;
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
