import 'dart:convert';

import 'package:ai_prg/src/core/data/isar/isar_collections.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';

class CampaignStorageMapper {
  const CampaignStorageMapper._();

  static CampaignRecord toCampaignRecord(final CampaignState state) {
    final CampaignRecord record = CampaignRecord()
      ..campaignId = state.id
      ..schemaVersion = state.schemaVersion
      ..title = state.title
      ..setting = state.setting.name
      ..mode = state.mode.name
      ..difficulty = state.difficulty.name
      ..location = state.location
      ..objective = state.objective
      ..turnNumber = state.turnNumber
      ..updatedAt = state.updatedAt
      ..characterJson = jsonEncode(state.character.toJson())
      ..memoryJson = jsonEncode(state.memory.toJson())
      ..inventoryJson = jsonEncode(state.inventory)
      ..questLogJson = jsonEncode(state.questLog)
      ..choicesJson = jsonEncode(state.choices)
      ..customStoryPrompt = state.customStoryPrompt
      ..characterPrompt = state.characterPrompt
      ..summary = state.summary
      ..activeGoal = state.activeGoal
      ..activeSituation = state.activeSituation;
    return record;
  }

  static WorldStateRecord toWorldStateRecord(final CampaignState state) {
    final WorldStateRecord record = WorldStateRecord()
      ..campaignId = state.id
      ..characterJson = jsonEncode(state.character.toJson())
      ..location = state.location
      ..objective = state.objective
      ..turnNumber = state.turnNumber
      ..questLogJson = jsonEncode(state.questLog)
      ..choicesJson = jsonEncode(state.choices)
      ..summary = state.summary
      ..activeGoal = state.activeGoal
      ..activeSituation = state.activeSituation
      ..memoryJson = jsonEncode(state.memory.toJson())
      ..updatedAt = state.updatedAt;
    return record;
  }

  static List<MessageRecord> toMessageRecords(final CampaignState state) {
    final List<MessageRecord> records = <MessageRecord>[];
    for (int i = 0; i < state.messages.length; i++) {
      final ChatMessage message = state.messages[i];
      records.add(
        MessageRecord()
          ..campaignId = state.id
          ..messageId = message.id
          ..role = message.role.name
          ..text = message.text
          ..createdAt = message.createdAt
          ..sortOrder = i,
      );
    }
    return records;
  }

  static List<InventoryItemRecord> toInventoryRecords(
    final CampaignState state,
  ) {
    final List<InventoryItemRecord> records = <InventoryItemRecord>[];
    for (int i = 0; i < state.inventory.length; i++) {
      final String title = state.inventory[i];
      records.add(
        InventoryItemRecord()
          ..campaignId = state.id
          ..itemId = '${state.id}::$i::$title'
          ..title = title
          ..quantity = 1
          ..sortOrder = i,
      );
    }
    return records;
  }

  static CampaignState fromRecords({
    required final CampaignRecord campaign,
    required final WorldStateRecord? worldState,
    required final List<MessageRecord> messages,
    required final List<InventoryItemRecord> inventoryItems,
  }) {
    final List<MessageRecord> sortedMessages = List<MessageRecord>.from(messages)
      ..sort((final a, final b) {
        final int orderCompare = a.sortOrder.compareTo(b.sortOrder);
        if (orderCompare != 0) {
          return orderCompare;
        }
        return a.createdAt.compareTo(b.createdAt);
      });
    final List<InventoryItemRecord> sortedInventory =
        List<InventoryItemRecord>.from(inventoryItems)
          ..sort((final a, final b) => a.sortOrder.compareTo(b.sortOrder));

    final CharacterStats character = worldState != null
        ? CharacterStats.fromJson(_jsonMap(worldState.characterJson))
        : CharacterStats.fromJson(_jsonMap(campaign.characterJson));
    final CampaignMemory memory = worldState != null
        ? CampaignMemory.fromJson(_jsonMap(worldState.memoryJson))
        : CampaignMemory.fromJson(_jsonMap(campaign.memoryJson));
    final String location =
        worldState?.location.isNotEmpty == true ? worldState!.location : campaign.location;
    final String objective = worldState?.objective.isNotEmpty == true
        ? worldState!.objective
        : campaign.objective;
    final int turnNumber = worldState?.turnNumber ?? campaign.turnNumber;
    final List<String> inventory = sortedInventory.isNotEmpty
        ? sortedInventory
            .expand(
              (final item) => List<String>.filled(item.quantity, item.title),
            )
            .toList()
        : _jsonList(campaign.inventoryJson)
            .map((final item) => item.toString())
            .toList();
    final List<String> questLog = worldState != null
        ? _jsonList(worldState.questLogJson)
            .map((final item) => item.toString())
            .toList()
        : _jsonList(campaign.questLogJson)
            .map((final item) => item.toString())
            .toList();
    final List<String> choices = worldState != null
        ? _jsonList(worldState.choicesJson)
            .map((final item) => item.toString())
            .toList()
        : _jsonList(campaign.choicesJson)
            .map((final item) => item.toString())
            .toList();
    final DateTime updatedAt = worldState?.updatedAt ?? campaign.updatedAt;

    return CampaignState(
      id: campaign.campaignId,
      schemaVersion: campaign.schemaVersion,
      title: campaign.title,
      setting: CampaignSetting.values.firstWhere(
        (final item) => item.name == campaign.setting,
        orElse: () => CampaignSetting.fantasy,
      ),
      mode: StoryMode.values.firstWhere(
        (final item) => item.name == campaign.mode,
        orElse: () => StoryMode.shortStory,
      ),
      difficulty: DifficultyLevel.values.firstWhere(
        (final item) => item.name == campaign.difficulty,
        orElse: () => DifficultyLevel.easy,
      ),
      character: character,
      location: location,
      objective: objective,
      turnNumber: turnNumber,
      memory: memory,
      inventory: inventory,
      questLog: questLog,
      messages: sortedMessages
          .map(
            (final message) => ChatMessage(
              id: message.messageId,
              role: ChatRole.values.firstWhere(
                (final item) => item.name == message.role,
                orElse: () => ChatRole.system,
              ),
              text: message.text,
              createdAt: message.createdAt,
            ),
          )
          .toList(),
      choices: choices,
      updatedAt: updatedAt,
      customStoryPrompt: campaign.customStoryPrompt,
      characterPrompt: campaign.characterPrompt,
    );
  }

  static Map<String, Object?> _jsonMap(final String raw) {
    if (raw.trim().isEmpty) {
      return const <String, Object?>{};
    }
    final Object? decoded = jsonDecode(raw);
    if (decoded is Map) {
      return decoded.map(
        (final key, final value) => MapEntry(key.toString(), value),
      );
    }
    return const <String, Object?>{};
  }

  static List<Object?> _jsonList(final String raw) {
    if (raw.trim().isEmpty) {
      return const <Object?>[];
    }
    final Object? decoded = jsonDecode(raw);
    return decoded is List ? List<Object?>.from(decoded) : const <Object?>[];
  }
}
