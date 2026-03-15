import 'package:ai_prg/src/app/app_scope.dart';
import 'package:ai_prg/src/app/theme.dart';
import 'package:ai_prg/src/core/repositories/campaign_repository.dart';
import 'package:ai_prg/src/core/repositories/settings_repository.dart';
import 'package:ai_prg/src/core/services/ai_service_factory.dart';
import 'package:ai_prg/src/core/services/game_engine.dart';
import 'package:ai_prg/src/core/services/lm_studio_auto_config.dart';
import 'package:ai_prg/src/features/home/presentation/home_screen.dart';
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
  bool _didBootstrap = false;

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
    await _lmStudioAutoConfig.sync(_settingsRepository);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(final BuildContext context) {
    return AppScope(
      settingsRepository: _settingsRepository,
      campaignRepository: _campaignRepository,
      aiServiceFactory: _aiServiceFactory,
      gameEngine: _gameEngine,
      child: MaterialApp(
        title: 'ИИ RPG',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: const HomeScreen(),
      ),
    );
  }
}
