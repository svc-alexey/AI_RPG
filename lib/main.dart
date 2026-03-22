import 'dart:async';
import 'dart:ui';

import 'package:ai_prg/src/app/app.dart';
import 'package:ai_prg/src/app/runtime_logger.dart';
import 'package:flutter/material.dart';

void main() {
  runZonedGuarded(
    () {
      WidgetsFlutterBinding.ensureInitialized();

      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        writeRuntimeLog(
          'FlutterError',
          details.exceptionAsString(),
          details.stack,
        );
      };

      PlatformDispatcher.instance.onError = (error, stack) {
        writeRuntimeLog('PlatformDispatcher', error.toString(), stack);
        return false;
      };

      runApp(const AiRpgApp());
    },
    (error, stack) {
      writeRuntimeLog('runZonedGuarded', error.toString(), stack);
    },
  );
}
