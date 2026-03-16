import 'dart:async';
import 'dart:convert';

import 'package:ai_prg/src/core/models/ai_settings.dart';
import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:ai_prg/src/core/services/ai_client.dart';
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
  }) async {
    if (storyWish.trim().isEmpty) {
      return const GeneratedPrompts(storyPrompt: '', characterPrompt: '');
    }

    final String metaPrompt = switch (language) {
      AppLanguage.ru => '''
Пользователь описывает желаемую историю для narrative RPG: "$storyWish"
Сеттинг: ${setting.name}.

Сгенерируй JSON с двумя ключами:
- storyPrompt: инструкции для narrative AI, как вести именно эту историю (тон, жанр, атмосфера). Максимум 300 слов.
- characterPrompt: краткое описание типа персонажа, подходящего для этой истории. Максимум 100 слов.

Ответь только JSON, без markdown.
''',
      AppLanguage.en => '''
User describes desired story for narrative RPG: "$storyWish"
Setting: ${setting.name}.

Generate JSON with two keys:
- storyPrompt: instructions for narrative AI on how to run this story (tone, genre, atmosphere). Max 300 words.
- characterPrompt: brief description of character type suited for this story. Max 100 words.

Reply only with JSON, no markdown.
''',
    };

    final Uri uri = Uri.parse(
      '${_normalizedBaseUrl(settings.baseUrl)}/chat/completions',
    );
    final Map<String, Object?> requestBody = <String, Object?>{
      'model': settings.model,
      'temperature': 0.5,
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

    try {
      final http.Response response = await http
          .post(uri, headers: _headers(settings), body: jsonEncode(requestBody))
          .timeout(Duration(seconds: _effectiveTimeoutSeconds(settings)));

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
      String characterPrompt = ((parsedMap['characterPrompt'] as String?) ?? '').trim();
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
  }) async {
    try {
      return await _requestTurn(
        settings: settings,
        language: language,
        state: state,
        playerAction: playerAction,
        suggestionsOnly: suggestionsOnly,
        fastMode: _shouldUseFastMode(settings),
      );
    } on AiTurnException catch (error) {
      if (!_shouldRetryWithoutFastMode(settings, error)) {
        rethrow;
      }

      return _requestTurn(
        settings: settings,
        language: language,
        state: state,
        playerAction: playerAction,
        suggestionsOnly: suggestionsOnly,
        fastMode: false,
      );
    }
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
    final Map<String, Object?> requestBody = <String, Object?>{
      'model': settings.model,
      'temperature': fastMode ? 0.2 : 0.7,
      'messages': <Map<String, String>>[
        <String, String>{
          'role': 'system',
          'content': _systemPrompt(
            language: language,
            state: state,
            suggestionsOnly: suggestionsOnly,
            fastMode: fastMode,
          ),
        },
        <String, String>{
          'role': 'user',
          'content': _userPrompt(
            language: language,
            state: state,
            playerAction: playerAction,
            fastMode: fastMode,
          ),
        },
      ],
    };

    final http.Response response;
    try {
      response = await http
          .post(uri, headers: _headers(settings), body: jsonEncode(requestBody))
          .timeout(Duration(seconds: _effectiveTimeoutSeconds(settings)));
    } on TimeoutException {
      throw AiTurnException(
        userMessage: _timeoutError(settings: settings, language: language),
        recoverable: true,
      );
    }

    final String rawResponse = _responseText(response);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AiTurnException(
        userMessage: _friendlyAiEndpointError(
          settings: settings,
          language: language,
          statusCode: response.statusCode,
          detail: _extractProviderErrorDetail(rawResponse),
        ),
        rawResponse: rawResponse,
        recoverable: true,
      );
    }

    final Object? decoded = _safeJsonDecode(rawResponse);
    if (decoded is! Map) {
      throw AiTurnException(
        userMessage: _providerUnexpectedFormat(language),
        rawResponse: rawResponse,
        recoverable: true,
      );
    }

    final Map<String, Object?> decodedMap = _jsonMap(decoded);
    final List<Object?> choices = _jsonList(decodedMap['choices']);
    if (choices.isEmpty) {
      throw AiTurnException(
        userMessage: _providerNoChoices(language),
        rawResponse: rawResponse,
        recoverable: true,
      );
    }

    final Map<String, Object?> choice = _jsonMap(choices.first);
    final Map<String, Object?> message = _jsonMap(choice['message']);
    final String content = (message['content'] as String?) ?? '';
    final String jsonString = _extractJson(content, language);
    final Object? turnDecoded = _safeJsonDecode(jsonString);
    if (turnDecoded is! Map) {
      throw AiTurnException(
        userMessage: _invalidJson(language),
        rawResponse: content,
        recoverable: true,
      );
    }

    return TurnResult.fromJson(_jsonMap(turnDecoded));
  }

  bool _shouldUseFastMode(final AiSettings settings) =>
      settings.provider == AiProviderType.lmStudio && settings.fastResponses;

  bool _shouldRetryWithoutFastMode(
    final AiSettings settings,
    final AiTurnException error,
  ) =>
      _shouldUseFastMode(settings) && error.recoverable;

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
    final String message = (error['message'] as String?)?.trim() ??
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

  String _providerLabel(final AiSettings settings, final AppLanguage language) =>
      switch ((settings.provider, language)) {
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
    final String detailText = detail == null || detail.isEmpty ? '' : ' $detail';

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
  }) {
    final String fastPrefix = fastMode ? '/no_think\n' : '';

    String base = '';
    if (suggestionsOnly) {
      base = switch (language) {
        AppLanguage.ru => '''
$fastPrefixТы повествовательный ИИ для детерминированной RPG.
Отвечай только JSON с ключами: narration, choices, state_changes, memory_entry.
Все тексты, narration, choices и memory_entry пиши только на русском языке.
Для режима подсказок:
- narration должен быть коротким продолжением сцены
- choices должны содержать не более 3 конкретных действий игрока
- state_changes должен содержать нулевые изменения и пустые списки
- memory_entry должен быть кратким
Не добавляй markdown или пояснения вне JSON.
''',
        AppLanguage.en => '''
${fastPrefix}You are a narrative AI for a deterministic RPG.
Reply only with JSON using the keys: narration, choices, state_changes, memory_entry.
Write all texts, narration, choices, and memory_entry only in English.
For suggestion mode:
- narration must be a short continuation of the scene
- choices must contain up to 3 concrete player actions
- state_changes must contain zero deltas and empty lists
- memory_entry must be brief
Do not add markdown or explanations outside JSON.
''',
      };
    } else {
      base = switch (language) {
        AppLanguage.ru => '''
$fastPrefixТы повествовательный ИИ для детерминированной RPG.
Отвечай только JSON с ключами: narration, choices, state_changes, memory_entry.
Все тексты, narration, choices, questNote и memory_entry пиши только на русском языке.
Правила:
- narration: 1-2 абзаца. Включай атмосферу сцены, эмоции персонажей, короткие диалоги в потоке, сенсорные детали (звук, свет, запах) в меру.
- choices: не более 3 коротких вариантов действий
- state_changes: { "hpDelta": int, "energyDelta": int, "inventoryAdd": [string], "inventoryRemove": [string], "questNote": string }
- изменения должны быть умеренными для MVP
- не ломай целостность мира
- не добавляй markdown fences
''',
        AppLanguage.en => '''
${fastPrefix}You are a narrative AI for a deterministic RPG.
Reply only with JSON using the keys: narration, choices, state_changes, memory_entry.
Write all texts, narration, choices, questNote, and memory_entry only in English.
Rules:
- narration: 1-2 paragraphs. Include scene atmosphere, character emotions, short in-flow dialogues, sensory details (sound, light, smell) in moderation.
- choices: up to 3 short action options
- state_changes: { "hpDelta": int, "energyDelta": int, "inventoryAdd": [string], "inventoryRemove": [string], "questNote": string }
- changes must stay moderate for the MVP
- do not break world continuity
- do not add markdown fences
''',
      };
    }

    final List<String> parts = <String>[base];
    if (state.customStoryPrompt.trim().isNotEmpty) {
      parts.add('\n\n--- Story context ---\n${state.customStoryPrompt.trim()}\n');
    }
    if (state.characterPrompt.trim().isNotEmpty) {
      parts.add('\n\n--- Character ---\n${state.characterPrompt.trim()}\n');
    }
    return parts.join('');
  }

  String _userPrompt({
    required final AppLanguage language,
    required final CampaignState state,
    required final String playerAction,
    required final bool fastMode,
  }) {
    final Map<String, Object?> contextPayload = fastMode
        ? _memoryManager.buildFastAiContext(state)
        : _memoryManager.buildAiContext(state);

    return switch (language) {
      AppLanguage.ru => '''
Контекст кампании:
${jsonEncode(contextPayload)}

Действие игрока:
$playerAction
''',
      AppLanguage.en => '''
Campaign context:
${jsonEncode(contextPayload)}

Player action:
$playerAction
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
  String _aiEndpointError(final AppLanguage language, final int statusCode) =>
      switch (language) {
        AppLanguage.ru =>
          'AI endpoint вернул ошибку $statusCode. Состояние кампании не изменено.',
        AppLanguage.en =>
          'The AI endpoint returned error $statusCode. The campaign state was not changed.',
      };

  String _providerUnexpectedFormat(final AppLanguage language) =>
      switch (language) {
        AppLanguage.ru =>
          'Провайдер вернул неожиданный формат ответа. Состояние кампании не изменено.',
        AppLanguage.en =>
          'The provider returned an unexpected response format. The campaign state was not changed.',
      };

  String _providerNoChoices(final AppLanguage language) => switch (language) {
    AppLanguage.ru =>
      'Провайдер не вернул ни одного варианта ответа. Состояние кампании не изменено.',
    AppLanguage.en =>
      'The provider returned no answer choices. The campaign state was not changed.',
  };

  String _invalidJson(final AppLanguage language) => switch (language) {
    AppLanguage.ru =>
      'Модель вернула невалидный JSON. Состояние кампании не изменено.',
    AppLanguage.en =>
      'The model returned invalid JSON. The campaign state was not changed.',
  };

  String _modelDidNotReturnJson(final AppLanguage language) =>
      switch (language) {
        AppLanguage.ru =>
          'Модель не вернула JSON в ожидаемом формате. Состояние кампании не изменено.',
        AppLanguage.en =>
          'The model did not return JSON in the expected format. The campaign state was not changed.',
      };
}
