import 'package:ai_prg/src/core/models/ai_settings.dart';
import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';

abstract class AiClient {
  Future<void> checkConnection({required AiSettings settings});

  Future<TurnResult> generateTurn({
    required AiSettings settings,
    required AppLanguage language,
    required CampaignState state,
    required String playerAction,
    required bool suggestionsOnly,
  });

  /// Generates story and character prompts from user's story wish.
  /// Returns empty prompts if AI is not configured or on error.
  Future<GeneratedPrompts> generatePromptsFromStoryWish({
    required AiSettings settings,
    required AppLanguage language,
    required String storyWish,
    required CampaignSetting setting,
  });
}

class AiTurnException implements Exception {
  const AiTurnException({
    required this.userMessage,
    this.rawResponse,
    this.recoverable = false,
  });

  final String userMessage;
  final String? rawResponse;
  final bool recoverable;

  @override
  String toString() => userMessage;
}
