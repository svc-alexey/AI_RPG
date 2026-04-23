/// World-frame presets for narrative (soft anchors; genre mixing allowed).
enum CampaignSetting {
  romantasy,
  cozyFantasy,
  darkAcademia,
  postApocalypse,
  litRpgProgression,
  grimdarkFantasy,
  nearFutureSciFi,
  horrorWeird,
  cozyCrime,
  altHistorySecret,
}

/// Literary genre emphasis (one pick in wizard; optional on saved campaigns).
enum LiteraryGenre {
  romance,
  romantasyGenre,
  fantasyGenre,
  psychologicalThriller,
  mysteryCrime,
  horrorGenre,
  youngAdult,
  speculativeFiction,
  darkAcademiaGenre,
  cozyFeelGood,
}

CampaignSetting parseCampaignSetting(final String? raw) {
  final String name = raw?.trim() ?? '';
  for (final CampaignSetting item in CampaignSetting.values) {
    if (item.name == name) {
      return item;
    }
  }
  return switch (name) {
    'fantasy' => CampaignSetting.romantasy,
    'detective' => CampaignSetting.cozyCrime,
    'sciFi' => CampaignSetting.nearFutureSciFi,
    _ => CampaignSetting.romantasy,
  };
}

LiteraryGenre? parseLiteraryGenre(final String? raw) {
  final String name = raw?.trim() ?? '';
  if (name.isEmpty) {
    return null;
  }
  for (final LiteraryGenre item in LiteraryGenre.values) {
    if (item.name == name) {
      return item;
    }
  }
  return null;
}

enum StoryMode { shortStory, longCampaign }

enum DifficultyLevel { easy, medium, hardcore }

enum ChatRole { narrator, player, system }

enum CharacterGender { male, female, other }

enum CampaignModule {
  inventory,
  companions,
  notes,
  vitality,
  resources,
  progression,
  checks,
}

/// Character classes per setting: fantasy (warrior, mage, rogue),
/// detective (detective, journalist, smuggler), sciFi (engineer, pilot, medic).
enum CharacterClass {
  warrior,
  mage,
  rogue,
  detective,
  journalist,
  smuggler,
  engineer,
  pilot,
  medic,

  /// No game class for this world (romance, cozy, etc.); not shown in wizard.
  unspecified,
}

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

int _jsonInt(final Object? value, {final int fallback = 0}) =>
    (value as num?)?.toInt() ?? fallback;

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
  }) => CharacterStats(
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

class CampaignModuleState {
  factory CampaignModuleState.fromJson(final Map<String, Object?> json) =>
      CampaignModuleState(
        module: CampaignModule.values.firstWhere(
          (final item) => item.name == json['module'],
          orElse: () => CampaignModule.notes,
        ),
        isActive: json['isActive'] as bool? ?? true,
        activationReason: _jsonString(json['activationReason']),
        activatedAt: DateTime.tryParse(_jsonString(json['activatedAt'])),
      );

  const CampaignModuleState({
    required this.module,
    required this.isActive,
    required this.activationReason,
    this.activatedAt,
  });

  final CampaignModule module;
  final bool isActive;
  final String activationReason;
  final DateTime? activatedAt;

  CampaignModuleState copyWith({
    final CampaignModule? module,
    final bool? isActive,
    final String? activationReason,
    final DateTime? activatedAt,
  }) => CampaignModuleState(
    module: module ?? this.module,
    isActive: isActive ?? this.isActive,
    activationReason: activationReason ?? this.activationReason,
    activatedAt: activatedAt ?? this.activatedAt,
  );

  Map<String, Object?> toJson() => <String, Object?>{
    'module': module.name,
    'isActive': isActive,
    'activationReason': activationReason,
    'activatedAt': activatedAt?.toIso8601String(),
  };
}

class CampaignCompanion {
  factory CampaignCompanion.fromJson(final Map<String, Object?> json) =>
      CampaignCompanion(
        id: _jsonString(json['id']),
        name: _jsonString(json['name']),
        status: _jsonString(json['status']),
        notes: _jsonString(json['notes']),
      );

  const CampaignCompanion({
    required this.id,
    required this.name,
    required this.status,
    this.notes = '',
  });

  final String id;
  final String name;
  final String status;
  final String notes;

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'name': name,
    'status': status,
    'notes': notes,
  };
}

