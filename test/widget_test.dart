import 'package:ai_prg/src/app/app.dart';
import 'package:ai_prg/src/app/app_scope.dart';
import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/repositories/campaign_repository.dart';
import 'package:ai_prg/src/core/repositories/settings_repository.dart';
import 'package:ai_prg/src/core/services/ai_service_factory.dart';
import 'package:ai_prg/src/core/services/game_engine.dart';
import 'package:ai_prg/src/features/new_game/presentation/new_game_screen.dart';
import 'package:ai_prg/src/features/settings/presentation/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Приложение открывается на главном экране', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(const AiRpgApp());
    await tester.pumpAndSettle();

    expect(find.text('AI RPG MVP'), findsOneWidget);
    expect(find.byType(FilledButton), findsWidgets);
  });

  testWidgets('Новая кампания открывает игровой чат', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(
      _buildScopedApp(
        const NewGameScreen(),
        language: AppLanguage.en,
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Мира');
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.auto_stories_rounded));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.byType(IconButton), findsWidgets);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('Настройки ИИ открываются и показывают базовые поля', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(
      _buildScopedApp(
        const SettingsScreen(),
        language: AppLanguage.en,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNWidgets(3));
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.byType(FilledButton), findsOneWidget);
    expect(find.byType(OutlinedButton), findsOneWidget);
    expect(find.byType(TextButton), findsWidgets);
  });
}

Widget _buildScopedApp(
  final Widget home, {
  required final AppLanguage language,
}) => AppScope(
    settingsRepository: SettingsRepository(),
    campaignRepository: CampaignRepository(),
    aiServiceFactory: const AiServiceFactory(),
    gameEngine: const GameEngine(),
    appLanguageListenable: ValueNotifier<AppLanguage>(language),
    child: MaterialApp(home: home),
  );
