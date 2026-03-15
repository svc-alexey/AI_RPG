import 'package:ai_prg/src/core/models/ai_settings.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';

abstract class AiClient {
  Future<void> checkConnection({required AiSettings settings});

  Future<TurnResult> generateTurn({
    required AiSettings settings,
    required CampaignState state,
    required String playerAction,
    required bool suggestionsOnly,
  });
}
