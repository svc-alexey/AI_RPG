import 'package:ai_prg/src/app/aether_shell.dart';
import 'package:ai_prg/src/app/app_localizations.dart';
import 'package:ai_prg/src/app/app_providers.dart';
import 'package:ai_prg/src/app/responsive.dart';
import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/models/symmetry_models.dart';
import 'package:ai_prg/src/core/utils/legal_urls.dart';
import 'package:ai_prg/src/features/auth/presentation/auth_screen.dart';
import 'package:ai_prg/src/features/settings/application/settings_controller.dart';
import 'package:ai_prg/src/features/settings/presentation/change_password_dialog.dart';
import 'package:ai_prg/src/features/story_admin/presentation/story_admin_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _baseUrlController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _apiKeyController = TextEditingController();
  bool _apiKeyObscured = true;
  final TextEditingController _timeoutController = TextEditingController();
  final FocusNode _urlFocus = FocusNode();
  final FocusNode _modelFocus = FocusNode();
  final FocusNode _apiKeyFocus = FocusNode();
  final FocusNode _timeoutFocus = FocusNode();

  @override
  void dispose() {
    _baseUrlController.dispose();
    _modelController.dispose();
    _apiKeyController.dispose();
    _timeoutController.dispose();
    _urlFocus.dispose();
    _modelFocus.dispose();
    _apiKeyFocus.dispose();
    _timeoutFocus.dispose();
    super.dispose();
  }

  Future<void> _openAuthScreen() async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (final routeContext) => AuthScreen(
          onAuthenticated: () => Navigator.of(routeContext).pop(true),
        ),
      ),
    );
    ref.invalidate(symmetrySessionProvider);
  }

  Future<void> _handleAccountAction(final SymmetrySession? session) async {
    final AppLocalizations l10n = context.l10n;
    if (session == null || session.isGuest) {
      await _openAuthScreen();
      return;
    }
    try {
      await ref.read(symmetryAuthRepositoryProvider).logout();
      ref.invalidate(symmetrySessionProvider);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.signedOutStatus)));
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(l10n.symmetryFriendlyError(error))),
        );
    }
  }

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = context.l10n;
    final AppResponsiveData responsive = context.responsive;
    final SettingsViewState settingsState = ref.watch(
      settingsControllerProvider,
    );
    final AsyncValue<SymmetrySession?> sessionState = ref.watch(
      symmetrySessionProvider,
    );
    final SettingsController controller = ref.read(
      settingsControllerProvider.notifier,
    );

    ref.listen<SettingsViewState>(settingsControllerProvider, (
      final previous,
      final next,
    ) {
      if (next.formRevision != (previous?.formRevision ?? 0)) {
        _baseUrlController.text = next.baseUrl;
        _modelController.text = next.model;
        _apiKeyController.text = next.apiKey;
        _timeoutController.text = next.timeoutText;
      }
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: Text(l10n.homeTertiaryCta)),
      body: settingsState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: responsive.settingsMaxWidth,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(responsive.pagePadding),
                    child: AetherPageReveal(
                      child: ListView(
                        children: <Widget>[
                          Text(
                            l10n.homeTertiaryCta,
                            style: theme.textTheme.headlineLarge,
                            maxLines: 2,
                          ),
                          SizedBox(height: responsive.blockSpacing - 4),
                          _SettingsSection(
                            title: l10n.contentRatingTitle,
                            child: SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(l10n.confirm18Plus),
                              subtitle: Text(l10n.contentRatingSubtitle),
                              value: settingsState.confirmed18Plus,
                              onChanged: controller.setConfirmed18Plus,
                            ),
                          ),
                          SizedBox(height: responsive.sectionSpacing),
                          _SettingsSection(
                            title: l10n.languageTitle,
                            child: SegmentedButton<AppLanguage>(
                              segments: <ButtonSegment<AppLanguage>>[
                                ButtonSegment<AppLanguage>(
                                  value: AppLanguage.ru,
                                  label: Text(l10n.russian),
                                ),
                                ButtonSegment<AppLanguage>(
                                  value: AppLanguage.en,
                                  label: Text(l10n.english),
                                ),
                              ],
                              selected: <AppLanguage>{
                                settingsState.appLanguage,
                              },
                              onSelectionChanged: (final selection) =>
                                  controller.setAppLanguage(selection.first),
                            ),
                          ),
                          SizedBox(height: responsive.sectionSpacing),
                          _SettingsSection(
                            title: l10n.accountTitle,
                            child: sessionState.when(
                              data: (final session) {
                                final bool isSignedIn =
                                    session != null && !session.isGuest;
                                final String email =
                                    session?.user.email.trim() ?? '';
                                final String displayName =
                                    session?.user.displayName.trim() ?? '';
                                final String primaryIdentity =
                                    displayName.isNotEmpty
                                    ? displayName
                                    : email;

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      isSignedIn
                                          ? l10n.homeSignedInCardSubtitle(
                                              primaryIdentity,
                                            )
                                          : l10n.accountSignedOutDescription,
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(height: 1.3),
                                    ),
                                    if (isSignedIn &&
                                        email.isNotEmpty &&
                                        email != primaryIdentity) ...<Widget>[
                                      const SizedBox(height: 6),
                                      Text(
                                        email,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: AetherPalette.textMuted,
                                            ),
                                      ),
                                    ],
                                    const SizedBox(height: 16),
                                    Row(
                                      children: <Widget>[
                                        OutlinedButton.icon(
                                          onPressed: () =>
                                              _handleAccountAction(session),
                                          icon: Icon(
                                            isSignedIn
                                                ? Icons.logout_rounded
                                                : Icons.login_rounded,
                                          ),
                                          label: Text(
                                            isSignedIn
                                                ? l10n.signOutAction
                                                : l10n.loginAction,
                                          ),
                                        ),
                                        if (isSignedIn) ...[
                                          const SizedBox(width: 12),
                                          OutlinedButton.icon(
                                            onPressed: () {
                                              showDialog<bool>(
                                                context: context,
                                                builder: (_) =>
                                                    const ChangePasswordDialog(),
                                              );
                                            },
                                            icon: const Icon(
                                              Icons.lock_outline,
                                              size: 20,
                                            ),
                                            label: Text(
                                              l10n.changePasswordAction,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                );
                              },
                              loading: () => const SizedBox(
                                height: 32,
                                width: 32,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              error: (final error, final stackTrace) => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    l10n.accountSignedOutDescription,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(height: 1.3),
                                  ),
                                  const SizedBox(height: 16),
                                  OutlinedButton.icon(
                                    onPressed: _openAuthScreen,
                                    icon: const Icon(Icons.login_rounded),
                                    label: Text(l10n.loginAction),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          sessionState.maybeWhen(
                            data: (final session) {
                              final bool showAdmin =
                                  session != null &&
                                  !session.isGuest &&
                                  session.user.isAdmin;
                              if (!showAdmin) {
                                return const SizedBox.shrink();
                              }
                              return Column(
                                children: <Widget>[
                                  SizedBox(height: responsive.sectionSpacing),
                                  _SettingsSection(
                                    title: l10n.storyAdminTitle,
                                    child: ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: const Icon(
                                        Icons.library_books_outlined,
                                      ),
                                      title: Text(l10n.storyAdminTitle),
                                      subtitle: Text(
                                        l10n.storyAdminMenuSubtitle,
                                      ),
                                      trailing: const Icon(
                                        Icons.chevron_right_rounded,
                                      ),
                                      onTap: () {
                                        Navigator.of(context).push<void>(
                                          MaterialPageRoute<void>(
                                            builder: (final ctx) =>
                                                const StoryAdminScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              );
                            },
                            orElse: () => const SizedBox.shrink(),
                          ),
                          sessionState.maybeWhen(
                            data: (final session) {
                              if (session == null ||
                                  session.isGuest ||
                                  session.isEmailVerified) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: EdgeInsets.only(
                                    bottom: responsive.sectionSpacing),
                                child: _EmailVerificationStatus(
                                  session: session,
                                  l10n: l10n,
                                ),
                              );
                            },
                            orElse: () => const SizedBox.shrink(),
                          ),
                          SizedBox(height: responsive.sectionSpacing),
                          _SettingsSection(
                            title: l10n.personalModelTitle,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  l10n.personalModelHint,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 12),
                                FocusTraversalGroup(
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        TextFormField(
                                          controller: _baseUrlController,
                                          focusNode: _urlFocus,
                                          onChanged: controller.setBaseUrl,
                                          keyboardType: TextInputType.url,
                                          autocorrect: false,
                                          enableSuggestions: false,
                                          textInputAction: TextInputAction.next,
                                          onFieldSubmitted: (_) =>
                                              _modelFocus.requestFocus(),
                                          decoration: InputDecoration(
                                            labelText: l10n.baseUrl,
                                            hintText:
                                                'https://api.example.com/v1',
                                          ),
                                        ),
                                        if (settingsState
                                            .showEndpointBuildDefaultsHint)
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8),
                                            child: Text(
                                              l10n.endpointBuildDefaultsHint,
                                              style: theme
                                                  .textTheme.bodySmall
                                                  ?.copyWith(
                                                    color: AetherPalette
                                                        .textMuted,
                                                    height: 1.35,
                                                  ),
                                            ),
                                          ),
                                        const SizedBox(height: 12),
                                        TextFormField(
                                          controller: _modelController,
                                          focusNode: _modelFocus,
                                          onChanged: controller.setModel,
                                          textInputAction: TextInputAction.next,
                                          onFieldSubmitted: (_) =>
                                              _apiKeyFocus.requestFocus(),
                                          decoration: InputDecoration(
                                            labelText: l10n.model,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        TextFormField(
                                          controller: _apiKeyController,
                                          focusNode: _apiKeyFocus,
                                          obscureText: _apiKeyObscured,
                                          autocorrect: false,
                                          enableSuggestions: false,
                                          keyboardType:
                                              TextInputType.visiblePassword,
                                          onChanged: controller.setApiKey,
                                          textInputAction: TextInputAction.next,
                                          onFieldSubmitted: (_) =>
                                              _timeoutFocus.requestFocus(),
                                          decoration: InputDecoration(
                                            labelText: l10n.apiKey,
                                            hintText: l10n.apiKeyHint,
                                            suffixIcon: IconButton(
                                              tooltip: _apiKeyObscured
                                                  ? l10n.showApiKey
                                                  : l10n.hideApiKey,
                                              icon: Icon(
                                                _apiKeyObscured
                                                    ? Icons
                                                        .visibility_outlined
                                                    : Icons
                                                        .visibility_off_outlined,
                                              ),
                                              onPressed: () => setState(
                                                () =>
                                                    _apiKeyObscured =
                                                        !_apiKeyObscured,
                                              ),
                                            ),
                                          ),
                                        ),
                                        if (settingsState
                                            .showApiKeyFromBuildHint)
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8),
                                            child: Text(
                                              l10n.apiKeyBuildTimeHiddenHint,
                                              style: theme
                                                  .textTheme.bodySmall
                                                  ?.copyWith(
                                                    color: AetherPalette
                                                        .textMuted,
                                                    height: 1.35,
                                                  ),
                                            ),
                                          ),
                                        const SizedBox(height: 12),
                                        TextFormField(
                                          controller: _timeoutController,
                                          focusNode: _timeoutFocus,
                                          onChanged: controller.setTimeoutText,
                                          keyboardType: TextInputType.number,
                                          textInputAction: TextInputAction.go,
                                          onFieldSubmitted: (_) {
                                            if (!settingsState.isSaving) {
                                              controller.save(l10n: l10n);
                                            }
                                          },
                                          validator: (v) {
                                            if (v != null &&
                                                v.isNotEmpty &&
                                                int.tryParse(v.trim()) ==
                                                    null) {
                                              return switch (l10n.language) {
                                                AppLanguage.ru =>
                                                  'Введите число',
                                                AppLanguage.en =>
                                                  'Enter a number',
                                              };
                                            }
                                            return null;
                                          },
                                          decoration: InputDecoration(
                                            labelText: l10n.timeoutSeconds,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (kIsWeb) ...[
                            SizedBox(height: responsive.sectionSpacing),
                            _SettingsSection(
                              title: l10n.legalInfoTitle,
                              child: _LegalLinks(l10n: l10n),
                            ),
                          ],
                          if (settingsState.status != null) ...[
                            SizedBox(height: responsive.sectionSpacing),
                            Row(
                              children: <Widget>[
                                Icon(
                                  settingsState.status!.contains('успешно') ||
                                          settingsState.status!.contains(
                                            'successful',
                                          )
                                      ? Icons.check_circle_outline_rounded
                                      : Icons.info_outline_rounded,
                                  size: 18,
                                  color:
                                      settingsState.status!.contains(
                                            'успешно',
                                          ) ||
                                          settingsState.status!.contains(
                                            'successful',
                                          )
                                      ? Colors.green
                                      : AetherPalette.textMuted,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    settingsState.status!,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          SizedBox(height: responsive.blockSpacing),
                          FilledButton(
                            onPressed: settingsState.isSaving
                                ? null
                                : () => controller.save(l10n: l10n),
                            child: settingsState.isSaving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(l10n.saveSettings),
                          ),
                          const SizedBox(height: 10),
                          OutlinedButton(
                            onPressed: settingsState.isChecking
                                ? null
                                : () => controller.checkConnection(l10n: l10n),
                            child: settingsState.isChecking
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(l10n.checkConnection),
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

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(final BuildContext context) => AetherCard(
    padding: EdgeInsets.all(context.responsive.cardPadding),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title.toUpperCase(),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AetherPalette.textMuted,
            letterSpacing: context.responsive.scaleLetterSpacing(3),
          ),
        ),
        SizedBox(height: context.responsive.sectionSpacing),
        child,
      ],
    ),
  );
}

class _EmailVerificationStatus extends ConsumerStatefulWidget {
  const _EmailVerificationStatus({
    required this.session,
    required this.l10n,
  });

  final SymmetrySession session;
  final AppLocalizations l10n;

  @override
  ConsumerState<_EmailVerificationStatus> createState() =>
      _EmailVerificationStatusState();
}

class _EmailVerificationStatusState
    extends ConsumerState<_EmailVerificationStatus> {
  bool _resending = false;

  Future<void> _resend() async {
    setState(() => _resending = true);
    try {
      await ref.read(symmetryAuthRepositoryProvider).resendVerification();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.l10n.authEmailVerificationResendSuccess),
          backgroundColor: const Color(0xFF34D399).withAlpha(220),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final String message;
      if (e.toString().contains('resend_too_soon')) {
        message = widget.l10n.authEmailVerificationResendTooSoon;
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
    final l10n = widget.l10n;
    final email = widget.session.user.email;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F0D0B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF7A7570).withAlpha(50)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.settingsEmailStatusTitle,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFFE8E4E0),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.close, size: 16, color: Color(0xFFC87941)),
              const SizedBox(width: 8),
              Text(
                l10n.settingsEmailStatusNotVerified,
                style: const TextStyle(
                  color: Color(0xFFC87941),
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: const TextStyle(
              color: Color(0xFF7A7570),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: _resending ? null : _resend,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFC87941)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _resending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Color(0xFFC87941)),
                    )
                  : Text(
                      l10n.settingsEmailResendAction,
                      style: const TextStyle(
                        color: Color(0xFFC87941),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegalLinks extends StatelessWidget {
  const _LegalLinks({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(final BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      for (final page in legalPages)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: InkWell(
            onTap: () => _openLegalPage(page),
            child: Row(
              children: <Widget>[
                Icon(
                  _iconForPage(page),
                  size: 18,
                  color: AetherPalette.textMuted,
                ),
                const SizedBox(width: 12),
                Text(
                  _titleForPage(page, l10n),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AetherPalette.narrativeText,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.open_in_new_rounded,
                  size: 14,
                  color: AetherPalette.textMuted,
                ),
              ],
            ),
          ),
        ),
    ],
  );

  static IconData _iconForPage(final String page) => switch (page) {
    'offer' => Icons.description_outlined,
    'privacy' => Icons.privacy_tip_outlined,
    'consent' => Icons.check_box_outlined,
    'refunds' => Icons.receipt_long_outlined,
    'contacts' => Icons.contact_mail_outlined,
    _ => Icons.article_outlined,
  };

  static String _titleForPage(final String page, final AppLocalizations l10n) {
    final bool isRu = l10n.language == AppLanguage.ru;
    return switch (page) {
      'offer' => isRu ? 'Лицензионный договор (Оферта)' : 'License Agreement (Offer)',
      'privacy' => isRu ? 'Политика конфиденциальности' : 'Privacy Policy',
      'consent' => isRu ? 'Согласие на обработку ПД' : 'Data Processing Consent',
      'refunds' => isRu ? 'Условия возврата' : 'Refund Policy',
      'contacts' => isRu ? 'Контакты и реквизиты' : 'Contact Information',
      'pricing' => isRu ? 'Цены' : 'Pricing',
      _ => page,
    };
  }

  static Future<void> _openLegalPage(final String page) async {
    final uri = Uri.parse(buildLegalUrl(page));
    await launchUrl(uri, webOnlyWindowName: '_blank');
  }
}
