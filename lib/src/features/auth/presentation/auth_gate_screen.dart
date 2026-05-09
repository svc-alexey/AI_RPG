import 'dart:async';

import 'package:ai_prg/src/app/app_localizations.dart';
import 'package:ai_prg/src/app/app_providers.dart';
import 'package:ai_prg/src/app/browser_location.dart';
import 'package:ai_prg/src/core/config/symmetry_runtime_env.dart';
import 'package:ai_prg/src/core/models/symmetry_models.dart';
import 'package:ai_prg/src/core/repositories/symmetry_auth_repository.dart';
import 'package:ai_prg/src/features/auth/presentation/email_verification_screen.dart';
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
  bool _dismissedVerification = false;
  bool _emailVerifiedSuccess = false;

  @override
  void initState() {
    super.initState();
    if (_hasEmailVerificationCallback) {
      _handleEmailVerificationCallback();
    } else if (_hasEmailVerifiedFlag) {
      _handleEmailVerifiedFlag();
    } else if (_hasYandexCallbackPayload) {
      _handleYandexCallback();
    } else {
      _warmSession();
    }
    ref.read(updateGateControllerProvider.notifier).checkForUpdates();
  }

  bool get _hasEmailVerificationCallback {
    if (!kIsWeb) return false;
    final String? vt = Uri.base.queryParameters['verify_token'];
    return vt != null && vt.isNotEmpty;
  }

  bool get _hasEmailVerifiedFlag {
    if (!kIsWeb) return false;
    return Uri.base.queryParameters['email_verified'] == '1';
  }

  bool get _hasEmailVerifyError {
    if (!kIsWeb) return false;
    final String? ve = Uri.base.queryParameters['verify_error'];
    return ve != null && ve.isNotEmpty;
  }

  Future<void> _handleEmailVerificationCallback() async {
    final String? token = Uri.base.queryParameters['verify_token'];
    if (token == null || token.isEmpty) return;
    try {
      await ref
          .read(symmetryAuthRepositoryProvider)
          .verifyEmail(token: token);
      replaceBrowserUrl(_browserUrlAfterYandexCallback());
      ref.invalidate(symmetrySessionProvider);
      setState(() => _emailVerifiedSuccess = true);
    } catch (error) {
      _callbackError = error;
      replaceBrowserUrl(_browserUrlAfterYandexCallback());
      await _warmSession();
    }
  }

  void _handleEmailVerifiedFlag() {
    replaceBrowserUrl(_browserUrlAfterYandexCallback());
    ref.invalidate(symmetrySessionProvider);
    setState(() => _emailVerifiedSuccess = true);
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

    if (_hasEmailVerifyError && !_didShowCallbackError) {
      _didShowCallbackError = true;
      final String? ve = Uri.base.queryParameters['verify_error'];
      replaceBrowserUrl(_browserUrlAfterYandexCallback());
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Text(
              l10n.symmetryFriendlyError(
                SymmetryApiException(
                  message: ve ?? 'verification_failed',
                  detailCode: ve,
                ),
              ),
            ),
            backgroundColor: Colors.red.shade800,
            behavior: SnackBarBehavior.floating,
          ));
      });
    }

    final sessionState = ref.watch(symmetrySessionProvider);
    final bool needsVerification = sessionState.hasValue &&
        sessionState.value != null &&
        !sessionState.value!.isGuest &&
        !sessionState.value!.isEmailVerified;
    final bool showVerification = needsVerification && !_dismissedVerification;

    return Stack(
      children: [
        const HomeScreen(),
        if (showVerification)
          _EmailVerificationOverlay(
            session: sessionState.value!,
            onDismiss: () {
              setState(() => _dismissedVerification = true);
            },
            onVerified: () {
              setState(() => _dismissedVerification = true);
              ref.invalidate(symmetrySessionProvider);
            },
          ),
        if (_emailVerifiedSuccess)
          _EmailVerifiedSuccessOverlay(
            onContinue: () {
              setState(() => _emailVerifiedSuccess = false);
            },
          ),
      ],
    );
  }
}

class _EmailVerificationOverlay extends ConsumerStatefulWidget {
  const _EmailVerificationOverlay({
    required this.session,
    required this.onDismiss,
    required this.onVerified,
  });

  final SymmetrySession session;
  final VoidCallback onDismiss;
  final VoidCallback onVerified;

