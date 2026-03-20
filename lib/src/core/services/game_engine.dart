import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:ai_prg/src/core/services/campaign_memory_manager.dart';
import 'package:ai_prg/src/core/services/character_prompt_builder.dart';

class GameEngine {
  const GameEngine();

  static const CampaignMemoryManager _memoryManager = CampaignMemoryManager();
  static const CharacterPromptBuilder _charBuilder = CharacterPromptBuilder();

  CampaignState createCampaign({
    required final CampaignDraft draft,
    required final AppLanguage language,
  }) {
    final DateTime now = DateTime.now();
    final String id = now.microsecondsSinceEpoch.toString();

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
    final List<String> inventory = draft.characterProfile != null
        ? <String>[...baseInventory, ...draft.characterProfile!.perks]
        : baseInventory;

    // Стартовая локация будет определена ИИ на основе промпта
    final String location = switch (language) {
      AppLanguage.ru => '...',
      AppLanguage.en => '...',
    };

    // Цель будет определена ИИ на основе промпта
    final String objective = switch (language) {
      AppLanguage.ru => 'Выжить и найти свой путь',
      AppLanguage.en => 'Survive and find your path',
    };

    final String settingLabel = switch (draft.setting) {
      CampaignSetting.fantasy => switch (language) {
        AppLanguage.ru => 'Фэнтези',
        AppLanguage.en => 'Fantasy',
      },
      CampaignSetting.detective => switch (language) {
        AppLanguage.ru => 'Детектив',
        AppLanguage.en => 'Detective',
      },
      CampaignSetting.sciFi => 'Sci-fi',
    };

    final String introText = switch (language) {
      AppLanguage.ru =>
        '${character.name} начинает свой путь. Следующий шаг определит судьбу.',
      AppLanguage.en =>
        '${character.name} begins their journey. The next step will determine their fate.',
    };

    final ChatMessage intro = ChatMessage(
      id: '${id}_intro',
      role: ChatRole.narrator,
      text: introText,
      createdAt: now,
    );

    return CampaignState(
      id: id,
      schemaVersion: 1,
      title: '${character.name} - $settingLabel',
      setting: draft.setting,
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
      inventory: inventory,
      questLog: <String>[objective],
      messages: const <ChatMessage>[],
      choices: const <String>[],
      updatedAt: now,
      customStoryPrompt: draft.customStoryPrompt,
      characterPrompt: characterPrompt,
    );
  }

  CampaignState applyTurn({
    required final AppLanguage language,
    required final CampaignState state,
    required final String playerAction,
    required final TurnResult result,
    required final int contextWindowSize,
  }) {
    final DateTime now = DateTime.now();
    final CharacterStats character = state.character.copyWith(
      hp: _clamp(
        value: state.character.hp + result.stateChanges.hpDelta,
        min: 0,
        max: state.character.maxHp,
      ),
      energy: _clamp(
        value: state.character.energy + result.stateChanges.energyDelta,
        min: 0,
        max: state.character.maxEnergy,
      ),
    );

    final List<String> inventory = List<String>.from(state.inventory)
      ..addAll(result.stateChanges.inventoryAdd)
      ..removeWhere(
        (final item) => result.stateChanges.inventoryRemove.contains(item),
      );

    final List<String> questLog = List<String>.from(state.questLog);
    if (result.stateChanges.questNote.trim().isNotEmpty) {
      questLog.add(result.stateChanges.questNote.trim());
    }

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

    return state.copyWith(
      character: character,
      location: location,
      turnNumber: state.turnNumber + 1,
      inventory: inventory,
      questLog: questLog,
      messages: messages,
      choices: result.choices,
      memory: _memoryManager.updateMemory(
        language: language,
        previousState: state,
        result: result,
        playerAction: playerAction,
        contextWindowSize: contextWindowSize,
      ),
      updatedAt: now,
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

  static String _truncateForObjective(final String text, final int maxLength) {
    final String normalized = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.length <= maxLength) {
      return normalized;
    }
    final int cut = normalized.lastIndexOf(RegExp(r'[.!?]\s'), maxLength);
    if (cut > maxLength ~/ 2) {
      return normalized.substring(0, cut + 1).trim();
    }
    final int space = normalized.lastIndexOf(' ', maxLength);
    if (space > maxLength ~/ 2) {
      return '${normalized.substring(0, space).trim()}...';
    }
    return '${normalized.substring(0, maxLength - 3).trim()}...';
  }

  int _clamp({
    required final int value,
    required final int min,
    required final int max,
  }) {
    if (value < min) {
      return min;
    }
    if (value > max) {
      return max;
    }
    return value;
  }
}
