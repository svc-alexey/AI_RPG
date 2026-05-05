import 'dart:async';

import 'package:ai_prg/src/app/app.dart';
import 'package:ai_prg/src/app/runtime_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
// MarionetteBinding is conditionally used via AI_PRG_MCP_ENABLED dart-define.
// Package is in dev_dependencies — only linked in debug/profile, tree-shaken in release.
// ignore: depend_on_referenced_packages
import 'package:marionette_flutter/marionette_flutter.dart';

void main() {
  runZonedGuarded(
    () {
      const isMcpEnabled = bool.fromEnvironment('AI_PRG_MCP_ENABLED');

      if (isMcpEnabled) {
        MarionetteBinding.ensureInitialized();
      } else {
        WidgetsFlutterBinding.ensureInitialized();
      }

      if (kIsWeb) {
        usePathUrlStrategy();
      }
      if (kIsWeb && !kReleaseMode) {
        SemanticsBinding.instance.ensureSemantics();
      }

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
