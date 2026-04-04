import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';

class EntityExtractionService {
  const EntityExtractionService();

  ReconciliationResult reconcile({
    required final CampaignState state,
    required final TurnResult result,
    required final AppLanguage language,
    final CampaignCheck? resolvedCheck,
  }) {
    final DateTime now = DateTime.now();
    final List<CampaignModuleState> modules = List<CampaignModuleState>.from(
      state.modules,
    );
    final CharacterStats character = _applyVitality(
      state: state,
      result: result,
      modules: modules,
      now: now,
    );
    final List<String> inventory = _applyInventory(
      state: state,
      result: result,
      modules: modules,
      now: now,
    );
    final List<String> notes = _applyNotes(
      state: state,
      result: result,
      modules: modules,
      now: now,
    );
    final List<CampaignResource> resources = _applyResources(
      state: state,
      result: result,
      modules: modules,
      now: now,
    );
    final CampaignProgression? progression = _applyProgression(
      state: state,
      result: result,
      modules: modules,
      now: now,
    );
    final List<CampaignCheck> checks = _applyChecks(
      state: state,
      resolvedCheck: resolvedCheck,
      modules: modules,
      now: now,
    );
    final List<CampaignCompanion> companions = _applyCompanions(
      state: state,
      result: result,
      modules: modules,
      now: now,
    );

    final List<StateChangeNotification> notifications = _buildNotifications(
      previousState: state,
      result: result,
      language: language,
      character: character,
      modules: modules,
      inventory: inventory,
      notes: notes,
      resources: resources,
      progression: progression,
      checks: checks,
      companions: companions,
    );

    return ReconciliationResult(
      character: character,
      modules: modules,
      inventory: inventory,
      notes: notes,
      resources: resources,
      progression: progression,
      checks: checks,
      companions: companions,
      notifications: notifications,
    );
  }

  CharacterStats _applyVitality({
    required final CampaignState state,
    required final TurnResult result,
    required final List<CampaignModuleState> modules,
    required final DateTime now,
  }) {
    if (result.stateChanges.hpDelta == 0 &&
        result.stateChanges.energyDelta == 0) {
      return state.character;
    }
    if (!_canTrackModule(state: state, module: CampaignModule.vitality)) {
      return state.character;
    }

    _activateModule(
      modules: modules,
      module: CampaignModule.vitality,
      reason: 'story_unlocked:vitality',
      now: now,
    );

    return state.character.copyWith(
      hp: _clamp(
        state.character.hp + result.stateChanges.hpDelta,
        min: 0,
        max: state.character.maxHp,
      ),
      energy: _clamp(
        state.character.energy + result.stateChanges.energyDelta,
        min: 0,
        max: state.character.maxEnergy,
      ),
    );
  }

  List<String> _applyInventory({
    required final CampaignState state,
    required final TurnResult result,
    required final List<CampaignModuleState> modules,
    required final DateTime now,
  }) {
    final bool hasInventoryChange =
        result.stateChanges.inventoryAdd.isNotEmpty ||
        result.stateChanges.inventoryRemove.isNotEmpty;
    if (hasInventoryChange &&
        !_canTrackModule(state: state, module: CampaignModule.inventory)) {
      return state.inventory;
    }
    if (!hasInventoryChange &&
        !state.isModuleActive(CampaignModule.inventory)) {
      return state.inventory;
    }

    if (hasInventoryChange) {
      _activateModule(
        modules: modules,
        module: CampaignModule.inventory,
        reason: 'story_unlocked:inventory',
        now: now,
      );
    }

    final List<String> inventory = List<String>.from(state.inventory)
      ..addAll(result.stateChanges.inventoryAdd);
    for (final String removed in result.stateChanges.inventoryRemove) {
      inventory.remove(removed);
    }
    return inventory;
  }

  List<String> _applyNotes({
    required final CampaignState state,
    required final TurnResult result,
    required final List<CampaignModuleState> modules,
    required final DateTime now,
  }) {
    final List<String> notes = List<String>.from(state.notes);
    final Set<String> candidates = <String>{};

    final String questNote = result.stateChanges.questNote.trim();
    if (questNote.isNotEmpty) {
      candidates.add(questNote);
    }

    final String? extractedNarrativeNote = _extractNarrativeNote(result);
    if (extractedNarrativeNote != null) {
      candidates.add(extractedNarrativeNote);
    }

    if (candidates.isNotEmpty) {
      if (!_canTrackModule(state: state, module: CampaignModule.notes)) {
        return state.notes;
      }
      _activateModule(
        modules: modules,
        module: CampaignModule.notes,
        reason: 'story_unlocked:notes',
        now: now,
      );
    }

    for (final String note in candidates) {
      if (!notes.contains(note)) {
        notes.add(note);
      }
    }
    return notes;
  }

