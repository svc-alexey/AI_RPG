import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ai_prg/src/app/app.dart';
import 'package:ai_prg/src/app/app_localizations.dart';
import 'package:ai_prg/src/app/app_providers.dart';
import 'package:ai_prg/src/core/data/isar/app_database.dart';
import 'package:ai_prg/src/core/models/ai_settings.dart';
import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:ai_prg/src/core/repositories/campaign_repository.dart';
import 'package:ai_prg/src/core/repositories/settings_repository.dart';
import 'package:ai_prg/src/core/services/ai_client.dart';
import 'package:ai_prg/src/core/services/ai_service_factory.dart';
import 'package:ai_prg/src/core/services/deterministic_check_service.dart';
import 'package:ai_prg/src/core/services/game_engine.dart';
import 'package:ai_prg/src/core/services/portrait_storage.dart';
import 'package:ai_prg/src/features/chat/presentation/chat_screen.dart';
import 'package:ai_prg/src/features/home/presentation/home_screen.dart';
import 'package:ai_prg/src/features/new_game/presentation/new_game_screen.dart';
import 'package:ai_prg/src/features/saves/presentation/saves_screen.dart';
import 'package:ai_prg/src/features/settings/presentation/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const AppLocalizations english = AppLocalizations(AppLanguage.en);
  const AppLocalizations russian = AppLocalizations(AppLanguage.ru);

  testWidgets('App opens on the home screen', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final _TestStorageBundle storage = _TestStorageBundle.create();
    addTearDown(storage.dispose);

    await tester.pumpWidget(
      AiRpgApp(
        database: storage.database,
        settingsRepository: storage.settingsRepository,
        campaignRepository: storage.campaignRepository,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(russian.brandName), findsOneWidget);
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('Launch UI ready signal waits for bootstrap completion', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final _TestStorageBundle storage = _TestStorageBundle.create();
    addTearDown(storage.dispose);
    final Completer<AppLanguage> languageCompleter = Completer<AppLanguage>();
    final _DelayedSettingsRepository settingsRepository =
        _DelayedSettingsRepository(storage.database, languageCompleter.future);
    int readySignals = 0;

    await tester.pumpWidget(
      AiRpgApp(
        database: storage.database,
        settingsRepository: settingsRepository,
        campaignRepository: storage.campaignRepository,
        onLaunchUiReady: () => readySignals += 1,
      ),
    );
    await tester.pump();

    expect(find.text(russian.appLoadingTitle), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);
    expect(readySignals, 0);

    languageCompleter.complete(AppLanguage.ru);
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(readySignals, 1);
  });

  testWidgets('Home screen shows saves entry point', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final _TestStorageBundle storage = _TestStorageBundle.create();
    addTearDown(storage.dispose);

    await tester.pumpWidget(
      _buildScopedApp(
        const HomeScreen(),
        storage: storage,
        language: AppLanguage.en,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(english.homeSecondaryCta), findsOneWidget);
  });

  testWidgets('New campaign opens gameplay chat', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final _TestStorageBundle storage = _TestStorageBundle.create();
    addTearDown(storage.dispose);

    await tester.binding.setSurfaceSize(const Size(1200, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _buildScopedApp(
        const NewGameScreen(),
        storage: storage,
        language: AppLanguage.en,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(english.quickStart));
    await tester.pumpAndSettle();

    await tester.tap(find.text(english.startAdventure));
    await tester.pumpAndSettle();

    expect(find.byType(ChatScreen), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('Custom story step uses one field and expands typed idea', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final _TestStorageBundle storage = _TestStorageBundle.create();
    addTearDown(storage.dispose);
    final _PromptGeneratingAiClient aiClient = _PromptGeneratingAiClient();

    await tester.pumpWidget(
      _buildScopedApp(
        const NewGameScreen(),
        storage: storage,
        language: AppLanguage.en,
        settingsRepository: _FakeSettingsRepository(
          const _ConfiguredAiSettings(),
        ),
        aiServiceFactory: _FakeAiServiceFactory(aiClient),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(english.customSetup));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip(english.nextButton));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);

    await tester.enterText(
      find.byType(TextField),
      'A stormbound city mystery with occult undertones',
    );
    await tester.tap(find.text(english.generatePrompts));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(
      aiClient.lastStoryWish,
      'A stormbound city mystery with occult undertones',
    );
    expect(_firstTextFieldValue(tester), contains('Expanded:'));
  });

  testWidgets('Custom story generation works from empty input', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final _TestStorageBundle storage = _TestStorageBundle.create();
    addTearDown(storage.dispose);
    final _PromptGeneratingAiClient aiClient = _PromptGeneratingAiClient();

    await tester.pumpWidget(
      _buildScopedApp(
        const NewGameScreen(),
        storage: storage,
        language: AppLanguage.en,
        settingsRepository: _FakeSettingsRepository(
          const _ConfiguredAiSettings(),
        ),
        aiServiceFactory: _FakeAiServiceFactory(aiClient),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(english.customSetup));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip(english.nextButton));
    await tester.pumpAndSettle();

    await tester.tap(find.text(english.generatePrompts));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(aiClient.lastStoryWish, isNotEmpty);
    expect(_firstTextFieldValue(tester), contains('Expanded:'));
  });

  testWidgets(
    'Custom campaign saves generated portrait when Sber returns one',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final _TestStorageBundle storage = _TestStorageBundle.create();
      addTearDown(storage.dispose);
      final _PortraitGeneratingAiClient aiClient =
          _PortraitGeneratingAiClient();
      final _FakePortraitStorage portraitStorage = _FakePortraitStorage();

      await tester.pumpWidget(
        _buildScopedApp(
          const NewGameScreen(),
          storage: storage,
          language: AppLanguage.en,
          settingsRepository: _FakeSettingsRepository(
            const _ConfiguredSberSettings(),
          ),
          aiServiceFactory: _FakeAiServiceFactory(aiClient),
          portraitStorage: portraitStorage,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(english.customSetup));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip(english.nextButton));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextField),
        'A stormbound city mystery',
      );
      await tester.tap(find.byTooltip(english.nextButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip(english.nextButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip(english.createCampaignButton));
      await tester.pumpAndSettle();

      final List<CampaignState> campaigns = await storage.campaignRepository
          .loadAllCampaigns();
      expect(campaigns, hasLength(1));
      expect(campaigns.single.portraitPath, portraitStorage.savedPath);
      expect(campaigns.single.portraitPrompt, contains('cinematic character'));
      expect(aiClient.lastStoryPrompt, contains('stormbound city mystery'));
    },
  );

  testWidgets('Custom campaign falls back when portrait generation fails', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final _TestStorageBundle storage = _TestStorageBundle.create();
    addTearDown(storage.dispose);

    await tester.pumpWidget(
      _buildScopedApp(
        const NewGameScreen(),
        storage: storage,
        language: AppLanguage.en,
        settingsRepository: _FakeSettingsRepository(
          const _ConfiguredSberSettings(),
        ),
        aiServiceFactory: const _FakeAiServiceFactory(_NullPortraitAiClient()),
        portraitStorage: _FakePortraitStorage(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(english.customSetup));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip(english.nextButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'An occult detective case');
    await tester.tap(find.byTooltip(english.nextButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip(english.nextButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip(english.createCampaignButton));
    await tester.pumpAndSettle();

    final List<CampaignState> campaigns = await storage.campaignRepository
        .loadAllCampaigns();
    expect(campaigns, hasLength(1));
    expect(campaigns.single.portraitPath, isEmpty);
    expect(campaigns.single.portraitPrompt, isEmpty);
  });

  testWidgets(
    'Custom campaign can generate portrait through Sber while story model stays non-Sber',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final _TestStorageBundle storage = _TestStorageBundle.create();
      addTearDown(storage.dispose);
      final _PortraitGeneratingAiClient aiClient =
          _PortraitGeneratingAiClient();
      final _FakePortraitStorage portraitStorage = _FakePortraitStorage();
      final ProviderScopedSettings scoped =
          ProviderScopedSettings(
            activeProvider: AiProviderType.openAiCompatible,
            profiles: <AiProviderType, ProviderProfile>{
              for (final AiProviderType provider in AiProviderType.values)
                provider: ProviderProfile.defaultsFor(provider),
            },
            fastResponses: false,
          ).copyWith(
            profiles: <AiProviderType, ProviderProfile>{
              for (final AiProviderType provider in AiProviderType.values)
                provider: switch (provider) {
                  AiProviderType.openAiCompatible => const ProviderProfile(
                    baseUrl: 'http://127.0.0.1:9999/v1',
                    model: 'story-model',
                    apiKey: 'story-key',
                    timeoutSeconds: 15,
                    runtimeSettings: ModelRuntimeSettings.smartPreset,
                  ),
                  AiProviderType.sberGigaChat => const ProviderProfile(
                    baseUrl: 'http://127.0.0.1:8787/v1',
                    model: 'GigaChat-2',
                    apiKey: '',
                    timeoutSeconds: 15,
                    runtimeSettings: ModelRuntimeSettings.smartPreset,
                  ),
                  _ => ProviderProfile.defaultsFor(provider),
                },
            },
          );

      await tester.pumpWidget(
        _buildScopedApp(
          const NewGameScreen(),
          storage: storage,
          language: AppLanguage.en,
          settingsRepository: _FakeSettingsRepository(
            const _ConfiguredAiSettings(),
            scoped: scoped,
          ),
          aiServiceFactory: _FakeAiServiceFactory(aiClient),
          portraitStorage: portraitStorage,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(english.customSetup));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip(english.nextButton));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextField),
        'A haunted archive mystery',
      );
      await tester.tap(find.byTooltip(english.nextButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip(english.nextButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip(english.createCampaignButton));
      await tester.pumpAndSettle();

      final List<CampaignState> campaigns = await storage.campaignRepository
          .loadAllCampaigns();
      expect(campaigns, hasLength(1));
      expect(campaigns.single.portraitPath, portraitStorage.savedPath);
      expect(aiClient.lastProvider, AiProviderType.sberGigaChat);
    },
  );

  testWidgets('Saves screen shows empty state', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final _TestStorageBundle storage = _TestStorageBundle.create();
    addTearDown(storage.dispose);

    await tester.pumpWidget(
      _buildScopedApp(
        const SavesScreen(),
        storage: storage,
        language: AppLanguage.en,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(english.noSavesYet), findsOneWidget);
  });

  testWidgets('Saves screen opens migrated legacy campaign', (tester) async {
    final CampaignState campaign = _sampleCampaign();
    SharedPreferences.setMockInitialValues(<String, Object>{
      'campaign.ids': <String>[campaign.id],
      'campaign.${campaign.id}': jsonEncode(campaign.toJson()),
    });
    final _TestStorageBundle storage = _TestStorageBundle.create();
    addTearDown(storage.dispose);

    await tester.pumpWidget(
      _buildScopedApp(
        const SavesScreen(),
        storage: storage,
        language: AppLanguage.en,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(campaign.title), findsOneWidget);

    final Finder openButton = find.ancestor(
      of: find.text(english.loadCampaignAction),
      matching: find.byType(GestureDetector),
    );
    await tester.tap(openButton.first, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.byType(ChatScreen), findsOneWidget);
    expect(find.text(campaign.title), findsOneWidget);
  });

  testWidgets('Gameplay chat saves campaign via save button', (tester) async {
    final CampaignState campaign = _sampleCampaign();
    SharedPreferences.setMockInitialValues(<String, Object>{
      'campaign.ids': <String>[campaign.id],
      'campaign.${campaign.id}': jsonEncode(campaign.toJson()),
    });
    final _TestStorageBundle storage = _TestStorageBundle.create();
    addTearDown(storage.dispose);

    await tester.pumpWidget(
      _buildScopedApp(
        ChatScreen(campaignId: campaign.id),
        storage: storage,
        language: AppLanguage.en,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip(english.saveTooltip));
    await tester.pumpAndSettle();

    expect(find.text(english.campaignSaved), findsOneWidget);

    final CampaignState? saved = await storage.campaignRepository.loadCampaign(
      campaign.id,
    );
    expect(saved, isNotNull);
    expect(saved?.title, campaign.title);
  });

  testWidgets(
    'Gameplay chat shows transient save feedback without status card',
    (tester) async {
      final CampaignState campaign = _sampleCampaign();
      SharedPreferences.setMockInitialValues(<String, Object>{
        'campaign.ids': <String>[campaign.id],
        'campaign.${campaign.id}': jsonEncode(campaign.toJson()),
      });
      final _TestStorageBundle storage = _TestStorageBundle.create();
      addTearDown(storage.dispose);

      await tester.pumpWidget(
        _buildScopedApp(
          ChatScreen(campaignId: campaign.id),
          storage: storage,
          language: AppLanguage.en,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip(english.saveTooltip));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.ancestor(
          of: find.text(english.campaignSaved),
          matching: find.byType(SnackBar),
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets('Portrait card shows only character name under image', (
    tester,
  ) async {
    final CampaignState campaign = _sampleCampaign();
    SharedPreferences.setMockInitialValues(<String, Object>{
      'campaign.ids': <String>[campaign.id],
      'campaign.${campaign.id}': jsonEncode(campaign.toJson()),
    });
    final _TestStorageBundle storage = _TestStorageBundle.create();
    addTearDown(storage.dispose);

    await tester.binding.setSurfaceSize(const Size(1200, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _buildScopedApp(
        ChatScreen(campaignId: campaign.id),
        storage: storage,
        language: AppLanguage.en,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(campaign.character.name), findsOneWidget);
    expect(find.text(english.portraitPlaceholderLabel), findsNothing);
    expect(find.text(english.portraitAiHint), findsNothing);
    expect(find.text(english.portraitAiReadyHint), findsNothing);
  });

  testWidgets('Without configured model, turn runs in demo mode', (
    tester,
  ) async {
    final CampaignState campaign = _sampleCampaign();
    SharedPreferences.setMockInitialValues(<String, Object>{
      'campaign.ids': <String>[campaign.id],
      'campaign.${campaign.id}': jsonEncode(campaign.toJson()),
    });
    final _TestStorageBundle storage = _TestStorageBundle.create();
    addTearDown(storage.dispose);

    await tester.pumpWidget(
      _buildScopedApp(
        ChatScreen(campaignId: campaign.id),
        storage: storage,
        language: AppLanguage.en,
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Step toward the tower');
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pumpAndSettle();

    expect(find.textContaining('in demo mode'), findsAtLeastNWidgets(1));

    final CampaignState? saved = await storage.campaignRepository.loadCampaign(
      campaign.id,
    );
    expect(saved, isNotNull);
    expect(
      saved?.messages.any(
        (final item) => item.text.contains('Step toward the tower'),
      ),
      isTrue,
    );
  });

  testWidgets('Gameplay chat shows recoverable AI error and stays alive', (
    tester,
  ) async {
    final CampaignState campaign = _sampleCampaign();
    SharedPreferences.setMockInitialValues(<String, Object>{
      'campaign.ids': <String>[campaign.id],
      'campaign.${campaign.id}': jsonEncode(campaign.toJson()),
    });
    final _TestStorageBundle storage = _TestStorageBundle.create();
    addTearDown(storage.dispose);

    await tester.pumpWidget(
      _buildScopedApp(
        ChatScreen(campaignId: campaign.id),
        storage: storage,
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

    final CampaignState? saved = await storage.campaignRepository.loadCampaign(
      campaign.id,
    );
    expect(saved, isNotNull);
    final String allTexts = saved!.messages
        .map((final item) => item.text)
        .join('\n');
    expect(allTexts, contains('Could not connect to the AI endpoint.'));
    expect(allTexts, contains('Technical note: the raw model response'));
  });

  testWidgets(
    'Gameplay chat keeps stable generating placeholder until turn completes',
    (tester) async {
      final CampaignState campaign = _sampleCampaign();
      SharedPreferences.setMockInitialValues(<String, Object>{
        'campaign.ids': <String>[campaign.id],
        'campaign.${campaign.id}': jsonEncode(campaign.toJson()),
      });
      final _TestStorageBundle storage = _TestStorageBundle.create();
      addTearDown(storage.dispose);

      await tester.pumpWidget(
        _buildScopedApp(
          ChatScreen(campaignId: campaign.id),
          storage: storage,
          language: AppLanguage.en,
          settingsRepository: _FakeSettingsRepository(
            const _ConfiguredAiSettings(),
          ),
          aiServiceFactory: const _FakeAiServiceFactory(_StreamingAiClient()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Open the ancient gate');
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 20));

      expect(find.textContaining('Generating'), findsWidgets);

      await tester.pumpAndSettle();

      expect(find.textContaining('cold dust spills out'), findsOneWidget);
    },
  );

  testWidgets(
    'Gameplay chat blocks duplicate submissions while a turn is active',
    (tester) async {
      final CampaignState campaign = _sampleCampaign();
      SharedPreferences.setMockInitialValues(<String, Object>{
        'campaign.ids': <String>[campaign.id],
        'campaign.${campaign.id}': jsonEncode(campaign.toJson()),
      });
      final _TestStorageBundle storage = _TestStorageBundle.create();
      addTearDown(storage.dispose);
      final _DelayedTurnAiClient aiClient = _DelayedTurnAiClient();

      await tester.pumpWidget(
        _buildScopedApp(
          ChatScreen(campaignId: campaign.id),
          storage: storage,
          language: AppLanguage.en,
          settingsRepository: _FakeSettingsRepository(
            const _ConfiguredAiSettings(),
          ),
          aiServiceFactory: _FakeAiServiceFactory(aiClient),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Open the gate');
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pump();

      expect(aiClient.callCount, 1);

      aiClient.complete();
      await tester.pumpAndSettle();
    },
  );

  testWidgets('Settings screen opens and shows core controls', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final _TestStorageBundle storage = _TestStorageBundle.create();
    addTearDown(storage.dispose);
    await tester.binding.setSurfaceSize(const Size(1200, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _buildScopedApp(
        const SettingsScreen(),
        storage: storage,
        language: AppLanguage.en,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('LM Studio'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text(english.maxResponseTokens),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text(english.maxResponseTokens), findsOneWidget);
    expect(find.text(english.contextWindowSize), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text(english.saveSettings),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text(english.saveSettings), findsOneWidget);
    expect(find.byType(OutlinedButton), findsWidgets);
  });

  testWidgets('Settings runtime presets update token controls', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final _TestStorageBundle storage = _TestStorageBundle.create();
    addTearDown(storage.dispose);
    await tester.binding.setSurfaceSize(const Size(1200, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _buildScopedApp(
        const SettingsScreen(),
        storage: storage,
        language: AppLanguage.en,
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      _textFieldByLabel(english.maxResponseTokens),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(_textFieldValue(tester, english.maxResponseTokens), '256');
    expect(_textFieldValue(tester, english.contextWindowSize), '1536');

    await tester.tap(
      find.widgetWithText(ChoiceChip, english.runtimeProfileCheap),
    );
    await tester.pumpAndSettle();

    expect(_textFieldValue(tester, english.maxResponseTokens), '160');
    expect(_textFieldValue(tester, english.contextWindowSize), '1024');

    await tester.tap(
      find.widgetWithText(ChoiceChip, english.runtimeProfileSmart),
    );
    await tester.pumpAndSettle();

    expect(_textFieldValue(tester, english.maxResponseTokens), '512');
    expect(_textFieldValue(tester, english.contextWindowSize), '3072');
  });

  testWidgets('Settings runtime edits become custom and persist after save', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final _TestStorageBundle storage = _TestStorageBundle.create();
    addTearDown(storage.dispose);
    await tester.binding.setSurfaceSize(const Size(1200, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _buildScopedApp(
        const SettingsScreen(),
        storage: storage,
        language: AppLanguage.en,
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      _textFieldByLabel(english.maxResponseTokens),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    await tester.enterText(_textFieldByLabel(english.maxResponseTokens), '777');
    await tester.pumpAndSettle();
    await tester.enterText(
      _textFieldByLabel(english.contextWindowSize),
      '2048',
    );
    await tester.pumpAndSettle();

    expect(find.text(english.runtimeProfileCustom), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text(english.saveSettings),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text(english.saveSettings));
    await tester.pumpAndSettle();

    final ProviderScopedSettings saved = await storage.settingsRepository
        .loadProviderScopedSettings();
    final ProviderProfile lmStudioProfile = saved.profileFor(
      AiProviderType.lmStudio,
    );

    expect(saved.activeProvider, AiProviderType.lmStudio);
    expect(lmStudioProfile.runtimeSettings.maxResponseTokens, 777);
    expect(lmStudioProfile.runtimeSettings.contextWindowSize, 2048);
    expect(lmStudioProfile.runtimeSettings.profile, ModelRuntimeProfile.custom);
    expect(find.text(english.settingsSaved), findsOneWidget);
  });

  testWidgets(
    'Settings restore provider-specific runtime controls when switching providers',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final _TestStorageBundle storage = _TestStorageBundle.create();
      addTearDown(storage.dispose);
      await tester.binding.setSurfaceSize(const Size(1200, 2000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final Map<AiProviderType, ProviderProfile> profiles =
          <AiProviderType, ProviderProfile>{
            for (final AiProviderType provider in AiProviderType.values)
              provider: ProviderProfile.defaultsFor(provider),
          };
      profiles[AiProviderType.lmStudio] = const ProviderProfile(
        baseUrl: 'http://127.0.0.1:1234/v1',
        model: 'local-model',
        apiKey: '',
        timeoutSeconds: 60,
        runtimeSettings: ModelRuntimeSettings.fastPreset,
      );
      profiles[AiProviderType.openRouter] = const ProviderProfile(
        baseUrl: 'https://openrouter.ai/api/v1',
        model: 'anthropic/claude-3',
        apiKey: 'openrouter-key',
        timeoutSeconds: 120,
        runtimeSettings: ModelRuntimeSettings(
          maxResponseTokens: 320,
          contextWindowSize: 2048,
          profile: ModelRuntimeProfile.custom,
        ),
      );
      await storage.settingsRepository.saveProviderScopedSettings(
        ProviderScopedSettings(
          activeProvider: AiProviderType.lmStudio,
          profiles: profiles,
          fastResponses: true,
        ),
      );

      await tester.pumpWidget(
        _buildScopedApp(
          const SettingsScreen(),
          storage: storage,
          language: AppLanguage.en,
        ),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        _textFieldByLabel(english.maxResponseTokens),
        300,
        scrollable: find.byType(Scrollable).first,
      );

      expect(_textFieldValue(tester, english.maxResponseTokens), '256');
      expect(_textFieldValue(tester, english.contextWindowSize), '1536');

      await tester.drag(find.byType(Scrollable).first, const Offset(0, 1200));
      await tester.pumpAndSettle();
      await tester.tap(find.text(english.openRouter));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        _textFieldByLabel(english.maxResponseTokens),
        300,
        scrollable: find.byType(Scrollable).first,
      );

      expect(_textFieldValue(tester, english.maxResponseTokens), '320');
      expect(_textFieldValue(tester, english.contextWindowSize), '2048');
      expect(find.text(english.runtimeProfileCustom), findsOneWidget);

      await tester.drag(find.byType(Scrollable).first, const Offset(0, 1200));
      await tester.pumpAndSettle();
      await tester.tap(find.text('LM Studio'));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        _textFieldByLabel(english.maxResponseTokens),
        300,
        scrollable: find.byType(Scrollable).first,
      );

      expect(_textFieldValue(tester, english.maxResponseTokens), '256');
      expect(_textFieldValue(tester, english.contextWindowSize), '1536');
      expect(find.text(english.runtimeProfileCustom), findsNothing);
    },
  );

  testWidgets('Narrow gameplay layout keeps drawer and focused chat area', (
    tester,
  ) async {
    final CampaignState campaign = _sampleCampaign();
    SharedPreferences.setMockInitialValues(<String, Object>{
      'campaign.ids': <String>[campaign.id],
      'campaign.${campaign.id}': jsonEncode(campaign.toJson()),
    });
    final _TestStorageBundle storage = _TestStorageBundle.create();
    addTearDown(storage.dispose);

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(360, 640)),
        child: _buildScopedApp(
          ChatScreen(campaignId: campaign.id),
          storage: storage,
          language: AppLanguage.en,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.menu), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(Icons.send_rounded), findsOneWidget);
  });

  testWidgets('Mobile chat stays stable when keyboard is open', (tester) async {
    final CampaignState campaign = _sampleCampaign();
    SharedPreferences.setMockInitialValues(<String, Object>{
      'campaign.ids': <String>[campaign.id],
      'campaign.${campaign.id}': jsonEncode(campaign.toJson()),
    });
    final _TestStorageBundle storage = _TestStorageBundle.create();
    addTearDown(storage.dispose);

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(360, 640),
          viewInsets: EdgeInsets.only(bottom: 280),
        ),
        child: _buildScopedApp(
          ChatScreen(campaignId: campaign.id),
          storage: storage,
          language: AppLanguage.en,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('Responsive layouts stay stable across common screen widths', (
    tester,
  ) async {
    final CampaignState campaign = _sampleCampaign();
    const List<Size> sizes = <Size>[
      Size(320, 760),
      Size(360, 800),
      Size(390, 844),
      Size(430, 932),
      Size(768, 1024),
      Size(1024, 1366),
    ];

    for (final Size size in sizes) {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'campaign.ids': <String>[campaign.id],
        'campaign.${campaign.id}': jsonEncode(campaign.toJson()),
      });
      final _TestStorageBundle storage = _TestStorageBundle.create();
      addTearDown(storage.dispose);

      await tester.binding.setSurfaceSize(size);
      await tester.pumpWidget(
        _buildScopedApp(
          const HomeScreen(),
          storage: storage,
          language: AppLanguage.en,
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'HomeScreen at $size');
      expect(find.text(english.brandName), findsOneWidget);

      await tester.pumpWidget(
        _buildScopedApp(
          const SettingsScreen(),
          storage: storage,
          language: AppLanguage.en,
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'SettingsScreen at $size');
      expect(find.text(english.aiSettings), findsWidgets);
    }

    await tester.binding.setSurfaceSize(null);
  });
}

Widget _buildScopedApp(
  final Widget home, {
  required final _TestStorageBundle storage,
  required final AppLanguage language,
  final SettingsRepository? settingsRepository,
  final CampaignRepository? campaignRepository,
  final AiServiceFactory? aiServiceFactory,
  final GameEngine? gameEngine,
  final PortraitStorage? portraitStorage,
}) {
  final SettingsRepository resolvedSettingsRepository =
      settingsRepository ?? storage.settingsRepository;
  final CampaignRepository resolvedCampaignRepository =
      campaignRepository ?? storage.campaignRepository;
  final AiServiceFactory resolvedAiServiceFactory =
      aiServiceFactory ?? const AiServiceFactory();
  final GameEngine resolvedGameEngine = gameEngine ?? const GameEngine();
  final PortraitStorage resolvedPortraitStorage =
      portraitStorage ?? const PortraitStorage();
  final ValueNotifier<AppLanguage> appLanguageListenable =
      ValueNotifier<AppLanguage>(language);

  return ProviderScope(
    overrides: buildAppProviderOverrides(
      settingsRepository: resolvedSettingsRepository,
      campaignRepository: resolvedCampaignRepository,
      aiServiceFactory: resolvedAiServiceFactory,
      gameEngine: resolvedGameEngine,
      portraitStorage: resolvedPortraitStorage,
      appLanguageListenable: appLanguageListenable,
    ),
    child: AppLocalizationsScope(
      localizations: AppLocalizations(language),
      child: MaterialApp(home: home),
    ),
  );
}

Finder _textFieldByLabel(final String label) => find.byWidgetPredicate(
  (final widget) =>
      widget is TextField && widget.decoration?.labelText == label,
);

String _textFieldValue(final WidgetTester tester, final String label) {
  final TextField field = tester.widget<TextField>(_textFieldByLabel(label));
  return field.controller?.text ?? '';
}

String _firstTextFieldValue(final WidgetTester tester) {
  final TextField field = tester.widget<TextField>(
    find.byType(TextField).first,
  );
  return field.controller?.text ?? '';
}

class _FakeSettingsRepository extends SettingsRepository {
  _FakeSettingsRepository(this._settings, {ProviderScopedSettings? scoped})
    : _scoped =
          scoped ??
          ProviderScopedSettings(
            activeProvider: _settings.provider,
            profiles: <AiProviderType, ProviderProfile>{
              for (final AiProviderType provider in AiProviderType.values)
                provider: provider == _settings.provider
                    ? ProviderProfile(
                        baseUrl: _settings.baseUrl,
                        model: _settings.model,
                        apiKey: _settings.apiKey,
                        timeoutSeconds: _settings.timeoutSeconds,
                        runtimeSettings: _settings.runtimeSettings,
                      )
                    : ProviderProfile.defaultsFor(provider),
            },
            fastResponses: _settings.fastResponses,
            confirmed18Plus: _settings.confirmed18Plus,
          );

  final AiSettings _settings;
  final ProviderScopedSettings _scoped;

  @override
  Future<AiSettings> loadAiSettings() async => _settings;

  @override
  Future<ProviderScopedSettings> loadProviderScopedSettings() async => _scoped;
}

class _DelayedSettingsRepository extends SettingsRepository {
  _DelayedSettingsRepository(final AppDatabase database, this._languageFuture)
    : super(database: database);

  final Future<AppLanguage> _languageFuture;

  @override
  Future<AppLanguage> loadAppLanguage() => _languageFuture;
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
  Future<void> checkConnection({required final AiSettings settings}) async {}

  @override
  Future<TurnResult> generateTurn({
    required final AiSettings settings,
    required final AppLanguage language,
    required final CampaignState state,
    required final String playerAction,
    required final bool suggestionsOnly,
    required final DeterministicTurnContext deterministicContext,
    final AiRequestMetadata? metadata,
    final NarrationDeltaCallback? onNarrationDelta,
    final CancelToken? cancelToken,
  }) async {
    throw _error;
  }

  @override
  Future<GeneratedPrompts> generatePromptsFromStoryWish({
    required final AiSettings settings,
    required final AppLanguage language,
    required final String storyWish,
    required final CampaignSetting setting,
    final CancelToken? cancelToken,
  }) async => const GeneratedPrompts(storyPrompt: '', characterPrompt: '');

  @override
  Future<GeneratedPortrait?> generateCharacterPortrait({
    required final AiSettings settings,
    required final AppLanguage language,
    required final CampaignSetting setting,
    required final String storyPrompt,
    required final CharacterProfile character,
    final CancelToken? cancelToken,
  }) async => null;
}

class _StreamingAiClient implements AiClient {
  const _StreamingAiClient();

  @override
  Future<void> checkConnection({required final AiSettings settings}) async {}

  @override
  Future<TurnResult> generateTurn({
    required final AiSettings settings,
    required final AppLanguage language,
    required final CampaignState state,
    required final String playerAction,
    required final bool suggestionsOnly,
    required final DeterministicTurnContext deterministicContext,
    final AiRequestMetadata? metadata,
    final NarrationDeltaCallback? onNarrationDelta,
    final CancelToken? cancelToken,
  }) async {
    onNarrationDelta?.call('The gate groans open');
    await Future<void>.delayed(const Duration(milliseconds: 30));
    onNarrationDelta?.call(
      'The gate groans open and cold dust spills out across the floor.',
    );
    await Future<void>.delayed(const Duration(milliseconds: 30));

    return const TurnResult(
      narration:
          'The gate groans open and cold dust spills out across the floor.',
      choices: <String>['Step inside', 'Wait', 'Call out'],
      stateChanges: StateChanges.empty(),
      memoryEntry: 'The sealed gate was opened.',
    );
  }

  @override
  Future<GeneratedPrompts> generatePromptsFromStoryWish({
    required final AiSettings settings,
    required final AppLanguage language,
    required final String storyWish,
    required final CampaignSetting setting,
    final CancelToken? cancelToken,
  }) async => const GeneratedPrompts(storyPrompt: '', characterPrompt: '');

  @override
  Future<GeneratedPortrait?> generateCharacterPortrait({
    required final AiSettings settings,
    required final AppLanguage language,
    required final CampaignSetting setting,
    required final String storyPrompt,
    required final CharacterProfile character,
    final CancelToken? cancelToken,
  }) async => null;
}

class _PromptGeneratingAiClient implements AiClient {
  String lastStoryWish = '';

  @override
  Future<void> checkConnection({required final AiSettings settings}) async {}

  @override
  Future<TurnResult> generateTurn({
    required final AiSettings settings,
    required final AppLanguage language,
    required final CampaignState state,
    required final String playerAction,
    required final bool suggestionsOnly,
    required final DeterministicTurnContext deterministicContext,
    final AiRequestMetadata? metadata,
    final NarrationDeltaCallback? onNarrationDelta,
    final CancelToken? cancelToken,
  }) async => const TurnResult(
    narration: 'The story begins.',
    choices: <String>['Continue'],
    stateChanges: StateChanges.empty(),
    memoryEntry: 'The story begins.',
  );

  @override
  Future<GeneratedPrompts> generatePromptsFromStoryWish({
    required final AiSettings settings,
    required final AppLanguage language,
    required final String storyWish,
    required final CampaignSetting setting,
    final CancelToken? cancelToken,
  }) async {
    lastStoryWish = storyWish;
    return GeneratedPrompts(
      storyPrompt: 'Expanded: $storyWish',
      characterPrompt: 'Watchful investigator',
    );
  }

  @override
  Future<GeneratedPortrait?> generateCharacterPortrait({
    required final AiSettings settings,
    required final AppLanguage language,
    required final CampaignSetting setting,
    required final String storyPrompt,
    required final CharacterProfile character,
    final CancelToken? cancelToken,
  }) async => null;
}

class _PortraitGeneratingAiClient implements AiClient {
  String lastStoryPrompt = '';
  AiProviderType? lastProvider;

  @override
  Future<void> checkConnection({required final AiSettings settings}) async {}

  @override
  Future<TurnResult> generateTurn({
    required final AiSettings settings,
    required final AppLanguage language,
    required final CampaignState state,
    required final String playerAction,
    required final bool suggestionsOnly,
    required final DeterministicTurnContext deterministicContext,
    final AiRequestMetadata? metadata,
    final NarrationDeltaCallback? onNarrationDelta,
    final CancelToken? cancelToken,
  }) async => const TurnResult(
    narration: 'The story begins.',
    choices: <String>['Continue'],
    stateChanges: StateChanges.empty(),
    memoryEntry: 'The story begins.',
  );

  @override
  Future<GeneratedPrompts> generatePromptsFromStoryWish({
    required final AiSettings settings,
    required final AppLanguage language,
    required final String storyWish,
    required final CampaignSetting setting,
    final CancelToken? cancelToken,
  }) async => const GeneratedPrompts(storyPrompt: '', characterPrompt: '');

  @override
  Future<GeneratedPortrait?> generateCharacterPortrait({
    required final AiSettings settings,
    required final AppLanguage language,
    required final CampaignSetting setting,
    required final String storyPrompt,
    required final CharacterProfile character,
    final CancelToken? cancelToken,
  }) async {
    lastProvider = settings.provider;
    lastStoryPrompt = storyPrompt;
    return const GeneratedPortrait(
      bytesBase64: 'aGVsbG8=',
      mimeType: 'image/png',
      promptUsed:
          'cinematic character portrait, expressive lighting, no text, no watermark',
    );
  }
}

class _NullPortraitAiClient implements AiClient {
  const _NullPortraitAiClient();

  @override
  Future<void> checkConnection({required final AiSettings settings}) async {}

  @override
  Future<TurnResult> generateTurn({
    required final AiSettings settings,
    required final AppLanguage language,
    required final CampaignState state,
    required final String playerAction,
    required final bool suggestionsOnly,
    required final DeterministicTurnContext deterministicContext,
    final AiRequestMetadata? metadata,
    final NarrationDeltaCallback? onNarrationDelta,
    final CancelToken? cancelToken,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<GeneratedPrompts> generatePromptsFromStoryWish({
    required final AiSettings settings,
    required final AppLanguage language,
    required final String storyWish,
    required final CampaignSetting setting,
    final CancelToken? cancelToken,
  }) async => const GeneratedPrompts(storyPrompt: '', characterPrompt: '');

  @override
  Future<GeneratedPortrait?> generateCharacterPortrait({
    required final AiSettings settings,
    required final AppLanguage language,
    required final CampaignSetting setting,
    required final String storyPrompt,
    required final CharacterProfile character,
    final CancelToken? cancelToken,
  }) async => null;
}

class _DelayedTurnAiClient implements AiClient {
  final Completer<TurnResult> _completer = Completer<TurnResult>();
  int callCount = 0;

  @override
  Future<void> checkConnection({required final AiSettings settings}) async {}

  @override
  Future<TurnResult> generateTurn({
    required final AiSettings settings,
    required final AppLanguage language,
    required final CampaignState state,
    required final String playerAction,
    required final bool suggestionsOnly,
    required final DeterministicTurnContext deterministicContext,
    final AiRequestMetadata? metadata,
    final NarrationDeltaCallback? onNarrationDelta,
    final CancelToken? cancelToken,
  }) {
    callCount += 1;
    return _completer.future;
  }

  @override
  Future<GeneratedPrompts> generatePromptsFromStoryWish({
    required final AiSettings settings,
    required final AppLanguage language,
    required final String storyWish,
    required final CampaignSetting setting,
    final CancelToken? cancelToken,
  }) async => const GeneratedPrompts(storyPrompt: '', characterPrompt: '');

  @override
  Future<GeneratedPortrait?> generateCharacterPortrait({
    required final AiSettings settings,
    required final AppLanguage language,
    required final CampaignSetting setting,
    required final String storyPrompt,
    required final CharacterProfile character,
    final CancelToken? cancelToken,
  }) async => null;

  void complete() {
    if (_completer.isCompleted) {
      return;
    }
    _completer.complete(
      const TurnResult(
        narration: 'The gate answers with a quiet metallic sigh.',
        choices: <String>['Step closer'],
        stateChanges: StateChanges.empty(),
        memoryEntry: 'The gate reacted.',
      ),
    );
  }
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
        runtimeSettings: ModelRuntimeSettings.smartPreset,
      );
}

class _ConfiguredSberSettings extends AiSettings {
  const _ConfiguredSberSettings()
    : super(
        provider: AiProviderType.sberGigaChat,
        baseUrl: 'http://127.0.0.1:8787/v1',
        model: 'GigaChat-2',
        apiKey: '',
        timeoutSeconds: 15,
        fastResponses: false,
        runtimeSettings: ModelRuntimeSettings.smartPreset,
      );
}

class _FakePortraitStorage extends PortraitStorage {
  String savedPath = '';

  @override
  Future<String?> savePortrait({
    required final String campaignId,
    required final String mimeType,
    required final String bytesBase64,
  }) async => savedPath = 'C:/tmp/$campaignId.png';
}

CampaignState _sampleCampaign() => CampaignState(
  id: 'campaign-1',
  schemaVersion: 3,
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
  modules: const <CampaignModuleState>[
    CampaignModuleState(
      module: CampaignModule.inventory,
      isActive: true,
      activationReason: 'test',
    ),
    CampaignModuleState(
      module: CampaignModule.notes,
      isActive: true,
      activationReason: 'test',
    ),
    CampaignModuleState(
      module: CampaignModule.vitality,
      isActive: true,
      activationReason: 'test',
    ),
  ],
  inventory: const <String>['Lantern', 'Map'],
  companions: const <CampaignCompanion>[],
  notes: const <String>['Follow the caravan trail'],
  resources: const <CampaignResource>[],
  progression: null,
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

class _TestStorageBundle {
  _TestStorageBundle._(
    this.directory,
    this.database,
    this.settingsRepository,
    this.campaignRepository,
  );

  factory _TestStorageBundle.create() {
    final Directory directory = Directory.systemTemp.createTempSync(
      'ai_prg_widget_test_',
    );
    final AppDatabase database = AppDatabase(
      directoryPath: directory.path,
      name: 'widget_${DateTime.now().microsecondsSinceEpoch}',
    );
    return _TestStorageBundle._(
      directory,
      database,
      SettingsRepository(database: database),
      CampaignRepository(database: database),
    );
  }

  final Directory directory;
  final AppDatabase database;
  final SettingsRepository settingsRepository;
  final CampaignRepository campaignRepository;

  Future<void> dispose() async {
    await database.close(deleteFromDisk: true);
    if (directory.existsSync()) {
      directory.deleteSync(recursive: true);
    }
  }
}
