import 'dart:convert';

import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';

class CampaignMemoryManager {
  const CampaignMemoryManager();

  static const int _maxRecentTurns = 5;

  CampaignMemory createInitialMemory({
    required final AppLanguage language,
    required final String objective,
    required final String introText,
  }) => CampaignMemory(
    rollingSummary: switch (language) {
      AppLanguage.ru => 'Кампания только началась.',
      AppLanguage.en => 'The campaign has only just begun.',
    },
    activeGoal: objective,
    activeSituation: introText,
    recentTurns: const <RecentTurnSummary>[],
  );

  CampaignMemory updateMemory({
    required final AppLanguage language,
    required final CampaignState previousState,
    required final TurnResult result,
    required final String playerAction,
  }) {
    final String action = playerAction.trim().isEmpty
        ? switch (language) {
            AppLanguage.ru => '(Начало игры)',
            AppLanguage.en => '(Game Start)',
          }
        : playerAction;

    final List<RecentTurnSummary> recentTurns =
        List<RecentTurnSummary>.from(previousState.memory.recentTurns)..add(
          RecentTurnSummary(
            playerAction: action,
            outcome: _compact(result.narration, 180),
            stateHint: _buildStateHint(language, result),
          ),
        );

    if (recentTurns.length > _maxRecentTurns) {
      recentTurns.removeRange(0, recentTurns.length - _maxRecentTurns);
    }

    return previousState.memory.copyWith(
      rollingSummary: result.memoryEntry.trim().isEmpty
          ? previousState.memory.rollingSummary
          : result.memoryEntry.trim(),
      activeGoal: result.stateChanges.questNote.trim().isEmpty
          ? previousState.objective
          : result.stateChanges.questNote.trim(),
      activeSituation: _compact(result.narration, 220),
      recentTurns: recentTurns,
    );
  }

  Map<String, Object?> buildAiContext(
    final CampaignState state, {
    required final int contextWindowSize,
  }) {
    final int recentTurnLimit = _recentTurnLimit(
      contextWindowSize: contextWindowSize,
      fastMode: false,
    );
    final List<RecentTurnSummary> recentTurns = _takeRecentTurns(
      state.memory.recentTurns,
      recentTurnLimit,
    );
    final Map<String, Object?> payload = <String, Object?>{
      'core_state': <String, Object?>{
        'title': _trimForContext(state.title, 120),
        'location': _trimForContext(state.location, 120),
        'objective': _trimForContext(
          state.objective,
          _textBudget(
            contextWindowSize: contextWindowSize,
            base: 180,
            max: 320,
          ),
        ),
        'turnNumber': state.turnNumber,
        'character': state.character.toJson(),
        'inventory': _takeTail(
          state.inventory,
          _listLimit(
            contextWindowSize: contextWindowSize,
            min: 3,
            max: 10,
            divider: 320,
          ),
        ),
        'questLog': _takeTail(
          state.questLog,
          _listLimit(
            contextWindowSize: contextWindowSize,
            min: 2,
            max: 8,
            divider: 380,
          ),
        ),
      },
      'active_context': <String, Object?>{
        'activeGoal': _trimForContext(
          state.memory.activeGoal,
          _textBudget(
            contextWindowSize: contextWindowSize,
            base: 140,
            max: 260,
          ),
        ),
        'activeSituation': _trimForContext(
          state.memory.activeSituation,
          _textBudget(
            contextWindowSize: contextWindowSize,
            base: 180,
            max: 360,
          ),
        ),
      },
      'rolling_summary': _trimForContext(
        state.memory.rollingSummary,
        _textBudget(contextWindowSize: contextWindowSize, base: 220, max: 520),
      ),
      'recent_turns': recentTurns.map((final item) => item.toJson()).toList(),
    };
    return _shrinkIfNeeded(
      payload,
      targetChars: contextWindowSize * 4,
      recentTurnsKey: 'recent_turns',
    );
  }