  @override
  ConsumerState<_EmailVerificationOverlay> createState() =>
      _EmailVerificationOverlayState();
}

class _EmailVerificationOverlayState
    extends ConsumerState<_EmailVerificationOverlay> {
  bool _resending = false;
  Timer? _pollTimer;
  int _pollAttempts = 0;
  static const int _maxPollAttempts = 12;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollAttempts = 0;
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _checkStatus();
    });
  }

  Future<void> _checkStatus() async {
    if (_pollAttempts >= _maxPollAttempts) {
      _pollTimer?.cancel();
      return;
    }
    _pollAttempts++;
    try {
      final session = await ref
          .read(symmetryAuthRepositoryProvider)
          .loadSessionWithSyncedProfile();
      if (!mounted) return;
      if (session != null && session.isEmailVerified) {
        _pollTimer?.cancel();
        widget.onVerified();
      }
    } catch (_) {}
  }

  Future<void> _resend() async {
    setState(() => _resending = true);
    try {
      await ref.read(symmetryAuthRepositoryProvider).resendVerification();
      if (!mounted) return;
      _startPolling();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.authEmailVerificationResendSuccess),
          backgroundColor: const Color(0xFF34D399).withAlpha(220),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final String message;
      if (e.toString().contains('resend_too_soon')) {
        message = context.l10n.authEmailVerificationResendTooSoon;
      } else {
        message = e.toString();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red.shade800,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final email = widget.session.user.email;

    final Widget card = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.mark_email_unread_outlined,
            size: 40, color: Color(0xFFBFA76F)),
        const SizedBox(height: 16),
        Text(
          l10n.authEmailVerificationTitle,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFFE8E4E0),
            fontFamily: 'Playfair Display',
            decoration: TextDecoration.none,
          ),
        ),
        const SizedBox(height: 8),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: const TextStyle(
              color: Color(0xFF7A7570),
              fontSize: 13,
              decoration: TextDecoration.none,
            ),
            text: l10n.authEmailVerificationMessage(email),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton(
            onPressed: _resending ? null : _resend,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFC87941),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: _resending
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : Text(l10n.authEmailVerificationResendAction,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.none)),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: widget.onDismiss,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(l10n.closeAction,
                style: const TextStyle(
                    color: Color(0xFF7A7570),
                    fontSize: 13,
                    decoration: TextDecoration.none)),
          ),
        ),
      ],
    );

    return GestureDetector(
      onTap: widget.onDismiss,
      child: Container(
        color: Colors.black54,
        alignment: Alignment.center,
        child: GestureDetector(
          onTap: () {},
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            constraints: const BoxConstraints(maxWidth: 420),
            decoration: BoxDecoration(
              color: const Color(0xFF0F0D0B),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: const Color(0xFFC87941).withAlpha(60), width: 1),
            ),
            padding: const EdgeInsets.all(28),
            child: card,
          ),
        ),
      ),
    );
  }
}

class _EmailVerifiedSuccessOverlay extends StatelessWidget {
  const _EmailVerifiedSuccessOverlay({required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;

    final Widget card = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFF34D399).withAlpha(30),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle_outline,
              size: 36, color: Color(0xFF34D399)),
        ),
        const SizedBox(height: 20),
        Text(
          l10n.authEmailVerificationSuccess,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFFE8E4E0),
            fontFamily: 'Playfair Display',
            decoration: TextDecoration.none,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          l10n.authEmailVerifiedSuccessMessage,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF7A7570),
            fontSize: 14,
            height: 1.5,
            decoration: TextDecoration.none,
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton(
            onPressed: onContinue,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF34D399),
              foregroundColor: const Color(0xFF0A0908),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(l10n.authEmailVerifiedSuccessAction,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.none)),
          ),
        ),
      ],
    );

    return GestureDetector(
      onTap: onContinue,
      child: Container(
        color: Colors.black54,
        alignment: Alignment.center,
        child: GestureDetector(
          onTap: () {},
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            constraints: const BoxConstraints(maxWidth: 420),
            decoration: BoxDecoration(
              color: const Color(0xFF0F0D0B),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: const Color(0xFF34D399).withAlpha(60), width: 1),
            ),
            padding: const EdgeInsets.all(28),
            child: card,
          ),
        ),
      ),
    );
  }
}