  List<CampaignCompanion> _applyCompanions({
    required final CampaignState state,
    required final TurnResult result,
    required final List<CampaignModuleState> modules,
    required final DateTime now,
  }) {
    final List<CampaignCompanion> companions = List<CampaignCompanion>.from(
      state.companions,
    );
    final String? name = _extractCompanionName(result);
    if (name == null) {
      return companions;
    }

    final bool exists = companions.any(
      (final item) => item.name.toLowerCase() == name.toLowerCase(),
    );
    if (exists) {
      return companions;
    }
    if (!_canTrackModule(state: state, module: CampaignModule.companions)) {
      return companions;
    }

    _activateModule(
      modules: modules,
      module: CampaignModule.companions,
      reason: 'story_unlocked:companions',
      now: now,
    );
    companions.add(
      CampaignCompanion(
        id: 'companion_${name.toLowerCase().replaceAll(RegExp(r"[^a-zа-я0-9]+", caseSensitive: false), "_")}',
        name: name,
        status: 'active',
      ),
    );
    return companions;
  }

  List<CampaignResource> _applyResources({
    required final CampaignState state,
    required final TurnResult result,
    required final List<CampaignModuleState> modules,
    required final DateTime now,
  }) {
    final List<_ResourceDelta> deltas = _extractResourceDeltas(result);
    if (deltas.isNotEmpty &&
        !_canTrackModule(state: state, module: CampaignModule.resources)) {
      return state.resources;
    }
    if (deltas.isEmpty && !state.isModuleActive(CampaignModule.resources)) {
      return state.resources;
    }

    if (deltas.isNotEmpty) {
      _activateModule(
        modules: modules,
        module: CampaignModule.resources,
        reason: 'story_unlocked:resources',
        now: now,
      );
    }

    final Map<String, CampaignResource> byId = <String, CampaignResource>{
      for (final CampaignResource item in state.resources) item.id: item,
    };
    for (final _ResourceDelta delta in deltas) {
      final CampaignResource? existing = byId[delta.id];
      if (delta.absoluteValue != null) {
        byId[delta.id] = CampaignResource(
          id: delta.id,
          label: delta.label,
          value: delta.absoluteValue!,
          maxValue: existing?.maxValue,
        );
        continue;
      }
      final int nextValue = (existing?.value ?? 0) + delta.delta;
      byId[delta.id] = CampaignResource(
        id: delta.id,
        label: delta.label,
        value: nextValue,
        maxValue: existing?.maxValue,
      );
    }
    return byId.values.toList();
  }

  CampaignProgression? _applyProgression({
    required final CampaignState state,
    required final TurnResult result,
    required final List<CampaignModuleState> modules,
    required final DateTime now,
  }) {
    final _ProgressionUpdate? update = _extractProgressionUpdate(result);
    if (update != null &&
        !_canTrackModule(state: state, module: CampaignModule.progression)) {
      return state.progression;
    }
    if (update == null && !state.isModuleActive(CampaignModule.progression)) {
      return state.progression;
    }

    if (update != null) {
      _activateModule(
        modules: modules,
        module: CampaignModule.progression,
        reason: 'story_unlocked:progression',
        now: now,
      );
    }

    final CampaignProgression base =
        state.progression ??
        const CampaignProgression(level: 1, experience: 0, rank: '');
    if (update == null) {
      return base;
    }

    return CampaignProgression(
      level: update.level ?? base.level,
      experience: base.experience + update.experienceDelta,
      rank: update.rank ?? base.rank,
    );
  }

  List<CampaignCheck> _applyChecks({
    required final CampaignState state,
    required final CampaignCheck? resolvedCheck,
    required final List<CampaignModuleState> modules,
    required final DateTime now,
  }) {
    if (resolvedCheck == null ||
        !_canTrackModule(state: state, module: CampaignModule.checks)) {
      return state.checks;
    }

    _activateModule(
      modules: modules,
      module: CampaignModule.checks,
      reason: 'story_unlocked:checks_client',
      now: now,
    );

    final List<CampaignCheck> checks = List<CampaignCheck>.from(state.checks);
    final CampaignCheck? latest = checks.isEmpty ? null : checks.last;
    if (latest != null &&
        latest.summary == resolvedCheck.summary &&
        latest.outcome == resolvedCheck.outcome &&
        latest.total == resolvedCheck.total &&
        latest.difficulty == resolvedCheck.difficulty) {
      return checks;
    }

    checks.add(resolvedCheck);
    if (checks.length > 6) {
      return checks.sublist(checks.length - 6);
    }
    return checks;
  }

