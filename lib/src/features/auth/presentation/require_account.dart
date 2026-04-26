import 'package:ai_prg/src/app/app_providers.dart';
import 'package:ai_prg/src/core/models/symmetry_models.dart';
import 'package:ai_prg/src/features/auth/presentation/auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<bool> requireRegisteredAccount(
  final BuildContext context,
  final WidgetRef ref,
) async {
  final SymmetrySession? current = await ref
      .read(symmetryAuthRepositoryProvider)
      .loadSessionWithSyncedProfile();
  if (current != null && !current.isGuest) {
    return true;
  }
  if (!context.mounted) {
    return false;
  }
  final bool? authenticated = await Navigator.of(context).push<bool>(
    MaterialPageRoute<bool>(
      builder: (final routeContext) => AuthScreen(
        onAuthenticated: () => Navigator.of(routeContext).pop(true),
      ),
    ),
  );
  ref.invalidate(symmetrySessionProvider);
  return authenticated ?? false;
}
