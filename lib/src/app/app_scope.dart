import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/repositories/campaign_repository.dart';
import 'package:ai_prg/src/core/repositories/settings_repository.dart';
import 'package:ai_prg/src/core/services/ai_service_factory.dart';
import 'package:ai_prg/src/core/services/game_engine.dart';
import 'package:flutter/widgets.dart';

class AppScope extends InheritedWidget {
  const AppScope({
    required this.settingsRepository,
    required this.campaignRepository,
    required this.aiServiceFactory,
    required this.gameEngine,
    required this.appLanguageListenable,
    required super.child,
    super.key,
  });

  final SettingsRepository settingsRepository;
  final CampaignRepository campaignRepository;
  final AiServiceFactory aiServiceFactory;
  final GameEngine gameEngine;
  final ValueNotifier<AppLanguage> appLanguageListenable;

  static AppScope of(final BuildContext context) {
    final AppScope? scope = context
        .dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope is missing in widget tree.');
    return scope!;
  }

  @override
  bool updateShouldNotify(final AppScope oldWidget) {
    return settingsRepository != oldWidget.settingsRepository ||
        campaignRepository != oldWidget.campaignRepository ||
        aiServiceFactory != oldWidget.aiServiceFactory ||
        gameEngine != oldWidget.gameEngine ||
        appLanguageListenable != oldWidget.appLanguageListenable;
  }
}
