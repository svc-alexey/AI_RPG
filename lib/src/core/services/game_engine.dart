import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:ai_prg/src/core/services/campaign_memory_manager.dart';
import 'package:ai_prg/src/core/services/campaign_module_resolver.dart';
import 'package:ai_prg/src/core/services/character_prompt_builder.dart';
import 'package:ai_prg/src/core/services/deterministic_check_service.dart';
import 'package:ai_prg/src/core/services/entity_extraction_service.dart';

class GameEngine {
  const GameEngine();

  static const CampaignMemoryManager _memoryManager = CampaignMemoryManager();
  static const CampaignModuleResolver _moduleResolver =
      CampaignModuleResolver();
  static const CharacterPromptBuilder _charBuilder = CharacterPromptBuilder();
  static const DeterministicCheckService _deterministicCheckService =
      DeterministicCheckService();
  static const EntityExtractionService _entityExtractionService =
      EntityExtractionService();

  CampaignState createCampaign({
    required final CampaignDraft draft,
    required final AppLanguage language,
  }) {
    final DateTime now = DateTime.now();
    final String id = draft.id?.trim().isNotEmpty == true
        ? draft.id!.trim()
        : now.microsecondsSinceEpoch.toString();
    final List<CampaignModuleState> modules = _moduleResolver
        .resolveInitialModules(draft: draft);
    final bool inventoryActive = _isModuleActive(
      modules,
      CampaignModule.inventory,
    );
    final bool notesActive = _isModuleActive(modules, CampaignModule.notes);

    final String characterName = draft.characterProfile != null
        ? draft.characterProfile!.name
        : (draft.heroName.trim().isEmpty
              ? switch (language) {
                  AppLanguage.ru => 'Странник',
                  AppLanguage.en => 'Wayfarer',
                }
              : draft.heroName.trim());

    final CharacterStats character = CharacterStats(
      name: characterName,
      hp: 12,
      maxHp: 12,
      energy: 8,
      maxEnergy: 8,
      might: draft.difficulty == DifficultyLevel.hardcore ? 2 : 3,
      wit: 3,
      spirit: draft.mode == StoryMode.longCampaign ? 3 : 2,
    );

    final String characterPrompt = draft.characterProfile != null
        ? _charBuilder.buildPrompt(
            profile: draft.characterProfile!,
            setting: draft.setting,
            language: language,
          )
        : '';

    final List<String> baseInventory = switch (language) {
      AppLanguage.ru => const <String>['Полевые записи', 'Дорожный набор'],
      AppLanguage.en => const <String>['Field Notes', 'Travel Kit'],
    };
    final List<String> inventory = inventoryActive
        ? draft.characterProfile != null
              ? <String>[...baseInventory, ...draft.characterProfile!.perks]
              : baseInventory
        : const <String>[];

    // Стартовая локация будет определена ИИ на основе промпта
    final String location = switch (language) {
      AppLanguage.ru => '...',
      AppLanguage.en => '...',
    };

    const String objective = '';

    final String settingLabel = _settingTitle(draft.setting, language);

    final String introText = switch (language) {
      AppLanguage.ru => 'История начинается.',
      AppLanguage.en => 'The story opens.',
    };

    return CampaignState(
      id: id,
      schemaVersion: 4,
      title: '${character.name} - $settingLabel',
      setting: draft.setting,
      literaryGenre: draft.literaryGenre,
      mode: draft.mode,
      difficulty: draft.difficulty,
      character: character,
      location: location,
      objective: objective,
      turnNumber: 0,
      memory: _memoryManager.createInitialMemory(
        language: language,
        objective: objective,
        introText: introText,
      ),
      modules: modules,
      inventory: inventory,
      companions: const <CampaignCompanion>[],
      notes: notesActive && objective.trim().isNotEmpty
          ? <String>[objective]
          : const <String>[],
      resources: const <CampaignResource>[],
      progression: null,
      messages: const <ChatMessage>[],
      choices: const <String>[],
      updatedAt: now,
      customStoryPrompt: draft.customStoryPrompt,
      characterPrompt: characterPrompt,
      portraitPath: draft.portraitPath,
      portraitPrompt: draft.portraitPrompt,
    );
  }

