import 'package:ai_prg/src/app/aether_shell.dart';
import 'package:ai_prg/src/app/app_localizations.dart';
import 'package:ai_prg/src/app/app_providers.dart';
import 'package:ai_prg/src/app/responsive.dart';
import 'package:ai_prg/src/core/models/symmetry_models.dart';
import 'package:ai_prg/src/core/services/app_logger.dart';
import 'package:ai_prg/src/features/auth/presentation/forgot_password_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({required this.onAuthenticated, super.key});

  final VoidCallback onAuthenticated;

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey _submitButtonKey = GlobalKey();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _displayNameController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();
  final FocusNode _displayNameFocus = FocusNode();
  final ScrollController _scrollController = ScrollController();
  bool _isSubmitting = false;
  bool _isYandexSubmitting = false;
  bool _registerMode = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    for (final FocusNode node in <FocusNode>[
      _emailFocus,
      _passwordFocus,
      _confirmPasswordFocus,
      _displayNameFocus,
    ]) {
      node.addListener(() {
        if (node.hasFocus) {
          _scrollToSubmitButton();
        }
      });
    }
  }

  void _scrollToSubmitButton() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _displayNameController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    _displayNameFocus.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final AppResponsiveData responsive = context.responsive;
    final AsyncValue<SymmetrySession?> sessionState = ref.watch(
      symmetrySessionProvider,
    );
    final bool isSignedInNonGuest = sessionState.maybeWhen(
      data: (final session) => session != null && !session.isGuest,
      orElse: () => false,
    );
    final bool isBusy = _isSubmitting || _isYandexSubmitting;

    final double bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: EdgeInsets.all(responsive.pagePadding),
            child: AetherCard(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: EdgeInsets.only(bottom: bottomInset),
                  child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        const Spacer(),
                        IconButton(
                          tooltip: l10n.closeAction,
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    Text(
                      l10n.authTitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    if (isSignedInNonGuest) ...<Widget>[
                      const SizedBox(height: 16),
                      Text(
                        l10n.authAlreadySignedInHint,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: isBusy
                            ? null
                            : () => widget.onAuthenticated(),
                        child: Text(l10n.homeSecondaryCta),
                      ),
                    ],
                    if (kIsWeb) ...<Widget>[
                      const SizedBox(height: 20),
                      OutlinedButton.icon(
                        onPressed: isBusy ? null : _continueWithYandex,
                        icon: _isYandexSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.account_circle_outlined),
                        label: Text(l10n.authContinueWithYandexAction),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.authContinueWithEmailHint,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    FocusTraversalGroup(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            TextFormField(
                              controller: _emailController,
                              focusNode: _emailFocus,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (_) =>
                                  _passwordFocus.requestFocus(),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty)
                                  return l10n.authEmailRequired;
                                if (!_looksLikeEmail(v.trim()))
                                  return l10n.authEmailInvalid;
                                return null;
                              },
                              decoration: InputDecoration(
                                labelText: l10n.emailLabel,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _passwordController,
                              focusNode: _passwordFocus,
                              obscureText: true,
                              textInputAction: _registerMode
                                  ? TextInputAction.next
                                  : TextInputAction.go,
                              onFieldSubmitted: (_) {
                                if (_registerMode) {
                                  _confirmPasswordFocus.requestFocus();
                                } else {
                                  _submit();
                                }
                              },
                              onChanged: (_) {
                                if (_registerMode) {
                                  setState(() {});
                                }
                              },
                              validator: (v) {
                                if (v == null || v.isEmpty)
                                  return l10n.authPasswordRequired;
                                if (v.length < 8)
                                  return l10n.authPasswordTooShort;
                                return null;
                              },
                              decoration: InputDecoration(
                                labelText: l10n.passwordLabel,
                              ),
                            ),
                            if (_registerMode) ...[
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _confirmPasswordController,
                                focusNode: _confirmPasswordFocus,
                                obscureText: true,
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (_) =>
                                    _displayNameFocus.requestFocus(),
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return l10n.authPasswordsMismatch;
                                  }
                                  if (v != _passwordController.text) {
                                    return l10n.authPasswordsMismatch;
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  labelText: l10n.authConfirmPasswordLabel,
                                  suffixIcon:
                                      _confirmPasswordController
                                              .text
                                              .isNotEmpty
                                          ? Icon(
                                              _confirmPasswordController.text ==
                                                      _passwordController.text
                                                  ? Icons.check_circle_outline
                                                  : Icons.cancel_outlined,
                                              color:
                                                  _confirmPasswordController.text ==
                                                          _passwordController.text
                                                      ? const Color(0xFF34D399)
                                                      : const Color(0xFFEF4444),
                                            )
                                          : null,
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _displayNameController,
                                focusNode: _displayNameFocus,
                                textInputAction: TextInputAction.go,
                                onFieldSubmitted: (_) => _submit(),
                                validator: (v) {
                                  if (v != null &&
                                      v.trim().length > 120)
                                    return l10n.authDisplayNameTooLong;
                                  return null;
                                },
                                decoration: InputDecoration(
                                  labelText: l10n.displayNameLabel,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
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
                    if (!_registerMode &&
                        sessionState.maybeWhen(
                          data: (s) => s == null || !s.isGuest,
                          orElse: () => false,
                        )) ...[
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: isBusy
                              ? null
                              : () => Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) =>
                                          const ForgotPasswordScreen(),
                                    ),
                                  ),
                          child: Text(l10n.forgotPasswordLink),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    FilledButton(
                      key: _submitButtonKey,
                      onPressed: isBusy ? null : _submit,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              _registerMode
                                  ? l10n.registerAction
                                  : l10n.loginAction,
                            ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: isBusy
                          ? null
                          : () => setState(() {
                              _registerMode = !_registerMode;
                              _error = null;
                            }),
                      child: Text(
                        _registerMode
                            ? l10n.switchToLoginAction
                            : l10n.switchToRegisterAction,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _continueWithYandex() async {
    setState(() {
      _isYandexSubmitting = true;
      _error = null;
    });
    try {
      final Uri startUri = await ref
          .read(symmetryAuthRepositoryProvider)
          .buildYandexStartUri();
      final bool launched = await launchUrl(
        startUri,
        webOnlyWindowName: '_self',
      );
      if (!launched) {
        throw StateError('yandex_sign_in_launch_failed');
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = context.l10n.authYandexFailed(error);
        _isYandexSubmitting = false;
      });
    }
  }

  Future<void> _submit() async {
    final AppLocalizations l10n = context.l10n;

    if (!_formKey.currentState!.validate()) return;

    final String email = _emailController.text.trim();
    final String password = _passwordController.text;
    final String displayName = _displayNameController.text.trim();

    final session = ref.read(symmetrySessionProvider).valueOrNull;
    final String? guestUserId =
        (session != null && session.isGuest) ? session.user.id : null;

    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    try {
      if (_registerMode) {
        await ref
            .read(symmetryAuthRepositoryProvider)
            .register(
              email: email,
              password: password,
              displayName: displayName,
            );
        final migrated =
            guestUserId != null &&
            await _tryMigrateGuest(guestUserId);
        if (!mounted) return;
        if (!migrated) {
          AppLogger.logDiagnostic(
            level: 'WARN',
            event: 'guest_migration_skipped',
            message: 'Guest migration was not performed.',
          );
        }
      } else {
        await ref
            .read(symmetryAuthRepositoryProvider)
            .login(email: email, password: password);
      }
      if (!mounted) {
        return;
      }
      widget.onAuthenticated();
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = _humanizeAuthError(l10n, error);
      });
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<bool> _tryMigrateGuest(final String guestUserId) async {
    try {
      await ref
          .read(billingRepositoryProvider)
          .migrateGuestCampaigns(guestUserId);
      return true;
    } catch (_) {
      return false;
    }
  }

  String? _validateInputs({
    required final AppLocalizations l10n,
    required final String email,
    required final String password,
    required final String displayName,
  }) {
    if (email.isEmpty) {
      return l10n.authEmailRequired;
    }
    if (!_looksLikeEmail(email)) {
      return l10n.authEmailInvalid;
    }
    if (password.isEmpty) {
      return l10n.authPasswordRequired;
    }
    if (password.length < 8) {
      return l10n.authPasswordTooShort;
    }
    if (_registerMode && displayName.length > 120) {
      return l10n.authDisplayNameTooLong;
    }
    return null;
  }

  bool _looksLikeEmail(final String value) {
    final int atIndex = value.indexOf('@');
    if (atIndex <= 0 || atIndex >= value.length - 3) {
      return false;
    }
    return value.substring(atIndex + 1).contains('.');
  }

  String _humanizeAuthError(final AppLocalizations l10n, final Object error) {
    if (error is SymmetryApiException && error.detailCode == 'email_taken') {
      return l10n.authEmailTaken;
    }
    if (error is SymmetryApiException && error.detailCode == 'invalid_login') {
      return l10n.authInvalidLogin;
    }
    if (error is SymmetryApiException && error.hasValidationErrors) {
      return _registerMode
          ? l10n.authRegisterValidationFailed
          : l10n.authLoginValidationFailed;
    }
    if (error is SymmetryApiException &&
        error.message == 'symmetry_unreachable') {
      return l10n.authBackendUnavailable;
    }
    return _registerMode
        ? l10n.authRegisterFailed(error)
        : l10n.authLoginFailed(error);
  }
}
