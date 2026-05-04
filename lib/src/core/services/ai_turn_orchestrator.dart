import 'dart:async';
import 'dart:convert';

import 'package:ai_prg/src/core/models/ai_settings.dart';
import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:ai_prg/src/core/services/ai_client.dart';
import 'package:ai_prg/src/core/services/ai_connection_checker.dart';
import 'package:ai_prg/src/core/services/ai_prompt_assembler.dart';
import 'package:ai_prg/src/core/services/ai_response_parser.dart';
import 'package:ai_prg/src/core/services/ai_user_messages.dart';
import 'package:ai_prg/src/core/services/app_logger.dart';
import 'package:ai_prg/src/core/services/deterministic_check_service.dart';
import 'package:ai_prg/src/core/services/narrative_nudge_service.dart';
import 'package:ai_prg/src/core/services/openai_compatible_json_helpers.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AiTurnOrchestrator {
  const AiTurnOrchestrator({
    required this.connectionChecker,
    required this.promptAssembler,
    required this.parser,
    required this.messages,
    required this.promptNudge,
  });

  final AiConnectionChecker connectionChecker;
  final AiPromptAssembler promptAssembler;
  final AiResponseParser parser;
  final AiUserMessages messages;
  final NarrativeNudgeService promptNudge;

  static const int _maxCustomPromptLength = 1000;

  // --- generateTurn ---

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
  }) async {
    const int maxAttempts = 3;
    const List<int> backoffMs = [0, 2000, 5000];

    int attemptCount = 0;
    final bool fastMode = _shouldUseFastMode(settings);

    while (attemptCount < maxAttempts) {
      try {
        if (attemptCount > 0) {
          AppLogger.instance.i(
            'Retry attempt $attemptCount/$maxAttempts after ${backoffMs[attemptCount]}ms',
          );
          AppLogger.logDiagnostic(
            level: 'WARN',
            event: 'ai_retry_scheduled',
            message:
                'Retry attempt $attemptCount/$maxAttempts after ${backoffMs[attemptCount]}ms.',
            flowId: metadata?.flowId,
            campaignId: metadata?.campaignId,
            triggerSource: metadata?.triggerSource,
            attempt: attemptCount,
            requestMode: 'retry',
            screenMounted: metadata?.screenMounted,
          );
          await Future<void>.delayed(
            Duration(milliseconds: backoffMs[attemptCount]),
          );
        }

        if (!suggestionsOnly &&
            onNarrationDelta != null &&
            supportsStreaming(settings)) {
          try {
            final Future<TurnResult> streamFuture = _requestTurnStreaming(
              settings: settings,
              language: language,
              state: state,
              playerAction: playerAction,
              suggestionsOnly: suggestionsOnly,
              deterministicContext: deterministicContext,
              metadata: metadata,
              fastMode: fastMode,
              onNarrationDelta: onNarrationDelta,
              cancelToken: cancelToken,
            );

            if (cancelToken != null) {
              return await Future.any(<Future<TurnResult>>[
                streamFuture,
                cancelToken.whenCancelled.then(
                  (_) => throw const AiCancelException(),
                ),
              ]);
            }

            return await streamFuture;
          } on AiCancelException {
            rethrow;
          } on AiTurnException catch (error) {
            AppLogger.instance.w(
              'Streaming failed, falling back to standard response: ${error.userMessage}',
            );
            AppLogger.logDiagnostic(
              level: 'WARN',
              event: 'streaming_fallback',
              message:
                  'Streaming failed, falling back to standard response: ${error.userMessage}',
              flowId: metadata?.flowId,
              campaignId: metadata?.campaignId,
              triggerSource: metadata?.triggerSource,
              attempt: attemptCount,
              requestMode: 'stream-fallback',
              screenMounted: metadata?.screenMounted,
            );
          } catch (error) {
            AppLogger.instance.w(
              'Streaming failed, falling back to standard response: $error',
            );
            AppLogger.logDiagnostic(
              level: 'WARN',
              event: 'streaming_fallback',
              message:
                  'Streaming failed, falling back to standard response: $error',
              flowId: metadata?.flowId,
              campaignId: metadata?.campaignId,
              triggerSource: metadata?.triggerSource,
              attempt: attemptCount,
              requestMode: 'stream-fallback',
              screenMounted: metadata?.screenMounted,
            );
          }
        }

        final Future<TurnResult> turnFuture = _requestTurn(
          settings: settings,
          language: language,
          state: state,
          playerAction: playerAction,
          suggestionsOnly: suggestionsOnly,
          deterministicContext: deterministicContext,
          metadata: metadata,
          attempt: attemptCount,
          requestMode: attemptCount == 0 ? 'standard' : 'retry',
          fastMode: fastMode,
          onNarrationDelta: onNarrationDelta,
        );

        if (cancelToken != null) {
          return await Future.any(<Future<TurnResult>>[
            turnFuture,
            cancelToken.whenCancelled.then(
              (_) => throw const AiCancelException(),
            ),
          ]);
        }

        return await turnFuture;
      } on AiTurnException catch (error) {
        attemptCount++;

        if (_shouldRetryWithoutFastMode(settings, error)) {
          final Future<TurnResult> retryFuture = _requestTurn(
            settings: settings,
            language: language,
            state: state,
            playerAction: playerAction,
            suggestionsOnly: suggestionsOnly,
            deterministicContext: deterministicContext,
            metadata: metadata,
            attempt: attemptCount,
            requestMode: 'retry',
            fastMode: false,
            onNarrationDelta: onNarrationDelta,
          );
          if (cancelToken != null) {
            return await Future.any(<Future<TurnResult>>[
              retryFuture,
              cancelToken.whenCancelled.then(
                (_) => throw const AiCancelException(),
              ),
            ]);
          }
          return await retryFuture;
        }

        if (!error.recoverable || attemptCount >= maxAttempts) {
          AppLogger.logAiError(
            message: 'Failed after $attemptCount attempts',
            exception: error,
            flowId: metadata?.flowId,
            campaignId: metadata?.campaignId,
            triggerSource: metadata?.triggerSource,
            attempt: attemptCount,
            requestMode: 'retry',
            screenMounted: metadata?.screenMounted,
          );
          rethrow;
        }

        AppLogger.instance.w(
          'Recoverable error, will retry: ${error.userMessage}',
        );
        AppLogger.logDiagnostic(
          level: 'WARN',
          event: 'recoverable_ai_error',
          message: error.userMessage,
          flowId: metadata?.flowId,
          campaignId: metadata?.campaignId,
          triggerSource: metadata?.triggerSource,
          attempt: attemptCount,
          requestMode: 'retry',
          screenMounted: metadata?.screenMounted,
        );
      }
    }

    throw const AiTurnException(
      userMessage: 'Max retry attempts ($maxAttempts) exceeded',
    );
  }

  // --- _requestTurn ---

  Future<TurnResult> _requestTurn({
    required AiSettings settings,
    required AppLanguage language,
    required CampaignState state,
    required String playerAction,
    required bool suggestionsOnly,
    required DeterministicTurnContext deterministicContext,
    required AiRequestMetadata? metadata,
    required int attempt,
    required String requestMode,
    required bool fastMode,
    int? maxTokensOverride,
    bool allowTruncationRetry = true,
    NarrationDeltaCallback? onNarrationDelta,
  }) async {
    final Uri uri = Uri.parse(
      '${connectionChecker.normalizedBaseUrl(settings.baseUrl)}/chat/completions',
    );
    final Map<String, Object?> requestBody = promptAssembler.buildTurnRequestBody(
      settings: settings,
      language: language,
      state: state,
      playerAction: playerAction,
      suggestionsOnly: suggestionsOnly,
      deterministicContext: deterministicContext,
      fastMode: fastMode,
      maxTokensOverride: maxTokensOverride,
    );

    AppLogger.logAiRequest(
      endpoint: uri.toString(),
      requestBody: requestBody,
      settings: settings,
      flowId: metadata?.flowId,
      campaignId: metadata?.campaignId,
      triggerSource: metadata?.triggerSource,
      attempt: attempt,
      requestMode: requestMode,
      screenMounted: metadata?.screenMounted,
    );

    final http.Response response;
    try {
      response = await http
          .post(
            uri,
            headers: connectionChecker.headers(settings),
            body: jsonEncode(requestBody),
          )
          .timeout(
            Duration(seconds: connectionChecker.effectiveTimeoutSeconds(settings)),
          );
    } on TimeoutException {
      final AiTurnException exception = AiTurnException(
        userMessage: messages.timeoutError(settings: settings, language: language),
        recoverable: true,
      );
      AppLogger.logAiError(
        message:
            'Timeout after ${connectionChecker.effectiveTimeoutSeconds(settings)}s',
        exception: exception,
        flowId: metadata?.flowId,
        campaignId: metadata?.campaignId,
        triggerSource: metadata?.triggerSource,
        attempt: attempt,
        requestMode: requestMode,
        screenMounted: metadata?.screenMounted,
      );
      throw exception;
    }

    final String rawResponse = connectionChecker.responseText(response);

    AppLogger.logAiResponse(
      endpoint: uri.toString(),
      statusCode: response.statusCode,
      rawResponse: rawResponse,
      flowId: metadata?.flowId,
      campaignId: metadata?.campaignId,
      triggerSource: metadata?.triggerSource,
      attempt: attempt,
      requestMode: requestMode,
      screenMounted: metadata?.screenMounted,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final AiTurnException exception = AiTurnException(
        userMessage: messages.friendlyAiEndpointError(
          settings: settings,
          language: language,
          statusCode: response.statusCode,
          detail: parser.extractProviderErrorDetail(rawResponse),
        ),
        rawResponse: rawResponse,
        recoverable: true,
      );
      AppLogger.logAiError(
        message: 'HTTP ${response.statusCode} error',
        exception: exception,
        flowId: metadata?.flowId,
        campaignId: metadata?.campaignId,
        triggerSource: metadata?.triggerSource,
        attempt: attempt,
        requestMode: requestMode,
        screenMounted: metadata?.screenMounted,
        statusCode: response.statusCode,
      );
      throw exception;
    }

    final Object? decoded = OpenAiCompatibleJsonHelpers.safeDecode(rawResponse);
    if (decoded is! Map) {
      final AiTurnException exception = AiTurnException(
        userMessage: messages.providerUnexpectedFormat(language),
        rawResponse: rawResponse,
        recoverable: true,
      );
      AppLogger.logAiError(
        message: 'Provider returned unexpected format (not a JSON map)',
        exception: exception,
        flowId: metadata?.flowId,
        campaignId: metadata?.campaignId,
        triggerSource: metadata?.triggerSource,
        attempt: attempt,
        requestMode: requestMode,
        screenMounted: metadata?.screenMounted,
      );
      throw exception;
    }

    final Map<String, Object?> responseMap =
        OpenAiCompatibleJsonHelpers.dynamicMap(decoded);
    if (allowTruncationRetry && parser.responseHitTokenLimit(responseMap)) {
      final int currentMaxTokens =
          maxTokensOverride ?? settings.maxResponseTokens;
      final int nextMaxTokens = parser.expandedMaxTokens(currentMaxTokens);
      if (nextMaxTokens > currentMaxTokens) {
        AppLogger.logDiagnostic(
          level: 'WARN',
          event: 'ai_truncation_retry',
          message:
              'Model response hit token limit, retrying with max_tokens=$nextMaxTokens.',
          flowId: metadata?.flowId,
          campaignId: metadata?.campaignId,
          triggerSource: metadata?.triggerSource,
          attempt: attempt,
          requestMode: requestMode,
          screenMounted: metadata?.screenMounted,
        );
        return _requestTurn(
          settings: settings,
          language: language,
          state: state,
          playerAction: playerAction,
          suggestionsOnly: suggestionsOnly,
          deterministicContext: deterministicContext,
          metadata: metadata,
          attempt: attempt,
          requestMode: '$requestMode-token-retry',
          fastMode: fastMode,
          maxTokensOverride: nextMaxTokens,
          allowTruncationRetry: false,
          onNarrationDelta: onNarrationDelta,
        );
      }
    }

    final TurnResult result = parser.parseTurnResponse(
      rawResponse: rawResponse,
      responseMap: responseMap,
      language: language,
    );
    onNarrationDelta?.call(result.narration);
    return result;
  }

  // --- _requestTurnStreaming ---

  Future<TurnResult> _requestTurnStreaming({
    required AiSettings settings,
    required AppLanguage language,
    required CampaignState state,
    required String playerAction,
    required bool suggestionsOnly,
    required DeterministicTurnContext deterministicContext,
    required AiRequestMetadata? metadata,
    required bool fastMode,
    required NarrationDeltaCallback onNarrationDelta,
    int? maxTokensOverride,
    bool allowTruncationRetry = true,
    CancelToken? cancelToken,
  }) async {
    final Uri uri = Uri.parse(
      '${connectionChecker.normalizedBaseUrl(settings.baseUrl)}/chat/completions',
    );
    final Map<String, Object?> requestBody = promptAssembler.buildTurnRequestBody(
      settings: settings,
      language: language,
      state: state,
      playerAction: playerAction,
      suggestionsOnly: suggestionsOnly,
      deterministicContext: deterministicContext,
      fastMode: fastMode,
      maxTokensOverride: maxTokensOverride,
      stream: true,
    );

    AppLogger.logAiRequest(
      endpoint: uri.toString(),
      requestBody: requestBody,
      settings: settings,
      flowId: metadata?.flowId,
      campaignId: metadata?.campaignId,
      triggerSource: metadata?.triggerSource,
      attempt: 0,
      requestMode: 'streaming',
      screenMounted: metadata?.screenMounted,
    );

    final http.Request request = http.Request('POST', uri)
      ..headers.addAll(connectionChecker.headers(settings))
      ..body = jsonEncode(requestBody);

    final http.Client client = http.Client();
    final http.StreamedResponse response;
    try {
      response = await client
          .send(request)
          .timeout(
            Duration(seconds: connectionChecker.effectiveTimeoutSeconds(settings)),
          );
    } on TimeoutException {
      client.close();
      final AiTurnException exception = AiTurnException(
        userMessage: messages.timeoutError(settings: settings, language: language),
        recoverable: true,
      );
      AppLogger.logAiError(
        message:
            'Streaming timeout after ${connectionChecker.effectiveTimeoutSeconds(settings)}s',
        exception: exception,
        flowId: metadata?.flowId,
        campaignId: metadata?.campaignId,
        triggerSource: metadata?.triggerSource,
        attempt: 0,
        requestMode: 'streaming',
        screenMounted: metadata?.screenMounted,
      );
      throw exception;
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final String rawResponse = await utf8.decoder
          .bind(response.stream)
          .join();
      AppLogger.logAiResponse(
        endpoint: uri.toString(),
        statusCode: response.statusCode,
        rawResponse: rawResponse,
        flowId: metadata?.flowId,
        campaignId: metadata?.campaignId,
        triggerSource: metadata?.triggerSource,
        attempt: 0,
        requestMode: 'streaming',
        screenMounted: metadata?.screenMounted,
      );
      final AiTurnException exception = AiTurnException(
        userMessage: messages.friendlyAiEndpointError(
          settings: settings,
          language: language,
          statusCode: response.statusCode,
          detail: parser.extractProviderErrorDetail(rawResponse),
        ),
        rawResponse: rawResponse,
        recoverable: true,
      );
      AppLogger.logAiError(
        message: 'Streaming HTTP ${response.statusCode} error',
        exception: exception,
        flowId: metadata?.flowId,
        campaignId: metadata?.campaignId,
        triggerSource: metadata?.triggerSource,
        attempt: 0,
        requestMode: 'streaming',
        screenMounted: metadata?.screenMounted,
        statusCode: response.statusCode,
      );
      client.close();
      throw exception;
    }

    final StringBuffer rawContent = StringBuffer();
    final StringBuffer eventBuffer = StringBuffer();
    bool cancelled = false;
    bool responseHitTokenLimit = false;
    String? lastPreview;
    unawaited(cancelToken?.whenCancelled.then((_) => cancelled = true));

    Future<void> processEvent() async {
      if (eventBuffer.isEmpty) {
        return;
      }

      final String payload = eventBuffer.toString().trim();
      eventBuffer.clear();
      if (payload.isEmpty || payload == '[DONE]') {
        return;
      }

      final Object? decoded = OpenAiCompatibleJsonHelpers.safeDecode(payload);
      if (decoded is! Map) {
        throw AiTurnException(
          userMessage: messages.providerUnexpectedFormat(language),
          rawResponse: payload,
          recoverable: true,
        );
      }

      final Map<String, Object?> decodedMap =
          OpenAiCompatibleJsonHelpers.dynamicMap(decoded);
      responseHitTokenLimit =
          responseHitTokenLimit || parser.responseHitTokenLimit(decodedMap);
      final String chunk = parser.extractStreamChunk(decodedMap);
      if (chunk.isEmpty) {
        return;
      }

      final String mergedContent = parser.mergeStreamChunk(
        existing: rawContent.toString(),
        incoming: chunk,
      );
      rawContent
        ..clear()
        ..write(mergedContent);
      final String? preview = parser.extractNarrationPreview(
        mergedContent,
      )?.trimRight();
      if (preview != null && preview.isNotEmpty && preview != lastPreview) {
        lastPreview = preview;
        onNarrationDelta(preview);
      }
    }

    try {
      await for (final String line
          in response.stream
              .transform(utf8.decoder)
              .transform(const LineSplitter())) {
        if (cancelled) {
          throw const AiCancelException();
        }
        if (line.isEmpty) {
          await processEvent();
          continue;
        }
        if (line.startsWith('data:')) {
          final String data = line.substring(5).trimLeft();
          if (eventBuffer.isNotEmpty) {
            eventBuffer.writeln();
          }
          eventBuffer.write(data);
        }
      }
      await processEvent();
    } on AiCancelException {
      client.close();
      rethrow;
    } catch (error) {
      client.close();
      if (error is AiTurnException) {
        rethrow;
      }
      throw AiTurnException(
        userMessage: messages.providerUnexpectedFormat(language),
        rawResponse: rawContent.toString(),
        recoverable: true,
      );
    }
    client.close();

    final String rawResponse = rawContent.toString().trim();
    if (rawResponse.isEmpty) {
      throw AiTurnException(
        userMessage: messages.providerNoChoices(language),
        rawResponse: rawResponse,
        recoverable: true,
      );
    }

    AppLogger.logAiResponse(
      endpoint: uri.toString(),
      statusCode: response.statusCode,
      rawResponse: rawResponse,
      flowId: metadata?.flowId,
      campaignId: metadata?.campaignId,
      triggerSource: metadata?.triggerSource,
      attempt: 0,
      requestMode: 'streaming',
      screenMounted: metadata?.screenMounted,
    );

    if (allowTruncationRetry && responseHitTokenLimit) {
      final int currentMaxTokens =
          maxTokensOverride ?? settings.maxResponseTokens;
      final int nextMaxTokens = parser.expandedMaxTokens(currentMaxTokens);
      if (nextMaxTokens > currentMaxTokens) {
        AppLogger.logDiagnostic(
          level: 'WARN',
          event: 'ai_stream_truncation_retry',
          message:
              'Streaming response hit token limit, retrying standard request with max_tokens=$nextMaxTokens.',
          flowId: metadata?.flowId,
          campaignId: metadata?.campaignId,
          triggerSource: metadata?.triggerSource,
          attempt: 0,
          requestMode: 'streaming',
          screenMounted: metadata?.screenMounted,
        );
        return _requestTurn(
          settings: settings,
          language: language,
          state: state,
          playerAction: playerAction,
          suggestionsOnly: suggestionsOnly,
          deterministicContext: deterministicContext,
          metadata: metadata,
          attempt: 0,
          requestMode: 'streaming-token-retry',
          fastMode: fastMode,
          maxTokensOverride: nextMaxTokens,
          allowTruncationRetry: false,
          onNarrationDelta: onNarrationDelta,
        );
      }
    }

    final TurnResult result = parser.parseRawTurnContent(
      rawContent: rawResponse,
      language: language,
    );
    if (result.narration.trim().isNotEmpty && result.narration != lastPreview) {
      onNarrationDelta(result.narration);
    }
    return result;
  }

  // --- Fast mode / streaming support ---

  bool _shouldUseFastMode(AiSettings settings) => false;

  bool supportsStreaming(AiSettings settings) => true;

  bool _shouldRetryWithoutFastMode(
    AiSettings settings,
    AiTurnException error,
  ) => _shouldUseFastMode(settings) && error.recoverable;

  // --- generateCampaignPrompts ---

  Future<GeneratedPrompts> generateCampaignPrompts({
    required AiSettings settings,
    required AppLanguage language,
    required CampaignPromptGenerationRequest request,
    CancelToken? cancelToken,
  }) async {
    final String contentNote = settings.confirmed18Plus
        ? ''
        : switch (language) {
            AppLanguage.ru =>
              ' Избегай сексуального контента. Контент для общей аудитории.',
            AppLanguage.en =>
              ' Avoid sexual content. Keep content suitable for general audiences.',
          };
    final String anchors = promptNudge.buildHiddenBlock(
      setting: request.setting,
      genre: request.literaryGenre,
      language: language,
      confirmed18Plus: settings.confirmed18Plus,
      difficulty: request.difficulty,
    );
    final String wishLine = request.storyWish.trim().isEmpty
        ? switch (language) {
            AppLanguage.ru =>
              'Пользователь не ввёл текстовое пожелание — придумай свежую завязку сам.',
            AppLanguage.en =>
              'The user did not type a free-form wish—invent a fresh hook.',
          }
        : switch (language) {
            AppLanguage.ru =>
              'Пожелание пользователя (развивай свободно): "${request.storyWish.trim()}"',
            AppLanguage.en =>
              'User wish (develop freely): "${request.storyWish.trim()}"',
          };
    final bool isLongCampaign = request.mode == StoryMode.longCampaign;
    final String lockedHeroBlock = request.characterProfile == null
        ? ''
        : campaignPromptLockedHeroBlock(
            profile: request.characterProfile!,
            language: language,
          );
    final String metaPrompt = switch (language) {
      AppLanguage.ru =>
        '''
Ты генерируешь промпты для narrative RPG.
Каркас мира (технический id): ${request.setting.name}
Жанровый акцент (технический id): ${request.literaryGenre.name}
Режим истории: ${request.mode.name}

Мягкие ориентиры:
$anchors

$wishLine$lockedHeroBlock

ВАЖНО: Ответ полностью на русском для русского интерфейса.

Сгенерируй JSON с ключами:
- storyPrompt: инструкции narrative AI (тон, атмосфера, как вести историю). ${isLongCampaign ? "Для longCampaign сделай текст заметно богаче: добавь предысторию героя или мира, долгую интригу и пространство для развития арки. Цель: 180-260 слов." : "Для shortStory держи быстрый темп, сразу выводи к завязке и не раздувай экспозицию. Цель: 80-140 слов."} Не копируй длинные шаблоны — будь конкретным.$contentNote
- characterPrompt: ${isLongCampaign ? "более содержательный портрет героя с мотивацией, внутренним напряжением и тоном." : "кратко тип героя под эту историю."} Максимум ${isLongCampaign ? "140" : "100"} слов.

Только JSON, без markdown.
''',
      AppLanguage.en =>
        '''
You generate prompts for a narrative RPG.
World frame (id): ${request.setting.name}
Genre lean (id): ${request.literaryGenre.name}
Story mode: ${request.mode.name}

Soft anchors:
$anchors

$wishLine$lockedHeroBlock

Generate JSON with keys:
- storyPrompt: instructions for the narrative AI (tone, atmosphere). ${isLongCampaign ? "For longCampaign, make it richer and more layered: include hero or world backstory, a durable conflict, and room for a longer arc. Target 180-260 words." : "For shortStory, keep it compact, fast, and centered on an immediate hook. Target 80-140 words."} Be specific; do not paste generic templates.$contentNote
- characterPrompt: ${isLongCampaign ? "a more detailed protagonist brief with motivation, inner tension, and tone." : "brief protagonist type for this story."} Max ${isLongCampaign ? "140" : "100"} words.

Reply only with JSON, no markdown.
''',
    };

    final Uri uri = Uri.parse(
      '${connectionChecker.normalizedBaseUrl(settings.baseUrl)}/chat/completions',
    );
    final Map<String, Object?> requestBody = promptAssembler.buildPromptRequestBody(
      settings: settings,
      language: language,
      metaPrompt: metaPrompt,
    );

    try {
      final Future<http.Response> requestFuture = http
          .post(
            uri,
            headers: connectionChecker.headers(settings),
            body: jsonEncode(requestBody),
          )
          .timeout(
            Duration(seconds: connectionChecker.effectiveTimeoutSeconds(settings)),
          );

      final http.Response response = cancelToken != null
          ? await Future.any(<Future<http.Response>>[
              requestFuture,
              cancelToken.whenCancelled.then(
                (_) => throw const AiCancelException(),
              ),
            ])
          : await requestFuture;

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final String errBody = connectionChecker.responseText(response);
        final String snippet = errBody.length > 280
            ? errBody.substring(0, 280)
            : errBody;
        debugPrint(
          'generateCampaignPrompts HTTP ${response.statusCode}: $snippet',
        );
        return const GeneratedPrompts(storyPrompt: '', characterPrompt: '');
      }

      final String rawResponse = connectionChecker.responseText(response);
      final Object? decoded = OpenAiCompatibleJsonHelpers.safeDecode(
        rawResponse,
      );
      if (decoded is! Map) {
        return const GeneratedPrompts(storyPrompt: '', characterPrompt: '');
      }

      final Map<String, Object?> map = OpenAiCompatibleJsonHelpers.dynamicMap(
        decoded,
      );
      final List<Object?> choices = OpenAiCompatibleJsonHelpers.dynamicList(
        map['choices'],
      );
      if (choices.isEmpty) {
        return const GeneratedPrompts(storyPrompt: '', characterPrompt: '');
      }

      final Map<String, Object?> choice =
          OpenAiCompatibleJsonHelpers.dynamicMap(choices.first);
      final Map<String, Object?> message =
          OpenAiCompatibleJsonHelpers.dynamicMap(choice['message']);
      final String content = OpenAiCompatibleJsonHelpers.stringValue(
        message['content'],
      );
      final String jsonStr = content.trim();
      final int start = jsonStr.indexOf('{');
      final int end = jsonStr.lastIndexOf('}');
      if (start == -1 || end == -1 || end <= start) {
        return const GeneratedPrompts(storyPrompt: '', characterPrompt: '');
      }

      final Object? parsed = OpenAiCompatibleJsonHelpers.safeDecode(
        jsonStr.substring(start, end + 1),
      );
      if (parsed is! Map) {
        return const GeneratedPrompts(storyPrompt: '', characterPrompt: '');
      }

      final Map<String, Object?> parsedMap =
          OpenAiCompatibleJsonHelpers.dynamicMap(parsed);
      String storyPrompt = OpenAiCompatibleJsonHelpers.stringValue(
        parsedMap['storyPrompt'],
      ).trim();
      if (storyPrompt.length > _maxCustomPromptLength) {
        storyPrompt = storyPrompt.substring(0, _maxCustomPromptLength);
      }
      String characterPrompt = OpenAiCompatibleJsonHelpers.stringValue(
        parsedMap['characterPrompt'],
      ).trim();
      if (characterPrompt.length > _maxCustomPromptLength) {
        characterPrompt = characterPrompt.substring(0, _maxCustomPromptLength);
      }

      return GeneratedPrompts(
        storyPrompt: storyPrompt,
        characterPrompt: characterPrompt,
      );
    } catch (e) {
      debugPrint('generateCampaignPrompts failed: $e');
      return const GeneratedPrompts(storyPrompt: '', characterPrompt: '');
    }
  }
}
