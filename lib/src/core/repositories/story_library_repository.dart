import 'package:ai_prg/src/core/models/literary_genre_model.dart';
import 'package:ai_prg/src/core/models/story_template_model.dart';
import 'package:ai_prg/src/core/models/symmetry_models.dart';
import 'package:ai_prg/src/core/repositories/symmetry_auth_repository.dart';
import 'package:ai_prg/src/core/services/symmetry_api_client.dart';

class StoryLibraryRepository {
  StoryLibraryRepository({required SymmetryAuthRepository authRepository})
    : _authRepository = authRepository;

  final SymmetryAuthRepository _authRepository;

  SymmetryApiClient _client(final String baseUrl) =>
      SymmetryApiClient(baseUrl: baseUrl);

  Future<List<LiteraryGenreCatalogItem>> loadLiteraryGenres() async {
    final SymmetrySession session = await _authRepository.ensureSession();
    final List<LiteraryGenreCatalogItem> rows =
        await _client(session.baseUrl).listLiteraryGenres(
      accessToken: session.tokens.accessToken,
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
  }) async {
    final SymmetrySession session = await _authRepository.ensureSession();
    return _client(session.baseUrl).listStoryTemplates(
      accessToken: session.tokens.accessToken,
      tag: tag,
      genre: genre,
      sort: sort,
      scope: scope,
    );
  }

  Future<StoryTemplate> loadTemplate(final String templateId) async {
    final SymmetrySession session = await _authRepository.ensureSession();
    return _client(session.baseUrl).getStoryTemplate(
      accessToken: session.tokens.accessToken,
      templateId: templateId,
    );
  }

  Future<StoryTemplate> publishStoryTemplate({
    required final Map<String, Object?> payload,
  }) async {
    final SymmetrySession session = await _authRepository.ensureSession();
    return _client(session.baseUrl).createStoryTemplate(
      accessToken: session.tokens.accessToken,
      body: payload,
    );
  }

  Future<void> recordView(final String templateId) async {
    final SymmetrySession session = await _authRepository.ensureSession();
    await _client(session.baseUrl).postStoryTemplateView(
      accessToken: session.tokens.accessToken,
      templateId: templateId,
    );
  }

  Future<void> toggleLike(final String templateId) async {
    final SymmetrySession session = await _authRepository.ensureSession();
    await _client(session.baseUrl).postStoryTemplateLike(
      accessToken: session.tokens.accessToken,
      templateId: templateId,
    );
  }

  Future<List<StoryTemplate>> loadAllTemplatesAdmin({
    final String sort = 'new',
    final String? tag,
    final String? genre,
  }) async {
    final SymmetrySession session = await _authRepository.ensureSession();
    return _client(session.baseUrl).adminListStoryTemplates(
      accessToken: session.tokens.accessToken,
      sort: sort,
      tag: tag,
      genre: genre,
    );
  }

  Future<StoryTemplate> saveStoryTemplateAdmin({
    required final Map<String, Object?> payload,
    final String? templateId,
  }) async {
    final SymmetrySession session = await _authRepository.ensureSession();
    return _client(session.baseUrl).adminUpsertStoryTemplate(
      accessToken: session.tokens.accessToken,
      body: payload,
      templateId: templateId,
    );
  }

  Future<void> deleteStoryTemplateAdmin(final String templateId) async {
    final SymmetrySession session = await _authRepository.ensureSession();
    await _client(session.baseUrl).adminDeleteStoryTemplate(
      accessToken: session.tokens.accessToken,
      templateId: templateId,
    );
  }

  Future<void> uploadStoryTemplateCover({
    required final String templateId,
    required final List<int> bytes,
    required final String contentType,
  }) async {
    final SymmetrySession session = await _authRepository.ensureSession();
    await _client(session.baseUrl).adminPutStoryTemplateCoverRaw(
      accessToken: session.tokens.accessToken,
      templateId: templateId,
      bytes: bytes,
      contentType: contentType,
    );
  }

  Future<void> deleteStoryTemplateCover(final String templateId) async {
    final SymmetrySession session = await _authRepository.ensureSession();
    await _client(session.baseUrl).adminDeleteStoryTemplateCover(
      accessToken: session.tokens.accessToken,
      templateId: templateId,
    );
  }
}
