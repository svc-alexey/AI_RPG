import 'package:ai_prg/src/core/data/storage/settings_storage.dart';
import 'package:ai_prg/src/core/models/ai_settings.dart';
import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/models/symmetry_models.dart';
import 'package:ai_prg/src/core/repositories/settings_repository.dart';
import 'package:ai_prg/src/core/repositories/symmetry_auth_repository.dart';
import 'package:ai_prg/src/core/services/symmetry_api_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('completeYandexHandoff saves the returned session', () async {
    final _FakeSettingsStorage storage = _FakeSettingsStorage(
      initialSymmetryBaseUrl: 'https://api.example.com/v1',
    );
    final _FakeSymmetryApiClient client = _FakeSymmetryApiClient(
      baseUrl: 'https://api.example.com/v1',
      response: const SymmetryAuthResponse(
        user: SymmetryUser(
          id: 'user-1',
          email: 'user@example.com',
          displayName: 'Example',
        ),
        tokens: SymmetryTokenPair(
          accessToken: 'access-token',
          accessTokenExpiresAt: '2030-01-01T00:00:00Z',
          refreshToken: 'refresh-token',
          refreshTokenExpiresAt: '2030-01-02T00:00:00Z',
        ),
      ),
    );
    final SymmetryAuthRepository repository = SymmetryAuthRepository(
      settingsRepository: SettingsRepository(storage: storage),
      clientFactory: (final baseUrl) {
        expect(baseUrl, 'https://api.example.com/v1');
        return client;
      },
    );

    final SymmetrySession session = await repository.completeYandexHandoff(
      handoffId: 'handoff-123',
    );

    expect(client.lastCompletedHandoffId, 'handoff-123');
    expect(session.baseUrl, 'https://api.example.com/v1');
    expect(storage.symmetrySession?.user.email, 'user@example.com');
    expect(storage.symmetrySession?.tokens.refreshToken, 'refresh-token');
  });
}

class _FakeSymmetryApiClient extends SymmetryApiClient {
  _FakeSymmetryApiClient({required super.baseUrl, required this.response});

  final SymmetryAuthResponse response;
  String? lastCompletedHandoffId;

  @override
  Future<SymmetryAuthResponse> completeYandexHandoff({
    required final String handoffId,
  }) async {
    lastCompletedHandoffId = handoffId;
    return response;
  }
}

class _FakeSettingsStorage implements SettingsStorage {
  _FakeSettingsStorage({String? initialSymmetryBaseUrl})
    : _symmetryBaseUrl = initialSymmetryBaseUrl;

  SymmetrySession? _symmetrySession;
  String? _symmetryBaseUrl;

  @override
  Future<AiSettings> loadAiSettings() async => const AiSettings.defaults();

  @override
  Future<AiSettings> loadAiSettingsPersisted() async =>
      const AiSettings.defaults();

  @override
  Future<void> saveAiSettings(final AiSettings settings) async {}

  @override
  Future<AppLanguage> loadAppLanguage() async => AppLanguage.ru;

  @override
  Future<void> saveAppLanguage(final AppLanguage language) async {}

  @override
  Future<String?> loadSymmetryBaseUrl() async => _symmetryBaseUrl;

  @override
  Future<void> saveSymmetryBaseUrl(final String baseUrl) async {
    _symmetryBaseUrl = baseUrl;
  }

  @override
  Future<SymmetrySession?> loadSymmetrySession() async => _symmetrySession;

  @override
  Future<void> saveSymmetrySession(final SymmetrySession? session) async {
    _symmetrySession = session;
  }

  SymmetrySession? get symmetrySession => _symmetrySession;
}
