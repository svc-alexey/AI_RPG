enum CampaignSetting { fantasy, detective, sciFi }

enum StoryMode { shortStory, longCampaign }

enum DifficultyLevel { easy, medium, hardcore }

enum ChatRole { narrator, player, system }

Map<String, Object?> _jsonMap(final Object? value) {
  if (value is Map) {
    return value.map((key, item) => MapEntry(key.toString(), item));
  }
  return const <String, Object?>{};
}

List<Object?> _jsonList(final Object? value) =>
    value is List ? List<Object?>.from(value) : const <Object?>[];

String _jsonString(final Object? value, {final String fallback = ''}) {
  if (value == null) {
    return fallback;
  }
  if (value is String) {
    final String trimmed = value.trim();
    return trimmed.isEmpty ? fallback : value;
  }
  return value.toString();
}

class CharacterStats {
  factory CharacterStats.fromJson(final Map<String, Object?> json) =>
      CharacterStats(
        name: _jsonString(json['name'], fallback: 'Герой'),
        hp: (json['hp'] as num?)?.toInt() ?? 12,
        maxHp: (json['maxHp'] as num?)?.toInt() ?? 12,
        energy: (json['energy'] as num?)?.toInt() ?? 8,
        maxEnergy: (json['maxEnergy'] as num?)?.toInt() ?? 8,
        might: (json['might'] as num?)?.toInt() ?? 2,
        wit: (json['wit'] as num?)?.toInt() ?? 2,
        spirit: (json['spirit'] as num?)?.toInt() ?? 2,
      );

  const CharacterStats({
    required this.name,
    required this.hp,
    required this.maxHp,
    required this.energy,
    required this.maxEnergy,
    required this.might,
    required this.wit,
    required this.spirit,
  });

  final String name;
  final int hp;
  final int maxHp;
  final int energy;
  final int maxEnergy;
  final int might;
  final int wit;
  final int spirit;

  CharacterStats copyWith({
    final String? name,
    final int? hp,
    final int? maxHp,
    final int? energy,
    final int? maxEnergy,
    final int? might,
    final int? wit,
    final int? spirit,
  }) =>
      CharacterStats(
        name: name ?? this.name,
        hp: hp ?? this.hp,
        maxHp: maxHp ?? this.maxHp,
        energy: energy ?? this.energy,
        maxEnergy: maxEnergy ?? this.maxEnergy,
        might: might ?? this.might,
        wit: wit ?? this.wit,
        spirit: spirit ?? this.spirit,
      );

  Map<String, Object?> toJson() => <String, Object?>{
        'name': name,
        'hp': hp,
        'maxHp': maxHp,
        'energy': energy,
        'maxEnergy': maxEnergy,
        'might': might,
        'wit': wit,
        'spirit': spirit,
      };
}

class ChatMessage {
  factory ChatMessage.fromJson(final Map<String, Object?> json) => ChatMessage(
        id: _jsonString(json['id']),
        role: ChatRole.values.firstWhere(
          (final item) => item.name == json['role'],
          orElse: () => ChatRole.system,
        ),
        text: _jsonString(json['text']),
        createdAt:
            DateTime.tryParse(_jsonString(json['createdAt'])) ?? DateTime.now(),
      );

  const ChatMessage({
    required this.id,
    required this.role,
    required this.text,
    required this.createdAt,
  });

  final String id;
  final ChatRole role;
  final String text;
  final DateTime createdAt;

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'role': role.name,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
      };
}

class RecentTurnSummary {
  factory RecentTurnSummary.fromJson(final Map<String, Object?> json) =>
      RecentTurnSummary(
        playerAction: _jsonString(json['playerAction']),
        outcome: _jsonString(json['outcome']),
        stateHint: _jsonString(json['stateHint']),
      );

  const RecentTurnSummary({
    required this.playerAction,
    required this.outcome,
    required this.stateHint,
  });

  final String playerAction;
  final String outcome;
  final String stateHint;

  Map<String, Object?> toJson() => <String, Object?>{
        'playerAction': playerAction,
        'outcome': outcome,
        'stateHint': stateHint,
      };
}