class CampaignResource {
  factory CampaignResource.fromJson(final Map<String, Object?> json) =>
      CampaignResource(
        id: _jsonString(json['id']),
        label: _jsonString(json['label']),
        value: _jsonInt(json['value']),
        maxValue: (json['maxValue'] as num?)?.toInt(),
      );

  const CampaignResource({
    required this.id,
    required this.label,
    required this.value,
    this.maxValue,
  });

  final String id;
  final String label;
  final int value;
  final int? maxValue;

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'label': label,
    'value': value,
    'maxValue': maxValue,
  };
}

class CampaignProgression {
  factory CampaignProgression.fromJson(final Map<String, Object?> json) =>
      CampaignProgression(
        level: _jsonInt(json['level'], fallback: 1),
        experience: _jsonInt(json['experience']),
        rank: _jsonString(json['rank']),
      );

  const CampaignProgression({
    required this.level,
    required this.experience,
    required this.rank,
  });

  final int level;
  final int experience;
  final String rank;

  Map<String, Object?> toJson() => <String, Object?>{
    'level': level,
    'experience': experience,
    'rank': rank,
  };
}

enum CampaignCheckOutcome { success, failure, mixed, unknown }

class CampaignCheck {
  factory CampaignCheck.fromJson(final Map<String, Object?> json) =>
      CampaignCheck(
        id: _jsonString(json['id']),
        label: _jsonString(json['label']),
        summary: _jsonString(json['summary']),
        outcome: CampaignCheckOutcome.values.firstWhere(
          (final item) => item.name == json['outcome'],
          orElse: () => CampaignCheckOutcome.unknown,
        ),
        stat: _jsonString(json['stat']),
        difficulty: (json['difficulty'] as num?)?.toInt(),
        roll: (json['roll'] as num?)?.toInt(),
        total: (json['total'] as num?)?.toInt(),
      );

  const CampaignCheck({
    required this.id,
    required this.label,
    required this.summary,
    required this.outcome,
    this.stat = '',
    this.difficulty,
    this.roll,
    this.total,
  });

  final String id;
  final String label;
  final String summary;
  final CampaignCheckOutcome outcome;
  final String stat;
  final int? difficulty;
  final int? roll;
  final int? total;

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'label': label,
    'summary': summary,
    'outcome': outcome.name,
    'stat': stat,
    'difficulty': difficulty,
    'roll': roll,
    'total': total,
  };
}

class CharacterProfile {
  factory CharacterProfile.fromJson(final Map<String, Object?> json) =>
      CharacterProfile(
        name: _jsonString(json['name'], fallback: 'Герой'),
        gender: CharacterGender.values.firstWhere(
          (final item) => item.name == json['gender'],
          orElse: () => CharacterGender.other,
        ),
        race: _jsonString(json['race']),
        characterClass: CharacterClass.values.firstWhere(
          (final item) =>
              item.name == (json['characterClass'] ?? json['character_class']),
          orElse: () => CharacterClass.unspecified,
        ),
        skills: _jsonList(
          json['skills'],
        ).map((final item) => item.toString()).toList(),
        personality: _jsonString(json['personality']),
        perks: _jsonList(
          json['perks'],
        ).map((final item) => item.toString()).toList(),
        promptFragment: _jsonString(
          json['promptFragment'] ?? json['prompt_fragment'],
        ),
      );

  const CharacterProfile({
    required this.name,
    required this.gender,
    required this.race,
    required this.characterClass,
    required this.skills,
    required this.personality,
    required this.perks,
    required this.promptFragment,
  });

  final String name;
  final CharacterGender gender;
  final String race;
  final CharacterClass characterClass;
  final List<String> skills;
  final String personality;
  final List<String> perks;
  final String promptFragment;

