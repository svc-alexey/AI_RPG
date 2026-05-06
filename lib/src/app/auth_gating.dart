import 'dart:async';

import 'package:ai_prg/src/app/app_localizations.dart';
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

  if (session != null) {
    if (!session.isGuest && !session.isEmailVerified) {
      if (!context.mounted) return;
      final bool? verified = await showDialog<bool>(
        context: context,
        barrierDismissible: true,
        builder: (final ctx) => _VerificationDialog(
          session: session,
          ref: ref,
        ),
      );
      if (verified == true) {
        ref.invalidate(symmetrySessionProvider);
        if (!context.mounted) return;
        await action();
      }
      return;
    }
    await action();
    return;
  }

  // No session — auto-create guest session, then proceed
  try {
    final repo = ref.read(symmetryAuthRepositoryProvider);
    await repo.guestLogin();
    ref.invalidate(symmetrySessionProvider);
    if (!context.mounted) return;
    await action();
  } catch (_) {
    // Guest login failed — show auth screen as fallback
    ref.read(deferredActionProvider.notifier).state = () async {
      await action();
    };

    if (!context.mounted) return;

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
}

class _VerificationDialog extends StatefulWidget {
  const _VerificationDialog({required this.session, required this.ref});

  final SymmetrySession session;
  final WidgetRef ref;

  @override
  State<_VerificationDialog> createState() => _VerificationDialogState();
}

class _VerificationDialogState extends State<_VerificationDialog> {
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
      final session = await widget.ref
          .read(symmetryAuthRepositoryProvider)
          .loadSessionWithSyncedProfile();
      if (!mounted) return;
      if (session != null && session.isEmailVerified) {
        _pollTimer?.cancel();
        Navigator.of(context).pop(true);
      }
    } catch (_) {}
  }

  Future<void> _resend() async {
    setState(() => _resending = true);
    try {
      await widget.ref
          .read(symmetryAuthRepositoryProvider)
          .resendVerification();
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

    return Dialog(
      backgroundColor: const Color(0xFF0F0D0B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
            color: const Color(0xFFC87941).withAlpha(60), width: 1),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: DefaultTextStyle(
            style: const TextStyle(decoration: TextDecoration.none),
            child: Column(
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
              onTap: () => Navigator.of(context).pop(),
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
        ),
      ),
      ),), // Padding, DefaultTextStyle, ConstrainedBox
    );
  }
}
