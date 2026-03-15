import 'package:ai_prg/src/app/app_scope.dart';
import 'package:ai_prg/src/app/theme.dart';
import 'package:ai_prg/src/core/repositories/campaign_repository.dart';
import 'package:ai_prg/src/core/repositories/settings_repository.dart';
import 'package:ai_prg/src/core/services/ai_service_factory.dart';
import 'package:ai_prg/src/core/services/game_engine.dart';
import 'package:ai_prg/src/features/home/presentation/home_screen.dart';
import 'package:flutter/material.dart';

class AiRpgApp extends StatelessWidget {
  const AiRpgApp({super.key});

  @override
  Widget build(final BuildContext context) {
    return AppScope(
      settingsRepository: SettingsRepository(),
      campaignRepository: CampaignRepository(),
      aiServiceFactory: const AiServiceFactory(),
      gameEngine: const GameEngine(),
      child: MaterialApp(
        title: 'ИИ RPG',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: const HomeScreen(),
      ),
    );
  }
}