  CharacterProfile copyWith({
    final String? name,
    final CharacterGender? gender,
    final String? race,
    final CharacterClass? characterClass,
    final List<String>? skills,
    final String? personality,
    final List<String>? perks,
    final String? promptFragment,
  }) => CharacterProfile(
    name: name ?? this.name,
    gender: gender ?? this.gender,
    race: race ?? this.race,
    characterClass: characterClass ?? this.characterClass,
    skills: skills ?? this.skills,
    personality: personality ?? this.personality,
    perks: perks ?? this.perks,
    promptFragment: promptFragment ?? this.promptFragment,
  );

  Map<String, Object?> toJson() => <String, Object?>{
    'name': name,
    'gender': gender.name,
    'race': race,
    'characterClass': characterClass.name,
    'skills': skills,
    'personality': personality,
    'perks': perks,
    'promptFragment': promptFragment,
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
  }) => CampaignMemory(
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
  factory StateChanges.fromJson(final Map<String, Object?> json) =>
      StateChanges(
        hpDelta: (json['hpDelta'] as num?)?.toInt() ?? 0,
        energyDelta: (json['energyDelta'] as num?)?.toInt() ?? 0,
        inventoryAdd: _jsonList(
          json['inventoryAdd'],
        ).map((final item) => item.toString()).toList(),
        inventoryRemove: _jsonList(
          json['inventoryRemove'],
        ).map((final item) => item.toString()).toList(),
        questNote: _jsonString(json['questNote']),
        location: _jsonString(json['location']),
      );

  const StateChanges({
    required this.hpDelta,
    required this.energyDelta,
    required this.inventoryAdd,
    required this.inventoryRemove,
    required this.questNote,
    required this.location,
  });

  const StateChanges.empty()
    : hpDelta = 0,
      energyDelta = 0,
      inventoryAdd = const <String>[],
      inventoryRemove = const <String>[],
      questNote = '',
      location = '';

  final int hpDelta;
  final int energyDelta;
  final List<String> inventoryAdd;
  final List<String> inventoryRemove;
  final String questNote;
  final String location;

  Map<String, Object?> toJson() => <String, Object?>{
    'hpDelta': hpDelta,
    'energyDelta': energyDelta,
    'inventoryAdd': inventoryAdd,
    'inventoryRemove': inventoryRemove,
    'questNote': questNote,
    'location': location,
  };
}

