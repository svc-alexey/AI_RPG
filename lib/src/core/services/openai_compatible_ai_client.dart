import 'dart:async';
import 'dart:convert';

import 'package:ai_prg/src/core/models/ai_settings.dart';
import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:ai_prg/src/core/services/ai_client.dart';
import 'package:ai_prg/src/core/services/app_logger.dart';
import 'package:ai_prg/src/core/services/campaign_memory_manager.dart';
import 'package:ai_prg/src/core/services/deterministic_check_service.dart';
import 'package:ai_prg/src/core/services/turn_prompt_builder.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class OpenAiCompatibleAiClient implements AiClient {
  OpenAiCompatibleAiClient();

  static const CampaignMemoryManager _memoryManager = CampaignMemoryManager();
  static const TurnPromptBuilder _turnPromptBuilder = TurnPromptBuilder();
  static const int _truncationRetryMultiplier = 2;

  Map<String, Object?> _jsonMap(final Object? value) {
    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), item));
    }
    return const <String, Object?>{};
  }

  List<Object?> _jsonList(final Object? value) =>
      value is List ? List<Object?>.from(value) : const <Object?>[];

  String _stringValue(final Object? value) => value == null ? '' : '$value';

  @override
  Future<void> checkConnection({required final AiSettings settings}) async {
    final Uri uri = Uri.parse('${_normalizedBaseUrl(settings.baseUrl)}/models');
    final http.Response response;

    try {
      response = await http
          .get(uri, headers: _headers(settings))
          .timeout(Duration(seconds: _effectiveTimeoutSeconds(settings)));
    } on TimeoutException {
      throw AiTurnException(
        userMessage: _timeoutError(
          settings: settings,
          language: AppLanguage.en,
        ),
        recoverable: true,
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final String rawResponse = _responseText(response);
      throw AiTurnException(
        userMessage: _friendlyAiEndpointError(
          settings: settings,
          language: AppLanguage.en,
          statusCode: response.statusCode,
          detail: _extractProviderErrorDetail(rawResponse),
        ),
        rawResponse: rawResponse,
      );
    }
  }

  static const int _maxCustomPromptLength = 1000;

  @override
  Future<GeneratedPrompts> generatePromptsFromStoryWish({
    required final AiSettings settings,
    required final AppLanguage language,
    required final String storyWish,
    required final CampaignSetting setting,
    final CancelToken? cancelToken,
  }) async {
    if (storyWish.trim().isEmpty) {
      return const GeneratedPrompts(storyPrompt: '', characterPrompt: '');
    }

    final String contentNote = settings.confirmed18Plus
        ? ''
        : switch (language) {
            AppLanguage.ru =>
              ' Избегай сексуального контента. Контент для общей аудитории.',
            AppLanguage.en =>
              ' Avoid sexual content. Keep content suitable for general audiences.',
          };
    final String metaPrompt = switch (language) {
      AppLanguage.ru =>
        '''
Пользователь описывает желаемую историю для narrative RPG: "$storyWish"
Сеттинг: ${setting.name}.

ВАЖНО: Ответ должен быть полностью на русском языке для корректного отображения в русском интерфейсе.

Сгенерируй JSON с двумя ключами:
- storyPrompt: инструкции на русском языке для narrative AI, как вести именно эту историю (тон, жанр, атмосфера). Максимум 300 слов.$contentNote
- characterPrompt: краткое описание на русском языке типа персонажа, подходящего для этой истории. Максимум 100 слов.

Ответь только JSON, без markdown.
''',
      AppLanguage.en =>
        '''
User describes desired story for narrative RPG: "$storyWish"
Setting: ${setting.name}.

Generate JSON with two keys:
- storyPrompt: instructions for narrative AI on how to run this story (tone, genre, atmosphere). Max 300 words.$contentNote
- characterPrompt: brief description of character type suited for this story. Max 100 words.

Reply only with JSON, no markdown.
''',
    };

    final Uri uri = Uri.parse(
      '${_normalizedBaseUrl(settings.baseUrl)}/chat/completions',
    );
    final Map<String, Object?> requestBody = buildPromptRequestBody(
      settings: settings,
      language: language,
      metaPrompt: metaPrompt,
    );

    try {
      final Future<http.Response> requestFuture = http
          .post(uri, headers: _headers(settings), body: jsonEncode(requestBody))
          .timeout(Duration(seconds: _effectiveTimeoutSeconds(settings)));

      final http.Response response = cancelToken != null
          ? await Future.any(<Future<http.Response>>[
              requestFuture,
              cancelToken.whenCancelled.then(
                (_) => throw const AiCancelException(),
              ),
            ])
          : await requestFuture;

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return const GeneratedPrompts(storyPrompt: '', characterPrompt: '');
      }

      final String rawResponse = _responseText(response);
      final Object? decoded = _safeJsonDecode(rawResponse);
      if (decoded is! Map) {
        return const GeneratedPrompts(storyPrompt: '', characterPrompt: '');
      }

      final Map<String, Object?> map = _jsonMap(decoded);
      final List<Object?> choices = _jsonList(map['choices']);
      if (choices.isEmpty) {
        return const GeneratedPrompts(storyPrompt: '', characterPrompt: '');
      }

      final Map<String, Object?> choice = _jsonMap(choices.first);
      final Map<String, Object?> message = _jsonMap(choice['message']);
      final String content = _stringValue(message['content']);
      final String jsonStr = content.trim();
      final int start = jsonStr.indexOf('{');
      final int end = jsonStr.lastIndexOf('}');
      if (start == -1 || end == -1 || end <= start) {
        return const GeneratedPrompts(storyPrompt: '', characterPrompt: '');
      }

      final Object? parsed = _safeJsonDecode(jsonStr.substring(start, end + 1));
      if (parsed is! Map) {
        return const GeneratedPrompts(storyPrompt: '', characterPrompt: '');
      }

      final Map<String, Object?> parsedMap = _jsonMap(parsed);
      String storyPrompt = _stringValue(parsedMap['storyPrompt']).trim();
      if (storyPrompt.length > _maxCustomPromptLength) {
        storyPrompt = storyPrompt.substring(0, _maxCustomPromptLength);
      }
      String characterPrompt = _stringValue(
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
      debugPrint('generatePromptsFromStoryWish failed: $e');
      return const GeneratedPrompts(storyPrompt: '', characterPrompt: '');
    }
  }

  @override
  Future<GeneratedPortrait?> generateCharacterPortrait({
    required final AiSettings settings,
    required final AppLanguage language,
    required final CampaignSetting setting,
    required final String storyPrompt,
    required final CharacterProfile character,
    final CancelToken? cancelToken,
  }) async => null;

  @override
  Future<TurnResult> generateTurn({
    required final AiSettings settings,
    required final AppLanguage language,
    required final CampaignState state,
    required final String playerAction,
    required final bool suggestionsOnly,
    required final DeterministicTurnContext deterministicContext,
    final AiRequestMetadata? metadata,
    final NarrationDeltaCallback? onNarrationDelta,
    final CancelToken? cancelToken,
  }) async {
    const int maxAttempts = 3;
    const List<int> backoffMs = [0, 2000, 5000]; // 0s, 2s, 5s

    int attemptCount = 0;
    final bool fastMode = _shouldUseFastMode(settings);

    while (attemptCount < maxAttempts) {
      try {
        // Задержка перед retry (не на первой попытке)
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
            _supportsStreaming(settings)) {
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

        // Если это fast mode ошибка, пробуем без fast mode
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

        // Если ошибка не recoverable или исчерпаны попытки
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

  Future<TurnResult> _requestTurn({
    required final AiSettings settings,
    required final AppLanguage language,
    required final CampaignState state,
    required final String playerAction,
    required final bool suggestionsOnly,
    required final DeterministicTurnContext deterministicContext,
    required final AiRequestMetadata? metadata,
    required final int attempt,
    required final String requestMode,
    required final bool fastMode,
    final int? maxTokensOverride,
    final bool allowTruncationRetry = true,
    final NarrationDeltaCallback? onNarrationDelta,
  }) async {
    final Uri uri = Uri.parse(
      '${_normalizedBaseUrl(settings.baseUrl)}/chat/completions',
    );
    final Map<String, Object?> requestBody = buildTurnRequestBody(
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
          .post(uri, headers: _headers(settings), body: jsonEncode(requestBody))
          .timeout(Duration(seconds: _effectiveTimeoutSeconds(settings)));
    } on TimeoutException {
      final AiTurnException exception = AiTurnException(
        userMessage: _timeoutError(settings: settings, language: language),
        recoverable: true,
      );
      AppLogger.logAiError(
        message: 'Timeout after ${_effectiveTimeoutSeconds(settings)}s',
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

    final String rawResponse = _responseText(response);

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
        userMessage: _friendlyAiEndpointError(
          settings: settings,
          language: language,
          statusCode: response.statusCode,
          detail: _extractProviderErrorDetail(rawResponse),
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

    final Object? decoded = _safeJsonDecode(rawResponse);
    if (decoded is! Map) {
      final AiTurnException exception = AiTurnException(
        userMessage: _providerUnexpectedFormat(language),
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

    final Map<String, Object?> responseMap = _jsonMap(decoded);
    if (allowTruncationRetry && _responseHitTokenLimit(responseMap)) {
      final int currentMaxTokens =
          maxTokensOverride ?? settings.maxResponseTokens;
      final int nextMaxTokens = _expandedMaxTokens(currentMaxTokens);
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

    final TurnResult result = _parseTurnResponse(
      rawResponse: rawResponse,
      responseMap: responseMap,
      language: language,
    );
    onNarrationDelta?.call(result.narration);
    return result;
  }

  Future<TurnResult> _requestTurnStreaming({
    required final AiSettings settings,
    required final AppLanguage language,
    required final CampaignState state,
    required final String playerAction,
    required final bool suggestionsOnly,
    required final DeterministicTurnContext deterministicContext,
    required final AiRequestMetadata? metadata,
    required final bool fastMode,
    required final NarrationDeltaCallback onNarrationDelta,
    final int? maxTokensOverride,
    final bool allowTruncationRetry = true,
    final CancelToken? cancelToken,
  }) async {
    final Uri uri = Uri.parse(
      '${_normalizedBaseUrl(settings.baseUrl)}/chat/completions',
    );
    final Map<String, Object?> requestBody = buildTurnRequestBody(
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
      ..headers.addAll(_headers(settings))
      ..body = jsonEncode(requestBody);

    final http.Client client = http.Client();
    final http.StreamedResponse response;
    try {
      response = await client
          .send(request)
          .timeout(Duration(seconds: _effectiveTimeoutSeconds(settings)));
    } on TimeoutException {
      client.close();
      final AiTurnException exception = AiTurnException(
        userMessage: _timeoutError(settings: settings, language: language),
        recoverable: true,
      );
      AppLogger.logAiError(
        message:
            'Streaming timeout after ${_effectiveTimeoutSeconds(settings)}s',
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
        userMessage: _friendlyAiEndpointError(
          settings: settings,
          language: language,
          statusCode: response.statusCode,
          detail: _extractProviderErrorDetail(rawResponse),
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

      final Object? decoded = _safeJsonDecode(payload);
      if (decoded is! Map) {
        throw AiTurnException(
          userMessage: _providerUnexpectedFormat(language),
          rawResponse: payload,
          recoverable: true,
        );
      }

      final Map<String, Object?> decodedMap = _jsonMap(decoded);
      responseHitTokenLimit =
          responseHitTokenLimit || _responseHitTokenLimit(decodedMap);
      final String chunk = _extractStreamChunk(decodedMap);
      if (chunk.isEmpty) {
        return;
      }

      final String mergedContent = _mergeStreamChunk(
        existing: rawContent.toString(),
        incoming: chunk,
      );
      rawContent
        ..clear()
        ..write(mergedContent);
      final String? preview = extractNarrationPreview(
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
        userMessage: _providerUnexpectedFormat(language),
        rawResponse: rawContent.toString(),
        recoverable: true,
      );
    }
    client.close();

    final String rawResponse = rawContent.toString().trim();
    if (rawResponse.isEmpty) {
      throw AiTurnException(
        userMessage: _providerNoChoices(language),
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
      final int nextMaxTokens = _expandedMaxTokens(currentMaxTokens);
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

    final TurnResult result = _parseRawTurnContent(
      rawContent: rawResponse,
      language: language,
    );
    if (result.narration.trim().isNotEmpty && result.narration != lastPreview) {
      onNarrationDelta(result.narration);
    }
    return result;
  }

  bool _shouldUseFastMode(final AiSettings settings) => false;

  bool _supportsStreaming(final AiSettings settings) => true;

  bool _shouldRetryWithoutFastMode(
    final AiSettings settings,
    final AiTurnException error,
  ) => _shouldUseFastMode(settings) && error.recoverable;

  @visibleForTesting
  Map<String, Object?> buildPromptRequestBody({
    required final AiSettings settings,
    required final AppLanguage language,
    required final String metaPrompt,
    final int? maxTokensOverride,
  }) => <String, Object?>{
    'model': settings.model,
    'temperature': 0.5,
    'max_tokens': maxTokensOverride ?? settings.maxResponseTokens,
    'messages': <Map<String, String>>[
      <String, String>{
        'role': 'system',
        'content': switch (language) {
          AppLanguage.ru => 'Ты помощник. Отвечай только валидным JSON.',
          AppLanguage.en => 'You are a helper. Reply only with valid JSON.',
        },
      },
      <String, String>{'role': 'user', 'content': metaPrompt},
    ],
  };

  @visibleForTesting
  Map<String, Object?> buildTurnRequestBody({
    required final AiSettings settings,
    required final AppLanguage language,
    required final CampaignState state,
    required final String playerAction,
    required final bool suggestionsOnly,
    required final DeterministicTurnContext deterministicContext,
    required final bool fastMode,
    final int? maxTokensOverride,
    final bool stream = false,
  }) => <String, Object?>{
    'model': settings.model,
    'temperature': fastMode ? 0.2 : 0.7,
    'max_tokens': maxTokensOverride ?? settings.maxResponseTokens,
    if (stream) 'stream': true,
    'messages': <Map<String, String>>[
      <String, String>{
        'role': 'system',
        'content': _turnPromptBuilder.buildSystemPrompt(
          language: language,
          state: state,
          suggestionsOnly: suggestionsOnly,
          deterministicContext: deterministicContext,
          fastMode: fastMode,
          confirmed18Plus: settings.confirmed18Plus,
        ),
      },
      <String, String>{
        'role': 'user',
        'content': _turnPromptBuilder.buildUserPrompt(
          language: language,
          state: state,
          playerAction: playerAction,
          deterministicContext: deterministicContext,
          fastMode: fastMode,
          contextWindowSize: settings.contextWindowSize,
        ),
      },
    ],
  };

  int _effectiveTimeoutSeconds(final AiSettings settings) =>
      settings.timeoutSeconds;

  Map<String, String> _headers(final AiSettings settings) {
    final Map<String, String> headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (settings.apiKey.trim().isNotEmpty) {
      headers['Authorization'] = 'Bearer ${settings.apiKey.trim()}';
    }
    return headers;
  }

  String _normalizedBaseUrl(final String baseUrl) => baseUrl.endsWith('/')
      ? baseUrl.substring(0, baseUrl.length - 1)
      : baseUrl;

  String _responseText(final http.Response response) =>
      utf8.decode(response.bodyBytes, allowMalformed: true);

  String? _extractProviderErrorDetail(final String rawResponse) {
    final Object? decoded = _safeJsonDecode(rawResponse);
    if (decoded is! Map) {
      return null;
    }

    final Map<String, Object?> map = _jsonMap(decoded);
    final Map<String, Object?> error = _jsonMap(map['error']);
    final String message = _stringValue(error['message']).trim().isNotEmpty
        ? _stringValue(error['message']).trim()
        : _stringValue(map['message']).trim();
    final String code = _stringValue(error['code']).trim();

    if (message.isEmpty && code.isEmpty) {
      return null;
    }
    if (message.isNotEmpty && code.isNotEmpty) {
      return '$message ($code)';
    }
    return message.isNotEmpty ? message : code;
  }

  String _providerLabel(
    final AiSettings settings,
    final AppLanguage language,
  ) => 'AI endpoint';

  String _friendlyAiEndpointError({
    required final AiSettings settings,
    required final AppLanguage language,
    required final int statusCode,
    required final String? detail,
  }) {
    final String provider = _providerLabel(settings, language);
    final String suffix = switch (language) {
      AppLanguage.ru => '?????????????????? ???????????????? ???? ????????????????.',
      AppLanguage.en => 'The campaign state was not changed.',
    };
    final String detailText = detail == null || detail.isEmpty
        ? ''
        : ' $detail';

    return switch (language) {
      AppLanguage.ru =>
        '$provider ???????????? ???????????? $statusCode.$detailText $suffix',
      AppLanguage.en =>
        '$provider returned error $statusCode.$detailText $suffix',
    };
  }

  String _timeoutError({
    required final AiSettings settings,
    required final AppLanguage language,
  }) {
    final String provider = _providerLabel(settings, language);
    final int seconds = _effectiveTimeoutSeconds(settings);

    return switch (language) {
      AppLanguage.ru =>
        '$provider ???? ?????????????? ???? $seconds ??????. ???????????????? ?????????????????? ?????????????? ?? ????????????????????.',
      AppLanguage.en =>
        '$provider did not respond within $seconds seconds. Try increasing the timeout in settings.',
    };
  }

  // ignore: unused_element
  String _systemPrompt({
    required final AppLanguage language,
    required final CampaignState state,
    required final bool suggestionsOnly,
    required final DeterministicTurnContext deterministicContext,
    required final bool fastMode,
    required final bool confirmed18Plus,
  }) {
    final String fastPrefix = fastMode ? '/no_think\n' : '';
    final String contentRule = confirmed18Plus
        ? ''
        : switch (language) {
            AppLanguage.ru =>
              '\nВажно: избегай сексуального и откровенного контента. Повествование должно быть подходящим для общей аудитории.\n',
            AppLanguage.en =>
              '\nImportant: avoid sexual or explicit adult content. Keep narration suitable for general audiences.\n',
          };
    final String deterministicRule =
        !suggestionsOnly && deterministicContext.hasResolvedCheck
        ? switch (language) {
            AppLanguage.ru =>
              '\nВ контексте может прийти deterministic_resolution. Это уже разрешённый на клиенте исход проверки. Не перебрасывай кубик, не меняй и не оспаривай этот результат.\n',
            AppLanguage.en =>
              '\nIf deterministic_resolution appears in the campaign context, it was already resolved on the client. Do not reroll it, change it, or contradict it.\n',
          }
        : '';

    String base = '';
    if (suggestionsOnly) {
      base = switch (language) {
        AppLanguage.ru =>
          '''
$fastPrefixТы повествовательный ИИ для детерминированной RPG.
Отвечай только JSON с ключами: narration, choices, state_changes, memory_entry.
Все тексты, narration, choices и memory_entry пиши только на русском языке.
Для режима подсказок:
- narration должен быть коротким продолжением сцены
- choices: не более 3 вариантов, каждый 2–3 слова (например: «Бежать», «Атаковать», «Договориться»)
- state_changes должен содержать нулевые изменения и пустые списки
- memory_entry должен быть кратким
Не добавляй markdown или пояснения вне JSON.
''',
        AppLanguage.en =>
          '''
${fastPrefix}You are a narrative AI for a deterministic RPG.
Reply only with JSON using the keys: narration, choices, state_changes, memory_entry.
Write all texts, narration, choices, and memory_entry only in English.
For suggestion mode:
- narration must be a short continuation of the scene
- choices: up to 3 options, each 2–3 words max (e.g. "Run away", "Attack", "Negotiate")
- state_changes must contain zero deltas and empty lists
- memory_entry must be brief
Do not add markdown or explanations outside JSON.
''',
      };
    } else {
      base = switch (language) {
        AppLanguage.ru =>
          '''
$fastPrefixТы повествовательный ИИ для детерминированной RPG.
Отвечай только JSON с ключами: narration, choices, state_changes, memory_entry.
Все тексты, narration, choices, questNote, location и memory_entry пиши только на русском языке.
Правила:
- narration: 1-2 абзаца. Включай атмосферу сцены, эмоции персонажей, короткие диалоги в потоке, сенсорные детали (звук, свет, запах) в меру.
- choices: не более 3 вариантов, каждый 2–3 слова
- state_changes: { "hpDelta": int, "energyDelta": int, "inventoryAdd": [string], "inventoryRemove": [string], "questNote": string, "location": string }
- location в state_changes: укажи текущую локацию (особенно важно в первом ходе). Если локация не меняется, оставь пустым "".
- изменения должны быть умеренными для MVP
- не ломай целостность мира
- не добавляй markdown fences
''',
        AppLanguage.en =>
          '''
${fastPrefix}You are a narrative AI for a deterministic RPG.
Reply only with JSON using the keys: narration, choices, state_changes, memory_entry.
Write all texts, narration, choices, questNote, location, and memory_entry only in English.
Rules:
- narration: 1-2 paragraphs. Include scene atmosphere, character emotions, short in-flow dialogues, sensory details (sound, light, smell) in moderation.
- choices: up to 3 options, each 2–3 words max
- state_changes: { "hpDelta": int, "energyDelta": int, "inventoryAdd": [string], "inventoryRemove": [string], "questNote": string, "location": string }
- choices must be plain visible button labels only
- location in state_changes: specify current location (especially important on first turn). If location doesn't change, leave empty "".
- changes must stay moderate for the MVP
- do not break world continuity
- if deterministic_resolution is present in the campaign context, it is already resolved on the client; do not reroll it or contradict it
- do not add markdown fences
''',
      };
    }

    final List<String> parts = <String>[base, contentRule, deterministicRule];
    if (state.customStoryPrompt.trim().isNotEmpty) {
      parts.add(
        '\n\n--- Story context ---\n${state.customStoryPrompt.trim()}\n',
      );
    }
    if (state.characterPrompt.trim().isNotEmpty) {
      parts.add('\n\n--- Character ---\n${state.characterPrompt.trim()}\n');
    }
    return parts.join();
  }

  // ignore: unused_element
  String _userPrompt({
    required final AppLanguage language,
    required final CampaignState state,
    required final String playerAction,
    required final DeterministicTurnContext deterministicContext,
    required final bool fastMode,
    required final int contextWindowSize,
  }) {
    final Map<String, Object?> contextPayload = fastMode
        ? _memoryManager.buildFastAiContext(
            state,
            contextWindowSize: contextWindowSize,
          )
        : _memoryManager.buildAiContext(
            state,
            contextWindowSize: contextWindowSize,
          );
    if (deterministicContext.hasResolvedCheck) {
      contextPayload['deterministic_resolution'] = deterministicContext
          .toJson();
    }

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
${jsonEncode(contextPayload)}

Действие игрока:
$actionText
''',
      AppLanguage.en =>
        '''
Campaign context:
${jsonEncode(contextPayload)}

Player action:
$actionText
''',
    };
  }

  Object? _safeJsonDecode(final String raw) {
    try {
      return jsonDecode(raw);
    } catch (error) {
      debugPrint('JSON decode failed: $error');
      return null;
    }
  }

  String _extractJson(final String raw, final AppLanguage language) {
    final String trimmed = raw.trim();
    if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
      return trimmed;
    }

    final int start = trimmed.indexOf('{');
    final int end = trimmed.lastIndexOf('}');
    if (start == -1 || end == -1 || end <= start) {
      throw AiTurnException(
        userMessage: _modelDidNotReturnJson(language),
        rawResponse: raw,
        recoverable: true,
      );
    }
    return trimmed.substring(start, end + 1);
  }

  TurnResult _parseTurnResponse({
    required final String rawResponse,
    required final Map<String, Object?> responseMap,
    required final AppLanguage language,
  }) {
    final List<Object?> choices = _jsonList(responseMap['choices']);
    if (choices.isEmpty) {
      final AiTurnException exception = AiTurnException(
        userMessage: _providerNoChoices(language),
        rawResponse: rawResponse,
        recoverable: true,
      );
      AppLogger.logAiError(
        message: 'Provider returned empty choices array',
        exception: exception,
      );
      throw exception;
    }

    final Map<String, Object?> choice = _jsonMap(choices.first);
    final String content = _extractChoiceContent(choice).trim();
    if (content.isEmpty) {
      final String nestedText = _extractResponseLevelText(responseMap).trim();
      if (nestedText.isNotEmpty) {
        return _parseRawTurnContent(rawContent: nestedText, language: language);
      }
    }
    return _parseRawTurnContent(rawContent: content, language: language);
  }

  TurnResult _parseRawTurnContent({
    required final String rawContent,
    required final AppLanguage language,
  }) {
    try {
      final String jsonString = _extractJson(rawContent, language);
      final Object? turnDecoded = _safeJsonDecode(jsonString);
      if (turnDecoded is Map) {
        final Map<String, Object?> turnMap = _jsonMap(turnDecoded);
        if (_hasMeaningfulTurnPayload(turnMap)) {
          return TurnResult.fromJson(turnMap);
        }
      }
    } on AiTurnException {
      // Fall back to heuristic parsing for providers that ignore structured output.
    }

    final TurnResult? structuredRecovery = _recoverTurnResultFromStructuredText(
      rawContent: rawContent,
      language: language,
    );
    if (structuredRecovery != null) {
      return structuredRecovery;
    }

    final TurnResult? recovered = _recoverTurnResultFromPlainText(
      rawContent: rawContent,
      language: language,
    );
    if (recovered != null) {
      return recovered;
    }

    final AiTurnException exception = AiTurnException(
      userMessage: _invalidJson(language),
      rawResponse: rawContent,
      recoverable: true,
    );
    AppLogger.logAiError(
      message: 'Model returned invalid JSON structure',
      exception: exception,
    );
    throw exception;
  }

  TurnResult? _recoverTurnResultFromPlainText({
    required final String rawContent,
    required final AppLanguage language,
  }) {
    final String cleaned = rawContent
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();
    if (cleaned.isEmpty) {
      return null;
    }
    if (cleaned.startsWith('{') || cleaned.startsWith('[')) {
      return null;
    }

    final List<String> lines = cleaned
        .split(RegExp(r'\r?\n'))
        .map((final item) => item.trim())
        .where((final item) => item.isNotEmpty)
        .toList();
    if (lines.isEmpty) {
      return null;
    }

    final List<String> narrationParts = <String>[];
    final List<String> recoveredChoices = <String>[];
    bool readingChoices = false;

    for (final String line in lines) {
      final String lower = line.toLowerCase();
      final bool isChoicesHeader =
          lower == 'choices:' ||
          lower == 'options:' ||
          lower == 'actions:' ||
          lower == 'варианты:' ||
          lower == 'выбор:' ||
          lower == 'действия:';
      if (isChoicesHeader) {
        readingChoices = true;
        continue;
      }

      final String? normalizedChoice = _normalizeChoiceLine(line);
      if (normalizedChoice != null) {
        recoveredChoices.add(normalizedChoice);
        readingChoices = true;
        continue;
      }

      if (!readingChoices) {
        narrationParts.add(line);
      }
    }

    final String narration = narrationParts.join('\n\n').trim();
    final List<String> choices = recoveredChoices.take(3).toList();
    if (narration.isEmpty && choices.isEmpty) {
      return null;
    }

    final List<String> fallbackChoices = choices.isNotEmpty
        ? choices
        : switch (language) {
            AppLanguage.ru => const <String>[
              'Осмотреться',
              'Действовать осторожно',
              'Сделать шаг',
            ],
            AppLanguage.en => const <String>[
              'Look around',
              'Move carefully',
              'Take action',
            ],
          };

    final String resolvedNarration = narration.isNotEmpty
        ? narration
        : switch (language) {
            AppLanguage.ru => 'История продолжается.',
            AppLanguage.en => 'The story continues.',
          };

    return TurnResult(
      narration: resolvedNarration,
      choices: fallbackChoices,
      stateChanges: const StateChanges.empty(),
      memoryEntry: resolvedNarration,
    );
  }

  TurnResult? _recoverTurnResultFromStructuredText({
    required final String rawContent,
    required final AppLanguage language,
  }) {
    final String cleaned = rawContent
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();
    if (cleaned.isEmpty) {
      return null;
    }

    final String narration = _firstMatchedValue(cleaned, <String>[
      'narration',
      'scene',
      'story',
      'description',
      'text',
      'response',
      'memory_entry',
    ]);
    final String incompleteNarration = _firstTruncatedStringValue(
      cleaned,
      const <String>[
        'narration',
        'scene',
        'story',
        'description',
        'text',
        'response',
      ],
    );
    final String location = _firstMatchedValue(cleaned, <String>[
      'location',
      'current_location',
      'place',
      'scene_location',
    ]);
    final String incompleteLocation = _firstTruncatedStringValue(
      cleaned,
      const <String>['location', 'current_location', 'place', 'scene_location'],
    );
    final List<String> choices = _extractStructuredChoices(cleaned);
    final String resolvedStructuredNarration = narration.isNotEmpty
        ? narration
        : incompleteNarration;
    final String resolvedStructuredLocation = location.isNotEmpty
        ? location
        : incompleteLocation;
    if (resolvedStructuredNarration.isEmpty &&
        resolvedStructuredLocation.isEmpty) {
      return null;
    }

    final List<String> fallbackChoices = choices.isNotEmpty
        ? choices.take(3).toList()
        : switch (language) {
            AppLanguage.ru => const <String>[
              'Осмотреться',
              'Действовать осторожно',
              'Сделать шаг',
            ],
            AppLanguage.en => const <String>[
              'Look around',
              'Move carefully',
              'Take action',
            ],
          };

    final String resolvedNarration = resolvedStructuredNarration.isNotEmpty
        ? resolvedStructuredNarration
        : switch (language) {
            AppLanguage.ru => 'История продолжается.',
            AppLanguage.en => 'The story continues.',
          };

    return TurnResult.fromJson(<String, Object?>{
      'narration': resolvedNarration,
      'choices': fallbackChoices,
      'state_changes': <String, Object?>{
        'location': resolvedStructuredLocation,
      },
      'memory_entry': resolvedNarration,
    });
  }

  List<String> _extractStructuredChoices(final String rawContent) {
    final RegExp arrayPattern = RegExp(
      r'"(?:choices|options|actions|variants)"\s*:\s*\[(.*?)\]',
      dotAll: true,
    );
    final Match? match = arrayPattern.firstMatch(rawContent);
    if (match == null) {
      return const <String>[];
    }

    final String body = match.group(1) ?? '';
    final RegExp stringPattern = RegExp(r'"((?:\\.|[^"\\])*)"');
    final List<String> directStrings = stringPattern
        .allMatches(body)
        .map((final item) => _unescapeJsonString(item.group(1) ?? ''))
        .where((final item) => item.trim().isNotEmpty)
        .toList();

    final List<String> labels = <String>[];
    for (int i = 0; i < directStrings.length; i++) {
      final String current = directStrings[i];
      if (current == 'label' ||
          current == 'title' ||
          current == 'text' ||
          current == 'choice' ||
          current == 'name') {
        if (i + 1 < directStrings.length) {
          labels.add(directStrings[i + 1].trim());
        }
      }
    }

    if (labels.isNotEmpty) {
      return labels;
    }
    return directStrings;
  }

  String _firstMatchedValue(final String rawContent, final List<String> keys) {
    for (final String key in keys) {
      final RegExp pattern = RegExp(
        '"${RegExp.escape(key)}"\\s*:\\s*(?:"((?:\\\\.|[^"\\\\])*)"|\\{[^\\}]*"text"\\s*:\\s*"((?:\\\\.|[^"\\\\])*)")',
        dotAll: true,
      );
      final Match? match = pattern.firstMatch(rawContent);
      if (match == null) {
        continue;
      }
      final String resolved = _unescapeJsonString(
        match.group(1) ?? match.group(2) ?? '',
      ).trim();
      if (resolved.isNotEmpty) {
        return resolved;
      }
    }
    return '';
  }

  String _firstTruncatedStringValue(
    final String rawContent,
    final List<String> keys,
  ) {
    for (final String key in keys) {
      final String resolved = _extractTruncatedStringField(rawContent, key);
      if (resolved.trim().isNotEmpty) {
        return resolved.trimRight();
      }
    }
    return '';
  }

  String _extractTruncatedStringField(
    final String rawContent,
    final String key,
  ) {
    final int fieldStart = rawContent.indexOf('"$key"');
    if (fieldStart == -1) {
      return '';
    }

    int index = fieldStart + key.length + 2;
    while (index < rawContent.length &&
        _isWhitespace(rawContent.codeUnitAt(index))) {
      index++;
    }
    if (index >= rawContent.length || rawContent[index] != ':') {
      return '';
    }
    index++;
    while (index < rawContent.length &&
        _isWhitespace(rawContent.codeUnitAt(index))) {
      index++;
    }
    if (index >= rawContent.length || rawContent[index] != '"') {
      return '';
    }
    index++;

    final StringBuffer buffer = StringBuffer();
    while (index < rawContent.length) {
      final String char = rawContent[index];
      if (char == '"') {
        return buffer.toString();
      }
      if (char == r'\') {
        if (index + 1 >= rawContent.length) {
          return buffer.toString();
        }
        final String escape = rawContent[index + 1];
        switch (escape) {
          case '"':
          case r'\':
          case '/':
            buffer.write(escape);
            break;
          case 'b':
            buffer.write('\b');
            break;
          case 'f':
            buffer.write('\f');
            break;
          case 'n':
            buffer.write('\n');
            break;
          case 'r':
            buffer.write('\r');
            break;
          case 't':
            buffer.write('\t');
            break;
          case 'u':
            if (index + 5 >= rawContent.length) {
              return buffer.toString();
            }
            final String codeUnit = rawContent.substring(index + 2, index + 6);
            final int? parsed = int.tryParse(codeUnit, radix: 16);
            if (parsed != null) {
              buffer.writeCharCode(parsed);
              index += 4;
            }
            break;
          default:
            buffer.write(escape);
            break;
        }
        index += 2;
        continue;
      }
      buffer.write(char);
      index++;
    }
    return buffer.toString();
  }

  String _unescapeJsonString(final String value) {
    try {
      return jsonDecode('"$value"') as String;
    } catch (_) {
      return value
          .replaceAll(r'\"', '"')
          .replaceAll(r'\n', '\n')
          .replaceAll(r'\r', '\r')
          .replaceAll(r'\t', '\t');
    }
  }

  String? _normalizeChoiceLine(final String line) {
    final RegExp prefixPattern = RegExp(
      r'^(?:[-*•]|\d+[.)]|[A-Za-zА-Яа-я][.)])\s+',
    );
    if (!prefixPattern.hasMatch(line)) {
      return null;
    }
    final String normalized = line.replaceFirst(prefixPattern, '').trim();
    return normalized.isEmpty ? null : normalized;
  }

  @visibleForTesting
  TurnResult parseTurnContentForTesting({
    required final String rawContent,
    required final AppLanguage language,
  }) => _parseRawTurnContent(rawContent: rawContent, language: language);

  @visibleForTesting
  bool supportsStreamingForTesting(final AiSettings settings) =>
      _supportsStreaming(settings);

  @visibleForTesting
  bool responseHitTokenLimitForTesting(final Map<String, Object?> responseMap) =>
      _responseHitTokenLimit(responseMap);

  @visibleForTesting
  int expandedMaxTokensForTesting(final int currentMaxTokens) =>
      _expandedMaxTokens(currentMaxTokens);

  @visibleForTesting
  String extractChoiceContentForTesting(final Map<String, Object?> choice) =>
      _extractChoiceContent(choice);

  @visibleForTesting
  String mergeStreamChunkForTesting({
    required final String existing,
    required final String incoming,
  }) => _mergeStreamChunk(existing: existing, incoming: incoming);

  bool _responseHitTokenLimit(final Map<String, Object?> responseMap) {
    final List<Object?> choices = _jsonList(responseMap['choices']);
    if (choices.isEmpty) {
      return false;
    }

    for (final Object? rawChoice in choices) {
      final Map<String, Object?> choice = _jsonMap(rawChoice);
      final String finishReason = _normalizedFinishReason(
        choice['finish_reason'] ?? choice['finishReason'],
      );
      if (_isTokenLimitFinishReason(finishReason)) {
        return true;
      }
    }
    return false;
  }

  int _expandedMaxTokens(final int currentMaxTokens) {
    final int cappedCurrent = currentMaxTokens.clamp(
      ModelRuntimeSettings.minMaxResponseTokens,
      ModelRuntimeSettings.maxMaxResponseTokens,
    );
    final int expanded = cappedCurrent * _truncationRetryMultiplier;
    return expanded.clamp(
      ModelRuntimeSettings.minMaxResponseTokens,
      ModelRuntimeSettings.maxMaxResponseTokens,
    );
  }

  String _normalizedFinishReason(final Object? value) =>
      _stringValue(value).trim().toLowerCase();

  bool _isTokenLimitFinishReason(final String finishReason) =>
      finishReason == 'length' ||
      finishReason == 'max_tokens' ||
      finishReason == 'max_output_tokens' ||
      finishReason == 'token_limit' ||
      finishReason == 'model_length';

  bool _hasMeaningfulTurnPayload(final Map<String, Object?> turnMap) {
    final String narration = _extractResponseLevelText(turnMap).trim();
    if (narration.isNotEmpty) {
      return true;
    }
    final String location = _firstMatchedValue(jsonEncode(turnMap), <String>[
      'location',
      'current_location',
      'place',
      'scene_location',
    ]).trim();
    return location.isNotEmpty;
  }

  String _extractResponseLevelText(final Map<String, Object?> map) {
    final String direct = _firstNonEmptyJsonString(map, const <String>[
      'narration',
      'scene',
      'story',
      'description',
      'text',
      'response',
      'memory_entry',
      'memoryEntry',
      'output_text',
      'content',
    ]);
    if (direct.isNotEmpty) {
      return direct;
    }

    final Map<String, Object?> message = _jsonMap(map['message']);
    final String messageContent = _extractMessageContent(message);
    if (messageContent.isNotEmpty) {
      return messageContent;
    }

    final List<Object?> output = _jsonList(map['output']);
    for (final Object? item in output) {
      final Map<String, Object?> outputItem = _jsonMap(item);
      final String itemText = _firstNonEmptyJsonString(outputItem, const <String>[
        'text',
        'content',
        'output_text',
      ]);
      if (itemText.isNotEmpty) {
        return itemText;
      }
      final List<Object?> content = _jsonList(outputItem['content']);
      for (final Object? contentItem in content) {
        final Map<String, Object?> contentMap = _jsonMap(contentItem);
        final String contentText = _firstNonEmptyJsonString(
          contentMap,
          const <String>['text', 'content', 'output_text'],
        );
        if (contentText.isNotEmpty) {
          return contentText;
        }
      }
    }
    return '';
  }

  String _extractChoiceContent(final Map<String, Object?> choice) {
    final Map<String, Object?> message = _jsonMap(choice['message']);
    final String messageContent = _extractMessageContent(message);
    if (messageContent.isNotEmpty) {
      return messageContent;
    }

    final String text = _stringValue(choice['text']).trim();
    if (text.isNotEmpty) {
      return text;
    }

    return _extractResponseLevelText(choice);
  }

  String _extractMessageContent(final Map<String, Object?> message) {
    final List<Object?> contentItems = _jsonList(message['content']);
    if (contentItems.isNotEmpty) {
      final List<String> textParts = <String>[];
      for (final Object? item in contentItems) {
        if (item is String) {
          final String value = item.trim();
          if (value.isNotEmpty) {
            textParts.add(value);
          }
          continue;
        }
        final Map<String, Object?> contentMap = _jsonMap(item);
        final String text = _firstNonEmptyJsonString(
          contentMap,
          const <String>['text', 'content', 'output_text'],
        );
        if (text.isNotEmpty) {
          textParts.add(text);
        }
      }
      return textParts.join('\n').trim();
    }

    final Object? rawContent = message['content'];
    if (rawContent is Map || rawContent is List) {
      return '';
    }

    final String direct = _stringValue(rawContent).trim();
    if (direct.isNotEmpty && direct != '[]' && direct != '{}') {
      return direct;
    }
    return '';
  }

  String _mergeStreamChunk({
    required final String existing,
    required final String incoming,
  }) {
    if (incoming.isEmpty) {
      return existing;
    }
    if (existing.isEmpty) {
      return incoming;
    }
    if (incoming == existing) {
      return existing;
    }
    if (incoming.startsWith(existing)) {
      return incoming;
    }
    if (existing.startsWith(incoming)) {
      return existing;
    }

    final int maxOverlap = existing.length < incoming.length
        ? existing.length
        : incoming.length;
    for (int overlap = maxOverlap; overlap > 0; overlap -= 1) {
      if (existing.endsWith(incoming.substring(0, overlap))) {
        return '$existing${incoming.substring(overlap)}';
      }
    }
    return '$existing$incoming';
  }

  String _firstNonEmptyJsonString(
    final Map<String, Object?> map,
    final List<String> keys,
  ) {
    for (final String key in keys) {
      final Object? value = map[key];
      if (value is Map || value is List) {
        continue;
      }
      final String text = _stringValue(value).trim();
      if (text.isNotEmpty) {
        return text;
      }
    }
    return '';
  }

  String _extractStreamChunk(final Map<String, Object?> event) {
    final List<Object?> choices = _jsonList(event['choices']);
    if (choices.isEmpty) {
      return '';
    }

    final Map<String, Object?> choice = _jsonMap(choices.first);
    final Map<String, Object?> delta = _jsonMap(choice['delta']);
    final String deltaContent = _stringValue(delta['content']);
    if (deltaContent.isNotEmpty) {
      return deltaContent;
    }

    final Map<String, Object?> message = _jsonMap(choice['message']);
    final String messageContent = _stringValue(message['content']);
    if (messageContent.isNotEmpty) {
      return messageContent;
    }

    return _stringValue(choice['text']);
  }

  @visibleForTesting
  String? extractNarrationPreview(final String rawContent) {
    final int fieldStart = rawContent.indexOf('"narration"');
    if (fieldStart == -1) {
      return null;
    }

    int index = fieldStart + '"narration"'.length;
    while (index < rawContent.length &&
        _isWhitespace(rawContent.codeUnitAt(index))) {
      index++;
    }
    if (index >= rawContent.length || rawContent[index] != ':') {
      return null;
    }
    index++;
    while (index < rawContent.length &&
        _isWhitespace(rawContent.codeUnitAt(index))) {
      index++;
    }
    if (index >= rawContent.length || rawContent[index] != '"') {
      return null;
    }
    index++;

    final StringBuffer buffer = StringBuffer();
    while (index < rawContent.length) {
      final String char = rawContent[index];
      if (char == '"') {
        return buffer.toString();
      }
      if (char == r'\') {
        if (index + 1 >= rawContent.length) {
          return buffer.toString();
        }
        final String escape = rawContent[index + 1];
        switch (escape) {
          case '"':
          case r'\':
          case '/':
            buffer.write(escape);
            break;
          case 'b':
            buffer.write('\b');
            break;
          case 'f':
            buffer.write('\f');
            break;
          case 'n':
            buffer.write('\n');
            break;
          case 'r':
            buffer.write('\r');
            break;
          case 't':
            buffer.write('\t');
            break;
          case 'u':
            if (index + 5 >= rawContent.length) {
              return buffer.toString();
            }
            final String hex = rawContent.substring(index + 2, index + 6);
            final int? codePoint = int.tryParse(hex, radix: 16);
            if (codePoint == null) {
              return buffer.toString();
            }
            buffer.write(String.fromCharCode(codePoint));
            index += 4;
            break;
          default:
            buffer.write(escape);
            break;
        }
        index += 2;
        continue;
      }
      buffer.write(char);
      index++;
    }

    return buffer.toString();
  }

  bool _isWhitespace(final int codeUnit) =>
      codeUnit == 0x20 ||
      codeUnit == 0x0A ||
      codeUnit == 0x0D ||
      codeUnit == 0x09;

  // ignore: unused_element
  String _aiEndpointError(
    final AppLanguage language,
    final int statusCode,
  ) => switch (language) {
    AppLanguage.ru =>
      'AI endpoint вернул ошибку $statusCode. Состояние кампании не изменено.',
    AppLanguage.en =>
      'The AI endpoint returned error $statusCode. The campaign state was not changed.',
  };

  String _providerUnexpectedFormat(
    final AppLanguage language,
  ) => switch (language) {
    AppLanguage.ru =>
      'Провайдер вернул неожиданный формат ответа.\n\n'
          'Попробуйте снова. Если проблема повторяется, проверьте настройки ИИ.',
    AppLanguage.en =>
      'The provider returned an unexpected response format.\n\n'
          'Try again. If the problem persists, check AI settings.',
  };

  String _providerNoChoices(final AppLanguage language) => switch (language) {
    AppLanguage.ru =>
      'Провайдер не вернул ни одного варианта ответа.\n\n'
          'Попробуйте снова или проверьте подключение к AI.',
    AppLanguage.en =>
      'The provider returned no answer choices.\n\n'
          'Try again or check your AI connection.',
  };

  String _invalidJson(final AppLanguage language) => switch (language) {
    AppLanguage.ru =>
      'Модель вернула невалидный JSON.\n\n'
          'Обычно это временная проблема. Попробуйте снова.',
    AppLanguage.en =>
      'The model returned invalid JSON.\n\n'
          'This is usually temporary. Try again.',
  };

  String _modelDidNotReturnJson(
    final AppLanguage language,
  ) => switch (language) {
    AppLanguage.ru =>
      'Модель не вернула JSON в ожидаемом формате.\n\n'
          'Попробуйте снова. Если проблема не исчезает, возможно модель не поддерживает structured output.',
    AppLanguage.en =>
      'The model did not return JSON in the expected format.\n\n'
          'Try again. If the problem persists, the model may not support structured output.',
  };
}
