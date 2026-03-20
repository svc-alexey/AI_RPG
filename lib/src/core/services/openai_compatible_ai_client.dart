import 'dart:async';
import 'dart:convert';

import 'package:ai_prg/src/core/models/ai_settings.dart';
import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:ai_prg/src/core/services/ai_client.dart';
import 'package:ai_prg/src/core/services/app_logger.dart';
import 'package:ai_prg/src/core/services/campaign_memory_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class OpenAiCompatibleAiClient implements AiClient {
  const OpenAiCompatibleAiClient();

  static const CampaignMemoryManager _memoryManager = CampaignMemoryManager();

  Map<String, Object?> _jsonMap(final Object? value) {
    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), item));
    }
    return const <String, Object?>{};
  }

  List<Object?> _jsonList(final Object? value) =>
      value is List ? List<Object?>.from(value) : const <Object?>[];

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
      final String content = (message['content'] as String?) ?? '';
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
      String storyPrompt = ((parsedMap['storyPrompt'] as String?) ?? '').trim();
      if (storyPrompt.length > _maxCustomPromptLength) {
        storyPrompt = storyPrompt.substring(0, _maxCustomPromptLength);
      }
      String characterPrompt = ((parsedMap['characterPrompt'] as String?) ?? '')
          .trim();
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
  Future<TurnResult> generateTurn({
    required final AiSettings settings,
    required final AppLanguage language,
    required final CampaignState state,
    required final String playerAction,
    required final bool suggestionsOnly,
    final CancelToken? cancelToken,
  }) async {
    const int maxAttempts = 3;
    const List<int> backoffMs = [0, 2000, 5000]; // 0s, 2s, 5s

    int attemptCount = 0;

    while (attemptCount < maxAttempts) {
      try {
        // Задержка перед retry (не на первой попытке)
        if (attemptCount > 0) {
          AppLogger.instance.i(
            'Retry attempt $attemptCount/$maxAttempts after ${backoffMs[attemptCount]}ms',
          );
          await Future<void>.delayed(
            Duration(milliseconds: backoffMs[attemptCount]),
          );
        }

        final Future<TurnResult> turnFuture = _requestTurn(
          settings: settings,
          language: language,
          state: state,
          playerAction: playerAction,
          suggestionsOnly: suggestionsOnly,
          fastMode: _shouldUseFastMode(settings),
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
            fastMode: false,
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
          );
          rethrow;
        }

        AppLogger.instance.w(
          'Recoverable error, will retry: ${error.userMessage}',
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
    required final bool fastMode,
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
      fastMode: fastMode,
    );

    AppLogger.logAiRequest(
      endpoint: uri.toString(),
      requestBody: requestBody,
      settings: settings,
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
      );
      throw exception;
    }

    final String rawResponse = _responseText(response);

    AppLogger.logAiResponse(
      endpoint: uri.toString(),
      statusCode: response.statusCode,
      rawResponse: rawResponse,
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
      );
      throw exception;
    }

    final Map<String, Object?> decodedMap = _jsonMap(decoded);
    final List<Object?> choices = _jsonList(decodedMap['choices']);
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
    final Map<String, Object?> message = _jsonMap(choice['message']);
    final String content = (message['content'] as String?) ?? '';
    final String jsonString = _extractJson(content, language);
    final Object? turnDecoded = _safeJsonDecode(jsonString);
    if (turnDecoded is! Map) {
      final AiTurnException exception = AiTurnException(
        userMessage: _invalidJson(language),
        rawResponse: content,
        recoverable: true,
      );
      AppLogger.logAiError(
        message: 'Model returned invalid JSON structure',
        exception: exception,
      );
      throw exception;
    }

    return TurnResult.fromJson(_jsonMap(turnDecoded));
  }

  bool _shouldUseFastMode(final AiSettings settings) =>
      settings.provider == AiProviderType.lmStudio && settings.fastResponses;

  bool _shouldRetryWithoutFastMode(
    final AiSettings settings,
    final AiTurnException error,
  ) => _shouldUseFastMode(settings) && error.recoverable;

  @visibleForTesting
  Map<String, Object?> buildPromptRequestBody({
    required final AiSettings settings,
    required final AppLanguage language,
    required final String metaPrompt,
  }) => <String, Object?>{
    'model': settings.model,
    'temperature': 0.5,
    'max_tokens': settings.maxResponseTokens,
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
    required final bool fastMode,
  }) => <String, Object?>{
    'model': settings.model,
    'temperature': fastMode ? 0.2 : 0.7,
    'max_tokens': settings.maxResponseTokens,
    'messages': <Map<String, String>>[
      <String, String>{
        'role': 'system',
        'content': _systemPrompt(
          language: language,
          state: state,
          suggestionsOnly: suggestionsOnly,
          fastMode: fastMode,
          confirmed18Plus: settings.confirmed18Plus,
        ),
      },
      <String, String>{
        'role': 'user',
        'content': _userPrompt(
          language: language,
          state: state,
          playerAction: playerAction,
          fastMode: fastMode,
          contextWindowSize: settings.contextWindowSize,
        ),
      },
    ],
  };

  int _effectiveTimeoutSeconds(final AiSettings settings) {
    if (settings.provider == AiProviderType.openRouter &&
        settings.timeoutSeconds < 120) {
      return 120;
    }
    return settings.timeoutSeconds;
  }

  Map<String, String> _headers(final AiSettings settings) {
    final Map<String, String> headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (settings.apiKey.trim().isNotEmpty) {
      headers['Authorization'] = 'Bearer ${settings.apiKey.trim()}';
    }
    if (settings.provider == AiProviderType.openRouter) {
      headers['HTTP-Referer'] = 'https://ai-prg.local';
      headers['X-Title'] = 'AI PRG';
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
    final String message =
        (error['message'] as String?)?.trim() ??
        (map['message'] as String?)?.trim() ??
        '';
    final String code = (error['code'] as String?)?.trim() ?? '';

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
  ) => switch ((settings.provider, language)) {
    (AiProviderType.deepSeek, _) => 'DeepSeek',
    (AiProviderType.openRouter, _) => 'OpenRouter',
    (AiProviderType.lmStudio, _) => 'LM Studio',
    (AiProviderType.openAiCompatible, AppLanguage.ru) => 'AI endpoint',
    (AiProviderType.openAiCompatible, AppLanguage.en) => 'AI endpoint',
  };

  String _friendlyAiEndpointError({
    required final AiSettings settings,
    required final AppLanguage language,
    required final int statusCode,
    required final String? detail,
  }) {
    final String provider = _providerLabel(settings, language);
    final String suffix = switch (language) {
      AppLanguage.ru => 'Состояние кампании не изменено.',
      AppLanguage.en => 'The campaign state was not changed.',
    };
    final String detailText = detail == null || detail.isEmpty
        ? ''
        : ' $detail';

    if (settings.provider == AiProviderType.deepSeek && statusCode == 402) {
      return switch (language) {
        AppLanguage.ru =>
          '$provider вернул 402. Обычно это означает, что на аккаунте нет баланса или не включён биллинг.$detailText $suffix',
        AppLanguage.en =>
          '$provider returned 402. This usually means your account has no balance or billing is not enabled.$detailText $suffix',
      };
    }

    return switch (language) {
      AppLanguage.ru =>
        '$provider вернул ошибку $statusCode.$detailText $suffix',
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

    if (settings.provider == AiProviderType.openRouter) {
      return switch (language) {
        AppLanguage.ru =>
          '$provider не ответил за $seconds сек. У OpenRouter бесплатные модели часто отвечают медленно или стоят в очереди. Попробуй подождать, увеличить таймаут в настройках или выбрать другую модель.',
        AppLanguage.en =>
          '$provider did not respond within $seconds seconds. Free OpenRouter models are often slow or queued. Try waiting longer, increasing the timeout, or choosing another model.',
      };
    }

    return switch (language) {
      AppLanguage.ru =>
        '$provider не ответил за $seconds сек. Попробуй увеличить таймаут в настройках.',
      AppLanguage.en =>
        '$provider did not respond within $seconds seconds. Try increasing the timeout in settings.',
    };
  }

  String _systemPrompt({
    required final AppLanguage language,
    required final CampaignState state,
    required final bool suggestionsOnly,
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
- location in state_changes: specify current location (especially important on first turn). If location doesn't change, leave empty "".
- changes must stay moderate for the MVP
- do not break world continuity
- do not add markdown fences
''',
      };
    }

    final List<String> parts = <String>[base, contentRule];
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

  String _userPrompt({
    required final AppLanguage language,
    required final CampaignState state,
    required final String playerAction,
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