class CampaignMemory {
  factory CampaignMemory.fromJson(final Map<String, Object?> json) =>
      CampaignMemory(
        rollingSummary: _jsonString(json['rollingSummary']),
        activeGoal: _jsonString(json['activeGoal']),
        activeSituation: _jsonString(json['activeSituation']),
        recentTurns: _jsonList(json['recentTurns'])
            .map((final item) => RecentTurnSummary.fromJson(_jsonMap(item)))
            .toList(),
      );

  const CampaignMemory({
    required this.rollingSummary,
    required this.activeGoal,
    required this.activeSituation,
    required this.recentTurns,
  });

  final String rollingSummary;
  final String activeGoal;
  final String activeSituation;
  final List<RecentTurnSummary> recentTurns;

  CampaignMemory copyWith({
    final String? rollingSummary,
    final String? activeGoal,
    final String? activeSituation,
    final List<RecentTurnSummary>? recentTurns,
  }) =>
      CampaignMemory(
        rollingSummary: rollingSummary ?? this.rollingSummary,
        activeGoal: activeGoal ?? this.activeGoal,
        activeSituation: activeSituation ?? this.activeSituation,
        recentTurns: recentTurns ?? this.recentTurns,
      );

  Map<String, Object?> toJson() => <String, Object?>{
        'rollingSummary': rollingSummary,
        'activeGoal': activeGoal,
        'activeSituation': activeSituation,
        'recentTurns': recentTurns.map((final item) => item.toJson()).toList(),
      };
}

class StateChanges {
  factory StateChanges.fromJson(final Map<String, Object?> json) => StateChanges(
        hpDelta: (json['hpDelta'] as num?)?.toInt() ?? 0,
        energyDelta: (json['energyDelta'] as num?)?.toInt() ?? 0,
        inventoryAdd: _jsonList(json['inventoryAdd'])
            .map((final item) => item.toString())
            .toList(),
        inventoryRemove: _jsonList(json['inventoryRemove'])
            .map((final item) => item.toString())
            .toList(),
        questNote: _jsonString(json['questNote']),
      );

  const StateChanges({
    required this.hpDelta,
    required this.energyDelta,
    required this.inventoryAdd,
    required this.inventoryRemove,
    required this.questNote,
  });

  const StateChanges.empty()
      : hpDelta = 0,
        energyDelta = 0,
        inventoryAdd = const <String>[],
        inventoryRemove = const <String>[],
        questNote = '';

  final int hpDelta;
  final int energyDelta;
  final List<String> inventoryAdd;
  final List<String> inventoryRemove;
  final String questNote;

  Map<String, Object?> toJson() => <String, Object?>{
        'hpDelta': hpDelta,
        'energyDelta': energyDelta,
        'inventoryAdd': inventoryAdd,
        'inventoryRemove': inventoryRemove,
        'questNote': questNote,
      };
}

class TurnResult {
  factory TurnResult.fromJson(final Map<String, Object?> json) => TurnResult(
        narration: _jsonString(
          json['narration'],
          fallback: 'Мир ненадолго замирает в тишине.',
        ),
        choices:
            _jsonList(json['choices']).map((final item) => item.toString()).toList(),
        stateChanges: StateChanges.fromJson(
          _jsonMap(json['state_changes'] ?? json['stateChanges']),
        ),
        memoryEntry: _jsonString(json['memory_entry'] ?? json['memoryEntry']),
      );

  const TurnResult({
    required this.narration,
    required this.choices,
    required this.stateChanges,
    required this.memoryEntry,
  });

  final String narration;
  final List<String> choices;
  final StateChanges stateChanges;
  final String memoryEntry;
}

