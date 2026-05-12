import 'dart:async';

import 'package:ai_prg/src/core/models/ai_settings.dart';
import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:ai_prg/src/core/services/ai_client.dart';
import 'package:ai_prg/src/core/services/ai_connection_checker.dart';
import 'package:ai_prg/src/core/services/ai_prompt_assembler.dart';
import 'package:ai_prg/src/core/services/ai_response_parser.dart';
import 'package:ai_prg/src/core/services/ai_turn_orchestrator.dart';
import 'package:ai_prg/src/core/services/ai_user_messages.dart';
import 'package:ai_prg/src/core/services/campaign_memory_manager.dart';
import 'package:ai_prg/src/core/services/deterministic_check_service.dart';
import 'package:ai_prg/src/core/services/narrative_nudge_service.dart';
import 'package:ai_prg/src/core/services/turn_prompt_builder.dart';
import 'package:flutter/foundation.dart';

class OpenAiCompatibleAiClient implements AiClient {
  OpenAiCompatibleAiClient()
      : _parser = const AiResponseParser(messages: AiUserMessages()),
        _connectionChecker = AiConnectionChecker(
          messages: const AiUserMessages(),
          parser: const AiResponseParser(messages: AiUserMessages()),
        ),
        _promptAssembler = const AiPromptAssembler(
          turnPromptBuilder: TurnPromptBuilder(),
          memoryManager: CampaignMemoryManager(),
        ),
        _turnOrchestrator = AiTurnOrchestrator(
          connectionChecker: AiConnectionChecker(
            messages: const AiUserMessages(),
            parser: const AiResponseParser(messages: AiUserMessages()),
          ),
          promptAssembler: const AiPromptAssembler(
            turnPromptBuilder: TurnPromptBuilder(),
            memoryManager: CampaignMemoryManager(),
          ),
          parser: const AiResponseParser(messages: AiUserMessages()),
          messages: const AiUserMessages(),
          promptNudge: const NarrativeNudgeService(),
        );

  late final AiResponseParser _parser;
  late final AiConnectionChecker _connectionChecker;
  late final AiPromptAssembler _promptAssembler;
  late final AiTurnOrchestrator _turnOrchestrator;

  // --- AiClient implementation ---

  @override
  Future<void> checkConnection({required AiSettings settings}) =>
      _connectionChecker.checkConnection(settings: settings);

  @override
  Future<GeneratedPrompts> generateCampaignPrompts({
    required AiSettings settings,
    required AppLanguage language,
    required CampaignPromptGenerationRequest request,
    CancelToken? cancelToken,
  }) => _turnOrchestrator.generateCampaignPrompts(
    settings: settings,
    language: language,
    request: request,
    cancelToken: cancelToken,
  );

  @override
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
  }) => _turnOrchestrator.generateTurn(
    settings: settings,
    language: language,
    state: state,
    playerAction: playerAction,
    suggestionsOnly: suggestionsOnly,
    deterministicContext: deterministicContext,
    metadata: metadata,
    onNarrationDelta: onNarrationDelta,
    cancelToken: cancelToken,
  );

  // --- @visibleForTesting ---

  @visibleForTesting
  Map<String, Object?> buildPromptRequestBody({
    required AiSettings settings,
    required AppLanguage language,
    required String metaPrompt,
    int? maxTokensOverride,
  }) => _promptAssembler.buildPromptRequestBody(
    settings: settings,
    language: language,
    metaPrompt: metaPrompt,
    maxTokensOverride: maxTokensOverride,
  );

  @visibleForTesting
  Map<String, Object?> buildTurnRequestBody({
    required AiSettings settings,
    required AppLanguage language,
    required CampaignState state,
    required String playerAction,
    required bool suggestionsOnly,
    required DeterministicTurnContext deterministicContext,
    required bool fastMode,
    int? maxTokensOverride,
    bool stream = false,
  }) => _promptAssembler.buildTurnRequestBody(
    settings: settings,
    language: language,
    state: state,
    playerAction: playerAction,
    suggestionsOnly: suggestionsOnly,
    deterministicContext: deterministicContext,
    fastMode: fastMode,
    maxTokensOverride: maxTokensOverride,
    stream: stream,
  );

  @visibleForTesting
  TurnResult parseTurnContentForTesting({
    required String rawContent,
    required AppLanguage language,
  }) => _parser.parseRawTurnContent(
    rawContent: rawContent,
    language: language,
  );

  @visibleForTesting
  bool supportsStreamingForTesting(AiSettings settings) =>
      _turnOrchestrator.supportsStreaming(settings);

  @visibleForTesting
  bool responseHitTokenLimitForTesting(
    Map<String, Object?> responseMap,
  ) => _parser.responseHitTokenLimit(responseMap);

  @visibleForTesting
  int expandedMaxTokensForTesting(int currentMaxTokens) =>
      _parser.expandedMaxTokens(currentMaxTokens);

  @visibleForTesting
  String extractChoiceContentForTesting(Map<String, Object?> choice) =>
      _parser.extractChoiceContent(choice);

  @visibleForTesting
  String mergeStreamChunkForTesting({
    required String existing,
    required String incoming,
  }) => _parser.mergeStreamChunk(existing: existing, incoming: incoming);

  @visibleForTesting
  String? extractNarrationPreview(String rawContent) =>
      _parser.extractNarrationPreview(rawContent);
}
