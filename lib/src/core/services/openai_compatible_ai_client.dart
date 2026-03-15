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

  @override
  Future<void> checkConnection({required final AiSettings settings}) async {
    final Uri uri = Uri.parse('${_normalizedBaseUrl(settings.baseUrl)}/models');
    final http.Response response = await http
        .get(uri, headers: _headers(settings))
        .timeout(Duration(seconds: settings.timeoutSeconds));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw const AiTurnException(
        userMessage: 'Could not connect to the AI endpoint.',
      );
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

    if (fastMode) {
      requestBody['response_format'] = _responseFormatSchema(
        suggestionsOnly: suggestionsOnly,
      );
    }

    final http.Response response = await http
        .post(uri, headers: _headers(settings), body: jsonEncode(requestBody))
        .timeout(Duration(seconds: settings.timeoutSeconds));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AiTurnException(
        userMessage: _aiEndpointError(language, response.statusCode),
        rawResponse: response.body,
        recoverable: true,
      );
    }

    final Object? decoded = _safeJsonDecode(response.body);
    if (decoded is! Map<String, Object?>) {
      throw AiTurnException(
        userMessage: _providerUnexpectedFormat(language),
        rawResponse: response.body,
        recoverable: true,
      );
    }

    final List<Object?> choices =
        (decoded['choices'] as List<Object?>?) ?? const <Object?>[];
    if (choices.isEmpty) {
      throw AiTurnException(
        userMessage: _providerNoChoices(language),
        rawResponse: response.body,
        recoverable: true,
      );
    }

    final Map<String, Object?> choice =
        choices.first as Map<String, Object?>? ?? const <String, Object?>{};
    final Map<String, Object?> message =
        choice['message'] as Map<String, Object?>? ?? const <String, Object?>{};
    final String content = (message['content'] as String?) ?? '';
    final String jsonString = fastMode
        ? content.trim()
        : _extractJson(content, language);
    final Object? turnDecoded = _safeJsonDecode(jsonString);
    if (turnDecoded is! Map<String, Object?>) {
      throw AiTurnException(
        userMessage: _invalidJson(language),
        rawResponse: content,
        recoverable: true,
      );
    }

    return TurnResult.fromJson(turnDecoded);
  }

  bool _shouldUseFastMode(final AiSettings settings) =>
      settings.provider == AiProviderType.lmStudio && settings.fastResponses;

  bool _shouldRetryWithoutFastMode(
    final AiSettings settings,
    final AiTurnException error,
  ) =>
      _shouldUseFastMode(settings) && error.recoverable;

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

  String _systemPrompt({
    required final AppLanguage language,
    required final bool suggestionsOnly,
    required final bool fastMode,
  }) {
    final String fastPrefix = fastMode ? '/no_think\n' : '';

    if (suggestionsOnly) {
      return switch (language) {
        AppLanguage.ru => '''
${fastPrefix}Ты повествовательный ИИ для детерминированной RPG.
Отвечай только строгим JSON с ключами: narration, choices, state_changes, memory_entry.
Все тексты, narration, choices и memory_entry пиши только на русском языке.
Для режима подсказок:
- narration должен быть коротким продолжением сцены
- choices должны содержать ровно 3 конкретных действия игрока
- state_changes должен содержать нулевые изменения и пустые списки
- memory_entry должен быть кратким
Никогда не добавляй markdown и пояснения вне JSON.
''',
        AppLanguage.en => '''
${fastPrefix}You are a narrative AI for a deterministic RPG.
Reply only with strict JSON using the keys: narration, choices, state_changes, memory_entry.
Write all texts, narration, choices, and memory_entry only in English.
For suggestion mode:
- narration must be a short continuation of the scene
- choices must contain exactly 3 concrete player actions
- state_changes must contain zero deltas and empty lists
- memory_entry must be brief
Never add markdown or explanations outside JSON.
''',
      };
    }

    return switch (language) {
      AppLanguage.ru => '''
${fastPrefix}Ты повествовательный ИИ для детерминированной RPG.
Отвечай только строгим JSON с ключами: narration, choices, state_changes, memory_entry.
Все тексты, narration, choices, questNote и memory_entry пиши только на русском языке.
Правила:
- narration: 1-3 абзаца
- choices: 3 коротких варианта действий
- state_changes: { "hpDelta": int, "energyDelta": int, "inventoryAdd": [string], "inventoryRemove": [string], "questNote": string }
- изменения должны быть умеренными для MVP
- не ломай целостность мира
- не добавляй markdown fences
''',
      AppLanguage.en => '''
${fastPrefix}You are a narrative AI for a deterministic RPG.
Reply only with strict JSON using the keys: narration, choices, state_changes, memory_entry.
Write all texts, narration, choices, questNote, and memory_entry only in English.
Rules:
- narration: 1-3 paragraphs
- choices: 3 short action options
- state_changes: { "hpDelta": int, "energyDelta": int, "inventoryAdd": [string], "inventoryRemove": [string], "questNote": string }
- changes must stay moderate for the MVP
- do not break world continuity
- do not add markdown fences
''',
    };
  }

  String _userPrompt({
    required final AppLanguage language,
    required final CampaignState state,
    required final String playerAction,
    required final bool fastMode,
  }) {
    final String fastPrefix = fastMode ? '/no_think\n' : '';
    final Map<String, Object?> contextPayload = _memoryManager.buildAiContext(
      state,
    );

    return switch (language) {
      AppLanguage.ru => '''
${fastPrefix}Контекст кампании:
${jsonEncode(contextPayload)}

Действие игрока:
$playerAction
''',
      AppLanguage.en => '''
${fastPrefix}Campaign context:
${jsonEncode(contextPayload)}

Player action:
$playerAction
''',
    };
  }

  Map<String, Object?> _responseFormatSchema({
    required final bool suggestionsOnly,
  }) {
    return <String, Object?>{
      'type': 'json_schema',
      'json_schema': <String, Object?>{
        'name': suggestionsOnly ? 'rpg_suggestions_turn' : 'rpg_story_turn',
        'schema': <String, Object?>{
          'type': 'object',
          'additionalProperties': false,
          'required': <String>[
            'narration',
            'choices',
            'state_changes',
            'memory_entry',
          ],
          'properties': <String, Object?>{
            'narration': <String, Object?>{'type': 'string'},
            'choices': <String, Object?>{
              'type': 'array',
              'minItems': 3,
              'maxItems': 3,
              'items': <String, Object?>{'type': 'string'},
            },
            'state_changes': <String, Object?>{
              'type': 'object',
              'additionalProperties': false,
              'required': <String>[
                'hpDelta',
                'energyDelta',
                'inventoryAdd',
                'inventoryRemove',
                'questNote',
              ],
              'properties': <String, Object?>{
                'hpDelta': <String, Object?>{'type': 'integer'},
                'energyDelta': <String, Object?>{'type': 'integer'},
                'inventoryAdd': <String, Object?>{
                  'type': 'array',
                  'items': <String, Object?>{'type': 'string'},
                },
                'inventoryRemove': <String, Object?>{
                  'type': 'array',
                  'items': <String, Object?>{'type': 'string'},
                },
                'questNote': <String, Object?>{'type': 'string'},
              },
            },
            'memory_entry': <String, Object?>{'type': 'string'},
          },
        },
      },
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
