import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:ai_prg/src/core/services/deterministic_check_service.dart';
import 'package:ai_prg/src/core/services/turn_prompt_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const TurnPromptBuilder builder = TurnPromptBuilder();

  test(
    'TurnPromptBuilder keeps story and character context in system prompt',
    () {
      final String prompt = builder.buildSystemPrompt(
        language: AppLanguage.en,
        state: _sampleCampaign(),
        suggestionsOnly: false,
        deterministicContext: const DeterministicTurnContext.none(),
        fastMode: false,
        confirmed18Plus: false,
      );

      expect(
        prompt,
        contains('Important: avoid sexual or explicit adult content'),
      );
      expect(prompt, contains('--- Story context ---'));
      expect(prompt, contains('A fading city where every promise has a cost.'));
      expect(prompt, contains('--- Character ---'));
      expect(prompt, contains('A guarded investigator who trusts patterns'));
    },
  );

  test(
    'TurnPromptBuilder injects deterministic resolution into user prompt',
    () {
      final String prompt = builder.buildUserPrompt(
        language: AppLanguage.en,
        state: _sampleCampaign(),
        playerAction: 'Inspect the sealed lock carefully',
        deterministicContext: DeterministicTurnContext(
          resolvedCheck: const CampaignCheck(
            id: 'check_1_wit_14',
            label: 'Wit check',
            summary: 'Wit check succeeded with 16 vs DC 13.',
            outcome: CampaignCheckOutcome.success,
            stat: 'wit',
            difficulty: 13,
            roll: 14,
            total: 16,
          ),
        ),
        fastMode: false,
        contextWindowSize: 1536,
      );

      expect(prompt, contains('Campaign context:'));
      expect(prompt, contains('"deterministic_resolution"'));
      expect(prompt, contains('"clientResolved":true'));
      expect(prompt, contains('Inspect the sealed lock carefully'));
    },
  );
}

CampaignState _sampleCampaign() => CampaignState(
  id: 'prompt-builder-campaign',
  schemaVersion: 3,
  title: 'Whispers Under Glass',
  setting: CampaignSetting.detective,
  mode: StoryMode.longCampaign,
  difficulty: DifficultyLevel.medium,
  character: const CharacterStats(
    name: 'Alex',
    hp: 11,
    maxHp: 12,
    energy: 7,
    maxEnergy: 8,
    might: 2,
    wit: 4,
    spirit: 3,
  ),
  location: 'Neon station',
  objective: 'Find the hidden broker before dawn',
  turnNumber: 8,
  memory: CampaignMemory(
    rollingSummary:
        'Alex tracked a courier through flooded alleys and learned the broker uses coded music cues.',
    activeGoal: 'Catch the broker alive',
    activeSituation:
        'Rain hammers the glass roof while station guards sweep the platforms.',
    recentTurns: List<RecentTurnSummary>.generate(
      3,
      (final index) => RecentTurnSummary(
        playerAction: 'Action $index',
        outcome: 'Outcome $index with extra detail about suspects and crowds.',
        stateHint: 'Hint $index',
      ),
    ),
  ),
  modules: const <CampaignModuleState>[
    CampaignModuleState(
      module: CampaignModule.notes,
      isActive: true,
      activationReason: 'test',
    ),
    CampaignModuleState(
      module: CampaignModule.checks,
      isActive: true,
      activationReason: 'test',
    ),
  ],
  inventory: const <String>['Lantern', 'Cipher shard'],
  companions: const <CampaignCompanion>[],
  notes: const <String>['The broker leaves coded notes in old train ledgers.'],
  resources: const <CampaignResource>[],
  progression: null,
  checks: const <CampaignCheck>[],
  messages: const <ChatMessage>[],
  choices: const <String>['Scout ahead', 'Light the lantern'],
  updatedAt: DateTime(2026, 3, 20, 12),
  customStoryPrompt: 'A fading city where every promise has a cost.',
  characterPrompt: 'A guarded investigator who trusts patterns over charm.',
);
