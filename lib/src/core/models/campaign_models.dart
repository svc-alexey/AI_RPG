enum CampaignSetting { fantasy, detective, sciFi }

enum StoryMode { shortStory, longCampaign }

enum DifficultyLevel { easy, medium, hardcore }

enum ChatRole { narrator, player, system }

class CharacterStats {
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
  }) {
    return CharacterStats(
      name: name ?? this.name,
      hp: hp ?? this.hp,
      maxHp: maxHp ?? this.maxHp,
      energy: energy ?? this.energy,
      maxEnergy: maxEnergy ?? this.maxEnergy,
      might: might ?? this.might,
      wit: wit ?? this.wit,
      spirit: spirit ?? this.spirit,
    );
  }

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

  factory CharacterStats.fromJson(final Map<String, Object?> json) {
    return CharacterStats(
      name: (json['name'] as String?) ?? 'Герой',
      hp: (json['hp'] as int?) ?? 12,
      maxHp: (json['maxHp'] as int?) ?? 12,
      energy: (json['energy'] as int?) ?? 8,
      maxEnergy: (json['maxEnergy'] as int?) ?? 8,
      might: (json['might'] as int?) ?? 2,
      wit: (json['wit'] as int?) ?? 2,
      spirit: (json['spirit'] as int?) ?? 2,
    );
  }
}

class ChatMessage {
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

  factory ChatMessage.fromJson(final Map<String, Object?> json) {
    return ChatMessage(
      id: (json['id'] as String?) ?? '',
      role: ChatRole.values.firstWhere(
        (final ChatRole item) => item.name == json['role'],
        orElse: () => ChatRole.system,
      ),
      text: (json['text'] as String?) ?? '',
      createdAt:
          DateTime.tryParse((json['createdAt'] as String?) ?? '') ??
          DateTime.now(),
    );
  }
}

class RecentTurnSummary {
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

  factory RecentTurnSummary.fromJson(final Map<String, Object?> json) {
    return RecentTurnSummary(
      playerAction: (json['playerAction'] as String?) ?? '',
      outcome: (json['outcome'] as String?) ?? '',
      stateHint: (json['stateHint'] as String?) ?? '',
    );
  }
}

class CampaignMemory {
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
  }) {
    return CampaignMemory(
      rollingSummary: rollingSummary ?? this.rollingSummary,
      activeGoal: activeGoal ?? this.activeGoal,
      activeSituation: activeSituation ?? this.activeSituation,
      recentTurns: recentTurns ?? this.recentTurns,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'rollingSummary': rollingSummary,
    'activeGoal': activeGoal,
    'activeSituation': activeSituation,
    'recentTurns': recentTurns
        .map((final RecentTurnSummary item) => item.toJson())
        .toList(),
  };

  factory CampaignMemory.fromJson(final Map<String, Object?> json) {
    return CampaignMemory(
      rollingSummary: (json['rollingSummary'] as String?) ?? '',
      activeGoal: (json['activeGoal'] as String?) ?? '',
      activeSituation: (json['activeSituation'] as String?) ?? '',
      recentTurns: ((json['recentTurns'] as List<Object?>?) ?? const <Object?>[])
          .map(
            (final Object? item) =>
                RecentTurnSummary.fromJson(item! as Map<String, Object?>),
          )
          .toList(),
    );
  }
}

class StateChanges {
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

  factory StateChanges.fromJson(final Map<String, Object?> json) {
    return StateChanges(
      hpDelta: (json['hpDelta'] as num?)?.toInt() ?? 0,
      energyDelta: (json['energyDelta'] as num?)?.toInt() ?? 0,
      inventoryAdd:
          ((json['inventoryAdd'] as List<Object?>?) ?? const <Object?>[])
              .map((final Object? item) => item.toString())
              .toList(),
      inventoryRemove:
          ((json['inventoryRemove'] as List<Object?>?) ?? const <Object?>[])
              .map((final Object? item) => item.toString())
              .toList(),
      questNote: (json['questNote'] as String?) ?? '',
    );
  }
}

class TurnResult {
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

  factory TurnResult.fromJson(final Map<String, Object?> json) {
    return TurnResult(
      narration:
          (json['narration'] as String?) ?? 'Мир ненадолго замирает в тишине.',
      choices: ((json['choices'] as List<Object?>?) ?? const <Object?>[])
          .map((final Object? item) => item.toString())
          .toList(),
      stateChanges: StateChanges.fromJson(
        (json['state_changes'] as Map<String, Object?>?) ??
            (json['stateChanges'] as Map<String, Object?>?) ??
            const <String, Object?>{},
      ),
      memoryEntry:
          (json['memory_entry'] as String?) ??
          (json['memoryEntry'] as String?) ??
          '',
    );
  }
}

class CampaignState {
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
  }) {
    return CampaignState(
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
  }

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
    'messages': messages.map((final ChatMessage item) => item.toJson()).toList(),
    'choices': choices,
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory CampaignState.fromJson(final Map<String, Object?> json) {
    final CampaignMemory memory =
        (json['memory'] as Map<String, Object?>?) != null
        ? CampaignMemory.fromJson(json['memory']! as Map<String, Object?>)
        : CampaignMemory(
            rollingSummary: (json['summary'] as String?) ?? '',
            activeGoal:
                (json['objective'] as String?) ?? 'Пережить первую сцену кампании.',
            activeSituation: ((json['messages'] as List<Object?>?) ?? const <Object?>[])
                    .isNotEmpty
                ? (((json['messages'] as List<Object?>).last
                            as Map<String, Object?>)['text']
                        as String?) ??
                    ''
                : '',
            recentTurns: const <RecentTurnSummary>[],
          );

    return CampaignState(
      id: (json['id'] as String?) ?? '',
      schemaVersion: (json['schemaVersion'] as int?) ?? 1,
      title: (json['title'] as String?) ?? 'Кампания',
      setting: CampaignSetting.values.firstWhere(
        (final CampaignSetting item) => item.name == json['setting'],
        orElse: () => CampaignSetting.fantasy,
      ),
      mode: StoryMode.values.firstWhere(
        (final StoryMode item) => item.name == json['mode'],
        orElse: () => StoryMode.shortStory,
      ),
      difficulty: DifficultyLevel.values.firstWhere(
        (final DifficultyLevel item) => item.name == json['difficulty'],
        orElse: () => DifficultyLevel.easy,
      ),
      character: CharacterStats.fromJson(
        (json['character'] as Map<String, Object?>?) ??
            const <String, Object?>{},
      ),
      location: (json['location'] as String?) ?? 'Неизвестная локация',
      objective:
          (json['objective'] as String?) ?? 'Пережить первую сцену кампании.',
      turnNumber: (json['turnNumber'] as int?) ?? 0,
      memory: memory,
      inventory: ((json['inventory'] as List<Object?>?) ?? const <Object?>[])
          .map((final Object? item) => item.toString())
          .toList(),
      questLog: ((json['questLog'] as List<Object?>?) ?? const <Object?>[])
          .map((final Object? item) => item.toString())
          .toList(),
      messages: ((json['messages'] as List<Object?>?) ?? const <Object?>[])
          .map(
            (final Object? item) =>
                ChatMessage.fromJson(item! as Map<String, Object?>),
          )
          .toList(),
      choices: ((json['choices'] as List<Object?>?) ?? const <Object?>[])
          .map((final Object? item) => item.toString())
          .toList(),
      updatedAt:
          DateTime.tryParse((json['updatedAt'] as String?) ?? '') ??
          DateTime.now(),
    );
  }
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