  Map<String, Object?> buildFastAiContext(
    final CampaignState state, {
    required final int contextWindowSize,
  }) {
    final int recentTurnLimit = _recentTurnLimit(
      contextWindowSize: contextWindowSize,
      fastMode: true,
    );
    final Map<String, Object?> payload = <String, Object?>{
      'title': _trimForContext(state.title, 96),
      'location': _trimForContext(state.location, 96),
      'objective': _trimForContext(
        state.objective,
        _textBudget(contextWindowSize: contextWindowSize, base: 96, max: 180),
      ),
      'turnNumber': state.turnNumber,
      'character': <String, Object?>{
        'name': state.character.name,
        'hp': state.character.hp,
        'energy': state.character.energy,
      },
      'activeGoal': _trimForContext(
        state.memory.activeGoal,
        _textBudget(contextWindowSize: contextWindowSize, base: 96, max: 160),
      ),
      'activeSituation': _trimForContext(
        state.memory.activeSituation,
        _textBudget(contextWindowSize: contextWindowSize, base: 120, max: 220),
      ),
      'rollingSummary': _trimForContext(
        state.memory.rollingSummary,
        _textBudget(contextWindowSize: contextWindowSize, base: 140, max: 260),
      ),
      'recentTurns': _takeRecentTurns(state.memory.recentTurns, recentTurnLimit)
          .map(
            (final item) => <String, Object?>{
              'playerAction': _trimForContext(item.playerAction, 80),
              'outcome': _trimForContext(item.outcome, 110),
            },
          )
          .toList(),
    };
    return _shrinkIfNeeded(
      payload,
      targetChars: contextWindowSize * 4,
      recentTurnsKey: 'recentTurns',
    );
  }

  String _buildStateHint(final AppLanguage language, final TurnResult result) {
    final List<String> hints = <String>[];
    if (result.stateChanges.hpDelta != 0) {
      hints.add(
        'hp ${result.stateChanges.hpDelta > 0 ? '+' : ''}${result.stateChanges.hpDelta}',
      );
    }
    if (result.stateChanges.energyDelta != 0) {
      hints.add(
        'energy ${result.stateChanges.energyDelta > 0 ? '+' : ''}${result.stateChanges.energyDelta}',
      );
    }
    if (result.stateChanges.inventoryAdd.isNotEmpty) {
      hints.add(switch (language) {
        AppLanguage.ru =>
          'добавлено ${result.stateChanges.inventoryAdd.join(', ')}',
        AppLanguage.en => 'add ${result.stateChanges.inventoryAdd.join(', ')}',
      });
    }
    if (result.stateChanges.inventoryRemove.isNotEmpty) {
      hints.add(switch (language) {
        AppLanguage.ru =>
          'убрано ${result.stateChanges.inventoryRemove.join(', ')}',
        AppLanguage.en =>
          'remove ${result.stateChanges.inventoryRemove.join(', ')}',
      });
    }
    if (result.stateChanges.questNote.trim().isNotEmpty) {
      hints.add(result.stateChanges.questNote.trim());
    }

    return hints.isEmpty
        ? switch (language) {
            AppLanguage.ru => 'без значимых изменений состояния',
            AppLanguage.en => 'no major state change',
          }
        : hints.join('; ');
  }

  String _compact(final String raw, final int maxLength) {
    final String normalized = raw.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.length <= maxLength) {
      return normalized;
    }
    return '${normalized.substring(0, maxLength - 3)}...';
  }

  int _recentTurnLimit({
    required final int contextWindowSize,
    required final bool fastMode,
  }) {
    final int min = fastMode ? 1 : 2;
    final int max = fastMode ? 3 : _maxRecentTurns;
    final int divider = fastMode ? 700 : 540;
    return _listLimit(
      contextWindowSize: contextWindowSize,
      min: min,
      max: max,
      divider: divider,
    );
  }

  int _listLimit({
    required final int contextWindowSize,
    required final int min,
    required final int max,
    required final int divider,
  }) {
    final int derived = (contextWindowSize / divider).floor();
    return derived.clamp(min, max);
  }

  int _textBudget({
    required final int contextWindowSize,
    required final int base,
    required final int max,
  }) {
    final int derived = base + (contextWindowSize / 8).floor();
    return derived.clamp(base, max);
  }

  List<T> _takeTail<T>(final List<T> items, final int limit) {
    if (items.length <= limit) {
      return List<T>.from(items);
    }
    return List<T>.from(items.sublist(items.length - limit));
  }

  List<RecentTurnSummary> _takeRecentTurns(
    final List<RecentTurnSummary> turns,
    final int limit,
  ) => _takeTail(turns, limit);

  String _trimForContext(final String raw, final int maxLength) {
    if (maxLength <= 3) {
      return raw.trim();
    }
    return _compact(raw, maxLength);
  }

  Map<String, Object?> _shrinkIfNeeded(
    final Map<String, Object?> payload, {
    required final int targetChars,
    required final String recentTurnsKey,
  }) {
    if (jsonEncode(payload).length <= targetChars) {
      return payload;
    }

    final List<Object?> recentTurns =
        (payload[recentTurnsKey] as List<Object?>?) ?? const <Object?>[];
    if (recentTurns.length <= 1) {
      return payload;
    }

    final Map<String, Object?> copy = Map<String, Object?>.from(payload);
    copy[recentTurnsKey] = recentTurns.sublist(recentTurns.length - 1);
    return copy;
  }
}
