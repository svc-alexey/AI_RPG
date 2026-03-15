import 'package:ai_prg/src/core/models/campaign_models.dart';

class CampaignMemoryManager {
  const CampaignMemoryManager();

  static const int _maxRecentTurns = 5;

  CampaignMemory createInitialMemory({
    required final String objective,
    required final String introText,
  }) {
    return CampaignMemory(
      rollingSummary: 'Кампания только началась.',
      activeGoal: objective,
      activeSituation: introText,
      recentTurns: const <RecentTurnSummary>[],
    );
  }

  CampaignMemory updateMemory({
    required final CampaignState previousState,
    required final TurnResult result,
    required final String playerAction,
  }) {
    final List<RecentTurnSummary> recentTurns =
        List<RecentTurnSummary>.from(previousState.memory.recentTurns)
          ..add(
            RecentTurnSummary(
              playerAction: playerAction,
              outcome: _compact(result.narration, 180),
              stateHint: _buildStateHint(result),
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

  Map<String, Object?> buildAiContext(final CampaignState state) {
    return <String, Object?>{
      'core_state': <String, Object?>{
        'title': state.title,
        'location': state.location,
        'objective': state.objective,
        'turnNumber': state.turnNumber,
        'character': state.character.toJson(),
        'inventory': state.inventory,
        'questLog': state.questLog,
      },
      'active_context': <String, Object?>{
        'activeGoal': state.memory.activeGoal,
        'activeSituation': state.memory.activeSituation,
      },
      'rolling_summary': state.memory.rollingSummary,
      'recent_turns': state.memory.recentTurns
          .map((final RecentTurnSummary item) => item.toJson())
          .toList(),
    };
  }

  String _buildStateHint(final TurnResult result) {
    final List<String> hints = <String>[];
    if (result.stateChanges.hpDelta != 0) {
      hints.add('hp ${result.stateChanges.hpDelta > 0 ? '+' : ''}${result.stateChanges.hpDelta}');
    }
    if (result.stateChanges.energyDelta != 0) {
      hints.add(
        'energy ${result.stateChanges.energyDelta > 0 ? '+' : ''}${result.stateChanges.energyDelta}',
      );
    }
    if (result.stateChanges.inventoryAdd.isNotEmpty) {
      hints.add('add ${result.stateChanges.inventoryAdd.join(', ')}');
    }
    if (result.stateChanges.inventoryRemove.isNotEmpty) {
      hints.add('remove ${result.stateChanges.inventoryRemove.join(', ')}');
    }
    if (result.stateChanges.questNote.trim().isNotEmpty) {
      hints.add(result.stateChanges.questNote.trim());
    }

    return hints.isEmpty ? 'no major state change' : hints.join('; ');
  }

  String _compact(final String raw, final int maxLength) {
    final String normalized = raw.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.length <= maxLength) {
      return normalized;
    }
    return '${normalized.substring(0, maxLength - 1)}…';
  }
}
