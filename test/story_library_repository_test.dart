import 'package:ai_prg/src/core/models/symmetry_models.dart';
import 'package:ai_prg/src/core/repositories/settings_repository.dart';
import 'package:ai_prg/src/core/repositories/story_library_repository.dart';
import 'package:ai_prg/src/core/repositories/symmetry_auth_repository.dart';
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

void main() {
  group('loadLiteraryGenres', () {
    test('fetches and sorts genres by sortOrder then slug', () async {
      final mock = MockClient((request) async {
        expect(request.url.path, contains('literary-genres'));
        return http.Response(
          '[{"slug":"noir","title_en":"Noir","title_ru":"Noir","sort_order":1},{"slug":"fantasy","title_en":"Fantasy","title_ru":"Fantasy","sort_order":0}]',
          200,
        );
      });

      final repo = StoryLibraryRepository(
        authRepository: _FakeAuthRepository(_testSession),
        clientFactory: (baseUrl) => SymmetryApiClient(httpClient: mock, baseUrl: baseUrl),
      );

      final genres = await repo.loadLiteraryGenres();
      expect(genres.length, 2);
      expect(genres.first.slug, 'fantasy');
      expect(genres.last.slug, 'noir');
    });
  });

  group('loadTemplates', () {
    test('passes filters to API', () async {
      final mock = MockClient((request) async {
        expect(request.url.query, contains('tag=fantasy'));
        expect(request.url.query, contains('genre=epic'));
        expect(request.url.query, contains('sort=popular'));
        expect(request.url.query, contains('scope=public'));
        return http.Response('[]', 200);
      });

      final repo = StoryLibraryRepository(
        authRepository: _FakeAuthRepository(_testSession),
        clientFactory: (baseUrl) => SymmetryApiClient(httpClient: mock, baseUrl: baseUrl),
      );

      final templates = await repo.loadTemplates(
        tag: 'fantasy',
        genre: 'epic',
        sort: 'popular',
        scope: 'public',
      );
      expect(templates, isEmpty);
    });
  });

  group('loadTemplate', () {
    test('fetches single template', () async {
      final mock = MockClient((request) async {
        expect(request.url.path, contains('st1'));
        return http.Response(
          '{"id":"st1","title":"Epic Quest","author_name":"GM","tag":"fantasy","genres":["fantasy"],"status":"published"}',
          200,
        );
      });

      final repo = StoryLibraryRepository(
        authRepository: _FakeAuthRepository(_testSession),
        clientFactory: (baseUrl) => SymmetryApiClient(httpClient: mock, baseUrl: baseUrl),
      );

      final template = await repo.loadTemplate('st1');
      expect(template.id, 'st1');
      expect(template.title, 'Epic Quest');
    });
  });

  group('publishStoryTemplate', () {
    test('sends payload to create endpoint', () async {
      final mock = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.body, contains('"title":"New"'));
        return http.Response(
          '{"id":"st2","title":"New","author_name":"GM","tag":"scifi","genres":["scifi"],"status":"draft"}',
          200,
        );
      });

      final repo = StoryLibraryRepository(
        authRepository: _FakeAuthRepository(_testSession),
        clientFactory: (baseUrl) => SymmetryApiClient(httpClient: mock, baseUrl: baseUrl),
      );

      final template = await repo.publishStoryTemplate(
        payload: <String, Object?>{'title': 'New'},
      );
      expect(template.id, 'st2');
    });
  });

  group('recordView', () {
    test('posts view', () async {
      final mock = MockClient((request) async {
        expect(request.url.path, contains('view'));
        expect(request.method, 'POST');
        return http.Response('{}', 200);
      });

      final repo = StoryLibraryRepository(
        authRepository: _FakeAuthRepository(_testSession),
        clientFactory: (baseUrl) => SymmetryApiClient(httpClient: mock, baseUrl: baseUrl),
      );

      await repo.recordView('st1');
    });
  });

  group('toggleLike', () {
    test('posts like', () async {
      final mock = MockClient((request) async {
        expect(request.url.path, contains('like'));
        expect(request.method, 'POST');
        return http.Response('{}', 200);
      });

      final repo = StoryLibraryRepository(
        authRepository: _FakeAuthRepository(_testSession),
        clientFactory: (baseUrl) => SymmetryApiClient(httpClient: mock, baseUrl: baseUrl),
      );

      await repo.toggleLike('st1');
    });
  });

  group('loadAllTemplatesAdmin', () {
    test('fetches admin list', () async {
      final mock = MockClient((request) async {
        expect(request.url.path, contains('admin'));
        expect(request.url.query, contains('sort=new'));
        return http.Response(
          '[{"id":"st3","title":"Admin Story","author_name":"Admin","tag":"horror","genres":["horror"],"status":"draft"}]',
          200,
        );
      });

      final repo = StoryLibraryRepository(
        authRepository: _FakeAuthRepository(_testSession),
        clientFactory: (baseUrl) => SymmetryApiClient(httpClient: mock, baseUrl: baseUrl),
      );

      final templates = await repo.loadAllTemplatesAdmin();
      expect(templates.length, 1);
      expect(templates.first.title, 'Admin Story');
    });
  });

  group('saveStoryTemplateAdmin', () {
    test('creates when no templateId', () async {
      final mock = MockClient((request) async {
        expect(request.method, 'POST');
        return http.Response(
          '{"id":"st4","title":"Created","author_name":"Admin","tag":"fantasy","genres":["fantasy"],"status":"draft"}',
          200,
        );
      });

      final repo = StoryLibraryRepository(
        authRepository: _FakeAuthRepository(_testSession),
        clientFactory: (baseUrl) => SymmetryApiClient(httpClient: mock, baseUrl: baseUrl),
      );

      final template = await repo.saveStoryTemplateAdmin(
        payload: <String, Object?>{'title': 'Created'},
      );
      expect(template.id, 'st4');
    });

    test('updates when templateId provided', () async {
      final mock = MockClient((request) async {
        expect(request.method, 'PATCH');
        expect(request.url.path, contains('st5'));
        return http.Response(
          '{"id":"st5","title":"Updated","author_name":"Admin","tag":"fantasy","genres":["fantasy"],"status":"published"}',
          200,
        );
      });

      final repo = StoryLibraryRepository(
        authRepository: _FakeAuthRepository(_testSession),
        clientFactory: (baseUrl) => SymmetryApiClient(httpClient: mock, baseUrl: baseUrl),
      );

      final template = await repo.saveStoryTemplateAdmin(
        payload: <String, Object?>{'title': 'Updated'},
        templateId: 'st5',
      );
      expect(template.title, 'Updated');
    });
  });

  group('deleteStoryTemplateAdmin', () {
    test('sends DELETE', () async {
      final mock = MockClient((request) async {
        expect(request.method, 'DELETE');
        expect(request.url.path, contains('st6'));
        return http.Response('', 204);
      });

      final repo = StoryLibraryRepository(
        authRepository: _FakeAuthRepository(_testSession),
        clientFactory: (baseUrl) => SymmetryApiClient(httpClient: mock, baseUrl: baseUrl),
      );

      await repo.deleteStoryTemplateAdmin('st6');
    });
  });

  group('uploadStoryTemplateCover', () {
    test('sends cover bytes', () async {
      final mock = MockClient((request) async {
        expect(request.method, 'PUT');
        expect(request.url.path, contains('cover'));
        expect(request.headers['Content-Type'], 'image/jpeg');
        return http.Response('', 200);
      });

      final repo = StoryLibraryRepository(
        authRepository: _FakeAuthRepository(_testSession),
        clientFactory: (baseUrl) => SymmetryApiClient(httpClient: mock, baseUrl: baseUrl),
      );

      await repo.uploadStoryTemplateCover(
        templateId: 'st1',
        bytes: [1, 2, 3],
        contentType: 'image/jpeg',
      );
    });
  });

  group('deleteStoryTemplateCover', () {
    test('sends DELETE for cover', () async {
      final mock = MockClient((request) async {
        expect(request.method, 'DELETE');
        expect(request.url.path, contains('cover'));
        return http.Response('', 204);
      });

      final repo = StoryLibraryRepository(
        authRepository: _FakeAuthRepository(_testSession),
        clientFactory: (baseUrl) => SymmetryApiClient(httpClient: mock, baseUrl: baseUrl),
      );

      await repo.deleteStoryTemplateCover('st1');
    });
  });
}
