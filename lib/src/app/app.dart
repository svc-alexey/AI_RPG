import 'dart:async';

import 'package:ai_prg/src/app/aether_shell.dart';
import 'package:ai_prg/src/app/app_localizations.dart';
import 'package:ai_prg/src/app/app_providers.dart';
import 'package:ai_prg/src/app/app_route_observer.dart';
import 'package:ai_prg/src/app/hide_loader_web.dart';
import 'package:ai_prg/src/app/responsive.dart';
import 'package:ai_prg/src/app/theme.dart';
import 'package:ai_prg/src/core/data/isar/app_database.dart';
import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/repositories/settings_repository.dart';
import 'package:ai_prg/src/core/repositories/story_library_repository.dart';
import 'package:ai_prg/src/core/repositories/symmetry_auth_repository.dart';
import 'package:ai_prg/src/core/repositories/symmetry_campaign_repository.dart';
import 'package:ai_prg/src/core/services/ai_service_factory.dart';
import 'package:ai_prg/src/core/services/game_engine.dart';
import 'package:ai_prg/src/core/services/portrait_storage.dart';
import 'package:ai_prg/src/features/auth/presentation/auth_gate_screen.dart';
import 'package:ai_prg/src/features/update/presentation/update_gate_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AiRpgApp extends StatefulWidget {
  const AiRpgApp({
    super.key,
    this.database,
    this.settingsRepository,
    this.aiServiceFactory,
    this.gameEngine,
    this.portraitStorage,
    this.appLanguageListenable,
    this.onLaunchUiReady,
  });

  final AppDatabase? database;
  final SettingsRepository? settingsRepository;
  final AiServiceFactory? aiServiceFactory;
  final GameEngine? gameEngine;
  final PortraitStorage? portraitStorage;
  final ValueNotifier<AppLanguage>? appLanguageListenable;
  final VoidCallback? onLaunchUiReady;

  @override
  State<AiRpgApp> createState() => _AiRpgAppState();
}

class _AiRpgAppState extends State<AiRpgApp> {
  late final AppDatabase _database;
  late final SettingsRepository _settingsRepository;
  late final SymmetryAuthRepository _symmetryAuthRepository;
  late final SymmetryCampaignRepository _symmetryCampaignRepository;
  late final StoryLibraryRepository _storyLibraryRepository;
  late final AiServiceFactory _aiServiceFactory;
  late final GameEngine _gameEngine;
  late final PortraitStorage _portraitStorage;
  late final ValueNotifier<AppLanguage> _appLanguageListenable;
  late final bool _ownsLanguageListenable;
  bool _didBootstrap = false;
  bool _bootstrapComplete = false;
  bool _didSignalLaunchUiReady = false;