class TurnResult {
  factory TurnResult.fromJson(final Map<String, Object?> json) {
    final String narration = _resolveTurnNarration(
      json,
      fallback: 'Мир ненадолго замирает в тишине.',
    );
    final List<String> choices = _resolveTurnChoices(json);
    final Map<String, Object?> stateChangesJson = _resolveTurnStateChanges(
      json,
    );

    return TurnResult(
      narration: narration,
      choices: choices,
      stateChanges: StateChanges.fromJson(stateChangesJson),
      memoryEntry: _resolveTurnMemoryEntry(json, fallback: narration),
    );
  }

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

String _choiceLabel(final Object? item) {
  if (item is String) {
    return item.trim();
  }
  final Map<String, Object?> map = _jsonMap(item);
  for (final String key in const <String>[
    'label',
    'title',
    'text',
    'choice',
    'name',
  ]) {
    final String value = _jsonString(map[key]).trim();
    if (value.isNotEmpty) {
      return value;
    }
  }
  return item?.toString().trim() ?? '';
}

Object? _jsonPathValue(final Object? root, final String path) {
  Object? current = root;
  for (final String segment in path.split('.')) {
    final Map<String, Object?> currentMap = _jsonMap(current);
    if (currentMap.isEmpty || !currentMap.containsKey(segment)) {
      return null;
    }
    current = currentMap[segment];
  }
  return current;
}

String _firstNonEmptyStringPath(final Object? root, final List<String> paths) {
  for (final String path in paths) {
    final Object? rawValue = _jsonPathValue(root, path);
    if (rawValue is Map || rawValue is List) {
      continue;
    }
    final String value = _jsonString(rawValue).trim();
    if (value.isNotEmpty) {
      return value;
    }
  }
  return '';
}

List<String> _resolveTurnChoices(final Map<String, Object?> json) {
  final List<Object?> rawChoices = _jsonList(
    json['choices'] ??
        json['options'] ??
        json['actions'] ??
        json['variants'] ??
        _jsonPathValue(json, 'result.choices') ??
        _jsonPathValue(json, 'result.options') ??
        _jsonPathValue(json, 'result.actions'),
  );
  return rawChoices
      .map((final item) => _choiceLabel(item))
      .where((final item) => item.isNotEmpty)
      .toList();
}

String _resolveTurnLocation(final Map<String, Object?> json) =>
    _firstNonEmptyStringPath(json, const <String>[
      'state_changes.location',
      'stateChanges.location',
      'state.location',
      'state.current_location',
      'state.place',
      'state.scene_location',
      'game_state.location',
      'game_state.current_location',
      'game_state.place',
      'game_state.scene_location',
      'updates.location',
      'updates.current_location',
      'updates.place',
      'updates.scene_location',
      'result.state_changes.location',
      'result.stateChanges.location',
      'result.state.location',
      'result.location',
      'current_location',
      'location',
      'place',
      'scene_location',
    ]);

Map<String, Object?> _resolveTurnStateChanges(final Map<String, Object?> json) {
  final Map<String, Object?> resolved = <String, Object?>{
    ..._jsonMap(
      json['state_changes'] ??
          json['stateChanges'] ??
          json['state'] ??
          json['game_state'] ??
          json['updates'] ??
          _jsonPathValue(json, 'result.state_changes') ??
          _jsonPathValue(json, 'result.stateChanges') ??
          _jsonPathValue(json, 'result.state') ??
          _jsonPathValue(json, 'result.game_state') ??
          _jsonPathValue(json, 'result.updates'),
    ),
  };
  final String location = _resolveTurnLocation(json);
  if (location.isNotEmpty && _jsonString(resolved['location']).trim().isEmpty) {
    resolved['location'] = location;
  }
  return resolved;
}

String _resolveTurnMemoryEntry(
  final Map<String, Object?> json, {
  required final String fallback,
}) {
  final String resolved = _firstNonEmptyStringPath(json, const <String>[
    'memory_entry',
    'memoryEntry',
    'memory_entry.text',
    'memoryEntry.text',
    'result.memory_entry',
    'result.memoryEntry',
    'result.memory_entry.text',
    'result.memoryEntry.text',
  ]);
  return resolved.isNotEmpty ? resolved : fallback;
}

String _resolveTurnNarration(
  final Object? value, {
  required final String fallback,
}) {
  final String resolved = _firstNonEmptyStringPath(value, const <String>[
    'narration',
    'naration',
    'scene',
    'story',
    'description',
    'text',
    'response',
    'memory_entry.text',
    'memoryEntry.text',
    'result.narration',
    'result.naration',
    'result.scene',
    'result.story',
    'result.description',
    'result.text',
    'result.response',
    'result.memory_entry.text',
    'result.memoryEntry.text',
  ]);
  return resolved.isNotEmpty ? resolved : fallback;
}

enum StateChangeNotificationKind {
  itemAdded,
  itemRemoved,
  companionJoined,
  noteAdded,
  resourceChanged,
  progressionChanged,
  vitalityChanged,
  checkResolved,
  moduleUnlocked,
}

class StateChangeNotification {
  const StateChangeNotification({
    required this.id,
    required this.kind,
    required this.message,
  });

  final String id;
  final StateChangeNotificationKind kind;
  final String message;
}

class TurnApplicationResult {
  const TurnApplicationResult({
    required this.state,
    required this.notifications,
  });

