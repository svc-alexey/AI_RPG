import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:ai_prg/src/core/services/game_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('applyTurn writes recovered location into campaign state', () {
    const GameEngine engine = GameEngine();
    final CampaignState state = CampaignState(
      id: 'campaign-location',
      schemaVersion: 4,
      title: 'Signal in the Dark',
      setting: CampaignSetting.sciFi,
      mode: StoryMode.longCampaign,
      difficulty: DifficultyLevel.medium,
      character: const CharacterStats(
        name: 'Astra',
        hp: 12,
        maxHp: 12,
        energy: 8,
        maxEnergy: 8,
        might: 3,
        wit: 3,
        spirit: 3,
      ),
      location: '...',
      objective: 'Find the distress source',
      turnNumber: 0,
      memory: const CampaignMemory(
        rollingSummary: '',
        activeGoal: 'Find the distress source',
        activeSituation: '',
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
      updatedAt: DateTime(2026, 3, 21),
    );

    final TurnResult result = TurnResult.fromJson(<String, Object?>{
      'narration': 'A red beacon flickers somewhere ahead.',
      'choices': <Object?>['Move closer'],
      'game_state': <String, Object?>{
        'current_location': 'Emergency service corridor',
      },
      'memory_entry': 'The beacon marks a nearby corridor.',
    });

    final TurnApplicationResult applied = engine.applyTurn(
      language: AppLanguage.en,
      state: state,
      playerAction: '',
      result: result,
      contextWindowSize: 6,
    );

    expect(applied.state.location, 'Emergency service corridor');
    expect(
      applied.state.messages.last.text,
      'A red beacon flickers somewhere ahead.',
    );
  });
}