  List<StateChangeNotification> _buildNotifications({
    required final CampaignState previousState,
    required final TurnResult result,
    required final AppLanguage language,
    required final CharacterStats character,
    required final List<CampaignModuleState> modules,
    required final List<String> inventory,
    required final List<String> notes,
    required final List<CampaignResource> resources,
    required final CampaignProgression? progression,
    required final List<CampaignCheck> checks,
    required final List<CampaignCompanion> companions,
  }) {
    final DateTime now = DateTime.now();
    final List<StateChangeNotification> notifications =
        <StateChangeNotification>[];
    final List<StateChangeNotification> moduleNotifications =
        <StateChangeNotification>[];

    for (final CampaignModuleState module in modules) {
      final bool wasActive = previousState.modules.any(
        (final item) => item.module == module.module && item.isActive,
      );
      if (!wasActive && module.isActive) {
        moduleNotifications.add(
          StateChangeNotification(
            id: 'module_${module.module.name}_${now.microsecondsSinceEpoch}',
            kind: StateChangeNotificationKind.moduleUnlocked,
            message: switch (language) {
              AppLanguage.ru =>
                'Новая система: ${_moduleLabel(language, module.module)}',
              AppLanguage.en =>
                'New system: ${_moduleLabel(language, module.module)}',
            },
          ),
        );
      }
    }

    for (final String item in inventory.where(
      (final candidate) => !previousState.inventory.contains(candidate),
    )) {
      notifications.add(
        StateChangeNotification(
          id: 'item_add_${item}_$now',
          kind: StateChangeNotificationKind.itemAdded,
          message: switch (language) {
            AppLanguage.ru => '+ $item',
            AppLanguage.en => '+ $item',
          },
        ),
      );
    }
    for (final String item in previousState.inventory.where(
      (final candidate) => !inventory.contains(candidate),
    )) {
      notifications.add(
        StateChangeNotification(
          id: 'item_remove_${item}_$now',
          kind: StateChangeNotificationKind.itemRemoved,
          message: switch (language) {
            AppLanguage.ru => '- $item',
            AppLanguage.en => '- $item',
          },
        ),
      );
    }

    final int hpDelta = character.hp - previousState.character.hp;
    final int energyDelta = character.energy - previousState.character.energy;
    if (hpDelta != 0 || energyDelta != 0) {
      final List<String> parts = <String>[
        if (hpDelta != 0) 'HP ${_signed(hpDelta)}',
        if (energyDelta != 0)
          switch (language) {
            AppLanguage.ru => 'Энергия ${_signed(energyDelta)}',
            AppLanguage.en => 'Energy ${_signed(energyDelta)}',
          },
      ];
      notifications.add(
        StateChangeNotification(
          id: 'vitality_$now',
          kind: StateChangeNotificationKind.vitalityChanged,
          message: parts.join(' • '),
        ),
      );
    }

    for (final CampaignResource item in resources) {
      final CampaignResource? previous = previousState.resources
          .where((final resource) => resource.id == item.id)
          .firstOrNull;
      if (previous == null || previous.value != item.value) {
        final int delta = item.value - (previous?.value ?? 0);
        notifications.add(
          StateChangeNotification(
            id: 'resource_${item.id}_$now',
            kind: StateChangeNotificationKind.resourceChanged,
            message: previous == null || delta == 0
                ? '${item.label}: ${item.value}'
                : '${item.label} ${_signed(delta)}',
          ),
        );
      }
    }

    if (progression != null) {
      final CampaignProgression? previous = previousState.progression;
      if (previous == null || previous.level != progression.level) {
        notifications.add(
          StateChangeNotification(
            id: 'progression_level_$now',
            kind: StateChangeNotificationKind.progressionChanged,
            message: switch (language) {
              AppLanguage.ru => 'Уровень ${progression.level}',
              AppLanguage.en => 'Level ${progression.level}',
            },
          ),
        );
      } else if (previous.experience != progression.experience) {
        notifications.add(
          StateChangeNotification(
            id: 'progression_xp_$now',
            kind: StateChangeNotificationKind.progressionChanged,
            message: switch (language) {
              AppLanguage.ru =>
                'Опыт ${_signed(progression.experience - previous.experience)}',
              AppLanguage.en =>
                'XP ${_signed(progression.experience - previous.experience)}',
            },
          ),
        );
      }
    }

    final Iterable<CampaignCheck> addedChecks = checks.where(
      (final item) => !previousState.checks.any(
        (final previous) =>
            previous.summary == item.summary &&
            previous.outcome == item.outcome &&
            previous.total == item.total &&
            previous.difficulty == item.difficulty,
      ),
    );
    final CampaignCheck? latestCheck = addedChecks.isEmpty
        ? null
        : addedChecks.first;
    if (latestCheck != null) {
      notifications.add(
        StateChangeNotification(
          id: 'check_$now',
          kind: StateChangeNotificationKind.checkResolved,
          message: latestCheck.summary,
        ),
      );
    }

    final String? companionName = _extractCompanionName(result);
    if (companionName != null &&
        companions.any(
          (final item) =>
              item.name.toLowerCase() == companionName.toLowerCase(),
        ) &&
        !previousState.companions.any(
          (final item) =>
              item.name.toLowerCase() == companionName.toLowerCase(),
        )) {
      notifications.add(
        StateChangeNotification(
          id: 'companion_${companionName}_$now',
          kind: StateChangeNotificationKind.companionJoined,
          message: switch (language) {
            AppLanguage.ru => 'Спутник: $companionName присоединяется',
            AppLanguage.en => 'Companion: $companionName joins you',
          },
        ),
      );
    }

    final Iterable<String> addedNotes = notes.where(
      (final item) => !previousState.notes.contains(item),
    );
    final String? latestNote = addedNotes.isEmpty ? null : addedNotes.first;
    if (latestNote != null && latestNote.trim().isNotEmpty) {
      notifications.add(
        StateChangeNotification(
          id: 'note_$now',
          kind: StateChangeNotificationKind.noteAdded,
          message: switch (language) {
            AppLanguage.ru => 'Заметка: $latestNote',
            AppLanguage.en => 'Note: $latestNote',
          },
        ),
      );
    }

    notifications.addAll(moduleNotifications);
    return notifications.take(4).toList();
  }

