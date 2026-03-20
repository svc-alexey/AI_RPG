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
        List<RecentTurnSummary>.from(previousState.memory.recentTurns)
          ..add(
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

  Map<String, Object?> buildAiContext(final CampaignState state) => <String, Object?>{
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
          .map((final item) => item.toJson())
          .toList(),
    };

  Map<String, Object?> buildFastAiContext(final CampaignState state) => <String, Object?>{
      'title': state.title,
      'location': state.location,
      'objective': state.objective,
      'turnNumber': state.turnNumber,
      'character': <String, Object?>{
        'name': state.character.name,
        'hp': state.character.hp,
        'energy': state.character.energy,
      },
      'activeGoal': state.memory.activeGoal,
      'activeSituation': state.memory.activeSituation,
      'rollingSummary': state.memory.rollingSummary,
      'recentTurns': state.memory.recentTurns
          .take(2)
          .map((item) => <String, Object?>{
                'playerAction': item.playerAction,
                'outcome': item.outcome,
              })
          .toList(),
    };

  String _buildStateHint(
    final AppLanguage language,
    final TurnResult result,
  ) {
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
      hints.add(
        switch (language) {
          AppLanguage.ru =>
            'добавлено ${result.stateChanges.inventoryAdd.join(', ')}',
          AppLanguage.en =>
            'add ${result.stateChanges.inventoryAdd.join(', ')}',
        },
      );
    }
    if (result.stateChanges.inventoryRemove.isNotEmpty) {
      hints.add(
        switch (language) {
          AppLanguage.ru =>
            'убрано ${result.stateChanges.inventoryRemove.join(', ')}',
          AppLanguage.en =>
            'remove ${result.stateChanges.inventoryRemove.join(', ')}',
        },
      );
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
}
