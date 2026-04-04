import 'dart:io';

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

  try {
    final File output = File(
      '${Directory.current.path}${Platform.pathSeparator}runtime_errors.log',
    );
    // ignore: cascade_invocations
    output.writeAsStringSync(
      buffer.toString(),
      mode: FileMode.append,
      flush: true,
    );
  } catch (_) {
    debugPrint(buffer.toString());
  }
}
