import 'dart:convert';

import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';

class ContextAssembly {
  const ContextAssembly({
    required this.staticHeader,
    required this.dynamicSummary,
    required this.recentBuffer,
    required this.worldState,
  });

  final Map<String, Object?> staticHeader;
  final Map<String, Object?> dynamicSummary;
  final List<Map<String, Object?>> recentBuffer;
  final Map<String, Object?> worldState;

  ContextAssembly copyWith({
    final Map<String, Object?>? staticHeader,
    final Map<String, Object?>? dynamicSummary,
    final List<Map<String, Object?>>? recentBuffer,
    final Map<String, Object?>? worldState,
  }) => ContextAssembly(
    staticHeader: staticHeader ?? this.staticHeader,
    dynamicSummary: dynamicSummary ?? this.dynamicSummary,
    recentBuffer: recentBuffer ?? this.recentBuffer,
    worldState: worldState ?? this.worldState,
  );

  Map<String, Object?> toJson() => <String, Object?>{
    'static_header': staticHeader,
    'dynamic_summary': dynamicSummary,
    'recent_buffer': recentBuffer,
    'world_state': worldState,
  };
}

class ContextAssemblyService {
  const ContextAssemblyService();

  static int summaryCadenceForContextWindow({
    required final StoryMode mode,
    required final int contextWindowSize,
  }) {
    if (mode == StoryMode.shortStory) {
      return 1;
    }
    if (contextWindowSize <= 1536) {
      return 2;
    }
    if (contextWindowSize <= 4096) {
      return 3;
    }
    return 4;
  }

  ContextAssembly build({
    required final CampaignState state,
    required final int contextWindowSize,
    required final bool fastMode,
  }) {
    final int summaryCadenceTurns = summaryCadenceForContextWindow(
      mode: state.mode,
      contextWindowSize: contextWindowSize,
    );
    final int recentTurnLimit = _recentTurnLimit(
      contextWindowSize: contextWindowSize,
      fastMode: fastMode,
    );

    final ContextAssembly assembly = ContextAssembly(
      staticHeader: <String, Object?>{
        'campaignTitle': _trimForContext(state.title, fastMode ? 90 : 120),
        'setting': state.setting.name,
        'mode': state.mode.name,
        'difficulty': state.difficulty.name,
        'turnNumber': state.turnNumber,
      },
      dynamicSummary: <String, Object?>{
        'rollingSummary': _trimForContext(
          state.memory.rollingSummary,
          _textBudget(
            contextWindowSize: contextWindowSize,
            base: fastMode ? 120 : 220,
            max: fastMode ? 220 : 520,
          ),
        ),
        'activeGoal': _trimForContext(
          state.memory.activeGoal,
          _textBudget(
            contextWindowSize: contextWindowSize,
            base: fastMode ? 100 : 140,
            max: fastMode ? 180 : 260,
          ),
        ),
        'activeSituation': _trimForContext(
          state.memory.activeSituation,
          _textBudget(
            contextWindowSize: contextWindowSize,
            base: fastMode ? 120 : 180,
            max: fastMode ? 220 : 360,
          ),
        ),
        'summaryCadenceTurns': summaryCadenceTurns,
      },
      recentBuffer: _takeRecentTurns(state.memory.recentTurns, recentTurnLimit)
          .map(
            (final item) => <String, Object?>{
              'playerAction': _trimForContext(
                item.playerAction,
                fastMode ? 80 : 120,
              ),
              'outcome': _trimForContext(
                item.outcome,
                _textBudget(
                  contextWindowSize: contextWindowSize,
                  base: fastMode ? 90 : 140,
                  max: fastMode ? 150 : 240,
                ),
              ),
              'stateHint': _trimForContext(
                item.stateHint,
                _textBudget(
                  contextWindowSize: contextWindowSize,
                  base: fastMode ? 70 : 110,
                  max: fastMode ? 120 : 180,
                ),
              ),
            },
          )
          .toList(),
      worldState: <String, Object?>{
        'location': _trimForContext(state.location, fastMode ? 90 : 120),
        'objective': _trimForContext(
          state.objective,
          _textBudget(
            contextWindowSize: contextWindowSize,
            base: fastMode ? 96 : 180,
            max: fastMode ? 180 : 320,
          ),
        ),
        'character': fastMode
            ? <String, Object?>{
                'name': state.character.name,
                'hp': state.character.hp,
                'energy': state.character.energy,
              }
            : state.character.toJson(),
        'inventory': _takeTail(
          state.inventory,
          _listLimit(
            contextWindowSize: contextWindowSize,
            min: fastMode ? 2 : 3,
            max: fastMode ? 5 : 10,
            divider: fastMode ? 420 : 320,
          ),
        ),
        'questLog': _takeTail(
          state.questLog,
          _listLimit(
            contextWindowSize: contextWindowSize,
            min: fastMode ? 1 : 2,
            max: fastMode ? 4 : 8,
            divider: fastMode ? 560 : 380,
          ),
        ),
      },
    );

    return _shrinkIfNeeded(assembly, targetChars: contextWindowSize * 4);
  }

  String buildUserPrompt({
    required final AppLanguage language,
    required final CampaignState state,
    required final String playerAction,
    required final bool fastMode,
    required final int contextWindowSize,
  }) {
    final ContextAssembly context = build(
      state: state,
      contextWindowSize: contextWindowSize,
      fastMode: fastMode,
    );

    final String actionText = playerAction.trim().isEmpty
        ? switch (language) {
            AppLanguage.ru =>
              '(Начало игры. Придумай интересную стартовую локацию, завязку и цель в рамках текущего сеттинга. Начни повествование.)',
            AppLanguage.en =>
              '(Game start. Invent an interesting starting location, hook, and objective within the current setting. Begin the narration.)',
          }
        : playerAction;

    return switch (language) {
      AppLanguage.ru =>
        '''
Контекст кампании:
${jsonEncode(context.toJson())}

Действие игрока:
$actionText
''',
      AppLanguage.en =>
        '''
Campaign context:
${jsonEncode(context.toJson())}

Player action:
$actionText
''',
    };
  }

  int _recentTurnLimit({
    required final int contextWindowSize,
    required final bool fastMode,
  }) {
    final int min = fastMode ? 1 : 2;
    final int max = fastMode ? 3 : 5;
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
    final String normalized = raw.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.length <= maxLength) {
      return normalized;
    }
    if (maxLength <= 3) {
      return normalized;
    }
    return '${normalized.substring(0, maxLength - 3)}...';
  }

  ContextAssembly _shrinkIfNeeded(
    final ContextAssembly assembly, {
    required final int targetChars,
  }) {
    ContextAssembly current = assembly;

    while (jsonEncode(current.toJson()).length > targetChars &&
        current.recentBuffer.length > 1) {
      current = current.copyWith(recentBuffer: current.recentBuffer.sublist(1));
    }

    return current;
  }
}
