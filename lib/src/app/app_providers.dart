import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/repositories/campaign_repository.dart';
import 'package:ai_prg/src/core/repositories/settings_repository.dart';
import 'package:ai_prg/src/core/services/ai_service_factory.dart';
import 'package:ai_prg/src/core/services/game_engine.dart';
import 'package:ai_prg/src/core/services/portrait_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<SettingsRepository> settingsRepositoryProvider =
    Provider<SettingsRepository>((final ref) {
      throw UnimplementedError(
        'settingsRepositoryProvider was not overridden.',
      );
    });

final Provider<CampaignRepository> campaignRepositoryProvider =
    Provider<CampaignRepository>((final ref) {
      throw UnimplementedError(
        'campaignRepositoryProvider was not overridden.',
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

final Provider<ValueNotifier<AppLanguage>> appLanguageListenableProvider =
    Provider<ValueNotifier<AppLanguage>>((final ref) {
      throw UnimplementedError(
        'appLanguageListenableProvider was not overridden.',
      );
    });

List<Override> buildAppProviderOverrides({
  required final SettingsRepository settingsRepository,
  required final CampaignRepository campaignRepository,
  required final AiServiceFactory aiServiceFactory,
  required final GameEngine gameEngine,
  required final PortraitStorage portraitStorage,
  required final ValueNotifier<AppLanguage> appLanguageListenable,
}) => <Override>[
  settingsRepositoryProvider.overrideWithValue(settingsRepository),
  campaignRepositoryProvider.overrideWithValue(campaignRepository),
  aiServiceFactoryProvider.overrideWithValue(aiServiceFactory),
  gameEngineProvider.overrideWithValue(gameEngine),
  portraitStorageProvider.overrideWithValue(portraitStorage),
  appLanguageListenableProvider.overrideWithValue(appLanguageListenable),
];
