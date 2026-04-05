import 'package:ai_prg/src/core/models/campaign_models.dart';

class DiceEngine {
  const DiceEngine();

  static const int startingLootDieSides = 6;
  static const int startingLootMinimumSuccessRoll = 4;

  int rollStartingLootD6({required final String campaignId}) {
    final int seed = _stableHash('$campaignId|starting_loot|0');
    return (seed % startingLootDieSides) + 1;
  }

  int rollD20({
    required final CampaignState state,
    required final String playerAction,
    required final String stat,
    required final int difficulty,
  }) {
    final int seed = _stableHash(
      '${state.id}|${state.turnNumber + 1}|${playerAction.trim().toLowerCase()}|$stat|$difficulty',
    );
    return (seed % 20) + 1;
  }

  int stableHash(final String input) => _stableHash(input);

  int _stableHash(final String input) {
    int hash = 0x811C9DC5;
    for (final int codeUnit in input.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 0x01000193) & 0x7fffffff;
    }
    return hash & 0x7fffffff;
  }
}
