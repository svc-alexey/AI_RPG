import 'package:ai_prg/src/app/app_providers.dart';
import 'package:ai_prg/src/core/models/symmetry_models.dart';
import 'package:ai_prg/src/features/auth/presentation/auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> requireAccountThen(
  final BuildContext context,
  final WidgetRef ref,
  final Future<void> Function() action,
) async {
  final SymmetrySession? session = ref.read(symmetrySessionProvider).valueOrNull;

  if (session != null && !session.isGuest) {
    await action();
    return;
  }

  // Store deferred action
  ref.read(deferredActionProvider.notifier).state = () async {
    await action();
  };

  if (!context.mounted) return;

  // Open auth screen
  await Navigator.of(context).push<bool>(
    MaterialPageRoute<bool>(
      builder: (final routeContext) => AuthScreen(
        onAuthenticated: () {
          final AsyncCallback? deferred =
              ref.read(deferredActionProvider.notifier).state;
          if (deferred != null) {
            deferred().then((final _) {
              ref.read(deferredActionProvider.notifier).state = null;
            });
          }
          Navigator.of(routeContext).pop(true);
        },
      ),
    ),
  );

  ref.invalidate(symmetrySessionProvider);
}