  @override
  void initState() {
    super.initState();
    _database = widget.database ?? AppDatabase.instance;
    _settingsRepository =
        widget.settingsRepository ?? SettingsRepository(database: _database);
    _symmetryAuthRepository = SymmetryAuthRepository(
      settingsRepository: _settingsRepository,
    );
    _symmetryCampaignRepository = SymmetryCampaignRepository(
      authRepository: _symmetryAuthRepository,
    );
    _storyLibraryRepository = StoryLibraryRepository(
      authRepository: _symmetryAuthRepository,
    );
    _aiServiceFactory = widget.aiServiceFactory ?? const AiServiceFactory();
    _gameEngine = widget.gameEngine ?? const GameEngine();
    _portraitStorage = widget.portraitStorage ?? const PortraitStorage();
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
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      await _database.ensureReady();
      final AppLanguage? launchLanguage = _languageOverrideFromUrl();
      final List<Future<void>> tasks = <Future<void>>[
        _settingsRepository.loadAppLanguage().then((
          final storedLanguage,
        ) async {
          final AppLanguage resolvedLanguage = launchLanguage ?? storedLanguage;
          if (launchLanguage != null && launchLanguage != storedLanguage) {
            await _settingsRepository.saveAppLanguage(launchLanguage);
          }
          _appLanguageListenable.value = resolvedLanguage;
        }),
      ];
      await Future.wait(
        tasks,
      ).timeout(const Duration(seconds: 3), onTimeout: () => <void>[]);
    } catch (_) {
      // Timeout or startup error: continue to the home screen instead of blocking launch.
    } finally {
      if (mounted) {
        setState(() => _bootstrapComplete = true);
      }
    }
  }

  AppLanguage? _languageOverrideFromUrl() {
    final String? raw = Uri.base.queryParameters['lang'];
    return switch (raw) {
      'ru' => AppLanguage.ru,
      'en' => AppLanguage.en,
      _ => null,
    };
  }

  void _signalLaunchUiReady() {
    if (_didSignalLaunchUiReady) {
      return;
    }
    _didSignalLaunchUiReady = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.endOfFrame.then((_) {
        if (!mounted) {
          return;
        }
        completeHtmlLoaderTransition();
        widget.onLaunchUiReady?.call();
      });
    });
  }

  @override
  void dispose() {
    if (_ownsLanguageListenable) {
      _appLanguageListenable.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    if (_bootstrapComplete) {
      _signalLaunchUiReady();
    }

    return ProviderScope(
      overrides: buildAppProviderOverrides(
        settingsRepository: _settingsRepository,
        symmetryAuthRepository: _symmetryAuthRepository,
        symmetryCampaignRepository: _symmetryCampaignRepository,
        storyLibraryRepository: _storyLibraryRepository,
        aiServiceFactory: _aiServiceFactory,
        gameEngine: _gameEngine,
        portraitStorage: _portraitStorage,
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
              navigatorObservers: <NavigatorObserver>[appRouteObserver],
              theme: buildAppTheme(),
              builder: (final context, final child) => Theme(
                data: adaptThemeForContext(context, Theme.of(context)),
                child: ColoredBox(
                  color: AetherPalette.background,
                  child: AetherBackdrop(
                    child: UpdateGateOverlay(
                      child: child ?? const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),
              home: _bootstrapComplete
                  ? const AuthGateScreen()
                  : const _SplashScreen(),
            ),
          );
        },
      ),
    );
  }
}

class _SplashScreen extends StatefulWidget {
  const _SplashScreen();

  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen> {
  Timer? _stageTimer;
  Timer? _flavorTimer;
  int _stageIndex = 0;
  int _flavorIndex = 0;
  bool _didSignalFirstFrame = false;

  bool get _animationsEnabled {
    final String bindingName = WidgetsBinding.instance.runtimeType.toString();
    return bindingName != 'AutomatedTestWidgetsFlutterBinding' &&
        bindingName != 'LiveTestWidgetsFlutterBinding';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.endOfFrame.then((_) {
        if (!mounted || _didSignalFirstFrame) {
          return;
        }
        _didSignalFirstFrame = true;
        notifyHtmlLoaderFirstFrame();
      });
    });
    if (_animationsEnabled) {
      _stageTimer = Timer.periodic(const Duration(milliseconds: 1100), (_) {
        if (!mounted || _stageIndex >= 3) {
          return;
        }
        setState(() => _stageIndex += 1);
      });
      _flavorTimer = Timer.periodic(const Duration(milliseconds: 2200), (_) {
        if (!mounted) {
          return;
        }
        setState(() => _flavorIndex += 1);
      });
    }
  }

  @override
  void dispose() {
    _stageTimer?.cancel();
    _flavorTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<String> stages = l10n.appLoadingStages;
    final List<String> flavorLines = l10n.appLoadingFlavorLines;
    final int stageIndex = _stageIndex.clamp(0, stages.length - 1);
    final String flavorLine = flavorLines[_flavorIndex % flavorLines.length];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.responsive.pagePadding,
                vertical: context.responsive.pagePadding,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    l10n.brandName,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: AetherPalette.textPrimary,
                      fontWeight: FontWeight.w500,
                      fontSize: context.responsive.isCompact ? 48 : 72,
                      letterSpacing: context.responsive.scaleLetterSpacing(8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.appLoadingTitle,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AetherPalette.textPrimary,
                      fontSize: context.responsive.isCompact ? 24 : 28,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    stages[stageIndex],
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AetherPalette.textMuted,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      minHeight: 10,
                      backgroundColor: AetherPalette.panelSoft.withValues(
                        alpha: 0.72,
                      ),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AetherPalette.accent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.appLoadingEtaShort,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AetherPalette.textMuted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      flavorLine,
                      key: ValueKey<String>(flavorLine),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AetherPalette.accent,
                        letterSpacing: 0.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 28),
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
      ),
    );
  }
}
