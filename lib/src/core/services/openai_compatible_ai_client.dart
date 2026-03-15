import 'dart:convert';

import 'package:ai_prg/src/core/models/ai_settings.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:ai_prg/src/core/services/ai_client.dart';
import 'package:http/http.dart' as http;

class OpenAiCompatibleAiClient implements AiClient {
  const OpenAiCompatibleAiClient();

  @override
  Future<void> checkConnection({required final AiSettings settings}) async {
    final Uri uri = Uri.parse('${_normalizedBaseUrl(settings.baseUrl)}/models');
    final http.Response response = await http
        .get(uri, headers: _headers(settings))
        .timeout(Duration(seconds: settings.timeoutSeconds));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Сервер вернул код ${response.statusCode}');
    }
  }

  @override
  Future<TurnResult> generateTurn({
    required final AiSettings settings,
    required final CampaignState state,
    required final String playerAction,
    required final bool suggestionsOnly,
  }) async {
    final Uri uri = Uri.parse(
      '${_normalizedBaseUrl(settings.baseUrl)}/chat/completions',
    );
    final Map<String, Object?> requestBody = <String, Object?>{
      'model': settings.model,
      'temperature': 0.7,
      'messages': <Map<String, String>>[
        <String, String>{
          'role': 'system',
          'content': _systemPrompt(suggestionsOnly: suggestionsOnly),
        },
        <String, String>{
          'role': 'user',
          'content': _userPrompt(state: state, playerAction: playerAction),
        },
      ],
    };

    final http.Response response = await http
        .post(uri, headers: _headers(settings), body: jsonEncode(requestBody))
        .timeout(Duration(seconds: settings.timeoutSeconds));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Запрос хода завершился кодом ${response.statusCode}');
    }

    final Object? decoded = jsonDecode(response.body);
    if (decoded is! Map<String, Object?>) {
      throw Exception('Неожиданный ответ от провайдера.');
    }

    final List<Object?> choices =
        (decoded['choices'] as List<Object?>?) ?? const <Object?>[];
    if (choices.isEmpty) {
      throw Exception('Провайдер не вернул вариантов ответа.');
    }

    final Map<String, Object?> choice =
        choices.first as Map<String, Object?>? ?? const <String, Object?>{};
    final Map<String, Object?> message =
        choice['message'] as Map<String, Object?>? ?? const <String, Object?>{};
    final String content = (message['content'] as String?) ?? '';
    final String jsonString = _extractJson(content);
    final Object? turnDecoded = jsonDecode(jsonString);
    if (turnDecoded is! Map<String, Object?>) {
      throw Exception('Ответ ИИ не является корректным JSON.');
    }

    return TurnResult.fromJson(turnDecoded);
  }

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

  String _systemPrompt({required final bool suggestionsOnly}) {
    if (suggestionsOnly) {
      return '''
Ты повествовательный ИИ для детерминированной RPG.
Отвечай только строгим JSON с ключами: narration, choices, state_changes, memory_entry.
Все тексты, narration, choices и memory_entry пиши только на русском языке.
Для режима подсказок:
- narration должен быть коротким продолжением сцены
- choices должен содержать ровно 3 конкретных действия игрока
- state_changes должен содержать нулевые изменения и пустые списки
- memory_entry должен быть кратким
Никогда не добавляй markdown и пояснения вне JSON.
''';
    }

    return '''
Ты повествовательный ИИ для детерминированной RPG.
Отвечай только строгим JSON с ключами: narration, choices, state_changes, memory_entry.
Все тексты, narration, choices, questNote и memory_entry пиши только на русском языке.
Правила:
- narration: 1-3 абзаца
- choices: 3 коротких варианта действий
- state_changes: { "hpDelta": int, "energyDelta": int, "inventoryAdd": [string], "inventoryRemove": [string], "questNote": string }
- изменения должны быть умеренными для MVP
- не ломай целостность мира
- не добавляй markdown fences
''';
  }

  String _userPrompt({
    required final CampaignState state,
    required final String playerAction,
  }) {
    return '''
Состояние кампании:
${jsonEncode(state.toJson())}

Действие игрока:
$playerAction
''';
  }

  String _extractJson(final String raw) {
    final String trimmed = raw.trim();
    if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
      return trimmed;
    }

    final int start = trimmed.indexOf('{');
    final int end = trimmed.lastIndexOf('}');
    if (start == -1 || end == -1 || end <= start) {
      throw Exception('Не удалось найти JSON в ответе провайдера.');
    }
    return trimmed.substring(start, end + 1);
  }
}