  final CampaignState state;
  final List<StateChangeNotification> notifications;
}

class CampaignState {
  factory CampaignState.fromJson(final Map<String, Object?> json) {
    final Map<String, Object?> memoryJson = _jsonMap(json['memory']);
    final List<Object?> messagesJson = _jsonList(json['messages']);
    final List<String> inventory = _jsonList(
      json['inventory'],
    ).map((final item) => item.toString()).toList();
    final List<String> notes = _jsonList(
      json['notes'] ?? json['questLog'],
    ).map((final item) => item.toString()).toList();
    final List<CampaignCompanion> companions = _jsonList(
      json['companions'],
    ).map((final item) => CampaignCompanion.fromJson(_jsonMap(item))).toList();
    final List<CampaignResource> resources = _jsonList(
      json['resources'],
    ).map((final item) => CampaignResource.fromJson(_jsonMap(item))).toList();
    final List<CampaignCheck> checks = _jsonList(
      json['checks'],
    ).map((final item) => CampaignCheck.fromJson(_jsonMap(item))).toList();
    final CampaignProgression? progression =
        _jsonMap(json['progression']).isEmpty
        ? null
        : CampaignProgression.fromJson(_jsonMap(json['progression']));
    final CharacterStats character = CharacterStats.fromJson(
      _jsonMap(json['character']),
    );
    final CampaignMemory memory = memoryJson.isNotEmpty
        ? CampaignMemory.fromJson(memoryJson)
        : CampaignMemory(
            rollingSummary: _jsonString(json['summary']),
            activeGoal: () {
              final String fromActiveGoal = _jsonString(json['activeGoal']);
              if (fromActiveGoal.trim().isNotEmpty) {
                return fromActiveGoal;
              }
              return _jsonString(json['objective']);
            }(),
            activeSituation: messagesJson.isNotEmpty
                ? _jsonString(_jsonMap(messagesJson.last)['text'])
                : '',
            recentTurns: const <RecentTurnSummary>[],
          );
    final List<CampaignModuleState> modules = _jsonList(json['modules'])
        .map((final item) => CampaignModuleState.fromJson(_jsonMap(item)))
        .toList();
    final List<CampaignModuleState> resolvedModules = modules.isNotEmpty
        ? modules
        : inferLegacyModules(
            inventory: inventory,
            notes: notes,
            character: character,
            companions: companions,
            resources: resources,
            progression: progression,
            checks: checks,
          );

    return CampaignState(
      id: _jsonString(json['id']),
      schemaVersion: (json['schemaVersion'] as num?)?.toInt() ?? 1,
      title: _jsonString(json['title'], fallback: 'Кампания'),
      setting: parseCampaignSetting(json['setting']?.toString()),
      mode: StoryMode.values.firstWhere(
        (final item) => item.name == json['mode'],
        orElse: () => StoryMode.shortStory,
      ),
      difficulty: DifficultyLevel.values.firstWhere(
        (final item) => item.name == json['difficulty'],
        orElse: () => DifficultyLevel.easy,
      ),
      character: character,
      location: _jsonString(json['location'], fallback: 'Неизвестная локация'),
      objective: _jsonString(json['objective']),
      turnNumber: (json['turnNumber'] as num?)?.toInt() ?? 0,
      memory: memory,
      modules: resolvedModules,
      inventory: inventory,
      companions: companions,
      notes: notes,
      resources: resources,
      progression: progression,
      checks: checks,
      messages: messagesJson
          .map((final item) => ChatMessage.fromJson(_jsonMap(item)))
          .toList(),
      choices: _jsonList(json['choices'])
          .map((final item) => _choiceLabel(item))
          .where((final item) => item.isNotEmpty)
          .toList(),
      updatedAt:
          DateTime.tryParse(_jsonString(json['updatedAt'])) ?? DateTime.now(),
      literaryGenre: parseLiteraryGenre(json['literaryGenre']?.toString()),
      customStoryPrompt: _jsonString(
        json['customStoryPrompt'] ?? json['custom_story_prompt'],
      ),
      characterPrompt: _jsonString(
        json['characterPrompt'] ?? json['character_prompt'],
      ),
      portraitPath: _jsonString(json['portraitPath']),
      portraitPrompt: _jsonString(json['portraitPrompt']),
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
    required this.modules,
    required this.inventory,
    required this.companions,
    required this.notes,
    required this.resources,
    required this.progression,
    required this.messages,
    required this.choices,
    required this.updatedAt,
    this.literaryGenre,
    this.checks = const <CampaignCheck>[],
    this.customStoryPrompt = '',
    this.characterPrompt = '',
    this.portraitPath = '',
    this.portraitPrompt = '',
  });

