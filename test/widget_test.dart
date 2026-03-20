import 'dart:convert';

import 'package:ai_prg/src/app/app.dart';
import 'package:ai_prg/src/app/app_localizations.dart';
import 'package:ai_prg/src/app/app_scope.dart';
import 'package:ai_prg/src/core/models/ai_settings.dart';
import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:ai_prg/src/core/repositories/campaign_repository.dart';
import 'package:ai_prg/src/core/repositories/settings_repository.dart';
import 'package:ai_prg/src/core/services/ai_client.dart';
import 'package:ai_prg/src/core/services/ai_service_factory.dart';
import 'package:ai_prg/src/core/services/game_engine.dart';
import 'package:ai_prg/src/features/chat/presentation/chat_screen.dart';
import 'package:ai_prg/src/features/home/presentation/home_screen.dart';
import 'package:ai_prg/src/features/new_game/presentation/new_game_screen.dart';
import 'package:ai_prg/src/features/saves/presentation/saves_screen.dart';
import 'package:ai_prg/src/features/settings/presentation/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const AppLocalizations english = AppLocalizations(AppLanguage.en);

  testWidgets('Приложение открывается на главном экране', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(const AiRpgApp());
    await tester.pumpAndSettle();

    expect(find.text('AETHERIS'), findsOneWidget);
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('Главный экран открывает список сохранений', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(
      _buildScopedApp(
        const HomeScreen(),
        language: AppLanguage.en,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(english.saves));
    await tester.pumpAndSettle();

    expect(find.byType(SavesScreen), findsOneWidget);
    expect(find.text(english.savedCampaigns), findsOneWidget);
  });

  testWidgets('Новая кампания открывает игровой чат', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.binding.setSurfaceSize(const Size(1200, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _buildScopedApp(
        const NewGameScreen(),
        language: AppLanguage.en,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(english.createCampaignButton));
    await tester.pumpAndSettle();

    expect(find.byType(ChatScreen), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('Экран сохранений показывает пустое состояние', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(
      _buildScopedApp(
        const SavesScreen(),
        language: AppLanguage.en,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(english.noSavesYet), findsOneWidget);
  });

  testWidgets('Экран сохранений открывает сохраненную кампанию', (
    tester,
  ) async {
    final CampaignState campaign = _sampleCampaign();
    SharedPreferences.setMockInitialValues(<String, Object>{
      'campaign.ids': <String>[campaign.id],
      'campaign.${campaign.id}': jsonEncode(campaign.toJson()),
    });

    await tester.pumpWidget(
      _buildScopedApp(
        const SavesScreen(),
        language: AppLanguage.en,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(campaign.title), findsOneWidget);

    await tester.tap(find.text(english.loadCampaignAction));
    await tester.pumpAndSettle();

    expect(find.byType(ChatScreen), findsOneWidget);
    expect(find.text(campaign.title), findsOneWidget);
    expect(find.textContaining('Location:'), findsOneWidget);
    expect(find.textContaining(campaign.location), findsOneWidget);
  });

  testWidgets('Игровой чат сохраняет кампанию по кнопке сохранения', (
    tester,
  ) async {
    final CampaignState campaign = _sampleCampaign();
    SharedPreferences.setMockInitialValues(<String, Object>{
      'campaign.ids': <String>[campaign.id],
      'campaign.${campaign.id}': jsonEncode(campaign.toJson()),
    });

    await tester.pumpWidget(
      _buildScopedApp(
        ChatScreen(campaignId: campaign.id),
        language: AppLanguage.en,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip(english.saveTooltip));
    await tester.pumpAndSettle();

    expect(find.text(english.campaignSaved), findsOneWidget);

    final SharedPreferences preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('campaign.${campaign.id}'), isNotNull);
  });

  testWidgets('Без настроенной модели ход выполняется в demo mode', (
    tester,
  ) async {
    final CampaignState campaign = _sampleCampaign();
    SharedPreferences.setMockInitialValues(<String, Object>{
      'campaign.ids': <String>[campaign.id],
      'campaign.${campaign.id}': jsonEncode(campaign.toJson()),
    });

    await tester.pumpWidget(
      _buildScopedApp(
        ChatScreen(campaignId: campaign.id),
        language: AppLanguage.en,
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Step toward the tower');
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pumpAndSettle();

    expect(find.textContaining('in demo mode'), findsAtLeastNWidgets(1));

    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String rawCampaign =
        preferences.getString('campaign.${campaign.id}') ?? '';
    expect(rawCampaign, contains('Step toward the tower'));
  });

  testWidgets('Игровой чат показывает recoverable AI-ошибку и не падает', (
    tester,
  ) async {
    final CampaignState campaign = _sampleCampaign();
    SharedPreferences.setMockInitialValues(<String, Object>{
      'campaign.ids': <String>[campaign.id],
      'campaign.${campaign.id}': jsonEncode(campaign.toJson()),
    });

    await tester.pumpWidget(
      _buildScopedApp(
        ChatScreen(campaignId: campaign.id),
        language: AppLanguage.en,
        settingsRepository: _FakeSettingsRepository(
          const _ConfiguredAiSettings(),
        ),
        aiServiceFactory: const _FakeAiServiceFactory(
          _ThrowingAiClient(
            AiTurnException(
              userMessage: 'Could not connect to the AI endpoint.',
              rawResponse: '503 Service Unavailable',
              recoverable: true,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Open the sealed gate');
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Could not connect to the AI endpoint.'), findsWidgets);

    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String rawCampaign =
        preferences.getString('campaign.${campaign.id}') ?? '';
    expect(rawCampaign, contains('Could not connect to the AI endpoint.'));
    expect(rawCampaign, contains('Technical note: the raw model response'));
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

    expect(find.text('LM Studio'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text(english.saveSettings),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text(english.saveSettings), findsOneWidget);
    expect(find.byType(OutlinedButton), findsWidgets);
  });

  testWidgets('Игровой чат на узкой ширине: drawer для sidebar, чат занимает основную область', (
    tester,
  ) async {
    final CampaignState campaign = _sampleCampaign();
    SharedPreferences.setMockInitialValues(<String, Object>{
      'campaign.ids': <String>[campaign.id],
      'campaign.${campaign.id}': jsonEncode(campaign.toJson()),
    });

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(360, 640)),
        child: _buildScopedApp(
          ChatScreen(campaignId: campaign.id),
          language: AppLanguage.en,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.menu), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(Icons.send_rounded), findsOneWidget);
  });
}

Widget _buildScopedApp(
  Widget home, {
  required AppLanguage language,
  SettingsRepository? settingsRepository,
  CampaignRepository? campaignRepository,
  AiServiceFactory? aiServiceFactory,
  GameEngine? gameEngine,
}) => AppScope(
      settingsRepository: settingsRepository ?? SettingsRepository(),
      campaignRepository: campaignRepository ?? CampaignRepository(),
      aiServiceFactory: aiServiceFactory ?? const AiServiceFactory(),
      gameEngine: gameEngine ?? const GameEngine(),
      appLanguageListenable: ValueNotifier<AppLanguage>(language),
      child: MaterialApp(home: home),
    );

class _FakeSettingsRepository extends SettingsRepository {
  _FakeSettingsRepository(this._settings);

  final AiSettings _settings;

  @override
  Future<AiSettings> loadAiSettings() async => _settings;
}

class _FakeAiServiceFactory extends AiServiceFactory {
  const _FakeAiServiceFactory(this._client);

  final AiClient _client;

  @override
  AiClient create(final AiSettings settings) => _client;
}

class _ThrowingAiClient implements AiClient {
  const _ThrowingAiClient(this._error);

  final AiTurnException _error;

  @override
  Future<void> checkConnection({required AiSettings settings}) async {}

  @override
  Future<TurnResult> generateTurn({
    required AiSettings settings,
    required AppLanguage language,
    required CampaignState state,
    required String playerAction,
    required bool suggestionsOnly,
    CancelToken? cancelToken,
  }) async {
    throw _error;
  }

  @override
  Future<GeneratedPrompts> generatePromptsFromStoryWish({
    required AiSettings settings,
    required AppLanguage language,
    required String storyWish,
    required CampaignSetting setting,
    CancelToken? cancelToken,
  }) async =>
      const GeneratedPrompts(storyPrompt: '', characterPrompt: '');
}

class _ConfiguredAiSettings extends AiSettings {
  const _ConfiguredAiSettings()
      : super(
          provider: AiProviderType.openAiCompatible,
          baseUrl: 'http://127.0.0.1:9999/v1',
          model: 'test-model',
          apiKey: 'test-key',
          timeoutSeconds: 15,
          fastResponses: false,
        );
}

CampaignState _sampleCampaign() => CampaignState(
      id: 'campaign-1',
      schemaVersion: 2,
      title: 'The Amber Road',
      setting: CampaignSetting.fantasy,
      mode: StoryMode.longCampaign,
      difficulty: DifficultyLevel.medium,
      character: const CharacterStats(
        name: 'Mira',
        hp: 10,
        maxHp: 12,
        energy: 7,
        maxEnergy: 8,
        might: 2,
        wit: 3,
        spirit: 4,
      ),
      location: 'Old forest road',
      objective: 'Reach the ruined tower before dusk',
      turnNumber: 3,
      memory: const CampaignMemory(
        rollingSummary: 'Mira followed the caravan trail into the woods.',
        activeGoal: 'Find the tower entrance',
        activeSituation: 'A storm is gathering above the tree line.',
        recentTurns: <RecentTurnSummary>[
          RecentTurnSummary(
            playerAction: 'Inspect the tracks',
            outcome: 'Fresh boot prints lead east',
            stateHint: 'Possible ambush nearby',
          ),
        ],
      ),
      inventory: const <String>['Lantern', 'Map'],
      questLog: const <String>['Follow the caravan trail'],
      messages: <ChatMessage>[
        ChatMessage(
          id: 'm1',
          role: ChatRole.narrator,
          text: 'The road narrows between ancient pines.',
          createdAt: DateTime(2026, 3, 15, 12),
        ),
      ],
      choices: const <String>['Scout ahead', 'Light the lantern'],
      updatedAt: DateTime(2026, 3, 15, 12, 30),
    );
