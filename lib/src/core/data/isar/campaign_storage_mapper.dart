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
      ..literaryGenre = state.literaryGenre?.name
      ..mode = state.mode.name
      ..difficulty = state.difficulty.name
      ..location = state.location
      ..objective = state.objective
      ..turnNumber = state.turnNumber
      ..updatedAt = state.updatedAt
      ..characterJson = jsonEncode(state.character.toJson())
      ..memoryJson = jsonEncode(state.memory.toJson())
      ..modulesJson = jsonEncode(
        state.modules.map((final item) => item.toJson()).toList(),
      )
      ..inventoryJson = jsonEncode(state.inventory)
      ..questLogJson = jsonEncode(state.notes)
      ..choicesJson = jsonEncode(state.choices)
      ..customStoryPrompt = state.customStoryPrompt
      ..characterPrompt = state.characterPrompt
      ..portraitPath = state.portraitPath
      ..portraitPrompt = state.portraitPrompt
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
      ..notesJson = jsonEncode(state.notes)
      ..resourcesJson = jsonEncode(
        state.resources.map((final item) => item.toJson()).toList(),
      )
      ..progressionJson = jsonEncode(state.progression?.toJson())
      ..checksJson = jsonEncode(
        state.checks.map((final item) => item.toJson()).toList(),
      )
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

  static List<CompanionRecord> toCompanionRecords(final CampaignState state) {
    final List<CompanionRecord> records = <CompanionRecord>[];
    for (int i = 0; i < state.companions.length; i++) {
      final CampaignCompanion companion = state.companions[i];
      records.add(
        CompanionRecord()
          ..campaignId = state.id
          ..companionId = companion.id
          ..name = companion.name
          ..status = companion.status
          ..notes = companion.notes
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
    required final List<CompanionRecord> companions,
  }) {
    final List<MessageRecord> sortedMessages =
        List<MessageRecord>.from(messages)..sort((final a, final b) {
          final int orderCompare = a.sortOrder.compareTo(b.sortOrder);
          if (orderCompare != 0) {
            return orderCompare;
          }
          return a.createdAt.compareTo(b.createdAt);
        });
    final List<InventoryItemRecord> sortedInventory =
        List<InventoryItemRecord>.from(inventoryItems)
          ..sort((final a, final b) => a.sortOrder.compareTo(b.sortOrder));
    final List<CompanionRecord> sortedCompanions = List<CompanionRecord>.from(
      companions,
    )..sort((final a, final b) => a.sortOrder.compareTo(b.sortOrder));

    final CharacterStats character = worldState != null
        ? CharacterStats.fromJson(_jsonMap(worldState.characterJson))
        : CharacterStats.fromJson(_jsonMap(campaign.characterJson));
    final CampaignMemory memory = worldState != null
        ? CampaignMemory.fromJson(_jsonMap(worldState.memoryJson))
        : CampaignMemory.fromJson(_jsonMap(campaign.memoryJson));
    final String location = worldState?.location.isNotEmpty == true
        ? worldState!.location
        : campaign.location;
    final String objective = worldState?.objective.isNotEmpty == true
        ? worldState!.objective
        : campaign.objective;
    final int turnNumber = worldState?.turnNumber ?? campaign.turnNumber;
    final List<CampaignModuleState> storedModules =
        _jsonList(campaign.modulesJson)
            .map(
              (final item) =>
                  CampaignModuleState.fromJson(_jsonMapObject(item)),
            )
            .toList();
    final List<String> inventory = sortedInventory.isNotEmpty
        ? sortedInventory
              .expand(
                (final item) => List<String>.filled(item.quantity, item.title),
              )
              .toList()
        : _jsonList(
            campaign.inventoryJson,
          ).map((final item) => item.toString()).toList();
    final List<String> questLog = worldState != null
        ? _jsonList(
            worldState.questLogJson,
          ).map((final item) => item.toString()).toList()
        : _jsonList(
            campaign.questLogJson,
          ).map((final item) => item.toString()).toList();
    final List<String> notes =
        worldState != null && worldState.notesJson.trim().isNotEmpty
        ? _jsonList(
            worldState.notesJson,
          ).map((final item) => item.toString()).toList()
        : questLog;
    final List<String> choices = worldState != null
        ? _jsonList(
            worldState.choicesJson,
          ).map((final item) => item.toString()).toList()
        : _jsonList(
            campaign.choicesJson,
          ).map((final item) => item.toString()).toList();
    final List<CampaignResource> resources =
        worldState != null && worldState.resourcesJson.trim().isNotEmpty
        ? _jsonList(worldState.resourcesJson)
              .map(
                (final item) => CampaignResource.fromJson(_jsonMapObject(item)),
              )
              .toList()
        : const <CampaignResource>[];
    final CampaignProgression? progression =
        worldState != null && worldState.progressionJson.trim().isNotEmpty
        ? _progressionFromRaw(worldState.progressionJson)
        : null;
    final List<CampaignCheck> checks =
        worldState != null && worldState.checksJson.trim().isNotEmpty
        ? _jsonList(worldState.checksJson)
              .map((final item) => CampaignCheck.fromJson(_jsonMapObject(item)))
              .toList()
        : const <CampaignCheck>[];
    final List<CampaignModuleState> modules = storedModules.isNotEmpty
        ? storedModules
        : CampaignState.inferLegacyModules(
            inventory: inventory,
            notes: notes,
            character: character,
            companions: sortedCompanions
                .map(
                  (final companion) => CampaignCompanion(
                    id: companion.companionId,
                    name: companion.name,
                    status: companion.status,
                    notes: companion.notes ?? '',
                  ),
                )
                .toList(),
            resources: resources,
            progression: progression,
            checks: checks,
          );
    final DateTime updatedAt = worldState?.updatedAt ?? campaign.updatedAt;

    return CampaignState(
      id: campaign.campaignId,
      schemaVersion: campaign.schemaVersion,
      title: campaign.title,
      setting: parseCampaignSetting(campaign.setting),
      literaryGenre: parseLiteraryGenre(campaign.literaryGenre),
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
      modules: modules,
      inventory: inventory,
      companions: sortedCompanions
          .map(
            (final companion) => CampaignCompanion(
              id: companion.companionId,
              name: companion.name,
              status: companion.status,
              notes: companion.notes ?? '',
            ),
          )
          .toList(),
      notes: notes,
      resources: resources,
      progression: progression,
      checks: checks,
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
      portraitPath: campaign.portraitPath,
      portraitPrompt: campaign.portraitPrompt,
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

  static Map<String, Object?> _jsonMapObject(final Object? value) {
    if (value is Map) {
      return value.map(
        (final key, final item) => MapEntry(key.toString(), item),
      );
    }
    return const <String, Object?>{};
  }

  static CampaignProgression? _progressionFromRaw(final String raw) {
    final Map<String, Object?> map = _jsonMap(raw);
    if (map.isEmpty) {
      return null;
    }
    return CampaignProgression.fromJson(map);
  }
}