  final String id;
  final int schemaVersion;
  final String title;
  final CampaignSetting setting;
  final LiteraryGenre? literaryGenre;
  final StoryMode mode;
  final DifficultyLevel difficulty;
  final CharacterStats character;
  final String location;
  final String objective;
  final int turnNumber;
  final CampaignMemory memory;
  final List<CampaignModuleState> modules;
  final List<String> inventory;
  final List<CampaignCompanion> companions;
  final List<String> notes;
  final List<CampaignResource> resources;
  final CampaignProgression? progression;
  final List<CampaignCheck> checks;
  final List<ChatMessage> messages;
  final List<String> choices;
  final DateTime updatedAt;
  final String customStoryPrompt;
  final String characterPrompt;
  final String portraitPath;
  final String portraitPrompt;

  String get summary => memory.rollingSummary;
  String get activeGoal => memory.activeGoal;
  String get activeSituation => memory.activeSituation;

  /// Sidebar goal line: `memory.activeGoal` (model questNote) first, else `objective`.
  String get displayObjectiveLine {
    final String fromMemory = memory.activeGoal.trim();
    if (fromMemory.isNotEmpty) {
      return fromMemory;
    }
    return objective.trim();
  }

  bool get hasDisplayObjective => displayObjectiveLine.isNotEmpty;
  List<RecentTurnSummary> get recentTurns => memory.recentTurns;
  List<String> get questLog => notes;
  List<CampaignModule> get activeModules => modules
      .where((final item) => item.isActive)
      .map((final item) => item.module)
      .toList();

  bool isModuleActive(final CampaignModule module) =>
      modules.any((final item) => item.module == module && item.isActive);

  CampaignModuleState? moduleState(final CampaignModule module) {
    for (final CampaignModuleState item in modules) {
      if (item.module == module) {
        return item;
      }
    }
    return null;
  }

  CampaignState copyWith({
    final int? schemaVersion,
    final String? title,
    final LiteraryGenre? literaryGenre,
    final CharacterStats? character,
    final String? location,
    final String? objective,
    final int? turnNumber,
    final CampaignMemory? memory,
    final List<CampaignModuleState>? modules,
    final List<String>? inventory,
    final List<CampaignCompanion>? companions,
    final List<String>? notes,
    final List<CampaignResource>? resources,
    final CampaignProgression? progression,
    final List<CampaignCheck>? checks,
    final List<ChatMessage>? messages,
    final List<String>? choices,
    final DateTime? updatedAt,
    final String? customStoryPrompt,
    final String? characterPrompt,
    final String? portraitPath,
    final String? portraitPrompt,
  }) => CampaignState(
    id: id,
    schemaVersion: schemaVersion ?? this.schemaVersion,
    title: title ?? this.title,
    setting: setting,
    mode: mode,
    difficulty: difficulty,
    character: character ?? this.character,
    location: location ?? this.location,
    objective: objective ?? this.objective,
    turnNumber: turnNumber ?? this.turnNumber,
    memory: memory ?? this.memory,
    modules: modules ?? this.modules,
    inventory: inventory ?? this.inventory,
    companions: companions ?? this.companions,
    notes: notes ?? this.notes,
    resources: resources ?? this.resources,
    progression: progression ?? this.progression,
    messages: messages ?? this.messages,
    choices: choices ?? this.choices,
    updatedAt: updatedAt ?? this.updatedAt,
    literaryGenre: literaryGenre ?? this.literaryGenre,
    checks: checks ?? this.checks,
    customStoryPrompt: customStoryPrompt ?? this.customStoryPrompt,
    characterPrompt: characterPrompt ?? this.characterPrompt,
    portraitPath: portraitPath ?? this.portraitPath,
    portraitPrompt: portraitPrompt ?? this.portraitPrompt,
  );

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'schemaVersion': schemaVersion,
    'title': title,
    'setting': setting.name,
    if (literaryGenre != null) 'literaryGenre': literaryGenre!.name,
    'mode': mode.name,
    'difficulty': difficulty.name,
    'character': character.toJson(),
    'location': location,
    'objective': objective,
    'turnNumber': turnNumber,
    'memory': memory.toJson(),
    'modules': modules.map((final item) => item.toJson()).toList(),
    'summary': memory.rollingSummary,
    'inventory': inventory,
    'companions': companions.map((final item) => item.toJson()).toList(),
    'notes': notes,
    'questLog': notes,
    'resources': resources.map((final item) => item.toJson()).toList(),
    'progression': progression?.toJson(),
    'checks': checks.map((final item) => item.toJson()).toList(),
    'messages': messages.map((final item) => item.toJson()).toList(),
    'choices': choices,
    'updatedAt': updatedAt.toIso8601String(),
    'customStoryPrompt': customStoryPrompt,
    'characterPrompt': characterPrompt,
    'portraitPath': portraitPath,
    'portraitPrompt': portraitPrompt,
  };

