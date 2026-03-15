import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:ai_prg/src/core/services/campaign_memory_manager.dart';

class GameEngine {
  const GameEngine();

  static const CampaignMemoryManager _memoryManager = CampaignMemoryManager();

  CampaignState createCampaign({
    required final CampaignDraft draft,
    required final AppLanguage language,
  }) {
    final DateTime now = DateTime.now();
    final String id = now.microsecondsSinceEpoch.toString();
    final CharacterStats character = CharacterStats(
      name: draft.heroName.trim().isEmpty
          ? switch (language) {
              AppLanguage.ru => 'Странник',
              AppLanguage.en => 'Wayfarer',
            }
          : draft.heroName.trim(),
      hp: 12,
      maxHp: 12,
      energy: 8,
      maxEnergy: 8,
      might: draft.difficulty == DifficultyLevel.hardcore ? 2 : 3,
      wit: 3,
      spirit: draft.mode == StoryMode.longCampaign ? 3 : 2,
    );

    final String location = switch (draft.setting) {
      CampaignSetting.fantasy => switch (language) {
        AppLanguage.ru => 'Пепельные врата',
        AppLanguage.en => 'Ashen Gate',
      },
      CampaignSetting.detective => switch (language) {
        AppLanguage.ru => 'Ночной квартал',
        AppLanguage.en => 'Night Quarter',
      },
      CampaignSetting.sciFi => switch (language) {
        AppLanguage.ru => 'Кольцо Орфея',
        AppLanguage.en => 'Orpheus Ring',
      },
    };

    final String objective = switch (draft.setting) {
      CampaignSetting.fantasy => switch (language) {
        AppLanguage.ru =>
          'Понять, почему древние врата снова пробудились.',
        AppLanguage.en =>
          'Understand why the ancient gate has awakened again.',
      },
      CampaignSetting.detective => switch (language) {
        AppLanguage.ru => 'Найти первую зацепку до рассвета.',
        AppLanguage.en => 'Find the first lead before dawn.',
      },
      CampaignSetting.sciFi => switch (language) {
        AppLanguage.ru =>
          'Стабилизировать станцию до следующего всплеска.',
        AppLanguage.en =>
          'Stabilize the station before the next surge.',
      },
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
        '${character.name} прибывает в локацию "$location". Воздух напряжен, цель уже определена, и следующий выбор задаст тон всей кампании.',
      AppLanguage.en =>
        '${character.name} arrives at "$location". The air is tense, the objective is already set, and the next choice will define the tone of the whole campaign.',
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
      inventory: switch (language) {
        AppLanguage.ru => const <String>['Полевые записи', 'Дорожный набор'],
        AppLanguage.en => const <String>['Field Notes', 'Travel Kit'],
      },
      questLog: <String>[objective],
      messages: <ChatMessage>[intro],
      choices: switch (language) {
        AppLanguage.ru => const <String>[
            'Осмотреться вокруг',
            'Двинуться к цели',
            'Попросить больше деталей',
          ],
        AppLanguage.en => const <String>[
            'Look around',
            'Move toward the objective',
            'Ask for more detail',
          ],
      },
      updatedAt: now,
    );
  }

  CampaignState applyTurn({
    required final AppLanguage language,
    required final CampaignState state,
    required final String playerAction,
    required final TurnResult result,
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
        (final String item) =>
            result.stateChanges.inventoryRemove.contains(item),
      );

    final List<String> questLog = List<String>.from(state.questLog);
    if (result.stateChanges.questNote.trim().isNotEmpty) {
      questLog.add(result.stateChanges.questNote.trim());
    }

    final List<ChatMessage> messages = List<ChatMessage>.from(state.messages)
      ..add(
        ChatMessage(
          id: '${state.id}_${now.microsecondsSinceEpoch}_player',
          role: ChatRole.player,
          text: playerAction,
          createdAt: now,
        ),
      )
      ..add(
        ChatMessage(
          id: '${state.id}_${now.microsecondsSinceEpoch}_narrator',
          role: ChatRole.narrator,
          text: result.narration,
          createdAt: now,
        ),
      );

    return state.copyWith(
      character: character,
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
