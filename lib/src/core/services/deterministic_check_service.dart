import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:ai_prg/src/core/services/dice_engine.dart';

class StartingLootGate {
  const StartingLootGate({
    required this.dieRoll,
    required this.grantsStartingItem,
  });

  final int dieRoll;
  final bool grantsStartingItem;

  Map<String, Object?> toJson() => <String, Object?>{
    'dieRoll': dieRoll,
    'dieSides': DiceEngine.startingLootDieSides,
    'minimumRollForItem': DiceEngine.startingLootMinimumSuccessRoll,
    'grantsStartingItem': grantsStartingItem,
  };
}

class DeterministicTurnContext {
  const DeterministicTurnContext({this.resolvedCheck, this.startingLootGate});

  const DeterministicTurnContext.none()
    : resolvedCheck = null,
      startingLootGate = null;

  final CampaignCheck? resolvedCheck;
  final StartingLootGate? startingLootGate;

  bool get hasResolvedCheck => resolvedCheck != null;

  bool get hasStartingLootGate => startingLootGate != null;

  Map<String, Object?> toJson() {
    final CampaignCheck? check = resolvedCheck;
    if (check == null) {
      return const <String, Object?>{};
    }

    final int? modifier = check.total != null && check.roll != null
        ? check.total! - check.roll!
        : null;

    return <String, Object?>{
      'label': check.label,
      'stat': check.stat,
      'difficulty': check.difficulty,
      'roll': check.roll,
      'modifier': modifier,
      'total': check.total,
      'outcome': check.outcome.name,
      'summary': check.summary,
      'clientResolved': true,
    };
  }
}

class DeterministicCheckService {
  const DeterministicCheckService({this.diceEngine = const DiceEngine()});

  final DiceEngine diceEngine;

  StartingLootGate rollStartingLootGate({required final String campaignId}) {
    final int dieRoll = diceEngine.rollStartingLootD6(campaignId: campaignId);
    final bool grantsStartingItem =
        dieRoll >= DiceEngine.startingLootMinimumSuccessRoll;
    return StartingLootGate(
      dieRoll: dieRoll,
      grantsStartingItem: grantsStartingItem,
    );
  }

  static final List<_StatPattern> _statPatterns = <_StatPattern>[
    const _StatPattern(
      stat: 'might',
      patterns: <Pattern>[
        'attack',
        'break',
        'charge',
        'climb',
        'cut',
        'force',
        'grab',
        'jump',
        'kick',
        'lift',
        'pry',
        'pull',
        'push',
        'rush',
        'smash',
        'strike',
        'wrestle',
        'атак',
        'брос',
        'взлом',
        'вышиб',
        'караб',
        'лом',
        'прыг',
        'проб',
        'рыв',
        'сил',
        'удар',
      ],
    ),
    const _StatPattern(
      stat: 'wit',
      patterns: <Pattern>[
        'analy',
        'bypass',
        'decode',
        'disarm',
        'hack',
        'inspect',
        'investig',
        'listen',
        'lock',
        'notice',
        'pick',
        'read',
        'scan',
        'search',
        'sneak',
        'spot',
        'study',
        'track',
        'взлом',
        'внимат',
        'вскры',
        'замет',
        'замок',
        'изуч',
        'исслед',
        'красть',
        'ловуш',
        'осмотр',
        'поиск',
        'проверь',
        'прочит',
        'прослед',
        'расслед',
        'скан',
      ],
    ),
    const _StatPattern(
      stat: 'spirit',
      patterns: <Pattern>[
        'calm',
        'convince',
        'endure',
        'focus',
        'hold',
        'ignore',
        'insist',
        'intimid',
        'negot',
        'pray',
        'persuade',
        'resist',
        'steady',
        'survive',
        'withstand',
        'выдерж',
        'вол',
        'внуш',
        'договор',
        'дух',
        'молит',
        'насто',
        'переж',
        'собер',
        'сопрот',
        'терп',
        'убеж',
        'успок',
      ],
    ),
  ];

  static final List<String> _explicitCheckSignals = <String>[
    'check',
    'roll',
    'test',
    'skill check',
    'saving throw',
    'провер',
    'брос',
    'куб',
    'тест',
  ];

  static final List<String> _hardSignals = <String>[
    'danger',
    'fragile',
    'hard',
    'heavily',
    'impossible',
    'quickly',
    'risky',
    'under fire',
    'ancient',
    'слож',
    'опас',
    'риск',
    'сроч',
    'тяжел',
    'хруп',
  ];

  static final List<String> _carefulSignals = <String>[
    'carefully',
    'patiently',
    'quietly',
    'slowly',
    'with time',
    'аккурат',
    'медлен',
    'осторож',
    'спокойно',
  ];

  DeterministicTurnContext resolve({
    required final CampaignState state,
    required final String playerAction,
    required final AppLanguage language,
  }) {
    if (!state.isModuleActive(CampaignModule.checks)) {
      return const DeterministicTurnContext.none();
    }

    final String normalizedAction = playerAction.trim();
    if (normalizedAction.isEmpty) {
      return const DeterministicTurnContext.none();
    }

    final _PlannedCheck? planned = _planCheck(
      state: state,
      playerAction: normalizedAction,
      language: language,
    );
    if (planned == null) {
      return const DeterministicTurnContext.none();
    }

    final int modifier = _modifierForStat(state.character, planned.stat);
    final int roll = diceEngine.rollD20(
      state: state,
      playerAction: normalizedAction,
      stat: planned.stat,
      difficulty: planned.difficulty,
    );
    final int total = roll + modifier;
    final CampaignCheckOutcome outcome = _resolveOutcome(
      total: total,
      difficulty: planned.difficulty,
      roll: roll,
    );

    return DeterministicTurnContext(
      resolvedCheck: CampaignCheck(
        id: 'check_${state.turnNumber + 1}_${planned.stat}_$roll',
        label: planned.label,
        summary: _buildSummary(
          language: language,
          label: planned.label,
          outcome: outcome,
          difficulty: planned.difficulty,
          total: total,
          roll: roll,
          modifier: modifier,
        ),
        outcome: outcome,
        stat: planned.stat,
        difficulty: planned.difficulty,
        roll: roll,
        total: total,
      ),
    );
  }