  bool _canTrackModule({
    required final CampaignState state,
    required final CampaignModule module,
  }) {
    if (state.isModuleActive(module)) {
      return true;
    }
    if (_isNarrativeOnlyCampaign(state) && _isGameplayChromeModule(module)) {
      return false;
    }

    final Set<CampaignModule> allowed = switch (state.setting) {
      CampaignSetting.romantasy ||
      CampaignSetting.cozyFantasy ||
      CampaignSetting.darkAcademia ||
      CampaignSetting.grimdarkFantasy ||
      CampaignSetting.litRpgProgression ||
      CampaignSetting.horrorWeird ||
      CampaignSetting.altHistorySecret =>
        <CampaignModule>{
          CampaignModule.inventory,
          CampaignModule.companions,
          CampaignModule.notes,
          CampaignModule.vitality,
          CampaignModule.resources,
          CampaignModule.progression,
        },
      CampaignSetting.cozyCrime => <CampaignModule>{
        CampaignModule.notes,
        CampaignModule.companions,
      },
      CampaignSetting.postApocalypse ||
      CampaignSetting.nearFutureSciFi => <CampaignModule>{
        CampaignModule.inventory,
        CampaignModule.companions,
        CampaignModule.notes,
        CampaignModule.vitality,
        CampaignModule.resources,
        CampaignModule.progression,
      },
    };

    return allowed.contains(module);
  }

  bool _isNarrativeOnlyCampaign(final CampaignState state) =>
      state.modules.any((item) {
        final String reason = item.activationReason.toLowerCase();
        return reason.contains('narrative_only') ||
            reason.contains('narrative-only');
      });

  bool _isGameplayChromeModule(final CampaignModule module) =>
      module == CampaignModule.inventory ||
      module == CampaignModule.vitality ||
      module == CampaignModule.resources ||
      module == CampaignModule.progression ||
      module == CampaignModule.checks;

  void _activateModule({
    required final List<CampaignModuleState> modules,
    required final CampaignModule module,
    required final String reason,
    required final DateTime now,
  }) {
    final int index = modules.indexWhere((final item) => item.module == module);
    if (index >= 0) {
      final CampaignModuleState existing = modules[index];
      if (!existing.isActive) {
        modules[index] = existing.copyWith(
          isActive: true,
          activationReason: reason,
          activatedAt: now,
        );
      }
      return;
    }
    modules.add(
      CampaignModuleState(
        module: module,
        isActive: true,
        activationReason: reason,
        activatedAt: now,
      ),
    );
  }

  String? _extractNarrativeNote(final TurnResult result) {
    final String source = '${result.narration} ${result.memoryEntry}'.trim();
    final RegExp notePattern = RegExp(
      r'(?:clue|evidence|note|journal|ledger|код|улика|доказательство|запись)\s*[:\-]\s*([^.!?\n]+)',
      caseSensitive: false,
      unicode: true,
    );
    final RegExpMatch? match = notePattern.firstMatch(source);
    if (match == null) {
      return null;
    }
    final String note = match.group(1)?.trim() ?? '';
    return note.isEmpty ? null : note;
  }

  String? _extractCompanionName(final TurnResult result) {
    final String source = '${result.narration}\n${result.memoryEntry}';
    final List<RegExp> patterns = <RegExp>[
      RegExp(
        r'([A-Z][a-z]+(?:\s+[A-Z][a-z]+)?)\s+(?:joins you|accompanies you|travels with you|becomes your companion)',
        caseSensitive: false,
      ),
      RegExp(
        r'(?:joined by|with you now is)\s+([A-Z][a-z]+(?:\s+[A-Z][a-z]+)?)',
        caseSensitive: false,
      ),
      RegExp(
        r'([А-ЯЁ][а-яё]+(?:\s+[А-ЯЁ][а-яё]+)?)\s+присоединяется(?:\s+к вам)?',
        caseSensitive: false,
        unicode: true,
      ),
      RegExp(
        r'к вам присоединяется\s+([А-ЯЁ][а-яё]+(?:\s+[А-ЯЁ][а-яё]+)?)',
        caseSensitive: false,
        unicode: true,
      ),
    ];

    for (final RegExp pattern in patterns) {
      final RegExpMatch? match = pattern.firstMatch(source);
      final String name = match?.group(1)?.trim() ?? '';
      if (name.isNotEmpty) {
        return name;
      }
    }
    return null;
  }

