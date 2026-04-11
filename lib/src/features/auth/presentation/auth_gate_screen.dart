import 'package:ai_prg/src/app/app_localizations.dart';
import 'package:ai_prg/src/app/app_providers.dart';
import 'package:ai_prg/src/app/browser_location.dart';
import 'package:ai_prg/src/core/models/symmetry_models.dart';
import 'package:ai_prg/src/features/home/presentation/home_screen.dart';
import 'package:ai_prg/src/features/update/application/update_gate_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthGateScreen extends ConsumerStatefulWidget {
  const AuthGateScreen({super.key});

  @override
  ConsumerState<AuthGateScreen> createState() => _AuthGateScreenState();
}

class _AuthGateScreenState extends ConsumerState<AuthGateScreen> {
  Object? _callbackError;
  bool _handlingYandexCallback = false;
  bool _didShowCallbackError = false;

  @override
  void initState() {
    super.initState();
    if (_isYandexCallback) {
      _handleYandexCallback();
    } else {
      _warmSession();
    }
    ref.read(updateGateControllerProvider.notifier).checkForUpdates();
  }

  bool get _isYandexCallback =>
      kIsWeb && Uri.base.path == '/auth/yandex/callback';

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

  Future<void> _handleYandexCallback() async {
    setState(() => _handlingYandexCallback = true);
    try {
      final String code = Uri.base.queryParameters['code']?.trim() ?? '';
      if (code.isEmpty) {
        throw const SymmetryApiException(
          message: 'missing_code',
          detailCode: 'missing_code',
        );
      }
      await ref
          .read(symmetryAuthRepositoryProvider)
          .loginWithYandexCode(code: code);
      ref.invalidate(symmetrySessionProvider);
      _callbackError = null;
    } catch (error) {
      _callbackError = error;
      await _warmSession();
    } finally {
      replaceBrowserUrl(_landingUrlPreservingLanguage());
      if (mounted) {
        setState(() => _handlingYandexCallback = false);
      }
    }
  }

  String _landingUrlPreservingLanguage() {
    final String? lang = Uri.base.queryParameters['lang']?.trim();
    if (lang == null || lang.isEmpty) {
      return '/';
    }
    return '/?lang=${Uri.encodeQueryComponent(lang)}';
  }

  @override
  Widget build(final BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    if (_callbackError != null && !_didShowCallbackError) {
      _didShowCallbackError = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(l10n.authYandexFailed(_callbackError!))),
          );
      });
    }
    if (_handlingYandexCallback) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(l10n.authYandexProcessing),
            ],
          ),
        ),
      );
    }
    return const HomeScreen();
  }
}
