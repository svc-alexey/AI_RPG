import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:ai_prg/src/core/services/deterministic_check_service.dart';
import 'package:ai_prg/src/core/services/dice_engine.dart';
import 'package:ai_prg/src/core/services/game_engine.dart';
import 'package:ai_prg/src/core/services/turn_prompt_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('starting inventory', () {
    test('createCampaign leaves inventory empty when module active', () {
      const GameEngine engine = GameEngine();
      final CampaignState campaign = engine.createCampaign(
        draft: const CampaignDraft(
          setting: CampaignSetting.litRpgProgression,
          mode: StoryMode.longCampaign,
          difficulty: DifficultyLevel.medium,
          heroName: 'Test',
          characterProfile: CharacterProfile(
            name: 'Rogue',
            gender: CharacterGender.other,
            race: 'human',
            characterClass: CharacterClass.rogue,
            skills: <String>['Stealth'],
            personality: 'wary',
            perks: <String>['Lockpick set'],
            promptFragment: '',
          ),
        ),
        language: AppLanguage.en,
      );
      expect(campaign.isModuleActive(CampaignModule.inventory), isTrue);
      expect(campaign.inventory, isEmpty);
    });
  });

  group('starting loot die', () {
    test('rollStartingLootD6 is stable for a given campaign id', () {
      const DiceEngine dice = DiceEngine();
      const String id = 'campaign-stable-id';
      final int first = dice.rollStartingLootD6(campaignId: id);
      final int second = dice.rollStartingLootD6(campaignId: id);
      expect(second, first);
    });

    test('rollStartingLootGate matches die threshold', () {
      const DeterministicCheckService service = DeterministicCheckService();
      const String id = 'campaign-stable-id';
      final StartingLootGate gate = service.rollStartingLootGate(campaignId: id);
      final int die = const DiceEngine().rollStartingLootD6(campaignId: id);
      expect(gate.dieRoll, die);
      expect(
        gate.grantsStartingItem,
        die >= DiceEngine.startingLootMinimumSuccessRoll,
      );
    });
  });

  group('TurnPromptBuilder starting loot', () {
    const TurnPromptBuilder builder = TurnPromptBuilder();

    test('includes starting_loot_gate in campaign context json', () {
      const StartingLootGate gate = StartingLootGate(
        dieRoll: 5,
        grantsStartingItem: true,
      );
      final String prompt = builder.buildUserPrompt(
        language: AppLanguage.en,
        state: _introStateWithInventory(),
        playerAction: '',
        deterministicContext: const DeterministicTurnContext(
          startingLootGate: gate,
        ),
        fastMode: false,
        contextWindowSize: 4096,
      );
      expect(prompt, contains('starting_loot_gate'));
      expect(prompt, contains('"grantsStartingItem":true'));
      expect(prompt, contains('exactly one item'));
    });

    test('failure gate instructs empty inventoryAdd', () {
      const StartingLootGate gate = StartingLootGate(
        dieRoll: 2,
        grantsStartingItem: false,
      );
      final String prompt = builder.buildUserPrompt(
        language: AppLanguage.ru,
        state: _introStateWithInventory(),
        playerAction: '',
        deterministicContext: const DeterministicTurnContext(
          startingLootGate: gate,
        ),
        fastMode: false,
        contextWindowSize: 4096,
      );
      expect(prompt, contains('starting_loot_gate'));
      expect(prompt, contains('"grantsStartingItem":false'));
      expect(prompt, contains('inventoryAdd'));
      expect(prompt, contains('Исход неуспешный'));
    });
  });
}

CampaignState _introStateWithInventory() => CampaignState(
  id: 'intro-loot-test',
  schemaVersion: 4,
  title: 'Test',
  setting: CampaignSetting.litRpgProgression,
  mode: StoryMode.shortStory,
  difficulty: DifficultyLevel.medium,
  character: const CharacterStats(
    name: 'Hero',
    hp: 10,
    maxHp: 12,
    energy: 8,
    maxEnergy: 8,
    might: 3,
    wit: 3,
    spirit: 2,
  ),
  location: '...',
  objective: '',
  turnNumber: 0,
  memory: const CampaignMemory(
    rollingSummary: 'Start.',
    activeGoal: '',
    activeSituation: 'Intro.',
    recentTurns: <RecentTurnSummary>[],
  ),
  modules: const <CampaignModuleState>[
    CampaignModuleState(
      module: CampaignModule.inventory,
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
  updatedAt: DateTime.utc(2026, 4, 5),
  customStoryPrompt: 'A test realm.',
  characterPrompt: 'A wary traveler.',
);