  List<_ResourceDelta> _extractResourceDeltas(final TurnResult result) {
    final String source = '${result.narration}\n${result.memoryEntry}';
    final List<_ResourceDelta> deltas = <_ResourceDelta>[];
    final List<_ResourceSpec> specs = <_ResourceSpec>[
      const _ResourceSpec(
        id: 'credits',
        label: 'Credits',
        aliases: <String>['credits', 'credit', 'кредит', 'кредитов'],
      ),
      const _ResourceSpec(
        id: 'gold',
        label: 'Gold',
        aliases: <String>['gold', 'золото', 'золота'],
      ),
      const _ResourceSpec(
        id: 'supplies',
        label: 'Supplies',
        aliases: <String>['supplies', 'supply', 'припасы', 'припасов'],
      ),
      const _ResourceSpec(
        id: 'reputation',
        label: 'Reputation',
        aliases: <String>['reputation', 'репутация', 'репутации'],
      ),
      const _ResourceSpec(
        id: 'heat',
        label: 'Heat',
        aliases: <String>['heat', 'розыск', 'тревога'],
      ),
    ];

    for (final _ResourceSpec spec in specs) {
      for (final String alias in spec.aliases) {
        final RegExp signedPattern = RegExp(
          '([+-]\\d+)\\s*$alias',
          caseSensitive: false,
          unicode: true,
        );
        final Iterable<RegExpMatch> signedMatches = signedPattern.allMatches(
          source,
        );
        for (final RegExpMatch match in signedMatches) {
          deltas.add(
            _ResourceDelta(
              id: spec.id,
              label: spec.label,
              delta: int.tryParse(match.group(1) ?? '') ?? 0,
            ),
          );
        }

        final RegExp gainPattern = RegExp(
          '(?:gain(?:ed)?|receive(?:d)?|earn(?:ed)?|found|получ(?:ает|ил|ено)?|наш[её]л|добы(?:л|то)?|теря(?:ет|л)?|lose|lost|spend|spent|потер(?:ял|яно)?|трат(?:ит|ил)?)\\s+(\\d+)\\s*$alias',
          caseSensitive: false,
          unicode: true,
        );
        final Iterable<RegExpMatch> gainMatches = gainPattern.allMatches(
          source,
        );
        for (final RegExpMatch match in gainMatches) {
          final int value = int.tryParse(match.group(1) ?? '') ?? 0;
          final String phrase = match.group(0)?.toLowerCase() ?? '';
          final bool negative =
              phrase.contains('lose') ||
              phrase.contains('lost') ||
              phrase.contains('spend') ||
              phrase.contains('spent') ||
              phrase.contains('потер') ||
              phrase.contains('трат');
          deltas.add(
            _ResourceDelta(
              id: spec.id,
              label: spec.label,
              delta: negative ? -value : value,
            ),
          );
        }

        final RegExp absolutePattern = RegExp(
          '$alias\\s*[:=]\\s*(\\d+)',
          caseSensitive: false,
          unicode: true,
        );
        final RegExpMatch? absoluteMatch = absolutePattern.firstMatch(source);
        if (absoluteMatch != null) {
          deltas.add(
            _ResourceDelta(
              id: spec.id,
              label: spec.label,
              delta: 0,
              absoluteValue: int.tryParse(absoluteMatch.group(1) ?? ''),
            ),
          );
        }
      }
    }

    final Map<String, _ResourceDelta> deduped = <String, _ResourceDelta>{};
    for (final _ResourceDelta delta in deltas) {
      final _ResourceDelta? existing = deduped[delta.id];
      if (existing == null) {
        deduped[delta.id] = delta;
        continue;
      }
      final int mergedDelta;
      if (existing.delta == 0) {
        mergedDelta = delta.delta;
      } else if (delta.delta == 0) {
        mergedDelta = existing.delta;
      } else if ((existing.delta > 0 && delta.delta > 0) ||
          (existing.delta < 0 && delta.delta < 0)) {
        mergedDelta = existing.delta.abs() >= delta.delta.abs()
            ? existing.delta
            : delta.delta;
      } else {
        mergedDelta = existing.delta + delta.delta;
      }
      deduped[delta.id] = _ResourceDelta(
        id: delta.id,
        label: delta.label,
        delta: mergedDelta,
        absoluteValue: delta.absoluteValue ?? existing.absoluteValue,
      );
    }

    return deduped.values
        .where((final item) => item.delta != 0 || item.absoluteValue != null)
        .toList();
  }