  _PlannedCheck? _planCheck({
    required final CampaignState state,
    required final String playerAction,
    required final AppLanguage language,
  }) {
    final String normalized = playerAction.toLowerCase();

    String stat = '';
    for (final _StatPattern pattern in _statPatterns) {
      if (pattern.matches(normalized)) {
        stat = pattern.stat;
        break;
      }
    }

    if (stat.isEmpty &&
        _explicitCheckSignals.any(
          (final signal) => normalized.contains(signal),
        )) {
      stat = _bestAvailableStat(state.character);
    }

    if (stat.isEmpty) {
      return null;
    }

    return _PlannedCheck(
      stat: stat,
      difficulty: _difficultyForAction(
        difficulty: state.difficulty,
        normalizedAction: normalized,
      ),
      label: _localizedLabel(language: language, stat: stat),
    );
  }

  int _difficultyForAction({
    required final DifficultyLevel difficulty,
    required final String normalizedAction,
  }) {
    int target = switch (difficulty) {
      DifficultyLevel.easy => 10,
      DifficultyLevel.medium => 12,
      DifficultyLevel.hardcore => 14,
    };

    if (_hardSignals.any((final signal) => normalizedAction.contains(signal))) {
      target += 2;
    }
    if (_carefulSignals.any(
      (final signal) => normalizedAction.contains(signal),
    )) {
      target -= 1;
    }

    return target.clamp(8, 18);
  }

  int _modifierForStat(final CharacterStats character, final String stat) =>
      switch (stat) {
        'might' => character.might,
        'wit' => character.wit,
        'spirit' => character.spirit,
        _ => 0,
      };

  String _bestAvailableStat(final CharacterStats character) {
    final Map<String, int> stats = <String, int>{
      'might': character.might,
      'wit': character.wit,
      'spirit': character.spirit,
    };

    return stats.entries.reduce((final left, final right) {
      if (right.value > left.value) {
        return right;
      }
      return left;
    }).key;
  }

  CampaignCheckOutcome _resolveOutcome({
    required final int total,
    required final int difficulty,
    required final int roll,
  }) {
    if (roll == 20 || total >= difficulty) {
      return CampaignCheckOutcome.success;
    }
    if (roll == 1 || total <= difficulty - 2) {
      return CampaignCheckOutcome.failure;
    }
    return CampaignCheckOutcome.mixed;
  }

  String _localizedLabel({
    required final AppLanguage language,
    required final String stat,
  }) => switch ((language, stat)) {
    (AppLanguage.ru, 'might') => 'Проверка силы',
    (AppLanguage.ru, 'wit') => 'Проверка ума',
    (AppLanguage.ru, 'spirit') => 'Проверка духа',
    (AppLanguage.en, 'might') => 'Might check',
    (AppLanguage.en, 'wit') => 'Wit check',
    (AppLanguage.en, 'spirit') => 'Spirit check',
    (AppLanguage.ru, _) => 'Проверка',
    (AppLanguage.en, _) => 'Check',
  };

  String _buildSummary({
    required final AppLanguage language,
    required final String label,
    required final CampaignCheckOutcome outcome,
    required final int difficulty,
    required final int total,
    required final int roll,
    required final int modifier,
  }) {
    final String outcomeText = switch ((language, outcome)) {
      (AppLanguage.ru, CampaignCheckOutcome.success) => 'успешна',
      (AppLanguage.ru, CampaignCheckOutcome.failure) => 'провалена',
      (AppLanguage.ru, CampaignCheckOutcome.mixed) => 'частично успешна',
      (AppLanguage.ru, CampaignCheckOutcome.unknown) => 'разрешена',
      (AppLanguage.en, CampaignCheckOutcome.success) => 'succeeded',
      (AppLanguage.en, CampaignCheckOutcome.failure) => 'failed',
      (AppLanguage.en, CampaignCheckOutcome.mixed) => 'partially succeeded',
      (AppLanguage.en, CampaignCheckOutcome.unknown) => 'resolved',
    };

    final String modifierText = modifier == 0
        ? '0'
        : modifier > 0
        ? '+$modifier'
        : '$modifier';

    return switch (language) {
      AppLanguage.ru =>
        '$label $outcomeText ($total vs DC $difficulty, бросок $roll, модификатор $modifierText)',
      AppLanguage.en =>
        '$label $outcomeText ($total vs DC $difficulty, roll $roll, modifier $modifierText)',
    };
  }
}

class _PlannedCheck {
  const _PlannedCheck({
    required this.stat,
    required this.difficulty,
    required this.label,
  });

  final String stat;
  final int difficulty;
  final String label;
}

class _StatPattern {
  const _StatPattern({required this.stat, required this.patterns});

  final String stat;
  final List<Pattern> patterns;

  bool matches(final String source) =>
      patterns.any((final pattern) => source.contains(pattern));
}
