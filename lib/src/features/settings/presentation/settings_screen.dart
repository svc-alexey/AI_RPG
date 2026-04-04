import 'package:ai_prg/src/app/aether_shell.dart';
import 'package:ai_prg/src/app/app_localizations.dart';
import 'package:ai_prg/src/app/responsive.dart';
import 'package:ai_prg/src/core/models/ai_settings.dart';
import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/features/settings/application/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final TextEditingController _baseUrlController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _apiKeyController = TextEditingController();
  bool _apiKeyObscured = true;
  final TextEditingController _timeoutController = TextEditingController();
  final TextEditingController _maxResponseTokensController =
      TextEditingController();
  final TextEditingController _contextWindowSizeController =
      TextEditingController();

  @override
  void dispose() {
    _baseUrlController.dispose();
    _modelController.dispose();
    _apiKeyController.dispose();
    _timeoutController.dispose();
    _maxResponseTokensController.dispose();
    _contextWindowSizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final AppResponsiveData responsive = context.responsive;
    final SettingsViewState settingsState = ref.watch(
      settingsControllerProvider,
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
        _maxResponseTokensController.text = next.maxResponseTokensText;
        _contextWindowSizeController.text = next.contextWindowSizeText;
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.aiSettings)),
      body: AetherBackdrop(
        child: settingsState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: responsive.dialogMaxWidth,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(responsive.pagePadding),
                    child: AetherPageReveal(
                      child: ListView(
                        children: <Widget>[
                          Text(
                            l10n.aiSettings,
                            style: Theme.of(context).textTheme.headlineLarge,
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
                            title: l10n.openAiCompatible,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Configure any OpenAI-compatible endpoint.',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 12),
                                if (settingsState.showEndpointBuildDefaultsHint) ...<Widget>[
                                  Text(
                                    l10n.endpointBuildDefaultsHint,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: AetherPalette.textMuted),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                                TextField(
                                  controller: _baseUrlController,
                                  onChanged: controller.setBaseUrl,
                                  decoration: InputDecoration(
                                    labelText: l10n.baseUrl,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: _modelController,
                                  onChanged: controller.setModel,
                                  decoration: InputDecoration(
                                    labelText: l10n.model,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                if (settingsState.showApiKeyFromBuildHint) ...<Widget>[
                                  Text(
                                    l10n.apiKeyBuildTimeHiddenHint,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: AetherPalette.textMuted),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                                TextField(
                                  controller: _apiKeyController,
                                  obscureText: _apiKeyObscured,
                                  autocorrect: false,
                                  enableSuggestions: false,
                                  keyboardType: TextInputType.visiblePassword,
                                  onChanged: controller.setApiKey,
                                  decoration: InputDecoration(
                                    labelText: l10n.apiKey,
                                    hintText: l10n.apiKeyHint,
                                    suffixIcon: IconButton(
                                      tooltip: _apiKeyObscured
                                          ? l10n.showApiKey
                                          : l10n.hideApiKey,
                                      icon: Icon(
                                        _apiKeyObscured
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                      ),
                                      onPressed: () => setState(
                                        () => _apiKeyObscured = !_apiKeyObscured,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: _timeoutController,
                                  onChanged: controller.setTimeoutText,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: l10n.timeoutSeconds,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: responsive.sectionSpacing),
                          _SettingsSection(
                            title: l10n.runtimeControlsTitle,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  l10n.runtimeControlsDescription,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: <Widget>[
                                    ChoiceChip(
                                      label: Text(l10n.runtimeProfileCheap),
                                      selected:
                                          settingsState.runtimeProfile ==
                                          ModelRuntimeProfile.cheap,
                                      onSelected: (_) =>
                                          controller.applyRuntimeProfile(
                                            ModelRuntimeProfile.cheap,
                                          ),
                                    ),
                                    ChoiceChip(
                                      label: Text(l10n.runtimeProfileFast),
                                      selected:
                                          settingsState.runtimeProfile ==
                                          ModelRuntimeProfile.fast,
                                      onSelected: (_) =>
                                          controller.applyRuntimeProfile(
                                            ModelRuntimeProfile.fast,
                                          ),
                                    ),
                                    ChoiceChip(
                                      label: Text(l10n.runtimeProfileSmart),
                                      selected:
                                          settingsState.runtimeProfile ==
                                          ModelRuntimeProfile.smart,
                                      onSelected: (_) =>
                                          controller.applyRuntimeProfile(
                                            ModelRuntimeProfile.smart,
                                          ),
                                    ),
                                    if (settingsState.runtimeProfile ==
                                        ModelRuntimeProfile.custom)
                                      Chip(
                                        label: Text(l10n.runtimeProfileCustom),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: _maxResponseTokensController,
                                  onChanged:
                                      controller.setMaxResponseTokensText,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: l10n.maxResponseTokens,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: _contextWindowSizeController,
                                  onChanged:
                                      controller.setContextWindowSizeText,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: l10n.contextWindowSize,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (settingsState.status != null) ...<Widget>[
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