class CampaignState {
  factory CampaignState.fromJson(final Map<String, Object?> json) {
    final Map<String, Object?> memoryJson = _jsonMap(json['memory']);
    final List<Object?> messagesJson = _jsonList(json['messages']);
    final CampaignMemory memory = memoryJson.isNotEmpty
        ? CampaignMemory.fromJson(memoryJson)
        : CampaignMemory(
            rollingSummary: _jsonString(json['summary']),
            activeGoal: _jsonString(
              json['objective'],
              fallback: 'Пережить первую сцену кампании.',
            ),
            activeSituation: messagesJson.isNotEmpty
                ? _jsonString(_jsonMap(messagesJson.last)['text'])
                : '',
            recentTurns: const <RecentTurnSummary>[],
          );

    return CampaignState(
      id: _jsonString(json['id']),
      schemaVersion: (json['schemaVersion'] as num?)?.toInt() ?? 1,
      title: _jsonString(json['title'], fallback: 'Кампания'),
      setting: CampaignSetting.values.firstWhere(
        (final item) => item.name == json['setting'],
        orElse: () => CampaignSetting.fantasy,
      ),
      mode: StoryMode.values.firstWhere(
        (final item) => item.name == json['mode'],
        orElse: () => StoryMode.shortStory,
      ),
      difficulty: DifficultyLevel.values.firstWhere(
        (final item) => item.name == json['difficulty'],
        orElse: () => DifficultyLevel.easy,
      ),
      character: CharacterStats.fromJson(_jsonMap(json['character'])),
      location: _jsonString(json['location'], fallback: 'Неизвестная локация'),
      objective: _jsonString(
        json['objective'],
        fallback: 'Пережить первую сцену кампании.',
      ),
      turnNumber: (json['turnNumber'] as num?)?.toInt() ?? 0,
      memory: memory,
      inventory:
          _jsonList(json['inventory']).map((final item) => item.toString()).toList(),
      questLog:
          _jsonList(json['questLog']).map((final item) => item.toString()).toList(),
      messages: messagesJson
          .map((final item) => ChatMessage.fromJson(_jsonMap(item)))
          .toList(),
      choices:
          _jsonList(json['choices']).map((final item) => item.toString()).toList(),
      updatedAt:
          DateTime.tryParse(_jsonString(json['updatedAt'])) ?? DateTime.now(),
    );
  }

  const CampaignState({
    required this.id,
    required this.schemaVersion,
    required this.title,
    required this.setting,
    required this.mode,
    required this.difficulty,
    required this.character,
    required this.location,
    required this.objective,
    required this.turnNumber,
    required this.memory,
    required this.inventory,
    required this.questLog,
    required this.messages,
    required this.choices,
    required this.updatedAt,
  });

  final String id;
  final int schemaVersion;
  final String title;
  final CampaignSetting setting;
  final StoryMode mode;
  final DifficultyLevel difficulty;
  final CharacterStats character;
  final String location;
  final String objective;
  final int turnNumber;
  final CampaignMemory memory;
  final List<String> inventory;
  final List<String> questLog;
  final List<ChatMessage> messages;
  final List<String> choices;
  final DateTime updatedAt;

  String get summary => memory.rollingSummary;
  String get activeGoal => memory.activeGoal;
  String get activeSituation => memory.activeSituation;
  List<RecentTurnSummary> get recentTurns => memory.recentTurns;

  CampaignState copyWith({
    final String? title,
    final CharacterStats? character,
    final String? location,
    final String? objective,
    final int? turnNumber,
    final CampaignMemory? memory,
    final List<String>? inventory,
    final List<String>? questLog,
    final List<ChatMessage>? messages,
    final List<String>? choices,
    final DateTime? updatedAt,
  }) =>
      CampaignState(
        id: id,
        schemaVersion: schemaVersion,
        title: title ?? this.title,
        setting: setting,
        mode: mode,
        difficulty: difficulty,
        character: character ?? this.character,
        location: location ?? this.location,
        objective: objective ?? this.objective,
        turnNumber: turnNumber ?? this.turnNumber,
        memory: memory ?? this.memory,
        inventory: inventory ?? this.inventory,
        questLog: questLog ?? this.questLog,
        messages: messages ?? this.messages,
        choices: choices ?? this.choices,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'schemaVersion': schemaVersion,
        'title': title,
        'setting': setting.name,
        'mode': mode.name,
        'difficulty': difficulty.name,
        'character': character.toJson(),
        'location': location,
        'objective': objective,
        'turnNumber': turnNumber,
        'memory': memory.toJson(),
        'summary': memory.rollingSummary,
        'inventory': inventory,
        'questLog': questLog,
        'messages': messages.map((final item) => item.toJson()).toList(),
        'choices': choices,
        'updatedAt': updatedAt.toIso8601String(),
      };
}

class CampaignDraft {
  const CampaignDraft({
    required this.setting,
    required this.mode,
    required this.difficulty,
    required this.heroName,
  });

  final CampaignSetting setting;
  final StoryMode mode;
  final DifficultyLevel difficulty;
  final String heroName;
}
