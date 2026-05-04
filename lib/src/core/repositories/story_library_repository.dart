import 'package:ai_prg/src/core/models/literary_genre_model.dart';
import 'package:ai_prg/src/core/models/story_template_model.dart';
import 'package:ai_prg/src/core/repositories/symmetry_auth_repository.dart';
import 'package:ai_prg/src/core/services/symmetry_api_client.dart';

class StoryLibraryRepository {
  StoryLibraryRepository({
    required SymmetryAuthRepository authRepository,
    SymmetryApiClient Function(String baseUrl)? clientFactory,
  }) : _authRepository = authRepository,
       _clientFactory = clientFactory;

  final SymmetryAuthRepository _authRepository;
  final SymmetryApiClient Function(String baseUrl)? _clientFactory;

  SymmetryApiClient _client(final String baseUrl) =>
      _clientFactory?.call(baseUrl) ?? SymmetryApiClient(baseUrl: baseUrl);

  Future<List<LiteraryGenreCatalogItem>> loadLiteraryGenres() async {
    final List<LiteraryGenreCatalogItem> rows = await _authRepository
        .runWithAuthorizedSession(
          (final session) => _client(
            session.baseUrl,
          ).listLiteraryGenres(accessToken: session.tokens.accessToken),
        );
    rows.sort((final a, final b) {
      final int byOrder = a.sortOrder.compareTo(b.sortOrder);
      if (byOrder != 0) {
        return byOrder;
      }
      return a.slug.compareTo(b.slug);
    });
    return rows;
  }

  Future<List<StoryTemplate>> loadTemplates({
    final String? tag,
    final String? genre,
    final String sort = 'new',
    final String scope = 'all',
  }) => _authRepository.runWithAuthorizedSession(
    (final session) => _client(session.baseUrl).listStoryTemplates(
      accessToken: session.tokens.accessToken,
      tag: tag,
      genre: genre,
      sort: sort,
      scope: scope,
    ),
  );

  Future<StoryTemplate> loadTemplate(final String templateId) =>
      _authRepository.runWithAuthorizedSession(
        (final session) => _client(session.baseUrl).getStoryTemplate(
          accessToken: session.tokens.accessToken,
          templateId: templateId,
        ),
      );

  Future<StoryTemplate> publishStoryTemplate({
    required final Map<String, Object?> payload,
  }) => _authRepository.runWithAuthorizedSession(
    (final session) => _client(session.baseUrl).createStoryTemplate(
      accessToken: session.tokens.accessToken,
      body: payload,
    ),
  );

  Future<void> recordView(final String templateId) =>
      _authRepository.runWithAuthorizedSession(
        (final session) => _client(session.baseUrl).postStoryTemplateView(
          accessToken: session.tokens.accessToken,
          templateId: templateId,
        ),
      );

  Future<void> toggleLike(final String templateId) =>
      _authRepository.runWithAuthorizedSession(
        (final session) => _client(session.baseUrl).postStoryTemplateLike(
          accessToken: session.tokens.accessToken,
          templateId: templateId,
        ),
      );

  Future<List<StoryTemplate>> loadAllTemplatesAdmin({
    final String sort = 'new',
    final String? tag,
    final String? genre,
  }) => _authRepository.runWithAuthorizedSession(
    (final session) => _client(session.baseUrl).adminListStoryTemplates(
      accessToken: session.tokens.accessToken,
      sort: sort,
      tag: tag,
      genre: genre,
    ),
    allowGuest: false,
  );

  Future<StoryTemplate> saveStoryTemplateAdmin({
    required final Map<String, Object?> payload,
    final String? templateId,
  }) => _authRepository.runWithAuthorizedSession(
    (final session) => _client(session.baseUrl).adminUpsertStoryTemplate(
      accessToken: session.tokens.accessToken,
      body: payload,
      templateId: templateId,
    ),
    allowGuest: false,
  );

  Future<void> deleteStoryTemplateAdmin(final String templateId) =>
      _authRepository.runWithAuthorizedSession(
        (final session) => _client(session.baseUrl).adminDeleteStoryTemplate(
          accessToken: session.tokens.accessToken,
          templateId: templateId,
        ),
        allowGuest: false,
      );

  Future<void> uploadStoryTemplateCover({
    required final String templateId,
    required final List<int> bytes,
    required final String contentType,
  }) => _authRepository.runWithAuthorizedSession(
    (final session) => _client(session.baseUrl).adminPutStoryTemplateCoverRaw(
      accessToken: session.tokens.accessToken,
      templateId: templateId,
      bytes: bytes,
      contentType: contentType,
    ),
    allowGuest: false,
  );

  Future<void> deleteStoryTemplateCover(final String templateId) =>
      _authRepository.runWithAuthorizedSession(
        (final session) =>
            _client(session.baseUrl).adminDeleteStoryTemplateCover(
              accessToken: session.tokens.accessToken,
              templateId: templateId,
            ),
        allowGuest: false,
      );
}
