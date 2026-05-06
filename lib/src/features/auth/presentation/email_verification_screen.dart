import 'dart:async';

import 'package:ai_prg/src/app/app_localizations.dart';
import 'package:ai_prg/src/app/app_providers.dart';
import 'package:ai_prg/src/core/models/symmetry_models.dart';
import 'package:ai_prg/src/core/repositories/symmetry_auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum _VerificationState { emailSent, resending, checking, verified }

class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({required this.onVerified, super.key});

  final VoidCallback onVerified;

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends ConsumerState<EmailVerificationScreen> {
  _VerificationState _state = _VerificationState.emailSent;
  Timer? _pollTimer;
  int _pollAttempts = 0;
  static const int _maxPollAttempts = 12; // ~2 min at 10s intervals

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
      final session =
          await ref.read(symmetryAuthRepositoryProvider).loadSessionWithSyncedProfile();
      if (!mounted) return;
      if (session != null && session.isEmailVerified) {
        _pollTimer?.cancel();
        setState(() => _state = _VerificationState.verified);
        await Future<void>.delayed(const Duration(milliseconds: 1500));
        if (mounted) widget.onVerified();
      }
    } catch (_) {
      // Silently retry — network may be flaky
    }
  }

  Future<void> _resend() async {
    setState(() => _state = _VerificationState.resending);
    try {
      await ref.read(symmetryAuthRepositoryProvider).resendVerification();
      if (!mounted) return;
      _startPolling();
      setState(() => _state = _VerificationState.emailSent);
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
      setState(() => _state = _VerificationState.emailSent);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red.shade800,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final session = ref.watch(symmetrySessionProvider).valueOrNull;
    final email = session?.user.email ?? '';

    if (_state == _VerificationState.verified) {
      return _buildVerified(l10n);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0908),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.mark_email_unread_outlined,
                  size: 64, color: Color(0xFFBFA76F)),
              const SizedBox(height: 24),
              Text(
                l10n.authEmailVerificationTitle,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFE8E4E0),
                  fontFamily: 'Playfair Display',
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.authEmailVerificationMessage(email),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF7A7570),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed:
                      _state == _VerificationState.resending ? null : _resend,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFC87941),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _state == _VerificationState.resending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(l10n.authEmailVerificationResendAction,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  setState(() => _state = _VerificationState.checking);
                  _checkStatus().then((_) {
                    if (mounted &&
                        _state == _VerificationState.checking) {
                      setState(() => _state = _VerificationState.emailSent);
                    }
                  });
                },
                child: Text(l10n.authEmailVerificationCheckAction,
                    style: const TextStyle(color: Color(0xFF7A7570))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerified(final AppLocalizations l10n) => Scaffold(
        backgroundColor: const Color(0xFF0A0908),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle,
                  size: 64, color: Color(0xFF34D399)),
              const SizedBox(height: 24),
              Text(
                l10n.authEmailVerificationSuccess,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFE8E4E0),
                  fontFamily: 'Playfair Display',
                ),
              ),
            ],
          ),
        ),
      );
}
