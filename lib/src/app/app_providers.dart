import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/models/symmetry_models.dart';
import 'package:ai_prg/src/core/repositories/settings_repository.dart';
import 'package:ai_prg/src/core/repositories/story_library_repository.dart';
import 'package:ai_prg/src/core/repositories/symmetry_auth_repository.dart';
import 'package:ai_prg/src/core/repositories/symmetry_campaign_repository.dart';
import 'package:ai_prg/src/core/repositories/update_repository.dart';
import 'package:ai_prg/src/core/services/ai_service_factory.dart';
import 'package:ai_prg/src/core/services/game_engine.dart';
import 'package:ai_prg/src/core/services/portrait_storage.dart';
import 'package:ai_prg/src/core/services/version_check_service.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<SettingsRepository> settingsRepositoryProvider =
    Provider<SettingsRepository>((final ref) {
      throw UnimplementedError(
        'settingsRepositoryProvider was not overridden.',
      );
    });

final Provider<SymmetryAuthRepository> symmetryAuthRepositoryProvider =
    Provider<SymmetryAuthRepository>((final ref) {
      throw UnimplementedError(
        'symmetryAuthRepositoryProvider was not overridden.',
      );
    });

final Provider<SymmetryCampaignRepository> symmetryCampaignRepositoryProvider =
    Provider<SymmetryCampaignRepository>((final ref) {
      throw UnimplementedError(
        'symmetryCampaignRepositoryProvider was not overridden.',
      );
    });

final Provider<StoryLibraryRepository> storyLibraryRepositoryProvider =
    Provider<StoryLibraryRepository>((final ref) {
      throw UnimplementedError(
        'storyLibraryRepositoryProvider was not overridden.',
      );
    });

final Provider<AiServiceFactory> aiServiceFactoryProvider =
    Provider<AiServiceFactory>((final ref) {
      throw UnimplementedError('aiServiceFactoryProvider was not overridden.');
    });

final Provider<GameEngine> gameEngineProvider = Provider<GameEngine>((
  final ref,
) {
  throw UnimplementedError('gameEngineProvider was not overridden.');
});

final Provider<PortraitStorage> portraitStorageProvider =
    Provider<PortraitStorage>((final ref) {
      throw UnimplementedError('portraitStorageProvider was not overridden.');
    });

final Provider<UpdateRepository> updateRepositoryProvider =
    Provider<UpdateRepository>(
      (final ref) => UpdateRepository(
        authRepository: ref.read(symmetryAuthRepositoryProvider),
      ),
    );

final Provider<VersionCheckService> versionCheckServiceProvider =
    Provider<VersionCheckService>(
      (final ref) => VersionCheckService(
        updateRepository: ref.read(updateRepositoryProvider),
      ),
    );

final Provider<ValueNotifier<AppLanguage>> appLanguageListenableProvider =
    Provider<ValueNotifier<AppLanguage>>((final ref) {
      throw UnimplementedError(
        'appLanguageListenableProvider was not overridden.',
      );
    });

final FutureProvider<SymmetrySession?> symmetrySessionProvider =
    FutureProvider<SymmetrySession?>((final ref) async {
      final SymmetryAuthRepository repository = ref.read(
        symmetryAuthRepositoryProvider,
      );
      final SymmetrySession? loaded =
          await repository.loadSessionWithSyncedProfile();
      if (loaded != null) {
        return loaded;
      }
      return repository.ensureSession();
    });

List<Override> buildAppProviderOverrides({
  required final SettingsRepository settingsRepository,
  required final AiServiceFactory aiServiceFactory,
  required final GameEngine gameEngine,
  required final PortraitStorage portraitStorage,
  required final ValueNotifier<AppLanguage> appLanguageListenable,
  final SymmetryAuthRepository? symmetryAuthRepository,
  final SymmetryCampaignRepository? symmetryCampaignRepository,
  final StoryLibraryRepository? storyLibraryRepository,
}) {
  final SymmetryAuthRepository resolvedAuthRepository =
      symmetryAuthRepository ??
      _ProviderStubSymmetryAuthRepository(
        settingsRepository: settingsRepository,
      );
  final SymmetryCampaignRepository resolvedCampaignRepository =
      symmetryCampaignRepository ??
      SymmetryCampaignRepository(authRepository: resolvedAuthRepository);
  final StoryLibraryRepository resolvedStoryLibraryRepository =
      storyLibraryRepository ??
      StoryLibraryRepository(authRepository: resolvedAuthRepository);
  return <Override>[
    settingsRepositoryProvider.overrideWithValue(settingsRepository),
    symmetryAuthRepositoryProvider.overrideWithValue(resolvedAuthRepository),
    symmetryCampaignRepositoryProvider.overrideWithValue(
      resolvedCampaignRepository,
    ),
    storyLibraryRepositoryProvider.overrideWithValue(
      resolvedStoryLibraryRepository,
    ),
    aiServiceFactoryProvider.overrideWithValue(aiServiceFactory),
    gameEngineProvider.overrideWithValue(gameEngine),
    portraitStorageProvider.overrideWithValue(portraitStorage),
    appLanguageListenableProvider.overrideWithValue(appLanguageListenable),
  ];
}

class _ProviderStubSymmetryAuthRepository extends SymmetryAuthRepository {
  _ProviderStubSymmetryAuthRepository({required super.settingsRepository});

  @override
  Future<bool> hasSession() async => false;

  @override
  Future<SymmetrySession> ensureSession({final bool allowGuest = true}) async =>
      const SymmetrySession(
        user: SymmetryUser(
          id: 'guest-stub',
          email: 'guest-stub@symmetry.dev',
          displayName: 'Guest',
        ),
        tokens: SymmetryTokenPair(
          accessToken: 'stub-access-token',
          accessTokenExpiresAt: '',
          refreshToken: 'stub-refresh-token',
          refreshTokenExpiresAt: '',
        ),
        baseUrl: 'http://127.0.0.1:8080/v1',
      );

  @override
  Future<void> logout() async {}
}
