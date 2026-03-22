import 'package:flutter/foundation.dart';

void writeRuntimeLog(
  final String source,
  final String message,
  final StackTrace? stack,
) {
  final StringBuffer buffer = StringBuffer()
    ..writeln('===== ${DateTime.now().toIso8601String()} [$source] =====')
    ..writeln(message);

  if (stack != null) {
    buffer
      ..writeln('--- stack ---')
      ..writeln(stack);
  }

  buffer.writeln();
  debugPrint(buffer.toString());
}
