import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:ai_prg/src/core/services/context_assembly_service.dart';

class CampaignMemoryManager {
  const CampaignMemoryManager();

  static const int _maxRecentTurns = 5;
  static const ContextAssemblyService _contextAssemblyService =
      ContextAssemblyService();

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
    required final int contextWindowSize,
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

    final String stateHint = _buildStateHint(language, result);
    final int nextTurnNumber = previousState.turnNumber + 1;
    final int summaryCadenceTurns = summaryCadenceForContextWindow(
      mode: previousState.mode,
      contextWindowSize: contextWindowSize,
    );
    final bool shouldRefreshSummary = _shouldRefreshRollingSummary(
      previousState: previousState,
      result: result,
      nextTurnNumber: nextTurnNumber,
      summaryCadenceTurns: summaryCadenceTurns,
    );

    return previousState.memory.copyWith(
      rollingSummary: shouldRefreshSummary
          ? _buildRollingSummary(
              previousState: previousState,
              result: result,
              recentTurns: recentTurns,
              stateHint: stateHint,
              contextWindowSize: contextWindowSize,
              summaryCadenceTurns: summaryCadenceTurns,
            )
          : previousState.memory.rollingSummary,
      activeGoal: result.stateChanges.questNote.trim().isEmpty
          ? previousState.memory.activeGoal
          : result.stateChanges.questNote.trim(),
      activeSituation: _compact(result.narration, 220),
      recentTurns: recentTurns,
    );
  }

  Map<String, Object?> buildAiContext(
    final CampaignState state, {
    required final int contextWindowSize,
  }) => _contextAssemblyService
      .build(
        state: state,
        contextWindowSize: contextWindowSize,
        fastMode: false,
      )
      .toJson();

  Map<String, Object?> buildFastAiContext(
    final CampaignState state, {
    required final int contextWindowSize,
  }) => _contextAssemblyService
      .build(state: state, contextWindowSize: contextWindowSize, fastMode: true)
      .toJson();

  static int summaryCadenceForContextWindow({
    required final StoryMode mode,
    required final int contextWindowSize,
  }) => ContextAssemblyService.summaryCadenceForContextWindow(
    mode: mode,
    contextWindowSize: contextWindowSize,
  );

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

  bool _shouldRefreshRollingSummary({
    required final CampaignState previousState,
    required final TurnResult result,
    required final int nextTurnNumber,
    required final int summaryCadenceTurns,
  }) {
    if (previousState.memory.rollingSummary.trim().isEmpty) {
      return true;
    }
    if (_isMajorTurn(result: result)) {
      return true;
    }
    return summaryCadenceTurns <= 1 ||
        nextTurnNumber % summaryCadenceTurns == 0;
  }

  bool _isMajorTurn({required final TurnResult result}) {
    if (result.stateChanges.questNote.trim().isNotEmpty ||
        result.stateChanges.location.trim().isNotEmpty) {
      return true;
    }
    if (result.stateChanges.inventoryAdd.isNotEmpty ||
        result.stateChanges.inventoryRemove.isNotEmpty) {
      return true;
    }
    return result.stateChanges.hpDelta.abs() >= 2 ||
        result.stateChanges.energyDelta.abs() >= 2;
  }

  String _buildRollingSummary({
    required final CampaignState previousState,
    required final TurnResult result,
    required final List<RecentTurnSummary> recentTurns,
    required final String stateHint,
    required final int contextWindowSize,
    required final int summaryCadenceTurns,
  }) {
    final List<String> summarySegments = <String>[
      previousState.memory.rollingSummary,
      ..._takeTail(recentTurns, summaryCadenceTurns).map(
        (final item) =>
            '${item.playerAction}: ${item.outcome} (${item.stateHint})',
      ),
      if (result.memoryEntry.trim().isNotEmpty) result.memoryEntry.trim(),
      if (result.memoryEntry.trim().isEmpty)
        '${_compact(result.narration, 180)} ($stateHint)',
    ];

    return _mergeSummarySegments(
      summarySegments,
      maxLength: _summaryBudget(contextWindowSize),
    );
  }

  String _compact(final String raw, final int maxLength) {
    final String normalized = raw.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.length <= maxLength) {
      return normalized;
    }
    return '${normalized.substring(0, maxLength - 3)}...';
  }

  List<T> _takeTail<T>(final List<T> items, final int limit) {
    if (items.length <= limit) {
      return List<T>.from(items);
    }
    return List<T>.from(items.sublist(items.length - limit));
  }

  int _summaryBudget(final int contextWindowSize) {
    if (contextWindowSize <= 1536) {
      return 280;
    }
    if (contextWindowSize <= 4096) {
      return 420;
    }
    return 560;
  }

  String _mergeSummarySegments(
    final List<String> segments, {
    required final int maxLength,
  }) {
    final List<String> normalized = segments
        .map((final segment) => segment.replaceAll(RegExp(r'\s+'), ' ').trim())
        .where((final segment) => segment.isNotEmpty)
        .toList();
    if (normalized.isEmpty) {
      return '';
    }

    final String joined = normalized.join(' ');
    if (joined.length <= maxLength) {
      return joined;
    }

    final int headLength = (maxLength * 0.4).floor().clamp(32, maxLength - 4);
    final int tailLength = (maxLength - headLength - 3).clamp(16, maxLength);
    return '${joined.substring(0, headLength).trim()}...'
        '${joined.substring(joined.length - tailLength).trim()}';
  }
}
