import 'package:ai_prg/src/core/models/campaign_models.dart';

class GameEngine {
  const GameEngine();

  CampaignState createCampaign(final CampaignDraft draft) {
    final DateTime now = DateTime.now();
    final String id = now.microsecondsSinceEpoch.toString();
    final CharacterStats character = CharacterStats(
      name: draft.heroName.trim().isEmpty ? 'Странник' : draft.heroName.trim(),
      hp: 12,
      maxHp: 12,
      energy: 8,
      maxEnergy: 8,
      might: draft.difficulty == DifficultyLevel.hardcore ? 2 : 3,
      wit: 3,
      spirit: draft.mode == StoryMode.longCampaign ? 3 : 2,
    );

    final String location = switch (draft.setting) {
      CampaignSetting.fantasy => 'Пепельные врата',
      CampaignSetting.detective => 'Ночной квартал',
      CampaignSetting.sciFi => 'Кольцо Орфея',
    };

    final String objective = switch (draft.setting) {
      CampaignSetting.fantasy =>
        'Понять, почему древние врата снова пробудились.',
      CampaignSetting.detective => 'Найти первую зацепку до рассвета.',
      CampaignSetting.sciFi =>
        'Стабилизировать станцию до следующего всплеска.',
    };

    final String settingLabel = switch (draft.setting) {
      CampaignSetting.fantasy => 'Фэнтези',
      CampaignSetting.detective => 'Детектив',
      CampaignSetting.sciFi => 'Sci-fi',
    };

    final ChatMessage intro = ChatMessage(
      id: '${id}_intro',
      role: ChatRole.narrator,
      text:
          '${character.name} прибывает в локацию "$location". Воздух напряжен, цель уже определена, и следующий выбор задаст тон всей кампании.',
      createdAt: now,
    );

    return CampaignState(
      id: id,
      schemaVersion: 1,
      title: '${character.name} — $settingLabel',
      setting: draft.setting,
      mode: draft.mode,
      difficulty: draft.difficulty,
      character: character,
      location: location,
      objective: objective,
      turnNumber: 0,
      summary: 'Кампания только началась.',
      inventory: const <String>['Полевые записи', 'Дорожный набор'],
      questLog: <String>[objective],
      messages: <ChatMessage>[intro],
      choices: const <String>[
        'Осмотреться вокруг',
        'Двинуться к цели',
        'Попросить больше деталей',
      ],
      updatedAt: now,
    );
  }

  CampaignState applyTurn({
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

    final String summary = result.memoryEntry.trim().isEmpty
        ? state.summary
        : result.memoryEntry.trim();

    return state.copyWith(
      character: character,
      turnNumber: state.turnNumber + 1,
      inventory: inventory,
      questLog: questLog,
      messages: messages,
      choices: result.choices,
      summary: summary,
      updatedAt: now,
    );
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
