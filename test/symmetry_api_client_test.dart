import 'package:ai_prg/src/core/models/ai_settings.dart';
import 'package:ai_prg/src/core/models/symmetry_models.dart';
import 'package:ai_prg/src/core/services/symmetry_api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  // ── normalizeSymmetryApiBaseUrl ────────────────────────────────────

  group('normalizeSymmetryApiBaseUrl', () {
    test('returns default when empty', () {
      expect(
        normalizeSymmetryApiBaseUrl(''),
        'http://127.0.0.1:8080/v1',
      );
    });

    test('returns default when whitespace only', () {
      expect(
        normalizeSymmetryApiBaseUrl('   '),
        'http://127.0.0.1:8080/v1',
      );
    });

    test('strips trailing slash', () {
      expect(
        normalizeSymmetryApiBaseUrl('http://127.0.0.1:8080/v1/'),
        'http://127.0.0.1:8080/v1',
      );
    });

    test('keeps /v1 suffix unchanged', () {
      expect(
        normalizeSymmetryApiBaseUrl('http://192.168.1.100:8080/v1'),
        'http://192.168.1.100:8080/v1',
      );
    });

    test('appends /v1 to loopback without path', () {
      expect(
        normalizeSymmetryApiBaseUrl('http://localhost:8080'),
        'http://localhost:8080/v1',
      );
    });

    test('appends /v1 to 127.0.0.1 without path', () {
      expect(
        normalizeSymmetryApiBaseUrl('http://127.0.0.1:9090'),
        'http://127.0.0.1:9090/v1',
      );
    });

    test('appends /v1 to ::1 without path', () {
      expect(
        normalizeSymmetryApiBaseUrl('http://[::1]:8080'),
        'http://[::1]:8080/v1',
      );
    });

    test('does NOT append /v1 to non-loopback', () {
      expect(
        normalizeSymmetryApiBaseUrl('https://symmetry.example.com'),
        'https://symmetry.example.com',
      );
    });

    test('does NOT append /v1 when path already present', () {
      expect(
        normalizeSymmetryApiBaseUrl('http://localhost:8080/api'),
        'http://localhost:8080/api',
      );
    });

    test('passthrough for unparseable string', () {
      expect(
        normalizeSymmetryApiBaseUrl('not a url'),
        'not a url',
      );
    });
  });

  // ── Constructor ────────────────────────────────────────────────────

  group('SymmetryApiClient constructor', () {
    test('normalizes base URL', () {
      final client = SymmetryApiClient(baseUrl: 'http://localhost:8080');
      expect(client.baseUrl, 'http://localhost:8080/v1');
    });

    test('accepts external http client', () {
      final httpClient = MockClient((_) async => http.Response('{}', 200));
      final client = SymmetryApiClient(httpClient: httpClient);
      expect(client.httpClient, same(httpClient));
    });
  });

  // ── Health Check ───────────────────────────────────────────────────

  group('checkHealth', () {
    test('succeeds on 200', () async {
      final mock = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, contains('health'));
        return http.Response('', 200);
      });
      final client = SymmetryApiClient(httpClient: mock);
      await client.checkHealth();
    });

    test('throws on 500', () async {
      final mock = MockClient((_) async => http.Response('', 500));
      final client = SymmetryApiClient(httpClient: mock);
      expect(
        client.checkHealth(),
        throwsA(isA<SymmetryApiException>()),
      );
    });

    test('rethrows network errors', () async {
      final mock = MockClient((_) async {
        throw http.ClientException('Connection refused');
      });
      final client = SymmetryApiClient(httpClient: mock);
      expect(
        client.checkHealth(),
        throwsA(isA<http.ClientException>()),
      );
    });
  });

  // ── Auth Endpoints ─────────────────────────────────────────────────

  group('guestLogin', () {
    test('parses success response', () async {
      final mock = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, contains('auth/guest'));
        return http.Response(
          '{"tokens":{"access_token":"at","refresh_token":"rt"},"user":{"id":"u1","email":""}}',
          200,
        );
      });
      final client = SymmetryApiClient(httpClient: mock);
      final response = await client.guestLogin();
      expect(response.tokens.accessToken, 'at');
      expect(response.tokens.refreshToken, 'rt');
    });

    test('throws on non-200', () async {
      final mock = MockClient((_) async => http.Response('{"detail":"error"}', 401));
      final client = SymmetryApiClient(httpClient: mock);
      expect(client.guestLogin(), throwsA(isA<SymmetryApiException>()));
    });
  });

  group('login', () {
    test('sends email and password', () async {
      final mock = MockClient((request) async {
        expect(request.body, contains('email'));
        expect(request.body, contains('password'));
        return http.Response(
          '{"tokens":{"access_token":"at","refresh_token":"rt"},"user":{"id":"u1","email":"test@test.com"}}',
          200,
        );
      });
      final client = SymmetryApiClient(httpClient: mock);
      final response = await client.login(email: 'test@test.com', password: 'secret');
      expect(response.user.email, 'test@test.com');
    });
  });

  group('register', () {
    test('sends registration payload', () async {
      final mock = MockClient((request) async {
        expect(request.body, contains('display_name'));
        return http.Response(
          '{"tokens":{"access_token":"at","refresh_token":"rt"},"user":{"id":"u2","email":"new@test.com"}}',
          200,
        );
      });
      final client = SymmetryApiClient(httpClient: mock);
      final response = await client.register(email: 'new@test.com', password: 'pwd', displayName: 'NewUser');
      expect(response.user.id, 'u2');
    });
  });

  group('refresh', () {
    test('sends refresh token', () async {
      final mock = MockClient((request) async {
        expect(request.body, contains('refresh_token'));
        return http.Response(
          '{"tokens":{"access_token":"new_at","refresh_token":"new_rt"},"user":{"id":"u3","email":"e@t.com"}}',
          200,
        );
      });
      final client = SymmetryApiClient(httpClient: mock);
      final response = await client.refresh(refreshToken: 'old_rt');
      expect(response.tokens.accessToken, 'new_at');
    });
  });

  group('completeYandexHandoff', () {
    test('sends handoff id', () async {
      final mock = MockClient((request) async {
        expect(request.body, contains('handoff_id'));
        return http.Response(
          '{"tokens":{"access_token":"at","refresh_token":"rt"},"user":{"id":"ya1","email":"ya@ya.ru"}}',
          200,
        );
      });
      final client = SymmetryApiClient(httpClient: mock);
      final response = await client.completeYandexHandoff(handoffId: 'h123');
      expect(response.user.id, 'ya1');
    });
  });

  group('logout', () {
    test('sends refresh token and succeeds on 200', () async {
      final mock = MockClient((request) async {
        expect(request.method, 'POST');
        return http.Response('{}', 200);
      });
      final client = SymmetryApiClient(httpClient: mock);
      await client.logout(refreshToken: 'rt');
    });
  });

  group('getCurrentUser', () {
    test('parses user from GET /auth/me', () async {
      final mock = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, contains('auth/me'));
        return http.Response('{"id":"u5","email":"me@test.com"}', 200);
      });
      final client = SymmetryApiClient(httpClient: mock);
      final user = await client.getCurrentUser(accessToken: 'at');
      expect(user.id, 'u5');
      expect(user.email, 'me@test.com');
    });

    test('throws StateError on non-map response', () async {
      final mock = MockClient((_) async => http.Response('[]', 200));
      final client = SymmetryApiClient(httpClient: mock);
      expect(
        client.getCurrentUser(accessToken: 'at'),
        throwsA(isA<StateError>()),
      );
    });
  });

  // ── Campaign Endpoints ─────────────────────────────────────────────

  group('createCampaign', () {
    test('sends payload and parses response', () async {
      final mock = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, endsWith('campaigns'));
        return http.Response(
          '{"campaign":{"id":"c1"},"state":{},"snapshot_version":1}',
          200,
        );
      });
      final client = SymmetryApiClient(httpClient: mock);
      final response = await client.createCampaign(
        accessToken: 'at',
        payload: <String, Object?>{'setting': 'fantasy'},
      );
      expect(response.campaignId, 'c1');
    });
  });

  group('listCampaigns', () {
    test('parses list response', () async {
      final mock = MockClient((request) async {
        expect(request.method, 'GET');
        return http.Response(
          '[{"id":"c1","setting":"fantasy","title":"Test","mode":"story","difficulty":"easy","language":"ru","status":"active"}]',
          200,
        );
      });
      final client = SymmetryApiClient(httpClient: mock);
      final list = await client.listCampaigns(accessToken: 'at');
      expect(list.length, 1);
      expect(list.first.id, 'c1');
    });

    test('throws StateError on non-list response', () async {
      final mock = MockClient((_) async => http.Response('{}', 200));
      final client = SymmetryApiClient(httpClient: mock);
      expect(
        client.listCampaigns(accessToken: 'at'),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('getCampaignState', () {
    test('parses campaign state', () async {
      final mock = MockClient((request) async {
        expect(request.url.path, contains('state'));
        return http.Response(
          '{"campaign":{"id":"c1"},"state":{},"snapshot_version":1}',
          200,
        );
      });
      final client = SymmetryApiClient(httpClient: mock);
      final state = await client.getCampaignState(accessToken: 'at', campaignId: 'c1');
      expect(state.campaignId, 'c1');
    });

    test('throws StateError on non-map', () async {
      final mock = MockClient((_) async => http.Response('null', 200));
      final client = SymmetryApiClient(httpClient: mock);
      expect(
        client.getCampaignState(accessToken: 'at', campaignId: 'c1'),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('deleteCampaign', () {
    test('sends DELETE request', () async {
      final mock = MockClient((request) async {
        expect(request.method, 'DELETE');
        expect(request.url.path, contains('campaigns/c1'));
        return http.Response('', 204);
      });
      final client = SymmetryApiClient(httpClient: mock);
      await client.deleteCampaign(accessToken: 'at', campaignId: 'c1');
    });

    test('throws on error status', () async {
      final mock = MockClient((_) async => http.Response('', 403));
      final client = SymmetryApiClient(httpClient: mock);
      expect(
        client.deleteCampaign(accessToken: 'at', campaignId: 'c1'),
        throwsA(isA<SymmetryApiException>()),
      );
    });
  });

  // ── Turn Processing ────────────────────────────────────────────────

  group('processTurn', () {
    test('sends player action and returns response', () async {
      final mock = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.body, contains('player_action'));
        expect(request.body, contains('trigger_source'));
        return http.Response(
          '{"narration":"You enter the cave.","choices":["Go deeper","Turn back"],"state_changes":{},"memory_entry":"","request_id":"r1","state":{}}',
          200,
        );
      });
      final client = SymmetryApiClient(httpClient: mock);
      final response = await client.processTurn(
        accessToken: 'at',
        campaignId: 'c1',
        playerAction: 'Look around',
        languageCode: 'ru',
        aiSettings: const AiSettings.defaults(),
      );
      expect(response.narration, 'You enter the cave.');
    });

    test('includes provider credentials when all fields are present', () async {
      final mock = MockClient((request) async {
        expect(request.body, contains('provider_credentials'));
        expect(request.body, contains('api_key'));
        return http.Response(
          '{"narration":"ok","choices":[],"state_changes":{},"memory_entry":"","request_id":"r1","state":{}}',
          200,
        );
      });
      final client = SymmetryApiClient(httpClient: mock);
      await client.processTurn(
        accessToken: 'at',
        campaignId: 'c1',
        playerAction: 'test',
        languageCode: 'en',
        aiSettings: const AiSettings(
          baseUrl: 'https://api.openai.com/v1',
          model: 'gpt-4',
          apiKey: 'sk-test',
          timeoutSeconds: 60,
          runtimeSettings: ModelRuntimeSettings.defaults,
        ),
      );
    });

    test('omits provider credentials when apiKey is empty', () async {
      final mock = MockClient((request) async {
        expect(request.body, isNot(contains('provider_credentials')));
        return http.Response(
          '{"narration":"ok","choices":[],"state_changes":{},"memory_entry":"","request_id":"r1","state":{}}',
          200,
        );
      });
      final client = SymmetryApiClient(httpClient: mock);
      await client.processTurn(
        accessToken: 'at',
        campaignId: 'c1',
        playerAction: 'test',
        languageCode: 'en',
        aiSettings: const AiSettings.defaults(),
      );
    });
  });

  // ── Story Templates ────────────────────────────────────────────────

  group('listStoryTemplates', () {
    test('builds query string and parses list', () async {
      final mock = MockClient((request) async {
        expect(request.url.query, contains('sort=new'));
        expect(request.url.query, contains('scope=all'));
        return http.Response(
          '[{"id":"st1","title":"Epic Quest","author_name":"GM","tag":"fantasy","genres":["fantasy"],"status":"published"}]',
          200,
        );
      });
      final client = SymmetryApiClient(httpClient: mock);
      final templates = await client.listStoryTemplates(accessToken: 'at');
      expect(templates.length, 1);
      expect(templates.first.id, 'st1');
      expect(templates.first.title, 'Epic Quest');
    });

    test('includes optional tag and genre in query', () async {
      final mock = MockClient((request) async {
        expect(request.url.query, contains('tag=fantasy'));
        expect(request.url.query, contains('genre=epic'));
        return http.Response('[]', 200);
      });
      final client = SymmetryApiClient(httpClient: mock);
      await client.listStoryTemplates(accessToken: 'at', tag: 'fantasy', genre: 'epic');
    });

    test('throws StateError on non-list', () async {
      final mock = MockClient((_) async => http.Response('invalid', 200));
      final client = SymmetryApiClient(httpClient: mock);
      expect(
        client.listStoryTemplates(accessToken: 'at'),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('createStoryTemplate', () {
    test('sends body and returns template', () async {
      final mock = MockClient((request) async {
        expect(request.method, 'POST');
        return http.Response(
          '{"id":"st2","title":"New Story","author_name":"Admin","tag":"scifi","genres":["scifi"],"status":"draft"}',
          200,
        );
      });
      final client = SymmetryApiClient(httpClient: mock);
      final template = await client.createStoryTemplate(
        accessToken: 'at',
        body: <String, Object?>{'title': 'New Story'},
      );
      expect(template.id, 'st2');
    });
  });

  group('getStoryTemplate', () {
    test('fetches single template', () async {
      final mock = MockClient((request) async {
        expect(request.url.path, contains('st3'));
        return http.Response(
          '{"id":"st3","title":"Single","author_name":"GM","tag":"horror","genres":["horror"],"status":"published"}',
          200,
        );
      });
      final client = SymmetryApiClient(httpClient: mock);
      final template = await client.getStoryTemplate(accessToken: 'at', templateId: 'st3');
      expect(template.title, 'Single');
    });
  });

  // ── Error Handling ─────────────────────────────────────────────────

  group('error handling', () {
    test('extracts detail code from error response', () async {
      final mock = MockClient((_) async =>
          http.Response('{"detail":"campaign_not_found"}', 404));
      final client = SymmetryApiClient(httpClient: mock);
      try {
        await client.getCampaignState(accessToken: 'at', campaignId: 'gone');
        fail('should throw');
      } on SymmetryApiException catch (e) {
        expect(e.statusCode, 404);
        expect(e.detailCode, 'campaign_not_found');
        expect(e.message, contains('404'));
      }
    });

    test('extracts validation errors from 422 response', () async {
      final mock = MockClient((_) async => http.Response(
        '{"detail":[{"loc":["body","title"],"msg":"Field required"}]}',
        422,
      ));
      final client = SymmetryApiClient(httpClient: mock);
      try {
        await client.createStoryTemplate(accessToken: 'at', body: <String, Object?>{});
        fail('should throw');
      } on SymmetryApiException catch (e) {
        expect(e.statusCode, 422);
        expect(e.validationErrors.length, 1);
        expect(e.validationErrors.first, 'title: Field required');
      }
    });

    test('handles empty response body gracefully', () async {
      final mock = MockClient((_) async => http.Response('', 500));
      final client = SymmetryApiClient(httpClient: mock);
      try {
        await client.getCampaignState(accessToken: 'at', campaignId: 'c1');
        fail('should throw');
      } on SymmetryApiException catch (e) {
        expect(e.statusCode, 500);
        expect(e.detailCode, isNull);
      }
    });

    test('handles malformed JSON error body', () async {
      final mock = MockClient((_) async => http.Response('not json', 502));
      final client = SymmetryApiClient(httpClient: mock);
      try {
        await client.getCampaignState(accessToken: 'at', campaignId: 'c1');
        fail('should throw');
      } on SymmetryApiException catch (e) {
        expect(e.statusCode, 502);
      }
    });
  });

  // ── Bearer Token ───────────────────────────────────────────────────

  group('authorization header', () {
    test('includes bearer token when provided', () async {
      final mock = MockClient((request) async {
        expect(request.headers['Authorization'], 'Bearer my_token');
        return http.Response('[]', 200);
      });
      final client = SymmetryApiClient(httpClient: mock);
      await client.listCampaigns(accessToken: 'my_token');
    });

    test('omits Authorization when access token is empty', () async {
      final mock = MockClient((request) async {
        expect(request.headers.containsKey('Authorization'), isFalse);
        return http.Response('[]', 200);
      });
      final client = SymmetryApiClient(httpClient: mock);
      await client.listStoryTemplates(accessToken: '');
    });
  });

  // ── Map Endpoints ──────────────────────────────────────────────────

  group('getCampaignMap', () {
    test('parses map response', () async {
      final mock = MockClient((request) async {
        expect(request.url.path, contains('map'));
        return http.Response('{"nodes":[],"links":[]}', 200);
      });
      final client = SymmetryApiClient(httpClient: mock);
      final map = await client.getCampaignMap(accessToken: 'at', campaignId: 'c1');
      expect(map['nodes'], isEmpty);
    });
  });

  group('seedCampaignMap', () {
    test('posts and returns seeded map', () async {
      final mock = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, contains('seed'));
        return http.Response('{"nodes":[{"id":"n1","label":"Forest"}],"links":[]}', 200);
      });
      final client = SymmetryApiClient(httpClient: mock);
      final map = await client.seedCampaignMap(accessToken: 'at', campaignId: 'c1');
      expect(map['nodes'], hasLength(1));
    });
  });

  group('submitMapProposals', () {
    test('sends proposals payload', () async {
      final mock = MockClient((request) async {
        expect(request.body, contains('proposals'));
        return http.Response('{"nodes":[],"links":[]}', 200);
      });
      final client = SymmetryApiClient(httpClient: mock);
      await client.submitMapProposals(
        accessToken: 'at',
        campaignId: 'c1',
        proposals: [<String, dynamic>{'node_id': 'n1', 'action': 'reveal'}],
      );
    });
  });

  group('markMapSeen', () {
    test('posts mark-seen', () async {
      final mock = MockClient((request) async {
        expect(request.url.path, contains('mark-seen'));
        return http.Response('{}', 200);
      });
      final client = SymmetryApiClient(httpClient: mock);
      await client.markMapSeen(accessToken: 'at', campaignId: 'c1');
    });
  });

  // ── Version ────────────────────────────────────────────────────────

  group('getVersionInfo', () {
    test('fetches version with query params', () async {
      final mock = MockClient((request) async {
        expect(request.url.query, contains('current_version=1.0.0'));
        return http.Response(
          '{"api_version":"1.1.0","release_id":"rel2","released_at":"2026-01-01","platforms":{"android":{"version":"1.1.0"},"ios":{"version":"1.1.0"}}}',
          200,
        );
      });
      final client = SymmetryApiClient(httpClient: mock);
      final info = await client.getVersionInfo(currentVersion: '1.0.0');
      expect(info.apiVersion, '1.1.0');
    });

    test('fetches version without query when both params null', () async {
      final mock = MockClient((request) async {
        expect(request.url.query, isEmpty);
        return http.Response(
          '{"api_version":"1.0.0","release_id":"rel1","released_at":"2025-01-01","platforms":{}}',
          200,
        );
      });
      final client = SymmetryApiClient(httpClient: mock);
      final info = await client.getVersionInfo();
      expect(info.apiVersion, '1.0.0');
    });
  });

  // ── Literary Genres ────────────────────────────────────────────────

  group('listLiteraryGenres', () {
    test('parses genre list', () async {
      final mock = MockClient((request) async {
        expect(request.url.path, contains('literary-genres'));
        return http.Response(
          '[{"slug":"fantasy","title_en":"Fantasy","title_ru":"Fantasy RU","sort_order":0},{"slug":"noir","title_en":"Noir","title_ru":"Noir RU","sort_order":1}]',
          200,
        );
      });
      final client = SymmetryApiClient(httpClient: mock);
      final genres = await client.listLiteraryGenres(accessToken: 'at');
      expect(genres.length, 2);
      expect(genres.first.slug, 'fantasy');
      expect(genres.first.titleEn, 'Fantasy');
    });
  });

  // ── Rumors ─────────────────────────────────────────────────────────

  group('getCampaignRumors', () {
    test('fetches rumors with limit', () async {
      final mock = MockClient((request) async {
        expect(request.url.query, contains('limit=3'));
        return http.Response(
          '[{"id":"r1","entity_type":"world_event","event_text":"Something stirs.","importance":5,"location_slug":"old-town","created_at":"2026-01-01T00:00:00Z"}]',
          200,
        );
      });
      final client = SymmetryApiClient(httpClient: mock);
      final rumors = await client.getCampaignRumors(
        accessToken: 'at',
        campaignId: 'c1',
        limit: 3,
      );
      expect(rumors.length, 1);
      expect(rumors.first.id, 'r1');
    });
  });
}
