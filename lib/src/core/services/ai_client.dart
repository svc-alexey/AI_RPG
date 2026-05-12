import 'dart:async';

import 'package:ai_prg/src/core/models/ai_settings.dart';
import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:ai_prg/src/core/services/deterministic_check_service.dart';

/// Token for cancelling an in-flight AI request.
class CancelToken {
  CancelToken();

  final Completer<void> _completer = Completer<void>();

  /// Completes when [cancel] was called.
  Future<void> get whenCancelled => _completer.future;

  /// Signals cancellation. Idempotent.
  void cancel() {
    if (!_completer.isCompleted) {
      _completer.complete();
    }
  }
}

/// Thrown when an AI request was cancelled by the user.
class AiCancelException implements Exception {
  const AiCancelException();

  @override
  String toString() => 'AiCancelException';
}

typedef NarrationDeltaCallback = void Function(String narration);

class AiRequestMetadata {
  const AiRequestMetadata({
    required this.flowId,
    required this.campaignId,
    required this.triggerSource,
    required this.screenMounted,
  });

  final String flowId;
  final String campaignId;
  final String triggerSource;
  final bool screenMounted;
}

abstract class AiClient {
  Future<void> checkConnection({required AiSettings settings});

  Future<TurnResult> generateTurn({
    required AiSettings settings,
    required AppLanguage language,
    required CampaignState state,
    required String playerAction,
    required bool suggestionsOnly,
    required DeterministicTurnContext deterministicContext,
    AiRequestMetadata? metadata,
    NarrationDeltaCallback? onNarrationDelta,
    CancelToken? cancelToken,
  });

  /// Generates story and character prompts (RO-RO). Empty on error.
  Future<GeneratedPrompts> generateCampaignPrompts({
    required AiSettings settings,
    required AppLanguage language,
    required CampaignPromptGenerationRequest request,
    CancelToken? cancelToken,
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
