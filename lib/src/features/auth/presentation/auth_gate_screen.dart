import 'package:ai_prg/src/app/app_providers.dart';
import 'package:ai_prg/src/features/home/presentation/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthGateScreen extends ConsumerStatefulWidget {
  const AuthGateScreen({super.key});

  @override
  ConsumerState<AuthGateScreen> createState() => _AuthGateScreenState();
}

class _AuthGateScreenState extends ConsumerState<AuthGateScreen> {
  @override
  void initState() {
    super.initState();
    _warmSession();
  }

  Future<void> _warmSession() async {
    try {
      final bool hasSession = await ref
          .read(symmetryAuthRepositoryProvider)
          .hasSession();
      if (hasSession) {
        await ref.read(symmetryAuthRepositoryProvider).refreshSession();
      }
    } catch (_) {
      await ref.read(symmetryAuthRepositoryProvider).logout();
    }
  }

  @override
  Widget build(final BuildContext context) => const HomeScreen();
}
