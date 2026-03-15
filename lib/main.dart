import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:ai_prg/src/app/app.dart';
import 'package:flutter/material.dart';

void main() {
  runZonedGuarded(
    () {
      WidgetsFlutterBinding.ensureInitialized();

      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        _writeRuntimeLog(
          'FlutterError',
          details.exceptionAsString(),
          details.stack,
        );
      };

      PlatformDispatcher.instance.onError = (error, stack) {
        _writeRuntimeLog('PlatformDispatcher', error.toString(), stack);
        return false;
      };

      runApp(const AiRpgApp());
    },
    (error, stack) {
      _writeRuntimeLog('runZonedGuarded', error.toString(), stack);
    },
  );
}

void _writeRuntimeLog(
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
    final File file = File(
      '${Directory.current.path}${Platform.pathSeparator}runtime_errors.log',
    );
    // ignore: cascade_invocations
    file.writeAsStringSync(
      buffer.toString(),
      mode: FileMode.append,
      flush: true,
    );
  } catch (_) {
    debugPrint(buffer.toString());
  }
}