  _ProgressionUpdate? _extractProgressionUpdate(final TurnResult result) {
    final String source = '${result.narration}\n${result.memoryEntry}';
    int? level;
    String? rank;
    int experienceDelta = 0;

    final RegExp levelPattern = RegExp(
      r'(?:level up(?: to)?|reaches level|level)\s+(\d+)|(?:уровень|до уровня)\s+(\d+)',
      caseSensitive: false,
      unicode: true,
    );
    final RegExpMatch? levelMatch = levelPattern.firstMatch(source);
    if (levelMatch != null) {
      level = int.tryParse(levelMatch.group(1) ?? levelMatch.group(2) ?? '');
    }

    final RegExp xpSignedPattern = RegExp(
      r'([+-]\d+)\s*(?:xp|experience|опыта|опыт)',
      caseSensitive: false,
      unicode: true,
    );
    final RegExpMatch? xpSignedMatch = xpSignedPattern.firstMatch(source);
    if (xpSignedMatch != null) {
      experienceDelta = int.tryParse(xpSignedMatch.group(1) ?? '') ?? 0;
    } else {
      final RegExp xpSuffixPattern = RegExp(
        r'(?:xp|experience|опыта|опыт)\s*([+-]\d+)',
        caseSensitive: false,
        unicode: true,
      );
      final RegExpMatch? xpSuffixMatch = xpSuffixPattern.firstMatch(source);
      if (xpSuffixMatch != null) {
        experienceDelta = int.tryParse(xpSuffixMatch.group(1) ?? '') ?? 0;
      } else {
        final RegExp xpGainPattern = RegExp(
          r'(?:gain(?:ed)?|earning|earn(?:ed)?|получ(?:ает|ил|ено)?)\s+(\d+)\s*(?:xp|experience|опыта|опыт)',
          caseSensitive: false,
          unicode: true,
        );
        final RegExpMatch? xpGainMatch = xpGainPattern.firstMatch(source);
        if (xpGainMatch != null) {
          experienceDelta = int.tryParse(xpGainMatch.group(1) ?? '') ?? 0;
        }
      }
    }

    final RegExp rankPattern = RegExp(
      r'(?:rank|title|ранг|звание)\s*[:=]?\s*([A-Za-zА-Яа-яЁё][A-Za-zА-Яа-яЁё\s-]+)',
      caseSensitive: false,
      unicode: true,
    );
    final RegExpMatch? rankMatch = rankPattern.firstMatch(source);
    if (rankMatch != null) {
      rank = rankMatch.group(1)?.trim();
    }

    if (level == null && rank == null && experienceDelta == 0) {
      return null;
    }

    return _ProgressionUpdate(
      level: level,
      rank: rank,
      experienceDelta: experienceDelta,
    );
  }

  // Kept temporarily for narrative-only reconciliation heuristics while
  // deterministic checks become the primary source of truth.
  // ignore: unused_element
  CampaignCheck? _extractCheck({
    required final TurnResult result,
    required final AppLanguage language,
    required final DateTime now,
  }) {
    final String source = '${result.narration}\n${result.memoryEntry}'.trim();
    if (source.isEmpty) {
      return null;
    }

    final bool hasSignal = RegExp(
      r'(?:skill check|check|checks|roll(?:ed|s)?|d20|dc\s*\d+|saving throw|test|проверк|брос(?:ок|ьте|ил)|куб|dc\s*\d+)',
      caseSensitive: false,
      unicode: true,
    ).hasMatch(source);
    if (!hasSignal) {
      return null;
    }

    final String stat = _extractCheckStat(source);
    final String label = _extractCheckLabel(
      source: source,
      language: language,
      stat: stat,
    );
    final CampaignCheckOutcome outcome = _extractCheckOutcome(source);
    final int? difficulty = _extractCheckDifficulty(source);
    final int? roll = _extractCheckRoll(source);
    final int? total = _extractCheckTotal(source, difficulty: difficulty);
    final String summary = _buildCheckSummary(
      language: language,
      label: label,
      outcome: outcome,
      total: total,
      difficulty: difficulty,
      roll: roll,
    );

    return CampaignCheck(
      id: 'check_${now.microsecondsSinceEpoch}',
      label: label,
      summary: summary,
      outcome: outcome,
      stat: stat,
      difficulty: difficulty,
      roll: roll,
      total: total,
    );
  }

