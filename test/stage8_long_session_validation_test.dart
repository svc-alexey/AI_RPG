import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:ai_prg/src/core/services/context_assembly_service.dart';
import 'package:ai_prg/src/core/services/deterministic_check_service.dart';
import 'package:ai_prg/src/core/services/game_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'Fantasy long-session save/load cycles stay coherent without full chat history',
    () async {
      const GameEngine engine = GameEngine();
      const ContextAssemblyService assemblyService = ContextAssemblyService();
      CampaignState state = _initialFantasyCampaign();

      for (int turn = 0; turn < 12; turn += 1) {
        final String action = switch (turn % 4) {
          0 => 'Pick the rune lock carefully',
          1 => 'Force the stone gate open',
          2 => 'Study the glowing sigil carefully',
          _ => 'Withstand the warding flame',
        };
        final DeterministicTurnContext deterministicContext = engine
            .resolveDeterministicTurn(
              language: AppLanguage.en,
              state: state,
              playerAction: action,
            );
        final TurnApplicationResult applied = engine.applyTurn(
          language: AppLanguage.en,
          state: state,
          playerAction: action,
          result: TurnResult(
            narration:
                'Turn ${turn + 1}: Mira pushes deeper into the vault, reads the ancient pressure in the room, and finds a clearer path toward chamber ${turn + 1}.',
            choices: const <String>['Advance', 'Listen', 'Mark the route'],
            stateChanges: StateChanges(
              hpDelta: turn.isEven ? -1 : 0,
              energyDelta: -1,
              inventoryAdd: turn % 3 == 0
                  ? <String>['Relic shard ${turn + 1}']
                  : const <String>[],
              inventoryRemove: turn % 5 == 4
                  ? <String>['Relic shard ${turn - 2}']
                  : const <String>[],
              questNote: turn % 4 == 3
                  ? 'Reach chamber ${turn + 1} before the vault seals'
                  : '',
              location: 'Vault chamber ${turn + 1}',
            ),
            memoryEntry:
                'Mira secured progress in chamber ${turn + 1} and mapped the safer route forward.',
          ),
          contextWindowSize: 1536,
          deterministicContext: deterministicContext,
        );
        state = applied.state;

        if ((turn + 1) % 3 == 0) {
          state = CampaignState.fromJson(state.toJson());
        }
      }

      final CampaignState loaded = CampaignState.fromJson(state.toJson());
      final Map<String, Object?> context = assemblyService
          .build(state: loaded, contextWindowSize: 1536, fastMode: false)
          .toJson();
      final Map<String, Object?> dynamicSummary =
          context['dynamic_summary'] as Map<String, Object?>? ??
          const <String, Object?>{};
      final List<Object?> recentBuffer =
          context['recent_buffer'] as List<Object?>? ?? const <Object?>[];
      final Map<String, Object?> worldState =
          context['world_state'] as Map<String, Object?>? ??
          const <String, Object?>{};
      final List<Object?> checks =
          worldState['checks'] as List<Object?>? ?? const <Object?>[];

      expect(loaded.turnNumber, 12);
      expect(loaded.location, 'Vault chamber 12');
      expect(loaded.memory.recentTurns.length, lessThanOrEqualTo(5));
      expect(loaded.memory.rollingSummary, contains('chamber 12'));
      expect(loaded.messages.length, greaterThan(20));
      expect(loaded.checks, isNotEmpty);
      expect(recentBuffer.length, lessThan(loaded.memory.recentTurns.length));
      expect(recentBuffer.length, lessThan(loaded.messages.length));
      expect(
        (dynamicSummary['rollingSummary'] as String?)?.length ?? 0,
        lessThanOrEqualTo(412),
      );
      expect(checks.length, lessThanOrEqualTo(4));
      expect(worldState['inventory'], isNotNull);
      expect(worldState['notes'], isNotNull);
    },
  );
}

CampaignState _initialFantasyCampaign() => CampaignState(
  id: 'fantasy-stage8-long-session',
  schemaVersion: 3,
  title: 'The Vault of Glass Rain',
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
    spirit: 3,
  ),
  location: 'Vault antechamber',
  objective: 'Reach the heart of the vault',
  turnNumber: 0,
  memory: const CampaignMemory(
    rollingSummary:
        'Mira entered the ancient vault beneath the observatory and found the first sealed gate.',
    activeGoal: 'Reach the heart of the vault',
    activeSituation:
        'Blue dust hangs in the air while old wards pulse across the stone.',
    recentTurns: <RecentTurnSummary>[],
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
    CampaignModuleState(
      module: CampaignModule.checks,
      isActive: true,
      activationReason: 'test',
    ),
  ],
  inventory: const <String>['Lantern', 'Chalk'],
  companions: const <CampaignCompanion>[],
  notes: const <String>['The outer seal answers to wit, not force.'],
  resources: const <CampaignResource>[],
  progression: null,
  messages: const <ChatMessage>[],
  choices: const <String>[],
  updatedAt: DateTime(2026, 3, 20, 12),
);
