import 'package:ai_prg/src/core/models/ai_settings.dart';
import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:ai_prg/src/core/models/symmetry_models.dart';
import 'package:ai_prg/src/core/repositories/settings_repository.dart';
import 'package:ai_prg/src/core/repositories/symmetry_auth_repository.dart';
import 'package:ai_prg/src/core/repositories/symmetry_campaign_repository.dart';
import 'package:ai_prg/src/core/services/symmetry_api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _testSession = SymmetrySession(
  user: SymmetryUser(id: 'u1', email: 'test@test.com', displayName: 'Tester'),
  tokens: SymmetryTokenPair(
    accessToken: 'at',
    refreshToken: 'rt',
    accessTokenExpiresAt: '',
    refreshTokenExpiresAt: '',
  ),
  baseUrl: 'http://localhost:8080/v1',
);

class _FakeAuthRepository extends SymmetryAuthRepository {
  _FakeAuthRepository(this.fakeSession)
    : super(settingsRepository: SettingsRepository());

  final SymmetrySession fakeSession;

  @override
  Future<T> runWithAuthorizedSession<T>(
    Future<T> Function(SymmetrySession session) action, {
    bool allowGuest = true,
  }) async => action(fakeSession);
}

CampaignState _sampleCampaign() => CampaignState(
  id: 'test-campaign',
  schemaVersion: 3,
  title: 'Test',
  setting: CampaignSetting.romantasy,
  mode: StoryMode.shortStory,
  difficulty: DifficultyLevel.easy,
  character: const CharacterStats(
    name: 'Hero',
    hp: 10,
    maxHp: 10,
    energy: 5,
    maxEnergy: 5,
    might: 2,
    wit: 2,
    spirit: 2,
  ),
  location: 'Start',
  objective: '',
  turnNumber: 0,
  memory: const CampaignMemory(
    rollingSummary: '',
    activeGoal: '',
    activeSituation: '',
    recentTurns: [],
  ),
  modules: const [],
  inventory: const [],
  companions: const [],
  notes: const [],
  resources: const [],
  progression: null,
  messages: const [],
  choices: const [],
  updatedAt: DateTime.now(),
);

