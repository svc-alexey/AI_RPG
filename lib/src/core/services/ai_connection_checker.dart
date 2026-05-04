import 'dart:async';
import 'dart:convert';

import 'package:ai_prg/src/core/models/ai_settings.dart';
import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/services/ai_client.dart';
import 'package:ai_prg/src/core/services/ai_response_parser.dart';
import 'package:ai_prg/src/core/services/ai_user_messages.dart';
import 'package:http/http.dart' as http;

class AiConnectionChecker {
  const AiConnectionChecker({
    required this.messages,
    required this.parser,
  });

  final AiUserMessages messages;
  final AiResponseParser parser;

  Future<void> checkConnection({required AiSettings settings}) async {
    final Uri uri = Uri.parse('${normalizedBaseUrl(settings.baseUrl)}/models');
    final http.Response response;

    try {
      response = await http
          .get(uri, headers: headers(settings))
          .timeout(Duration(seconds: effectiveTimeoutSeconds(settings)));
    } on TimeoutException {
      throw AiTurnException(
        userMessage: messages.timeoutError(
          settings: settings,
          language: AppLanguage.en,
        ),
        recoverable: true,
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final String rawResponse = responseText(response);
      throw AiTurnException(
        userMessage: messages.friendlyAiEndpointError(
          settings: settings,
          language: AppLanguage.en,
          statusCode: response.statusCode,
          detail: parser.extractProviderErrorDetail(rawResponse),
        ),
        rawResponse: rawResponse,
      );
    }
  }

  String normalizedBaseUrl(String baseUrl) {
    String normalized = baseUrl.trim();
    if (normalized.endsWith('/')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }
    final Uri? parsed = Uri.tryParse(normalized);
    if (parsed != null &&
        parsed.hasScheme &&
        parsed.host == 'api.deepseek.com' &&
        (parsed.path.isEmpty || parsed.path == '/')) {
      return '$normalized/v1';
    }
    return normalized;
  }

  Map<String, String> headers(AiSettings settings) {
    final Map<String, String> headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (settings.apiKey.trim().isNotEmpty) {
      headers['Authorization'] = 'Bearer ${settings.apiKey.trim()}';
    }
    return headers;
  }

  int effectiveTimeoutSeconds(AiSettings settings) => settings.timeoutSeconds;

  String responseText(http.Response response) =>
      utf8.decode(response.bodyBytes, allowMalformed: true);
}
