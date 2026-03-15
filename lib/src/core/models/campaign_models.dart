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

  Map<String, Object?> toJson() {
    return <String, Object?>{
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

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'role': role.name,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
    };
  }

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

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'hpDelta': hpDelta,
      'energyDelta': energyDelta,
      'inventoryAdd': inventoryAdd,
      'inventoryRemove': inventoryRemove,
      'questNote': questNote,
    };
  }

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
    required this.summary,
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
  final String summary;
  final List<String> inventory;
  final List<String> questLog;
  final List<ChatMessage> messages;
  final List<String> choices;
  final DateTime updatedAt;

  CampaignState copyWith({
    final String? title,
    final CharacterStats? character,
    final String? location,
    final String? objective,
    final int? turnNumber,
    final String? summary,
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
      summary: summary ?? this.summary,
      inventory: inventory ?? this.inventory,
      questLog: questLog ?? this.questLog,
      messages: messages ?? this.messages,
      choices: choices ?? this.choices,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
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
      'summary': summary,
      'inventory': inventory,
      'questLog': questLog,
      'messages': messages
          .map((final ChatMessage item) => item.toJson())
          .toList(),
      'choices': choices,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory CampaignState.fromJson(final Map<String, Object?> json) {
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
      summary: (json['summary'] as String?) ?? '',
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