  static List<CampaignModuleState> inferLegacyModules({
    required final List<String> inventory,
    required final List<String> notes,
    required final CharacterStats character,
    required final List<CampaignCompanion> companions,
    required final List<CampaignResource> resources,
    required final CampaignProgression? progression,
    final List<CampaignCheck> checks = const <CampaignCheck>[],
  }) {
    final DateTime now = DateTime.now();
    final List<CampaignModuleState> inferred = <CampaignModuleState>[];

    void add(final CampaignModule module, final String reason) {
      if (inferred.any((final item) => item.module == module)) {
        return;
      }
      inferred.add(
        CampaignModuleState(
          module: module,
          isActive: true,
          activationReason: reason,
          activatedAt: now,
        ),
      );
    }

    if (inventory.isNotEmpty) {
      add(CampaignModule.inventory, 'legacy_inventory');
    }
    if (notes.isNotEmpty) {
      add(CampaignModule.notes, 'legacy_notes');
    }
    if (companions.isNotEmpty) {
      add(CampaignModule.companions, 'legacy_companions');
    }
    if (resources.isNotEmpty) {
      add(CampaignModule.resources, 'legacy_resources');
    }
    if (progression != null) {
      add(CampaignModule.progression, 'legacy_progression');
    }
    if (checks.isNotEmpty) {
      add(CampaignModule.checks, 'legacy_checks');
    }
    if (character.maxHp > 0 || character.maxEnergy > 0) {
      add(CampaignModule.vitality, 'legacy_vitality');
    }

    return inferred;
  }
}

class CampaignDraft {
  const CampaignDraft({
    required this.setting,
    required this.mode,
    required this.difficulty,
    required this.heroName,
    this.id,
    this.literaryGenre,
    this.storyWish = '',
    this.customStoryPrompt = '',
    this.campaignTitle = '',
    this.objectiveHint = '',
    this.characterProfile,
    this.portraitPath = '',
    this.portraitPrompt = '',
  });

  final String? id;
  final CampaignSetting setting;
  final LiteraryGenre? literaryGenre;
  final StoryMode mode;
  final DifficultyLevel difficulty;
  final String heroName;
  final String storyWish;
  final String customStoryPrompt;
  final String campaignTitle;
  final String objectiveHint;
  final CharacterProfile? characterProfile;
  final String portraitPath;
  final String portraitPrompt;
}

/// Result of AI-generated prompts from story wish.
class GeneratedPrompts {
  const GeneratedPrompts({
    required this.storyPrompt,
    required this.characterPrompt,
    this.campaignTitle = '',
    this.objectiveHint = '',
  });

  final String storyPrompt;
  final String characterPrompt;
  final String campaignTitle;
  final String objectiveHint;
}

/// RO-RO input for campaign prompt generation via AiClient.
class CampaignPromptGenerationRequest {
  const CampaignPromptGenerationRequest({
    required this.setting,
    required this.literaryGenre,
    required this.mode,
    required this.difficulty,
    this.storyWish = '',
    this.characterProfile,
  });

  final CampaignSetting setting;
  final LiteraryGenre literaryGenre;
  final StoryMode mode;
  final DifficultyLevel difficulty;
  final String storyWish;
  final CharacterProfile? characterProfile;
}

class GeneratedPortrait {
  const GeneratedPortrait({
    required this.bytesBase64,
    required this.mimeType,
    required this.promptUsed,
  });

  final String bytesBase64;
  final String mimeType;
  final String promptUsed;
}