  String _extractCheckStat(final String source) {
    final List<MapEntry<String, List<String>>> stats =
        <MapEntry<String, List<String>>>[
          const MapEntry<String, List<String>>('might', <String>[
            'might',
            'strength',
            'athletics',
            'force',
            'сила',
            'мощ',
          ]),
          const MapEntry<String, List<String>>('wit', <String>[
            'wit',
            'intellect',
            'logic',
            'investigation',
            'perception',
            'ум',
            'интеллект',
            'вниматель',
            'расслед',
          ]),
          const MapEntry<String, List<String>>('spirit', <String>[
            'spirit',
            'will',
            'resolve',
            'faith',
            'дух',
            'вол',
            'стойк',
          ]),
        ];

    final String lowered = source.toLowerCase();
    for (final MapEntry<String, List<String>> entry in stats) {
      if (entry.value.any(lowered.contains)) {
        return entry.key;
      }
    }
    return '';
  }

  String _extractCheckLabel({
    required final String source,
    required final AppLanguage language,
    required final String stat,
  }) {
    if (stat.isNotEmpty) {
      return switch ((language, stat)) {
        (AppLanguage.ru, 'might') => 'Проверка силы',
        (AppLanguage.ru, 'wit') => 'Проверка ума',
        (AppLanguage.ru, 'spirit') => 'Проверка духа',
        (AppLanguage.en, 'might') => 'Might check',
        (AppLanguage.en, 'wit') => 'Wit check',
        (AppLanguage.en, 'spirit') => 'Spirit check',
        _ => switch (language) {
          AppLanguage.ru => 'Проверка',
          AppLanguage.en => 'Check',
        },
      };
    }

    final RegExp englishPattern = RegExp(
      r'([A-Za-z][A-Za-z\s-]{0,24})\s+check',
      caseSensitive: false,
    );
    final RegExp russianPattern = RegExp(
      r'проверк[а-я]*\s+([А-Яа-яЁёA-Za-z][А-Яа-яЁёA-Za-z\s-]{0,24})',
      caseSensitive: false,
      unicode: true,
    );
    final String? captured =
        englishPattern.firstMatch(source)?.group(1)?.trim() ??
        russianPattern.firstMatch(source)?.group(1)?.trim();
    if (captured != null && captured.isNotEmpty) {
      return _normalizeCheckLabel(captured);
    }
    return switch (language) {
      AppLanguage.ru => 'Проверка',
      AppLanguage.en => 'Check',
    };
  }

