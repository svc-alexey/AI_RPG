import 'package:ai_prg/src/app/aether_shell.dart';
import 'package:ai_prg/src/app/app_localizations.dart';
import 'package:ai_prg/src/app/app_providers.dart';
import 'package:ai_prg/src/app/hide_loader_web.dart';
import 'package:ai_prg/src/app/responsive.dart';
import 'package:ai_prg/src/app/theme.dart';
import 'package:ai_prg/src/core/data/isar/app_database.dart';
import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/repositories/campaign_repository.dart';
import 'package:ai_prg/src/core/repositories/settings_repository.dart';
import 'package:ai_prg/src/core/services/ai_service_factory.dart';
import 'package:ai_prg/src/core/services/game_engine.dart';
import 'package:ai_prg/src/core/services/lm_studio_auto_config.dart';
import 'package:ai_prg/src/features/home/presentation/home_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AiRpgApp extends StatefulWidget {
  const AiRpgApp({
    super.key,
    this.database,
    this.settingsRepository,
    this.campaignRepository,
    this.aiServiceFactory,
    this.gameEngine,
    this.lmStudioAutoConfig,
    this.appLanguageListenable,
  });

  final AppDatabase? database;
  final SettingsRepository? settingsRepository;
  final CampaignRepository? campaignRepository;
  final AiServiceFactory? aiServiceFactory;
  final GameEngine? gameEngine;
  final LmStudioAutoConfig? lmStudioAutoConfig;
  final ValueNotifier<AppLanguage>? appLanguageListenable;

  @override
  State<AiRpgApp> createState() => _AiRpgAppState();
}

class _AiRpgAppState extends State<AiRpgApp> {
  late final AppDatabase _database;
  late final SettingsRepository _settingsRepository;
  late final CampaignRepository _campaignRepository;
  late final AiServiceFactory _aiServiceFactory;
  late final GameEngine _gameEngine;
  late final LmStudioAutoConfig _lmStudioAutoConfig;
  late final ValueNotifier<AppLanguage> _appLanguageListenable;
  late final bool _ownsLanguageListenable;
  bool _didBootstrap = false;
  bool _bootstrapComplete = false;

  @override
  void initState() {
    super.initState();
    _database = widget.database ?? AppDatabase.instance;
    _settingsRepository =
        widget.settingsRepository ?? SettingsRepository(database: _database);
    _campaignRepository =
        widget.campaignRepository ?? CampaignRepository(database: _database);
    _aiServiceFactory = widget.aiServiceFactory ?? const AiServiceFactory();
    _gameEngine = widget.gameEngine ?? const GameEngine();
    _lmStudioAutoConfig =
        widget.lmStudioAutoConfig ?? const LmStudioAutoConfig();
    _appLanguageListenable =
        widget.appLanguageListenable ??
        ValueNotifier<AppLanguage>(AppLanguage.ru);
    _ownsLanguageListenable = widget.appLanguageListenable == null;
  }

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
      await _database.ensureReady();
      final List<Future<void>> tasks = <Future<void>>[
        _settingsRepository.loadAppLanguage().then((final l) {
          _appLanguageListenable.value = l;
        }),
      ];
      if (!kIsWeb) {
        tasks.add(_lmStudioAutoConfig.sync(_settingsRepository));
      }
      await Future.wait(
        tasks,
      ).timeout(const Duration(seconds: 3), onTimeout: () => <void>[]);
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
    if (_ownsLanguageListenable) {
      _appLanguageListenable.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => ProviderScope(
    overrides: buildAppProviderOverrides(
      settingsRepository: _settingsRepository,
      campaignRepository: _campaignRepository,
      aiServiceFactory: _aiServiceFactory,
      gameEngine: _gameEngine,
      appLanguageListenable: _appLanguageListenable,
    ),
    child: ValueListenableBuilder<AppLanguage>(
      valueListenable: _appLanguageListenable,
      builder: (final context, final language, _) {
        final AppLocalizations l10n = AppLocalizations(language);
        return AppLocalizationsScope(
          localizations: l10n,
          child: MaterialApp(
            title: l10n.appTitle,
            debugShowCheckedModeBanner: false,
            theme: buildAppTheme(),
            builder: (final context, final child) => Theme(
              data: adaptThemeForContext(context, Theme.of(context)),
              child: ColoredBox(
                color: AetherPalette.background,
                child: child ?? const SizedBox.shrink(),
              ),
            ),
            home: _bootstrapComplete
                ? const HomeScreen()
                : const _SplashScreen(),
          ),
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
