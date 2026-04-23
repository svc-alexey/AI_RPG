import 'package:ai_prg/src/app/app_localizations.dart';
import 'package:ai_prg/src/app/app_providers.dart';
import 'package:ai_prg/src/app/browser_location.dart';
import 'package:ai_prg/src/core/config/symmetry_runtime_env.dart';
import 'package:ai_prg/src/core/models/symmetry_models.dart';
import 'package:ai_prg/src/core/repositories/symmetry_auth_repository.dart';
import 'package:ai_prg/src/features/auth/yandex_oauth_callback_result.dart';
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
  bool _didShowWarmSessionWarning = false;
  Object? _warmSessionWarning;
  bool _redirectingLegacyYandexCallback = false;

  @override
  void initState() {
    super.initState();
    if (_hasYandexCallbackPayload) {
      _handleYandexCallback();
    } else {
      _warmSession();
    }
    ref.read(updateGateControllerProvider.notifier).checkForUpdates();
  }

  bool get _hasYandexCallbackPayload {
    if (!kIsWeb) {
      return false;
    }
    final YandexOAuthCallbackResult callbackResult =
        YandexOAuthCallbackResult.fromUri(Uri.base);
    return Uri.base.path == '/auth/yandex/callback' ||
        callbackResult.hasHandoff ||
        callbackResult.hasError ||
        callbackResult.hasLegacyCode ||
        callbackResult.hasLegacyState;
  }

  Future<void> _warmSession() async {
    try {
      final bool hasSession = await ref
          .read(symmetryAuthRepositoryProvider)
          .hasSession();
      if (!hasSession) {
        return;
      }
      await _refreshSessionWithSingleRetry();
    } catch (error) {
      if (_shouldClearSessionAfterRefreshError(error)) {
        await ref.read(symmetryAuthRepositoryProvider).logout();
        return;
      }
      if (mounted) {
        setState(() => _warmSessionWarning = error);
      } else {
        _warmSessionWarning = error;
      }
    }
  }

  Future<void> _refreshSessionWithSingleRetry() async {
    final SymmetryAuthRepository repository = ref.read(
      symmetryAuthRepositoryProvider,
    );
    try {
      await repository.refreshSession();
    } catch (firstError) {
      if (!_isTransientRefreshFailure(firstError)) {
        rethrow;
      }
      await Future<void>.delayed(const Duration(milliseconds: 450));
      await repository.refreshSession();
    }
  }

  bool _isTransientRefreshFailure(final Object error) {
    if (error is! SymmetryApiException) {
      return true;
    }
    final int? code = error.statusCode;
    if (code == null) {
      return false;
    }
    if (code == 408 || code == 429) {
      return true;
    }
    return code >= 500;
  }

  bool _shouldClearSessionAfterRefreshError(final Object error) {
    if (error is! SymmetryApiException) {
      return false;
    }
    final int? code = error.statusCode;
    if (code == null) {
      return false;
    }
    if (code >= 500 || code == 408 || code == 429 || code == 404) {
      return false;
    }
    return code >= 400 && code < 500;
  }

  Future<void> _handleYandexCallback() async {
    setState(() => _handlingYandexCallback = true);
    try {
      final YandexOAuthCallbackResult callbackResult =
          YandexOAuthCallbackResult.fromUri(Uri.base);
      if (callbackResult.hasError) {
        throw SymmetryApiException(
          message: callbackResult.errorCode,
          detailCode: callbackResult.errorCode,
        );
      }
      if (callbackResult.hasHandoff) {
        await ref
            .read(symmetryAuthRepositoryProvider)
            .completeYandexHandoff(handoffId: callbackResult.handoffId);
      } else if (callbackResult.hasLegacyOAuthCallback) {
        _redirectingLegacyYandexCallback = true;
        navigateBrowserUrl(_legacyYandexBackendCallbackUrl(callbackResult));
        return;
      } else if (callbackResult.hasLegacyCode) {
        throw const SymmetryApiException(
          message: 'missing_yandex_state',
          detailCode: 'missing_yandex_state',
        );
      } else {
        throw const SymmetryApiException(
          message: 'missing_yandex_handoff',
          detailCode: 'missing_yandex_handoff',
        );
      }
      _callbackError = null;
      ref.invalidate(symmetrySessionProvider);
      await ref.read(symmetrySessionProvider.future);
    } catch (error) {
      _callbackError = error;
      await _warmSession();
    } finally {
      if (!_redirectingLegacyYandexCallback) {
        replaceBrowserUrl(_browserUrlAfterYandexCallback());
      }
      if (mounted) {
        setState(() => _handlingYandexCallback = false);
      }
    }
  }

  String _legacyYandexBackendCallbackUrl(
    final YandexOAuthCallbackResult callbackResult,
  ) {
    final Uri apiBaseUri = Uri.parse(SymmetryRuntimeEnv.defaultBaseUrl);
    final String normalizedApiPath = apiBaseUri.path.endsWith('/v1')
        ? apiBaseUri.path
        : '${apiBaseUri.path}/v1';
    return apiBaseUri
        .replace(
          path: '$normalizedApiPath/auth/yandex/callback',
          queryParameters: <String, String>{
            'code': callbackResult.legacyCode,
            'state': callbackResult.legacyState,
          },
        )
        .toString();
  }

  /// Clears the OAuth callback params from the address bar without reloading.
  String _browserUrlAfterYandexCallback() {
    final Map<String, String> queryParameters = <String, String>{};
    final String? lang = Uri.base.queryParameters['lang']?.trim();
    if (lang != null && lang.isNotEmpty) {
      queryParameters['lang'] = lang;
    }
    return Uri(
      path: '/',
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    ).toString();
  }

  @override
  Widget build(final BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    if (_warmSessionWarning != null && !_didShowWarmSessionWarning) {
      _didShowWarmSessionWarning = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(l10n.authBackendUnavailable)));
      });
    }
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
        backgroundColor: Colors.transparent,
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