  String _normalizeCheckLabel(final String raw) {
    final String normalized = raw.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.isEmpty) {
      return normalized;
    }
    return '${normalized[0].toUpperCase()}${normalized.substring(1)}';
  }

  CampaignCheckOutcome _extractCheckOutcome(final String source) {
    final String lowered = source.toLowerCase();
    if (RegExp(
      r'(?:critical success|crit success|success|succeed(?:ed|s)?|pass(?:ed|es)?|beat(?:s|en)?|clears?|успеш|прош[её]л|выдержал)',
      caseSensitive: false,
      unicode: true,
    ).hasMatch(lowered)) {
      return CampaignCheckOutcome.success;
    }
    if (RegExp(
      r'(?:critical failure|crit fail|failure|fail(?:ed|s)?|miss(?:ed|es)?|fumble|botch|провал|неудач|сорвал|не прош[её]л)',
      caseSensitive: false,
      unicode: true,
    ).hasMatch(lowered)) {
      return CampaignCheckOutcome.failure;
    }
    if (RegExp(
      r'(?:mixed success|partial success|частичн)',
      caseSensitive: false,
      unicode: true,
    ).hasMatch(lowered)) {
      return CampaignCheckOutcome.mixed;
    }
    return CampaignCheckOutcome.unknown;
  }

  int? _extractCheckDifficulty(final String source) {
    final RegExp difficultyPattern = RegExp(
      r'(?:dc|difficulty|сложност[ьи])\s*[:=]?\s*(\d+)',
      caseSensitive: false,
      unicode: true,
    );
    final RegExpMatch? match = difficultyPattern.firstMatch(source);
    return int.tryParse(match?.group(1) ?? '');
  }

  int? _extractCheckRoll(final String source) {
    final List<RegExp> patterns = <RegExp>[
      RegExp(
        r'(?:rolled?|roll|d20)\s*(?:a|=|:)?\s*(\d+)',
        caseSensitive: false,
      ),
      RegExp(
        r'брос(?:ок|ил|ьте)?\s*(?:кубика|d20|=|:)?\s*(\d+)',
        caseSensitive: false,
        unicode: true,
      ),
    ];
    for (final RegExp pattern in patterns) {
      final RegExpMatch? match = pattern.firstMatch(source);
      final int? value = int.tryParse(match?.group(1) ?? '');
      if (value != null) {
        return value;
      }
    }
    return null;
  }

  int? _extractCheckTotal(final String source, {final int? difficulty}) {
    final List<RegExp> patterns = <RegExp>[
      RegExp(
        r'(\d+)\s*(?:vs|against)\s*(?:dc|difficulty)\s*\d+',
        caseSensitive: false,
      ),
      RegExp(
        r'(?:check|total|result|итог)\s*[:=]?\s*(\d+)',
        caseSensitive: false,
        unicode: true,
      ),
      RegExp(
        r'проверк[а-я]*\s*[:=]?\s*(\d+)',
        caseSensitive: false,
        unicode: true,
      ),
    ];
    for (final RegExp pattern in patterns) {
      final RegExpMatch? match = pattern.firstMatch(source);
      final int? value = int.tryParse(match?.group(1) ?? '');
      if (value != null) {
        return value;
      }
    }
    if (difficulty != null) {
      final RegExp beatPattern = RegExp(
        r'(?:beat|beats|clears?|passed|успеш|прош[её]л)\s*(?:dc|difficulty)?\s*\d*',
        caseSensitive: false,
        unicode: true,
      );
      if (beatPattern.hasMatch(source)) {
        return difficulty;
      }
    }
    return null;
  }

  String _buildCheckSummary({
    required final AppLanguage language,
    required final String label,
    required final CampaignCheckOutcome outcome,
    required final int? total,
    required final int? difficulty,
    required final int? roll,
  }) {
    final String outcomeLabel = switch ((language, outcome)) {
      (_, CampaignCheckOutcome.success) =>
        language == AppLanguage.ru ? 'успешна' : 'succeeded',
      (_, CampaignCheckOutcome.failure) =>
        language == AppLanguage.ru ? 'провалена' : 'failed',
      (_, CampaignCheckOutcome.mixed) =>
        language == AppLanguage.ru ? 'частично успешна' : 'partially succeeded',
      (_, CampaignCheckOutcome.unknown) =>
        language == AppLanguage.ru ? 'разрешена' : 'resolved',
    };
    final List<String> details = <String>[
      if (total != null && difficulty != null) '$total vs DC $difficulty',
      if (total != null && difficulty == null)
        switch (language) {
          AppLanguage.ru => 'итог $total',
          AppLanguage.en => 'total $total',
        },
      if (roll != null && total != roll)
        switch (language) {
          AppLanguage.ru => 'бросок $roll',
          AppLanguage.en => 'roll $roll',
        },
    ];
    if (details.isEmpty) {
      return '$label $outcomeLabel';
    }
    return '$label $outcomeLabel (${details.join(', ')})';
  }

  String _signed(final int value) => '${value > 0 ? '+' : ''}$value';

  int _clamp(
    final int value, {
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

  String _moduleLabel(
    final AppLanguage language,
    final CampaignModule module,
  ) => switch ((language, module)) {
    (AppLanguage.ru, CampaignModule.inventory) => 'Инвентарь',
    (AppLanguage.ru, CampaignModule.companions) => 'Спутники',
    (AppLanguage.ru, CampaignModule.notes) => 'Заметки',
    (AppLanguage.ru, CampaignModule.vitality) => 'Живучесть',
    (AppLanguage.ru, CampaignModule.resources) => 'Ресурсы',
    (AppLanguage.ru, CampaignModule.progression) => 'Прогресс',
    (AppLanguage.ru, CampaignModule.checks) => 'Проверки',
    (AppLanguage.en, CampaignModule.inventory) => 'Inventory',
    (AppLanguage.en, CampaignModule.companions) => 'Companions',
    (AppLanguage.en, CampaignModule.notes) => 'Notes',
    (AppLanguage.en, CampaignModule.vitality) => 'Vitality',
    (AppLanguage.en, CampaignModule.resources) => 'Resources',
    (AppLanguage.en, CampaignModule.progression) => 'Progression',
    (AppLanguage.en, CampaignModule.checks) => 'Checks',
  };
}

class ReconciliationResult {
  const ReconciliationResult({
    required this.character,
    required this.modules,
    required this.inventory,
    required this.notes,
    required this.resources,
    required this.progression,
    required this.checks,
    required this.companions,
    required this.notifications,
  });

  final CharacterStats character;
  final List<CampaignModuleState> modules;
  final List<String> inventory;
  final List<String> notes;
  final List<CampaignResource> resources;
  final CampaignProgression? progression;
  final List<CampaignCheck> checks;
  final List<CampaignCompanion> companions;
  final List<StateChangeNotification> notifications;
}

class _ResourceSpec {
  const _ResourceSpec({
    required this.id,
    required this.label,
    required this.aliases,
  });

  final String id;
  final String label;
  final List<String> aliases;
}

class _ResourceDelta {
  const _ResourceDelta({
    required this.id,
    required this.label,
    required this.delta,
    this.absoluteValue,
  });

  final String id;
  final String label;
  final int delta;
  final int? absoluteValue;
}

class _ProgressionUpdate {
  const _ProgressionUpdate({
    required this.level,
    required this.rank,
    required this.experienceDelta,
  });

  final int? level;
  final String? rank;
  final int experienceDelta;
}

extension on Iterable<CampaignResource> {
  CampaignResource? get firstOrNull => isEmpty ? null : first;
}
