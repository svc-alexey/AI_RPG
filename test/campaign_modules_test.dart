import 'package:ai_prg/src/app/app_localizations.dart';
import 'package:ai_prg/src/app/app_providers.dart';
import 'package:ai_prg/src/core/models/ai_settings.dart';
import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:ai_prg/src/core/models/symmetry_models.dart';
import 'package:ai_prg/src/core/repositories/settings_repository.dart';
import 'package:ai_prg/src/core/repositories/symmetry_auth_repository.dart';
import 'package:ai_prg/src/core/repositories/symmetry_campaign_repository.dart';
import 'package:ai_prg/src/core/services/ai_client.dart';
import 'package:ai_prg/src/core/services/ai_service_factory.dart';
import 'package:ai_prg/src/core/services/campaign_module_resolver.dart';
import 'package:ai_prg/src/core/services/deterministic_check_service.dart';
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
        setting: CampaignSetting.cozyCrime,
        mode: StoryMode.longCampaign,
        difficulty: DifficultyLevel.medium,
        heroName: 'Alex',
      ),
      language: AppLanguage.en,
    );

    expect(campaign.isModuleActive(CampaignModule.notes), isTrue);
    expect(campaign.isModuleActive(CampaignModule.inventory), isFalse);
    expect(campaign.inventory, isEmpty);
    expect(campaign.notes, isEmpty);
  });

  test(
    'CampaignModuleResolver activates companions and resources from prompt',
    () {
      const CampaignModuleResolver resolver = CampaignModuleResolver();

      final List<CampaignModuleState> modules = resolver.resolveInitialModules(
        draft: const CampaignDraft(
          setting: CampaignSetting.nearFutureSciFi,
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
      'setting': 'fantasy',
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
    expect(state.setting, CampaignSetting.romantasy);
  });

  test(
    'CampaignState keeps vitality disabled for server payloads without modules and stats',
    () {
      final CampaignState state = CampaignState.fromJson(<String, Object?>{
        'id': 'server-1',
        'title': 'Server state',
        'setting': CampaignSetting.cozyCrime.name,
        'mode': StoryMode.longCampaign.name,
        'difficulty': DifficultyLevel.medium.name,
        'character': const <String, Object?>{
          'name': 'Rhea',
          'hp': 0,
          'maxHp': 0,
          'energy': 0,
          'maxEnergy': 0,
          'might': 0,
          'wit': 0,
          'spirit': 0,
        },
        'location': 'Old road',
        'objective': 'Reach the chapel',
        'turnNumber': 1,
        'modules': const <Object?>[],
        'messages': const <Object?>[],
        'choices': const <Object?>[],
        'updatedAt': DateTime(2026, 4, 7).toIso8601String(),
      });

      // cozyCrime does not auto-enable vitality (unlike grimdarkFantasy).
      expect(state.isModuleActive(CampaignModule.vitality), isFalse);
    },
  );

  test('CampaignModuleResolver does not enable vitality by preset alone', () {
    const CampaignModuleResolver resolver = CampaignModuleResolver();

    final List<CampaignModuleState> modules = resolver.resolveInitialModules(
      draft: const CampaignDraft(
        setting: CampaignSetting.nearFutureSciFi,
        mode: StoryMode.longCampaign,
        difficulty: DifficultyLevel.medium,
        heroName: 'Nova',
      ),
    );

    final List<CampaignModule> active = modules
        .where((final item) => item.isActive)
        .map((final item) => item.module)
        .toList();

    expect(active, isNot(contains(CampaignModule.vitality)));
  });

  test(
    'CampaignState roundtrip preserves resources, progression, and reasons',
    () {
      final CampaignState state = CampaignState(
        id: 'roundtrip-1',
        schemaVersion: 3,
        title: 'Roundtrip',
        setting: CampaignSetting.nearFutureSciFi,
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
        portraitPath: 'C:/tmp/roundtrip-1.png',
        portraitPrompt: 'cinematic portrait',
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
      expect(decoded.portraitPath, 'C:/tmp/roundtrip-1.png');
      expect(decoded.portraitPrompt, 'cinematic portrait');
    },
  );

  test('EntityExtractionService unlocks companions from narration', () {
    const EntityExtractionService service = EntityExtractionService();
    final CampaignState state = CampaignState(
      id: 'camp-1',
      schemaVersion: 3,
      title: 'Ash Harbor',
      setting: CampaignSetting.cozyCrime,
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
        setting: CampaignSetting.nearFutureSciFi,
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

  test('GameEngine resolves deterministic checks on the client', () {
    const GameEngine engine = GameEngine();
    final CampaignState state = CampaignState(
      id: 'camp-checks',
      schemaVersion: 3,
      title: 'Glass Vault',
      setting: CampaignSetting.romantasy,
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
          module: CampaignModule.checks,
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

    final DeterministicTurnContext firstContext = engine
        .resolveDeterministicTurn(
          language: AppLanguage.en,
          state: state,
          playerAction: 'Pick the ancient lock carefully',
        );
    final DeterministicTurnContext secondContext = engine
        .resolveDeterministicTurn(
          language: AppLanguage.en,
          state: state,
          playerAction: 'Pick the ancient lock carefully',
        );

    expect(firstContext.resolvedCheck, isNotNull);
    expect(firstContext.resolvedCheck?.roll, secondContext.resolvedCheck?.roll);

    final TurnApplicationResult applied = engine.applyTurn(
      language: AppLanguage.en,
      state: state,
      playerAction: 'Pick the ancient lock carefully',
      result: const TurnResult(
        narration: 'The lock answers your touch with a reluctant click.',
        choices: <String>['Open the vault'],
        stateChanges: StateChanges.empty(),
        memoryEntry: 'The vault lock gives way.',
      ),
      contextWindowSize: 1536,
      deterministicContext: firstContext,
    );

    expect(applied.state.checks, hasLength(1));
    expect(
      applied.state.checks.single.summary,
      firstContext.resolvedCheck!.summary,
    );
    expect(
      applied.notifications.any(
        (final item) => item.kind == StateChangeNotificationKind.checkResolved,
      ),
      isTrue,
    );
    expect(
      applied.state.memory.recentTurns.last.stateHint,
      contains('Wit check'),
    );
  });

  test('Detective campaigns keep RPG chrome hidden over long play', () {
    const GameEngine engine = GameEngine();
    CampaignState state = CampaignState(
      id: 'detective-long-play',
      schemaVersion: 3,
      title: 'Ash Ledger',
      setting: CampaignSetting.cozyCrime,
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
      location: 'Records room',
      objective: 'Find the forged ledger',
      turnNumber: 0,
      memory: const CampaignMemory(
        rollingSummary: 'Iris starts the investigation in the records room.',
        activeGoal: 'Find the forged ledger',
        activeSituation: 'Dust hangs in the air above old cabinets.',
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
      notes: const <String>['Start with the night ledger'],
      resources: const <CampaignResource>[],
      progression: null,
      messages: const <ChatMessage>[],
      choices: const <String>[],
      updatedAt: DateTime(2026, 3, 20, 12),
    );

    for (int index = 0; index < 8; index += 1) {
      final TurnApplicationResult applied = engine.applyTurn(
        language: AppLanguage.en,
        state: state,
        playerAction: 'Review clue $index',
        result: TurnResult(
          narration: 'You uncover another clue in the forged entries.',
          choices: const <String>['Continue'],
          stateChanges: StateChanges(
            hpDelta: -2,
            energyDelta: -1,
            inventoryAdd: <String>['Suspicious receipt $index'],
            inventoryRemove: const <String>[],
            questNote: 'Clue $index points to the same forged account',
            location: '',
          ),
          memoryEntry:
              'Clue: forged account $index matches the same signature.',
        ),
        contextWindowSize: 1536,
      );
      state = applied.state;
    }

    expect(state.isModuleActive(CampaignModule.notes), isTrue);
    expect(state.isModuleActive(CampaignModule.inventory), isFalse);
    expect(state.isModuleActive(CampaignModule.vitality), isFalse);
    expect(state.isModuleActive(CampaignModule.resources), isFalse);
    expect(state.isModuleActive(CampaignModule.progression), isFalse);
    expect(state.isModuleActive(CampaignModule.checks), isFalse);
    expect(state.inventory, isEmpty);
    expect(state.character.hp, 12);
    expect(state.character.energy, 8);
    expect(state.notes.length, greaterThan(1));
    expect(state.turnNumber, 8);
  });

  test('Narrative-only campaigns keep RPG chrome hidden over long play', () {
    const GameEngine engine = GameEngine();
    CampaignState state = CampaignState(
      id: 'narrative-only-long-play',
      schemaVersion: 3,
      title: 'Moonlit Letters',
      setting: CampaignSetting.romantasy,
      mode: StoryMode.longCampaign,
      difficulty: DifficultyLevel.medium,
      character: const CharacterStats(
        name: 'Mira',
        hp: 12,
        maxHp: 12,
        energy: 8,
        maxEnergy: 8,
        might: 3,
        wit: 3,
        spirit: 4,
      ),
      location: 'Old observatory',
      objective: 'Understand the final letter',
      turnNumber: 0,
      memory: const CampaignMemory(
        rollingSummary: 'Mira studies a box of letters in the observatory.',
        activeGoal: 'Understand the final letter',
        activeSituation: 'Moonlight spills across the dusty floorboards.',
        recentTurns: <RecentTurnSummary>[],
      ),
      modules: const <CampaignModuleState>[
        CampaignModuleState(
          module: CampaignModule.notes,
          isActive: true,
          activationReason: 'test_narrative_only',
        ),
      ],
      inventory: const <String>[],
      companions: const <CampaignCompanion>[],
      notes: const <String>['A missing signature appears on the last page'],
      resources: const <CampaignResource>[],
      progression: null,
      messages: const <ChatMessage>[],
      choices: const <String>[],
      updatedAt: DateTime(2026, 3, 20, 12),
    );

    for (int index = 0; index < 6; index += 1) {
      final TurnApplicationResult applied = engine.applyTurn(
        language: AppLanguage.en,
        state: state,
        playerAction: 'Interpret the next letter $index',
        result: TurnResult(
          narration: 'Another emotional thread appears in the correspondence.',
          choices: const <String>['Read on'],
          stateChanges: StateChanges(
            hpDelta: -3,
            energyDelta: -2,
            inventoryAdd: <String>['Keepsake $index'],
            inventoryRemove: const <String>[],
            questNote: 'Letter $index reveals a hidden promise',
            location: '',
          ),
          memoryEntry: 'Note: Letter $index reveals a hidden promise.',
        ),
        contextWindowSize: 1536,
      );
      state = applied.state;
    }

    expect(state.activeModules, contains(CampaignModule.notes));
    expect(state.activeModules, isNot(contains(CampaignModule.inventory)));
    expect(state.activeModules, isNot(contains(CampaignModule.vitality)));
    expect(state.activeModules, isNot(contains(CampaignModule.resources)));
    expect(state.activeModules, isNot(contains(CampaignModule.progression)));
    expect(state.activeModules, isNot(contains(CampaignModule.checks)));
    expect(state.inventory, isEmpty);
    expect(state.character.hp, 12);
    expect(state.character.energy, 8);
    expect(state.notes.length, greaterThan(1));
    expect(state.turnNumber, 6);
  });

  testWidgets('Chat sidebar renders only active modules', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final CampaignState campaign = CampaignState(
      id: 'detective-ui',
      schemaVersion: 3,
      title: 'Quiet Case',
      setting: CampaignSetting.cozyCrime,
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
        overrides: _buildServerOverrides(
          campaign: campaign,
          aiClient: const _NotesOnlyAiClient(),
        ),
        child: const AppLocalizationsScope(
          localizations: AppLocalizations(AppLanguage.en),
          child: MaterialApp(home: ChatScreen(campaignId: 'detective-ui')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('pier 9'), findsWidgets);
    expect(find.text('Inventory'), findsNothing);
    expect(find.text('Vitality'), findsNothing);
  });

  testWidgets('Chat sidebar uses rumor location title and hides opaque slug', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final CampaignState campaign = CampaignState(
      id: 'rumor-location-title',
      schemaVersion: 3,
      title: 'Sorting Night',
      setting: CampaignSetting.romantasy,
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
      location: 'Great Hall',
      objective: 'Meet the other students',
      turnNumber: 4,
      memory: const CampaignMemory(
        rollingSummary: 'The sorting ceremony begins under floating candles.',
        activeGoal: 'Meet the other students',
        activeSituation: 'The hall hums with nervous whispers.',
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
      notes: const <String>['Watch the sorting table'],
      resources: const <CampaignResource>[],
      progression: null,
      messages: <ChatMessage>[
        ChatMessage(
          id: 'n1',
          role: ChatRole.narrator,
          text: 'Candles sway above the tables as the hall quiets down.',
          createdAt: DateTime(2026, 3, 20, 10),
        ),
      ],
      choices: const <String>[],
      updatedAt: DateTime(2026, 3, 20, 10, 5),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: _buildServerOverrides(
          campaign: campaign,
          aiClient: const _NotesOnlyAiClient(),
          worldRumors: <SymmetryWorldRumor>[
            SymmetryWorldRumor(
              id: 'rumor-1',
              entityType: 'location',
              eventText:
                  'While the hero was occupied, the situation shifted: students gather at the entrance.',
              importance: 4,
              locationSlug: 'place-08d822431e',
              locationTitle: 'Great Hall',
              createdAt: DateTime(2026, 3, 20, 10, 4),
            ),
          ],
        ),
        child: const AppLocalizationsScope(
          localizations: AppLocalizations(AppLanguage.en),
          child: MaterialApp(
            home: ChatScreen(campaignId: 'rumor-location-title'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Great Hall'), findsOneWidget);
    expect(find.textContaining('place-08d822431e'), findsNothing);
    expect(find.textContaining('place 08d822431e'), findsNothing);
  });

  testWidgets('Detective campaigns keep irrelevant RPG chrome hidden', (
    tester,
  ) async {
    final CampaignState campaign = CampaignState(
      id: 'detective-gating',
      schemaVersion: 3,
      title: 'Paper Trail',
      setting: CampaignSetting.cozyCrime,
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
      location: 'Archive block',
      objective: 'Find the forged ledger',
      turnNumber: 4,
      memory: const CampaignMemory(
        rollingSummary: 'Iris followed the forger into the archive block.',
        activeGoal: 'Find the forged ledger',
        activeSituation: 'Dust and whispers cling to the old records room.',
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
      notes: const <String>['The forger used archive access'],
      resources: const <CampaignResource>[],
      progression: null,
      messages: <ChatMessage>[
        ChatMessage(
          id: 'n1',
          role: ChatRole.narrator,
          text: 'Rows of ledgers disappear into the shadows.',
          createdAt: DateTime(2026, 3, 20, 10),
        ),
      ],
      choices: const <String>[],
      updatedAt: DateTime(2026, 3, 20, 10, 5),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: _buildServerOverrides(
          campaign: campaign,
          aiClient: const _DetectiveChromeAiClient(),
        ),
        child: const AppLocalizationsScope(
          localizations: AppLocalizations(AppLanguage.en),
          child: MaterialApp(home: ChatScreen(campaignId: 'detective-gating')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Search the forged ledger');
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(
      find.textContaining('Note: Ledger confirms the forged entries'),
      findsOneWidget,
    );
    expect(find.text('Inventory'), findsNothing);
    expect(find.text('Vitality'), findsNothing);
    expect(find.text('Resources'), findsNothing);
  });

  testWidgets('Chat shows transient state-change overlays after a turn', (
    tester,
  ) async {
    final CampaignState campaign = CampaignState(
      id: 'overlay-campaign',
      schemaVersion: 3,
      title: 'Star Run',
      setting: CampaignSetting.nearFutureSciFi,
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
        overrides: _buildServerOverrides(
          campaign: campaign,
          aiClient: const _OverlayAiClient(),
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
      setting: CampaignSetting.cozyCrime,
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
        overrides: _buildServerOverrides(
          campaign: campaign,
          aiClient: const _NotesOnlyAiClient(),
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

    expect(
      find.textContaining('Note: Ledger points to warehouse 12'),
      findsOneWidget,
    );
  });

  testWidgets('Chat shows client-resolved checks in sidebar after a turn', (
    tester,
  ) async {
    final CampaignState campaign = CampaignState(
      id: 'checks-sidebar',
      schemaVersion: 3,
      title: 'Vault Run',
      setting: CampaignSetting.romantasy,
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
          module: CampaignModule.checks,
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
        overrides: _buildServerOverrides(
          campaign: campaign,
          aiClient: const _ChecksAiClient(),
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

    expect(find.textContaining('Wit check'), findsWidgets);
  });
}

List<Override> _buildServerOverrides({
  required final CampaignState campaign,
  required final AiClient aiClient,
  final List<SymmetryWorldRumor> worldRumors = const <SymmetryWorldRumor>[],
}) {
  final SettingsRepository settingsRepository =
      _FakeConfiguredSettingsRepository();
  final _FakeSymmetryAuthRepository authRepository =
      _FakeSymmetryAuthRepository(settingsRepository: settingsRepository);
  final _FakeSymmetryCampaignRepository symmetryCampaignRepository =
      _FakeSymmetryCampaignRepository(
        authRepository: authRepository,
        aiClient: aiClient,
        gameEngine: const GameEngine(),
        initialCampaigns: <CampaignState>[campaign],
        initialRumorsByCampaign: <String, List<SymmetryWorldRumor>>{
          campaign.id: worldRumors,
        },
      );

  return buildAppProviderOverrides(
    settingsRepository: settingsRepository,
    symmetryAuthRepository: authRepository,
    symmetryCampaignRepository: symmetryCampaignRepository,
    aiServiceFactory: const AiServiceFactory(),
    gameEngine: const GameEngine(),
    appLanguageListenable: ValueNotifier<AppLanguage>(AppLanguage.en),
  );
}

class _FakeConfiguredSettingsRepository extends SettingsRepository {
  @override
  Future<AiSettings> loadAiSettings() async => const AiSettings(
    baseUrl: 'http://127.0.0.1:1234/v1',
    model: 'test-model',
    apiKey: 'test-key',
    timeoutSeconds: 15,
    runtimeSettings: ModelRuntimeSettings.smartPreset,
  );

  @override
  Future<AiSettings> loadAiSettingsPersisted() async => loadAiSettings();
}

class _FakeSymmetryAuthRepository extends SymmetryAuthRepository {
  _FakeSymmetryAuthRepository({required super.settingsRepository});

  static const SymmetrySession _session = SymmetrySession(
    user: SymmetryUser(
      id: 'user-test',
      email: 'tester@example.com',
      displayName: 'Tester',
    ),
    tokens: SymmetryTokenPair(
      accessToken: 'access-test',
      accessTokenExpiresAt: '2030-01-01T00:00:00Z',
      refreshToken: 'refresh-test',
      refreshTokenExpiresAt: '2030-01-01T00:00:00Z',
    ),
    baseUrl: 'http://localhost:8080',
  );

  @override
  Future<bool> hasSession() async => true;

  @override
  Future<SymmetrySession?> loadSession() async => _session;

  @override
  Future<SymmetrySession> requireSession() async => _session;

  @override
  Future<void> logout() async {}

  @override
  Future<GeneratedPrompts> generateCampaignPrompts({
    required final AiSettings aiSettings,
    required final AppLanguage language,
    required final CampaignPromptGenerationRequest request,
  }) async => GeneratedPrompts(
    storyPrompt: request.storyWish.trim().isEmpty
        ? 'Generated story seed'
        : request.storyWish.trim(),
    characterPrompt: 'Generated character prompt',
  );
}

class _FakeSymmetryCampaignRepository extends SymmetryCampaignRepository {
  _FakeSymmetryCampaignRepository({
    required super.authRepository,
    required this.aiClient,
    required this.gameEngine,
    required final List<CampaignState> initialCampaigns,
    final Map<String, List<SymmetryWorldRumor>> initialRumorsByCampaign =
        const <String, List<SymmetryWorldRumor>>{},
  }) : _campaigns = <String, CampaignState>{
         for (final CampaignState campaign in initialCampaigns)
           campaign.id: campaign,
       },
       _worldRumorsByCampaign = <String, List<SymmetryWorldRumor>>{
         for (final MapEntry<String, List<SymmetryWorldRumor>> entry
             in initialRumorsByCampaign.entries)
           entry.key: List<SymmetryWorldRumor>.from(entry.value),
       };

  final AiClient aiClient;
  final GameEngine gameEngine;
  final Map<String, CampaignState> _campaigns;
  final Map<String, List<SymmetryWorldRumor>> _worldRumorsByCampaign;

  @override
  Future<List<CampaignState>> loadAllCampaigns() async =>
      _campaigns.values.toList(growable: false);

  @override
  Future<CampaignState?> loadCampaign(final String id) async => _campaigns[id];

  @override
  Future<List<SymmetryWorldRumor>> loadCampaignRumors(
    final String id, {
    final int limit = 5,
  }) async => List<SymmetryWorldRumor>.from(
    _worldRumorsByCampaign[id] ?? const <SymmetryWorldRumor>[],
  ).take(limit).toList(growable: false);

  @override
  Future<CampaignState> createCampaign({
    required final CampaignDraft draft,
    required final AppLanguage language,
    required final AiSettings aiSettings,
  }) async {
    final CampaignState campaign = gameEngine.createCampaign(
      draft: draft,
      language: language,
    );
    _campaigns[campaign.id] = campaign;
    return campaign;
  }

  @override
  Future<CampaignState> processTurn({
    required final CampaignState campaign,
    required final String playerAction,
    required final AppLanguage language,
    required final AiSettings aiSettings,
    final String triggerSource = 'manual',
    final int? diceRoll,
  }) async {
    final CampaignState current = _campaigns[campaign.id] ?? campaign;
    final DeterministicTurnContext deterministicContext =
        playerAction.trim().isEmpty
        ? const DeterministicTurnContext.none()
        : gameEngine.resolveDeterministicTurn(
            language: language,
            state: current,
            playerAction: playerAction,
          );
    final TurnResult result = await aiClient.generateTurn(
      settings: aiSettings,
      language: language,
      state: current,
      playerAction: playerAction,
      suggestionsOnly: false,
      deterministicContext: deterministicContext,
    );
    final TurnApplicationResult applied = gameEngine.applyTurn(
      language: language,
      state: current,
      playerAction: playerAction,
      result: result,
      contextWindowSize: aiSettings.contextWindowSize,
      deterministicContext: deterministicContext,
    );
    _campaigns[campaign.id] = applied.state;
    return applied.state;
  }

  @override
  Future<void> deleteCampaign(final String id) async {
    _campaigns.remove(id);
  }

  @override
  Future<void> saveCampaign(final CampaignState campaign) async {
    _campaigns[campaign.id] = campaign;
  }
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
    required final DeterministicTurnContext deterministicContext,
    final AiRequestMetadata? metadata,
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
  Future<GeneratedPrompts> generateCampaignPrompts({
    required final AiSettings settings,
    required final AppLanguage language,
    required final CampaignPromptGenerationRequest request,
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
    required final DeterministicTurnContext deterministicContext,
    final AiRequestMetadata? metadata,
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
  Future<GeneratedPrompts> generateCampaignPrompts({
    required final AiSettings settings,
    required final AppLanguage language,
    required final CampaignPromptGenerationRequest request,
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
    required final DeterministicTurnContext deterministicContext,
    final AiRequestMetadata? metadata,
    final NarrationDeltaCallback? onNarrationDelta,
    final CancelToken? cancelToken,
  }) async {
    const TurnResult result = TurnResult(
      narration:
          'You test the lock and the mechanism answers with a harsh click.',
      choices: <String>['Open the vault'],
      stateChanges: StateChanges.empty(),
      memoryEntry: 'The vault lock reacts to your attempt.',
    );
    onNarrationDelta?.call(result.narration);
    return result;
  }

  @override
  Future<GeneratedPrompts> generateCampaignPrompts({
    required final AiSettings settings,
    required final AppLanguage language,
    required final CampaignPromptGenerationRequest request,
    final CancelToken? cancelToken,
  }) async => const GeneratedPrompts(storyPrompt: '', characterPrompt: '');
}

class _DetectiveChromeAiClient implements AiClient {
  const _DetectiveChromeAiClient();

  @override
  Future<void> checkConnection({required final AiSettings settings}) async {}

  @override
  Future<TurnResult> generateTurn({
    required final AiSettings settings,
    required final AppLanguage language,
    required final CampaignState state,
    required final String playerAction,
    required final bool suggestionsOnly,
    required final DeterministicTurnContext deterministicContext,
    final AiRequestMetadata? metadata,
    final NarrationDeltaCallback? onNarrationDelta,
    final CancelToken? cancelToken,
  }) async {
    const TurnResult result = TurnResult(
      narration:
          'You find the forged ledger tucked behind the municipal tax books.',
      choices: <String>['Read the ledger'],
      stateChanges: StateChanges(
        hpDelta: -2,
        energyDelta: -1,
        inventoryAdd: <String>['Forged ledger'],
        inventoryRemove: <String>[],
        questNote: 'Ledger confirms the forged entries',
        location: '',
      ),
      memoryEntry: 'Clue: Ledger confirms the forged entries.',
    );
    onNarrationDelta?.call(result.narration);
    return result;
  }

  @override
  Future<GeneratedPrompts> generateCampaignPrompts({
    required final AiSettings settings,
    required final AppLanguage language,
    required final CampaignPromptGenerationRequest request,
    final CancelToken? cancelToken,
  }) async => const GeneratedPrompts(storyPrompt: '', characterPrompt: '');
}
