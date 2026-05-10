import 'dart:async';

import 'package:ai_prg/src/app/app_localizations.dart';
import 'package:ai_prg/src/app/app_providers.dart';
import 'package:ai_prg/src/app/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  bool _isSubmitting = false;
  bool _success = false;
  String? _error;
  Timer? _cooldownTimer;
  int _cooldownSeconds = 0;
  String _lastEmail = '';

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocus.dispose();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  Future<void> _submit() async {
    final AppLocalizations l10n = context.l10n;
    if (!_formKey.currentState!.validate()) return;

    final String email = _emailController.text.trim();
    setState(() {
      _isSubmitting = true;
      _error = null;
      _success = false;
    });

    try {
      await ref
          .read(symmetryAuthRepositoryProvider)
          .forgotPassword(email: email);
      if (!mounted) return;
      setState(() {
        _success = true;
        _lastEmail = email;
        _cooldownSeconds = 60;
      });
      _startCooldown();
    } catch (error) {
      if (!mounted) return;
      final bool isSmtpError = error.toString().contains('502') ||
          error.toString().contains('SMTP');
      setState(() {
        _error = isSmtpError
            ? l10n.forgotPasswordSmtpError
            : l10n.symmetryFriendlyError(error);
      });
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _cooldownSeconds = _cooldownSeconds > 0 ? _cooldownSeconds - 1 : 0;
      });
      if (_cooldownSeconds == 0) {
        timer.cancel();
      }
    });
  }

  bool _looksLikeEmail(final String value) {
    final int atIndex = value.indexOf('@');
    if (atIndex <= 0 || atIndex >= value.length - 3) return false;
    return value.substring(atIndex + 1).contains('.');
  }

  @override
  Widget build(final BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final AppResponsiveData responsive = context.responsive;
    final bool isBusy = _isSubmitting || _cooldownSeconds > 0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: Text(l10n.forgotPasswordTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: EdgeInsets.all(responsive.pagePadding),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    l10n.forgotPasswordTitle,
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.forgotPasswordDescription,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _emailController,
                    focusNode: _emailFocus,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.go,
                    onFieldSubmitted: (_) => _submit(),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return l10n.authEmailRequired;
                      }
                      if (!_looksLikeEmail(v.trim())) {
                        return l10n.authEmailInvalid;
                      }
                      return null;
                    },
                    decoration: InputDecoration(labelText: l10n.emailLabel),
                  ),
                  if (_error != null) ...<Widget>[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  if (_success) ...<Widget>[
                    const SizedBox(height: 12),
                    Text(
                      l10n.forgotPasswordEmailSent(_lastEmail),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF34D399),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: isBusy ? null : _submit,
                    child: isBusy
                        ? _cooldownSeconds > 0
                            ? Text(l10n.forgotPasswordCooldown(_cooldownSeconds))
                            : const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                        : Text(l10n.forgotPasswordSendAction),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
