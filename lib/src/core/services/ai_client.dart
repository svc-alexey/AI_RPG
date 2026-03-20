import 'dart:async';

import 'package:ai_prg/src/core/models/ai_settings.dart';
import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';

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

abstract class AiClient {
  Future<void> checkConnection({required AiSettings settings});

  Future<TurnResult> generateTurn({
    required AiSettings settings,
    required AppLanguage language,
    required CampaignState state,
    required String playerAction,
    required bool suggestionsOnly,
    CancelToken? cancelToken,
  });

  /// Generates story and character prompts from user's story wish.
  /// Returns empty prompts if AI is not configured or on error.
  Future<GeneratedPrompts> generatePromptsFromStoryWish({
    required AiSettings settings,
    required AppLanguage language,
    required String storyWish,
    required CampaignSetting setting,
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
