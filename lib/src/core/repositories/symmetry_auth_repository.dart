import 'package:ai_prg/src/core/config/symmetry_runtime_env.dart';
import 'package:ai_prg/src/core/models/ai_settings.dart';
import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:ai_prg/src/core/models/symmetry_models.dart';
import 'package:ai_prg/src/core/repositories/settings_repository.dart';
import 'package:ai_prg/src/core/services/symmetry_api_client.dart';

class SymmetryAuthRepository {
  SymmetryAuthRepository({
    required SettingsRepository settingsRepository,
    SymmetryApiClient Function(String baseUrl)? clientFactory,
  }) : _settingsRepository = settingsRepository,
       _clientFactory = clientFactory;

  final SettingsRepository _settingsRepository;
  final SymmetryApiClient Function(String baseUrl)? _clientFactory;

  Future<String> loadBaseUrl() async {
    final String? persisted = await _settingsRepository.loadSymmetryBaseUrl();
    if (persisted != null && persisted.trim().isNotEmpty) {
      return persisted.trim();
    }
    return SymmetryRuntimeEnv.defaultBaseUrl;
  }

  Future<void> saveBaseUrl(final String baseUrl) =>
      _settingsRepository.saveSymmetryBaseUrl(baseUrl.trim());

  Future<SymmetrySession?> loadSession() =>
      _settingsRepository.loadSymmetrySession();

  Future<bool> hasSession() async =>
      (await _settingsRepository.loadSymmetrySession()) != null;

  Future<SymmetrySession> guestLogin() async {
    final String baseUrl = await loadBaseUrl();
    final SymmetryAuthResponse response = await _client(baseUrl).guestLogin();
    final SymmetrySession session = SymmetrySession(
      user: response.user,
      tokens: response.tokens,
      baseUrl: baseUrl,
    );
    await _settingsRepository.saveSymmetrySession(session);
    return session;
  }

  Future<SymmetrySession> login({
    required final String email,
    required final String password,
  }) async {
    final String baseUrl = await loadBaseUrl();
    final SymmetryAuthResponse response = await _client(
      baseUrl,
    ).login(email: email, password: password);
    final SymmetrySession session = SymmetrySession(
      user: response.user,
      tokens: response.tokens,
      baseUrl: baseUrl,
    );
    await _settingsRepository.saveSymmetrySession(session);
    return session;
  }

  Future<SymmetrySession> register({
    required final String email,
    required final String password,
    final String displayName = '',
  }) async {
    final String baseUrl = await loadBaseUrl();
    final SymmetryAuthResponse response = await _client(
      baseUrl,
    ).register(email: email, password: password, displayName: displayName);
    final SymmetrySession session = SymmetrySession(
      user: response.user,
      tokens: response.tokens,
      baseUrl: baseUrl,
    );
    await _settingsRepository.saveSymmetrySession(session);
    return session;
  }

  Future<SymmetrySession> requireSession() async {
    final SymmetrySession? session = await _settingsRepository
        .loadSymmetrySession();
    if (session == null) {
      throw StateError('symmetry_session_required');
    }
    return session;
  }

  Future<SymmetrySession> ensureSession({final bool allowGuest = true}) async {
    final SymmetrySession? session = await _settingsRepository
        .loadSymmetrySession();
    if (session != null) {
      return session;
    }
    if (!allowGuest) {
      throw StateError('symmetry_session_required');
    }
    return guestLogin();
  }

  Future<SymmetrySession> refreshSession() async {
    final SymmetrySession current = await requireSession();
    final SymmetryAuthResponse response = await _client(
      current.baseUrl,
    ).refresh(refreshToken: current.tokens.refreshToken);
    final SymmetrySession refreshed = SymmetrySession(
      user: response.user,
      tokens: response.tokens,
      baseUrl: current.baseUrl,
    );
    await _settingsRepository.saveSymmetrySession(refreshed);
    return refreshed;
  }

  Future<Uri> buildYandexStartUri() async {
    final String baseUrl = await loadBaseUrl();
    return _client(baseUrl).buildYandexStartUri();
  }

  Future<SymmetrySession> completeYandexHandoff({
    required final String handoffId,
  }) async {
    final String baseUrl = await loadBaseUrl();
    final SymmetryAuthResponse response = await _client(
      baseUrl,
    ).completeYandexHandoff(handoffId: handoffId);
    final SymmetrySession session = SymmetrySession(
      user: response.user,
      tokens: response.tokens,
      baseUrl: baseUrl,
    );
    await _settingsRepository.saveSymmetrySession(session);
    return session;
  }

  Future<void> logout() async {
    final SymmetrySession? session = await _settingsRepository
        .loadSymmetrySession();
    if (session != null) {
      await _client(
        session.baseUrl,
      ).logout(refreshToken: session.tokens.refreshToken);
    }
    await _settingsRepository.saveSymmetrySession(null);
  }

  Future<void> checkProviderConnection({
    required final AiSettings aiSettings,
  }) async {
    final SymmetrySession session = await ensureSession();
    await _client(session.baseUrl).checkProviderConnection(
      accessToken: session.tokens.accessToken,
      aiSettings: aiSettings,
    );
  }

  Future<void> checkBackendHealth({final String? baseUrlOverride}) async {
    final String baseUrl =
        baseUrlOverride != null && baseUrlOverride.trim().isNotEmpty
        ? baseUrlOverride.trim()
        : await loadBaseUrl();
    await _client(baseUrl).checkHealth();
  }

  Future<GeneratedPrompts> generateCampaignPrompts({
    required final AiSettings aiSettings,
    required final AppLanguage language,
    required final CampaignPromptGenerationRequest request,
  }) async {
    final SymmetrySession session = await ensureSession();
    final SymmetryGeneratedPrompts generated = await _client(session.baseUrl)
        .generatePrompts(
          accessToken: session.tokens.accessToken,
          setting: request.setting,
          literaryGenre: request.literaryGenre,
          mode: request.mode,
          difficulty: request.difficulty,
          languageCode: language.code,
          storyWish: request.storyWish,
          aiSettings: aiSettings,
        );
    return GeneratedPrompts(
      storyPrompt: generated.storyPrompt,
      characterPrompt: generated.characterPrompt,
      campaignTitle: generated.campaignTitle,
      objectiveHint: generated.objectiveHint,
    );
  }

  SymmetryApiClient _client(final String baseUrl) =>
      _clientFactory?.call(baseUrl) ?? SymmetryApiClient(baseUrl: baseUrl);
}
