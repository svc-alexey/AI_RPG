import 'package:ai_prg/src/app/aether_shell.dart';
import 'package:ai_prg/src/app/app_localizations.dart';
import 'package:ai_prg/src/app/app_scope.dart';
import 'package:ai_prg/src/app/hide_loader_web.dart';
import 'package:ai_prg/src/app/theme.dart';
import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/repositories/campaign_repository.dart';
import 'package:ai_prg/src/core/repositories/settings_repository.dart';
import 'package:ai_prg/src/core/services/ai_service_factory.dart';
import 'package:ai_prg/src/core/services/game_engine.dart';
import 'package:ai_prg/src/core/services/lm_studio_auto_config.dart';
import 'package:ai_prg/src/features/home/presentation/home_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AiRpgApp extends StatefulWidget {
  const AiRpgApp({super.key});

  @override
  State<AiRpgApp> createState() => _AiRpgAppState();
}

class _AiRpgAppState extends State<AiRpgApp> {
  final SettingsRepository _settingsRepository = SettingsRepository();
  final CampaignRepository _campaignRepository = CampaignRepository();
  final AiServiceFactory _aiServiceFactory = const AiServiceFactory();
  final GameEngine _gameEngine = const GameEngine();
  final LmStudioAutoConfig _lmStudioAutoConfig = const LmStudioAutoConfig();
  final ValueNotifier<AppLanguage> _appLanguageListenable =
      ValueNotifier<AppLanguage>(AppLanguage.ru);
  bool _didBootstrap = false;
  bool _bootstrapComplete = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didBootstrap) {
      return;
    }
    _didBootstrap = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => hideHtmlLoader());
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      final List<Future<void>> tasks = <Future<void>>[
        _settingsRepository.loadAppLanguage().then((final l) {
          _appLanguageListenable.value = l;
        }),
      ];
      if (!kIsWeb) {
        tasks.add(_lmStudioAutoConfig.sync(_settingsRepository));
      }
      await Future.wait(tasks).timeout(
        const Duration(seconds: 3),
        onTimeout: () => <void>[],
      );
    } catch (_) {
      // Таймаут или ошибка — переходим на главный экран
    } finally {
      if (mounted) {
        setState(() => _bootstrapComplete = true);
      }
    }
  }

  @override
  void dispose() {
    _appLanguageListenable.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => AppScope(
      settingsRepository: _settingsRepository,
      campaignRepository: _campaignRepository,
      aiServiceFactory: _aiServiceFactory,
      gameEngine: _gameEngine,
      appLanguageListenable: _appLanguageListenable,
      child: ValueListenableBuilder<AppLanguage>(
        valueListenable: _appLanguageListenable,
        builder: (final context, final _, _) {
          final AppLocalizations l10n = AppLocalizations.of(context);
          return MaterialApp(
            title: l10n.appTitle,
            debugShowCheckedModeBanner: false,
            theme: buildAppTheme(),
            builder: (final context, final child) => ColoredBox(
              color: AetherPalette.background,
              child: child ?? const SizedBox.shrink(),
            ),
            home: _bootstrapComplete
                ? const HomeScreen()
                : const _SplashScreen(),
          );
        },
      ),
    );
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(final BuildContext context) => Scaffold(
        backgroundColor: AetherPalette.background,
        body: AetherBackdrop(
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'AETHERIS',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: AetherPalette.textPrimary,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 10,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context).appTitle,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AetherPalette.textMuted,
                          letterSpacing: 4,
                        ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    width: 88,
                    height: 1,
                    color: AetherPalette.accent.withValues(alpha: 0.45),
                  ),
                  const SizedBox(height: 40),
                  const SizedBox(
                    width: 56,
                    height: 56,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AetherPalette.accent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
