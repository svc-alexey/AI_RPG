import 'dart:convert';
import 'dart:math';

import 'package:ai_prg/src/core/models/ai_settings.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:ai_prg/src/core/models/symmetry_models.dart';
import 'package:ai_prg/src/core/services/symmetry_api_client.dart';
import 'package:ai_prg/src/features/new_game/application/new_game_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  test('quick start mode picker favors short stories', () {
    final Random random = Random(12345);
    int shortCount = 0;
    int longCount = 0;

    for (int index = 0; index < 1000; index += 1) {
      final StoryMode mode = NewGameController.pickQuickStartStoryMode(random);
      if (mode == StoryMode.shortStory) {
        shortCount += 1;
      } else {
        longCount += 1;
      }
    }

    expect(shortCount, greaterThan(longCount));
    expect(shortCount, inInclusiveRange(650, 750));
    expect(longCount, inInclusiveRange(250, 350));
  });

  test(
    'SymmetryApiClient sends story mode in generate prompts payload',
    () async {
      final _RecordingClient httpClient = _RecordingClient();
      final SymmetryApiClient client = SymmetryApiClient(
        baseUrl: 'http://localhost:8080',
        httpClient: httpClient,
      );

      final SymmetryGeneratedPrompts response = await client.generatePrompts(
        accessToken: 'token',
        setting: CampaignSetting.cozyCrime,
        literaryGenre: LiteraryGenre.mysteryCrime,
        mode: StoryMode.longCampaign,
        difficulty: DifficultyLevel.medium,
        languageCode: 'ru',
        storyWish: 'Ищу исчезнувшего свидетеля.',
        aiSettings: const AiSettings(
          baseUrl: 'http://provider.test/v1',
          model: 'gpt-test',
          apiKey: 'secret',
          timeoutSeconds: 30,
          runtimeSettings: ModelRuntimeSettings.smartPreset,
        ),
      );

      expect(httpClient.recordedBody?['mode'], StoryMode.longCampaign.name);
      expect(response.storyPrompt, 'Story seed');
    },
  );

  test('SymmetryApiClient parses world rumors payload', () async {
    final _RecordingClient httpClient = _RecordingClient();
    httpClient.nextResponseBody = jsonEncode(<Object?>[
      <String, Object?>{
        'id': 'rumor_1',
        'entity_type': 'company',
        'event_text': 'While the hero was occupied, the supply caravan shifted the situation.',
        'importance': 5,
        'location_slug': 'ash-harbor',
        'created_at': '2026-04-07T03:30:00Z',
      },
    ]);
    final SymmetryApiClient client = SymmetryApiClient(
      baseUrl: 'http://localhost:8080',
      httpClient: httpClient,
    );

    final List<SymmetryWorldRumor> rumors = await client.getCampaignRumors(
      accessToken: 'token',
      campaignId: 'campaign_1',
    );

    expect(rumors, hasLength(1));
    expect(rumors.single.locationSlug, 'ash-harbor');
    expect(rumors.single.eventText, contains('supply caravan'));
  });
}

class _RecordingClient extends http.BaseClient {
  Map<String, Object?>? recordedBody;
  String nextResponseBody = '';

  @override
  Future<http.StreamedResponse> send(final http.BaseRequest request) async {
    if (request is http.Request && request.body.isNotEmpty) {
      recordedBody = jsonDecode(request.body) as Map<String, Object?>;
    }
    final String body =
        nextResponseBody.isNotEmpty
            ? nextResponseBody
            : jsonEncode(<String, Object?>{
                'story_prompt': 'Story seed',
                'character_prompt': 'Character seed',
                'campaign_title': 'Ash Harbor',
                'objective_hint': 'Find the witness',
              });
    return http.StreamedResponse(
      Stream<List<int>>.fromIterable(<List<int>>[utf8.encode(body)]),
      200,
      headers: const <String, String>{'content-type': 'application/json'},
    );
  }
}
