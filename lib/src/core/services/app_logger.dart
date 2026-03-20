import 'package:ai_prg/src/core/models/ai_settings.dart';
import 'package:ai_prg/src/core/services/ai_client.dart';
import 'package:flutter/foundation.dart';

/// Централизованный логгер приложения для отладки AI запросов и ответов.
/// 
/// ПРИМЕЧАНИЕ: Для полноценного логирования добавьте пакет logger в pubspec.yaml:
/// dependencies:
///   logger: ^2.0.0
/// 
/// Текущая версия использует debugPrint для временного логирования.
class AppLogger {
  AppLogger._();

  /// Простой логгер для отладки (без пакета logger).
  static void _log(String level, String message, {Object? error}) {
    if (kDebugMode) {
      final String errorStr = error != null ? '\n  Error: $error' : '';
      debugPrint('[$level] $message$errorStr');
    }
  }

  static dynamic get instance => _AppLoggerInstance();

  /// Логирует AI запрос перед отправкой.
  static void logAiRequest({
    required String endpoint,
    required Map<String, dynamic> requestBody,
    required AiSettings settings,
  }) {
    _log('DEBUG', 'AI Request to $endpoint', error: {
      'provider': settings.provider.name,
      'model': settings.model,
      'body': requestBody,
    });
  }

  /// Логирует AI ответ после получения.
  static void logAiResponse({
    required String endpoint,
    required int statusCode,
    required String rawResponse,
  }) {
    final String truncated = rawResponse.length > 500
        ? '${rawResponse.substring(0, 500)}...[truncated ${rawResponse.length} chars]'
        : rawResponse;
    
    _log('DEBUG', 'AI Response from $endpoint (status: $statusCode)', 
      error: truncated);
  }

  /// Логирует AI ошибку с деталями.
  static void logAiError({
    required String message,
    required AiTurnException exception,
  }) {
    _log('ERROR', 'AI Error: $message', error: {
      'userMessage': exception.userMessage,
      'recoverable': exception.recoverable,
      'rawResponse': exception.rawResponse != null 
          ? (exception.rawResponse!.length > 300
              ? '${exception.rawResponse!.substring(0, 300)}...[truncated]'
              : exception.rawResponse)
          : null,
    });
  }
}

/// Простая заглушка для instance методов (i, w, e, d).
class _AppLoggerInstance {
  void d(String message, {Object? error, StackTrace? stackTrace}) {
    AppLogger._log('DEBUG', message, error: error);
  }

  void i(String message, {Object? error, StackTrace? stackTrace}) {
    AppLogger._log('INFO', message, error: error);
  }

  void w(String message, {Object? error, StackTrace? stackTrace}) {
    AppLogger._log('WARN', message, error: error);
  }

  void e(String message, {Object? error, StackTrace? stackTrace}) {
    AppLogger._log('ERROR', message, error: error);
  }
}