void main() {
  group('createCampaign', () {
    test('sends full draft payload', () async {
      final mock = MockClient((request) async {
        expect(request.method, 'POST');
        final body = request.body;
        expect(body, contains('setting'));
        expect(body, contains('mode'));
        expect(body, contains('difficulty'));
        expect(body, contains('language'));
        expect(body, contains('character'));
        return http.Response(
          '{"campaign":{"id":"new-c1"},"state":{"id":"new-c1","title":"Test Campaign","setting":"fantasy","mode":"story","difficulty":"easy","language":"ru","turn_number":0},"snapshot_version":1}',
          200,
        );
      });

      final repo = SymmetryCampaignRepository(
        authRepository: _FakeAuthRepository(_testSession),
        clientFactory: (baseUrl) => SymmetryApiClient(httpClient: mock, baseUrl: baseUrl),
      );

      final state = await repo.createCampaign(
        draft: const CampaignDraft(
          setting: CampaignSetting.romantasy,
          mode: StoryMode.shortStory,
          difficulty: DifficultyLevel.easy,
          campaignTitle: 'Test Campaign',
          heroName: 'Hero',
          customStoryPrompt: 'Once upon a time',
          storyWish: 'Adventure',
          objectiveHint: 'Find the treasure',
        ),
        language: AppLanguage.ru,
        aiSettings: const AiSettings.defaults(),
      );

      expect(state.title, isNotEmpty);
    });

    test('normalizes title from custom story prompt when title is empty', () async {
      final mock = MockClient((request) async {
        final body = request.body;
        expect(body, contains('"title":"Find the treasure"'));
        return http.Response(
          '{"campaign":{"id":"c2"},"state":{"id":"c2","title":"Find the treasure","setting":"fantasy","mode":"story","difficulty":"easy","language":"ru","turn_number":0},"snapshot_version":1}',
          200,
        );
      });

      final repo = SymmetryCampaignRepository(
        authRepository: _FakeAuthRepository(_testSession),
        clientFactory: (baseUrl) => SymmetryApiClient(httpClient: mock, baseUrl: baseUrl),
      );

      await repo.createCampaign(
        draft: const CampaignDraft(
          setting: CampaignSetting.romantasy,
          mode: StoryMode.shortStory,
          difficulty: DifficultyLevel.easy,
          heroName: 'Hero',
          customStoryPrompt: 'Find the treasure',
        ),
        language: AppLanguage.ru,
        aiSettings: const AiSettings.defaults(),
      );
    });

    test('includes provider credentials when set', () async {
      final mock = MockClient((request) async {
        expect(request.body, contains('provider_credentials'));
        return http.Response(
          '{"campaign":{"id":"c3"},"state":{"id":"c3","title":"T","setting":"fantasy","mode":"story","difficulty":"easy","language":"en","turn_number":0},"snapshot_version":1}',
          200,
        );
      });

      final repo = SymmetryCampaignRepository(
        authRepository: _FakeAuthRepository(_testSession),
        clientFactory: (baseUrl) => SymmetryApiClient(httpClient: mock, baseUrl: baseUrl),
      );

      await repo.createCampaign(
        draft: const CampaignDraft(
          setting: CampaignSetting.romantasy,
          mode: StoryMode.shortStory,
          difficulty: DifficultyLevel.easy,
          campaignTitle: 'T',
          heroName: 'H',
        ),
        language: AppLanguage.en,
        aiSettings: const AiSettings(
          baseUrl: 'https://api.example.com',
          model: 'gpt-4',
          apiKey: 'sk-key',
          timeoutSeconds: 60,
          runtimeSettings: ModelRuntimeSettings.defaults,
        ),
      );
    });
  });

  group('processTurn', () {
    test('sends turn and returns updated state', () async {
      final mock = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.body, contains('player_action'));
        expect(request.body, contains('trigger_source'));
        expect(request.url.path, contains('turns/process'));
        return http.Response(
          '{"narration":"Done.","choices":["Yes","No"],"state_changes":{},"memory_entry":"mem","request_id":"r1","state":{"id":"c1","title":"Test","setting":"fantasy","turn_number":1},"campaign_snapshot_version":2}',
          200,
        );
      });

      final repo = SymmetryCampaignRepository(
        authRepository: _FakeAuthRepository(_testSession),
        clientFactory: (baseUrl) => SymmetryApiClient(httpClient: mock, baseUrl: baseUrl),
      );

      final state = await repo.processTurn(
        campaign: _sampleCampaign(),
        playerAction: 'Look around',
        language: AppLanguage.ru,
        aiSettings: const AiSettings.defaults(),
      );

      expect(state.turnNumber, 1);
    });
  });

  group('loadCampaign', () {
    test('loads single campaign from server state', () async {
      final mock = MockClient((request) async {
        expect(request.method, 'GET');
        return http.Response(
          '{"campaign":{"id":"c1"},"state":{"id":"c1","title":"My Campaign","setting":"scifi","mode":"campaign","difficulty":"medium","language":"ru","turn_number":10,"location":"Space Station","objective":"Survive"},"snapshot_version":5}',
          200,
        );
      });

      final repo = SymmetryCampaignRepository(
        authRepository: _FakeAuthRepository(_testSession),
        clientFactory: (baseUrl) => SymmetryApiClient(httpClient: mock, baseUrl: baseUrl),
      );

      final state = await repo.loadCampaign('c1');
      expect(state, isNotNull);
      expect(state!.title, 'My Campaign');
    });

    test('returns null for missing campaign', () async {
      final mock = MockClient((_) async => http.Response('{"detail":"not_found"}', 404));

      final repo = SymmetryCampaignRepository(
        authRepository: _FakeAuthRepository(_testSession),
        clientFactory: (baseUrl) => SymmetryApiClient(httpClient: mock, baseUrl: baseUrl),
      );

      expect(
        repo.loadCampaign('gone'),
        throwsA(isA<SymmetryApiException>()),
      );
    });
  });

  group('loadAllCampaigns', () {
    test('loads all campaigns with state', () async {
      int callCount = 0;
      final mock = MockClient((request) async {
        callCount++;
        if (request.method == 'GET' && request.url.path.endsWith('campaigns')) {
          return http.Response(
            '[{"id":"c1","title":"A","setting":"fantasy","mode":"story","difficulty":"easy","language":"ru","status":"active"},{"id":"c2","title":"B","setting":"scifi","mode":"campaign","difficulty":"hard","language":"en","status":"active"}]',
            200,
          );
        }
        // Campaign state requests
        return http.Response(
          '{"campaign":{"id":"c1"},"state":{"id":"c1","title":"A","setting":"fantasy","turn_number":1},"snapshot_version":1}',
          200,
        );
      });

      final repo = SymmetryCampaignRepository(
        authRepository: _FakeAuthRepository(_testSession),
        clientFactory: (baseUrl) => SymmetryApiClient(httpClient: mock, baseUrl: baseUrl),
      );

      final campaigns = await repo.loadAllCampaigns();
      expect(campaigns.length, 2);
    });
  });

  group('deleteCampaign', () {
    test('sends DELETE request', () async {
      final mock = MockClient((request) async {
        expect(request.method, 'DELETE');
        expect(request.url.path, contains('c-to-delete'));
        return http.Response('', 204);
      });

      final repo = SymmetryCampaignRepository(
        authRepository: _FakeAuthRepository(_testSession),
        clientFactory: (baseUrl) => SymmetryApiClient(httpClient: mock, baseUrl: baseUrl),
      );

      await repo.deleteCampaign('c-to-delete');
    });
  });

  group('loadCampaignRumors', () {
    test('fetches rumors', () async {
      final mock = MockClient((request) async {
        expect(request.url.query, contains('limit=10'));
        return http.Response(
          '[{"id":"r1","entity_type":"world_event","event_text":"Rumor 1","importance":5,"location_slug":"tavern","created_at":"2026-01-01T00:00:00Z"}]',
          200,
        );
      });

      final repo = SymmetryCampaignRepository(
        authRepository: _FakeAuthRepository(_testSession),
        clientFactory: (baseUrl) => SymmetryApiClient(httpClient: mock, baseUrl: baseUrl),
      );

      final rumors = await repo.loadCampaignRumors('c1', limit: 10);
      expect(rumors.length, 1);
      expect(rumors.first.id, 'r1');
    });
  });

  group('saveCampaign', () {
    test('is a no-op, does not throw', () async {
      final repo = SymmetryCampaignRepository(
        authRepository: _FakeAuthRepository(_testSession),
      );
      await repo.saveCampaign(_sampleCampaign());
    });
  });

  group('server state normalization', () {
    test('resolves title from server state json', () async {
      final mock = MockClient((_) async => http.Response(
        '{"campaign":{"id":"norm"},"state":{"id":"norm","title":"  in Moscow, where shadows  ","setting":"noir","mode":"story","difficulty":"easy","language":"en","turn_number":0},"snapshot_version":1}',
        200,
      ));

      final repo = SymmetryCampaignRepository(
        authRepository: _FakeAuthRepository(_testSession),
        clientFactory: (baseUrl) => SymmetryApiClient(httpClient: mock, baseUrl: baseUrl),
      );

      final state = await repo.loadCampaign('norm');
      expect(state!.title, isNotEmpty);
      expect(state.title, isNot(contains('where')));
    });

    test('resolves missing location to default', () async {
      final mock = MockClient((_) async => http.Response(
        '{"campaign":{"id":"noloc"},"state":{"id":"noloc","title":"A","setting":"fantasy","mode":"story","difficulty":"easy","language":"ru","location":"","turn_number":0},"snapshot_version":1}',
        200,
      ));

      final repo = SymmetryCampaignRepository(
        authRepository: _FakeAuthRepository(_testSession),
        clientFactory: (baseUrl) => SymmetryApiClient(httpClient: mock, baseUrl: baseUrl),
      );

      final state = await repo.loadCampaign('noloc');
      expect(state!.location, isNotEmpty);
    });
  });
}