  TurnApplicationResult applyTurn({
    required final AppLanguage language,
    required final CampaignState state,
    required final String playerAction,
    required final TurnResult result,
    required final int contextWindowSize,
    final DeterministicTurnContext deterministicContext =
        const DeterministicTurnContext.none(),
  }) {
    final DateTime now = DateTime.now();
    final ReconciliationResult reconciliation = _entityExtractionService
        .reconcile(
          state: state,
          result: result,
          language: language,
          resolvedCheck: deterministicContext.resolvedCheck,
        );

    final String location = result.stateChanges.location.trim().isNotEmpty
        ? result.stateChanges.location.trim()
        : state.location;

    final List<ChatMessage> messages = List<ChatMessage>.from(state.messages);
    if (playerAction.trim().isNotEmpty) {
      messages.add(
        ChatMessage(
          id: '${state.id}_${now.microsecondsSinceEpoch}_player',
          role: ChatRole.player,
          text: playerAction,
          createdAt: now,
        ),
      );
    }
    messages.add(
      ChatMessage(
        id: '${state.id}_${now.microsecondsSinceEpoch}_narrator',
        role: ChatRole.narrator,
        text: result.narration,
        createdAt: now,
      ),
    );

    final CampaignState nextState = state.copyWith(
      schemaVersion: 4,
      character: reconciliation.character,
      location: location,
      turnNumber: state.turnNumber + 1,
      modules: reconciliation.modules,
      inventory: reconciliation.inventory,
      companions: reconciliation.companions,
      notes: reconciliation.notes,
      resources: reconciliation.resources,
      progression: reconciliation.progression,
      checks: reconciliation.checks,
      messages: messages,
      choices: result.choices,
      memory: _memoryManager.updateMemory(
        language: language,
        previousState: state.copyWith(
          character: reconciliation.character,
          location: location,
          modules: reconciliation.modules,
          inventory: reconciliation.inventory,
          companions: reconciliation.companions,
          notes: reconciliation.notes,
          resources: reconciliation.resources,
          progression: reconciliation.progression,
          checks: reconciliation.checks,
        ),
        result: result,
        playerAction: playerAction,
        contextWindowSize: contextWindowSize,
        resolvedCheck: deterministicContext.resolvedCheck,
      ),
      updatedAt: now,
    );

    return TurnApplicationResult(
      state: nextState,
      notifications: reconciliation.notifications,
    );
  }

  CampaignState appendSystemMessage({
    required final CampaignState state,
    required final String text,
  }) {
    final DateTime now = DateTime.now();
    final List<ChatMessage> messages = List<ChatMessage>.from(state.messages)
      ..add(
        ChatMessage(
          id: '${state.id}_${now.microsecondsSinceEpoch}_system',
          role: ChatRole.system,
          text: text,
          createdAt: now,
        ),
      );

    return state.copyWith(messages: messages, updatedAt: now);
  }

  DeterministicTurnContext resolveDeterministicTurn({
    required final AppLanguage language,
    required final CampaignState state,
    required final String playerAction,
  }) => _deterministicCheckService.resolve(
    state: state,
    playerAction: playerAction,
    language: language,
  );

  static bool _isModuleActive(
    final List<CampaignModuleState> modules,
    final CampaignModule module,
  ) => modules.any((final item) => item.module == module && item.isActive);

  static String _settingTitle(
    final CampaignSetting setting,
    final AppLanguage language,
  ) =>
      switch ((setting, language)) {
        (CampaignSetting.romantasy, AppLanguage.ru) => 'Романтическое фэнтези',
        (CampaignSetting.romantasy, AppLanguage.en) => 'Romantasy',
        (CampaignSetting.cozyFantasy, AppLanguage.ru) => 'Уютное фэнтези',
        (CampaignSetting.cozyFantasy, AppLanguage.en) => 'Cozy fantasy',
        (CampaignSetting.darkAcademia, AppLanguage.ru) => 'Тёмная академия',
        (CampaignSetting.darkAcademia, AppLanguage.en) => 'Dark academia',
        (CampaignSetting.postApocalypse, AppLanguage.ru) => 'Постапокалипсис',
        (CampaignSetting.postApocalypse, AppLanguage.en) => 'Post-apocalypse',
        (CampaignSetting.litRpgProgression, AppLanguage.ru) => 'LitRPG',
        (CampaignSetting.litRpgProgression, AppLanguage.en) => 'LitRPG',
        (CampaignSetting.grimdarkFantasy, AppLanguage.ru) => 'Гримдарк',
        (CampaignSetting.grimdarkFantasy, AppLanguage.en) => 'Grimdark',
        (CampaignSetting.nearFutureSciFi, AppLanguage.ru) => 'НФ близкого будущего',
        (CampaignSetting.nearFutureSciFi, AppLanguage.en) => 'Near-future SF',
        (CampaignSetting.horrorWeird, AppLanguage.ru) => 'Хоррор',
        (CampaignSetting.horrorWeird, AppLanguage.en) => 'Horror',
        (CampaignSetting.cozyCrime, AppLanguage.ru) => 'Cozy crime',
        (CampaignSetting.cozyCrime, AppLanguage.en) => 'Cozy crime',
        (CampaignSetting.altHistorySecret, AppLanguage.ru) => 'Альт-история',
        (CampaignSetting.altHistorySecret, AppLanguage.en) => 'Alt history',
      };
}
