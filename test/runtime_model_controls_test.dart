import 'package:ai_prg/src/core/models/ai_settings.dart';
import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:ai_prg/src/core/services/campaign_memory_manager.dart';
import 'package:ai_prg/src/core/services/context_assembly_service.dart';
import 'package:ai_prg/src/core/services/openai_compatible_ai_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ContextAssemblyService trims hybrid context for smaller windows', () {
    const ContextAssemblyService service = ContextAssemblyService();
    final CampaignState campaign = _sampleCampaign();

    final Map<String, Object?> compact = service
        .build(state: campaign, contextWindowSize: 1024, fastMode: false)
        .toJson();
    final Map<String, Object?> roomy = service
        .build(state: campaign, contextWindowSize: 4096, fastMode: false)
        .toJson();

    final List<Object?> compactRecent =
        compact['recent_buffer'] as List<Object?>? ?? const <Object?>[];
    final List<Object?> roomyRecent =
        roomy['recent_buffer'] as List<Object?>? ?? const <Object?>[];

    final Map<String, Object?> compactWorld =
        compact['world_state'] as Map<String, Object?>? ??
        const <String, Object?>{};
    final Map<String, Object?> roomyWorld =
        roomy['world_state'] as Map<String, Object?>? ??
        const <String, Object?>{};

    expect(
      compact.keys,
      containsAll(<String>[
        'static_header',
        'dynamic_summary',
        'recent_buffer',
        'world_state',
      ]),
    );
    expect(compactRecent.length, lessThan(roomyRecent.length));
    expect(
      (compactWorld['inventory'] as List<Object?>).length,
      lessThan((roomyWorld['inventory'] as List<Object?>).length),
    );
  });

  test('CampaignMemoryManager refreshes rolling summary on cadence turns', () {
    const CampaignMemoryManager manager = CampaignMemoryManager();
    final CampaignState campaign = _sampleCampaign().copyWith(turnNumber: 1);

    final CampaignMemory updated = manager.updateMemory(
      language: AppLanguage.en,
      previousState: campaign,
      result: const TurnResult(
        narration:
            'Alex corners the broker on the upper platform and forces a confession.',
        choices: <String>['Arrest', 'Interrogate'],
        stateChanges: StateChanges(
          hpDelta: 0,
          energyDelta: -1,
          inventoryAdd: <String>[],
          inventoryRemove: <String>[],
          questNote: '',
          location: '',
        ),
        memoryEntry:
            'Alex forced the broker into the open on the upper platform and finally secured proof.',
      ),
      playerAction: 'Cut off the broker near the stairs',
      contextWindowSize: 1024,
    );

    expect(updated.rollingSummary, isNot(campaign.memory.rollingSummary));
    expect(updated.rollingSummary, contains('upper platform'));
    expect(updated.activeGoal, campaign.memory.activeGoal);
  });

  test('OpenAI-compatible request body uses runtime token controls', () {
    final OpenAiCompatibleAiClient client = OpenAiCompatibleAiClient();
    const AiSettings settings = AiSettings(
      provider: AiProviderType.openAiCompatible,
      baseUrl: 'http://127.0.0.1:1234/v1',
      model: 'test-model',
      apiKey: '',
      timeoutSeconds: 30,
      fastResponses: false,
      runtimeSettings: ModelRuntimeSettings(
        maxResponseTokens: 222,
        contextWindowSize: 1024,
        profile: ModelRuntimeProfile.custom,
      ),
    );

    final Map<String, Object?> requestBody = client.buildTurnRequestBody(
      settings: settings,
      language: AppLanguage.en,
      state: _sampleCampaign(),
      playerAction: 'Inspect the shrine',
      suggestionsOnly: false,
      fastMode: false,
      stream: true,
    );

    expect(requestBody['max_tokens'], 222);
    expect(requestBody['stream'], isTrue);

    final List<Object?> messages =
        requestBody['messages'] as List<Object?>? ?? const <Object?>[];
    final Map<String, Object?> userMessage =
        messages[1] as Map<String, Object?>? ?? const <String, Object?>{};
    final String content = userMessage['content'] as String? ?? '';

    expect(content, contains('Campaign context:'));
    expect(content, contains('"static_header"'));
    expect(content, contains('"dynamic_summary"'));
    expect(content, contains('Inspect the shrine'));
  });

  test('Streaming preview extracts partial narration from streamed JSON', () {
    final OpenAiCompatibleAiClient client = OpenAiCompatibleAiClient();

    expect(
      client.extractNarrationPreview(
        '{"narration":"A torch flares in the tunnel',
      ),
      'A torch flares in the tunnel',
    );
    expect(
      client.extractNarrationPreview(
        '{"narration":"Line one\\nLine two","choices":[]}',
      ),
      'Line one\nLine two',
    );
    expect(client.extractNarrationPreview('{"choices":["Wait"]}'), isNull);
  });
}

CampaignState _sampleCampaign() => CampaignState(
  id: 'runtime-campaign',
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
        'Alex tracked a courier through flooded alleys, lost them near the station market, and learned the broker uses coded music cues.',
    activeGoal: 'Catch the broker alive',
    activeSituation:
        'Rain hammers the glass roof while station guards sweep the platforms.',
    recentTurns: List<RecentTurnSummary>.generate(
      5,
      (final index) => RecentTurnSummary(
        playerAction: 'Action $index',
        outcome:
            'Outcome $index with extra detail about suspects, crowds, and the changing weather.',
        stateHint: 'Hint $index',
      ),
    ),
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
  inventory: const <String>[
    'Badge',
    'Recorder',
    'Encrypted note',
    'Lockpick',
    'Map shard',
    'Signal jammer',
  ],
  companions: const <CampaignCompanion>[],
  notes: const <String>[
    'Reach the station',
    'Decode the note',
    'Avoid the patrols',
    'Find the broker',
  ],
  resources: const <CampaignResource>[],
  progression: null,
  messages: const <ChatMessage>[],
  choices: const <String>['Ask around', 'Hide', 'Run'],
  updatedAt: DateTime(2026, 3, 20, 12),
);
