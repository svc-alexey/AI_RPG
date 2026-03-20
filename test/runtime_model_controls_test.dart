import 'package:ai_prg/src/core/models/ai_settings.dart';
import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:ai_prg/src/core/services/campaign_memory_manager.dart';
import 'package:ai_prg/src/core/services/openai_compatible_ai_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CampaignMemoryManager trims context for smaller windows', () {
    const CampaignMemoryManager manager = CampaignMemoryManager();
    final CampaignState campaign = _sampleCampaign();

    final Map<String, Object?> compact = manager.buildAiContext(
      campaign,
      contextWindowSize: 1024,
    );
    final Map<String, Object?> roomy = manager.buildAiContext(
      campaign,
      contextWindowSize: 4096,
    );

    final List<Object?> compactRecent =
        compact['recent_turns'] as List<Object?>? ?? const <Object?>[];
    final List<Object?> roomyRecent =
        roomy['recent_turns'] as List<Object?>? ?? const <Object?>[];

    final Map<String, Object?> compactCore =
        compact['core_state'] as Map<String, Object?>? ??
        const <String, Object?>{};
    final Map<String, Object?> roomyCore =
        roomy['core_state'] as Map<String, Object?>? ??
        const <String, Object?>{};

    expect(compactRecent.length, lessThan(roomyRecent.length));
    expect(
      (compactCore['inventory'] as List<Object?>).length,
      lessThan((roomyCore['inventory'] as List<Object?>).length),
    );
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
  schemaVersion: 2,
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
  inventory: const <String>[
    'Badge',
    'Recorder',
    'Encrypted note',
    'Lockpick',
    'Map shard',
    'Signal jammer',
  ],
  questLog: const <String>[
    'Reach the station',
    'Decode the note',
    'Avoid the patrols',
    'Find the broker',
  ],
  messages: const <ChatMessage>[],
  choices: const <String>['Ask around', 'Hide', 'Run'],
  updatedAt: DateTime(2026, 3, 20, 12),
);
