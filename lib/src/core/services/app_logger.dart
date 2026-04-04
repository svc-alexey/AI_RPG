import 'dart:convert';
import 'dart:developer' as developer;

import 'package:ai_prg/src/core/models/ai_settings.dart';
import 'package:ai_prg/src/core/services/ai_client.dart';
import 'package:flutter/foundation.dart';

class AppDiagnosticEvent {
  const AppDiagnosticEvent({
    required this.timestamp,
    required this.level,
    required this.event,
    required this.message,
    this.flowId,
    this.campaignId,
    this.triggerSource,
    this.attempt,
    this.requestMode,
    this.screenMounted,
    this.statusCode,
  });

  final DateTime timestamp;
  final String level;
  final String event;
  final String message;
  final String? flowId;
  final String? campaignId;
  final String? triggerSource;
  final int? attempt;
  final String? requestMode;
  final bool? screenMounted;
  final int? statusCode;

  Map<String, Object?> toJson() => <String, Object?>{
    'timestamp': timestamp.toIso8601String(),
    'level': level,
    'event': event,
    'message': message,
    'flowId': flowId,
    'campaignId': campaignId,
    'triggerSource': triggerSource,
    'attempt': attempt,
    'requestMode': requestMode,
    'screenMounted': screenMounted,
    'statusCode': statusCode,
  };
}

class AppLogger {
  AppLogger._();

  static const int _maxDiagnosticEvents = 60;
  static final ValueNotifier<List<AppDiagnosticEvent>> _diagnostics =
      ValueNotifier<List<AppDiagnosticEvent>>(const <AppDiagnosticEvent>[]);

  static ValueListenable<List<AppDiagnosticEvent>> get diagnosticsListenable =>
      _diagnostics;

  static void _log(
    final String level,
    final String message, {
    Object? error,
    Object? detail,
  }) {
    if (kDebugMode) {
      final String errorStr = error != null ? '\n  Error: $error' : '';
      final String detailStr = detail != null ? '\n  Detail: $detail' : '';
      debugPrint('[$level] $message$errorStr$detailStr');
    }
  }

  static AppLoggerInstance get instance => AppLoggerInstance();

  static void logDiagnostic({
    required final String level,
    required final String event,
    required final String message,
    final String? flowId,
    final String? campaignId,
    final String? triggerSource,
    final int? attempt,
    final String? requestMode,
    final bool? screenMounted,
    final int? statusCode,
  }) {
    final AppDiagnosticEvent entry = AppDiagnosticEvent(
      timestamp: DateTime.now(),
      level: level,
      event: event,
      message: message,
      flowId: flowId,
      campaignId: campaignId,
      triggerSource: triggerSource,
      attempt: attempt,
      requestMode: requestMode,
      screenMounted: screenMounted,
      statusCode: statusCode,
    );

    final List<AppDiagnosticEvent> next = <AppDiagnosticEvent>[
      ..._diagnostics.value,
      entry,
    ];
    if (next.length > _maxDiagnosticEvents) {
      next.removeRange(0, next.length - _maxDiagnosticEvents);
    }
    _diagnostics.value = List<AppDiagnosticEvent>.unmodifiable(next);

    final String payload = jsonEncode(entry.toJson());
    developer.log(payload, name: 'AI_PRG_DIAG');
    if (kDebugMode || kIsWeb) {
      debugPrint('[AI_PRG_DIAG] $payload');
    }
  }

  static void logAiRequest({
    required final String endpoint,
    required final Map<String, dynamic> requestBody,
    required final AiSettings settings,
    final String? flowId,
    final String? campaignId,
    final String? triggerSource,
    final int? attempt,
    final String? requestMode,
    final bool? screenMounted,
  }) {
    _log(
      'DEBUG',
      'AI Request to $endpoint',
      detail: <String, Object?>{
        'provider': settings.provider.name,
        'model': settings.model,
        'body': requestBody,
      },
    );
    logDiagnostic(
      level: 'DEBUG',
      event: 'ai_request',
      message: 'POST $endpoint',
      flowId: flowId,
      campaignId: campaignId,
      triggerSource: triggerSource,
      attempt: attempt,
      requestMode: requestMode,
      screenMounted: screenMounted,
    );
  }

  static void logAiResponse({
    required final String endpoint,
    required final int statusCode,
    required final String rawResponse,
    final String? flowId,
    final String? campaignId,
    final String? triggerSource,
    final int? attempt,
    final String? requestMode,
    final bool? screenMounted,
  }) {
    final String truncated = rawResponse.length > 500
        ? '${rawResponse.substring(0, 500)}...[truncated ${rawResponse.length} chars]'
        : rawResponse;

    _log(
      'DEBUG',
      'AI Response from $endpoint (status: $statusCode)',
      detail: truncated,
    );
    logDiagnostic(
      level: 'DEBUG',
      event: 'ai_response',
      message: 'Response from $endpoint',
      flowId: flowId,
      campaignId: campaignId,
      triggerSource: triggerSource,
      attempt: attempt,
      requestMode: requestMode,
      screenMounted: screenMounted,
      statusCode: statusCode,
    );
  }

  static void logAiError({
    required final String message,
    required final AiTurnException exception,
    final String? flowId,
    final String? campaignId,
    final String? triggerSource,
    final int? attempt,
    final String? requestMode,
    final bool? screenMounted,
    final int? statusCode,
  }) {
    _log(
      'ERROR',
      'AI Error: $message',
      error: <String, Object?>{
        'userMessage': exception.userMessage,
        'recoverable': exception.recoverable,
        'rawResponse': exception.rawResponse != null
            ? (exception.rawResponse!.length > 300
                  ? '${exception.rawResponse!.substring(0, 300)}...[truncated]'
                  : exception.rawResponse)
            : null,
      },
    );
    logDiagnostic(
      level: 'ERROR',
      event: 'ai_error',
      message: message,
      flowId: flowId,
      campaignId: campaignId,
      triggerSource: triggerSource,
      attempt: attempt,
      requestMode: requestMode,
      screenMounted: screenMounted,
      statusCode: statusCode,
    );
  }
}

class AppLoggerInstance {
  void d(
    final String message, {
    final Object? error,
    final StackTrace? stackTrace,
  }) {
    AppLogger._log('DEBUG', message, error: error);
  }

  void i(
    final String message, {
    final Object? error,
    final StackTrace? stackTrace,
  }) {
    AppLogger._log('INFO', message, error: error);
  }

  void w(
    final String message, {
    final Object? error,
    final StackTrace? stackTrace,
  }) {
    AppLogger._log('WARN', message, error: error);
  }

  void e(
    final String message, {
    final Object? error,
    final StackTrace? stackTrace,
  }) {
    AppLogger._log('ERROR', message, error: error);
  }
}
