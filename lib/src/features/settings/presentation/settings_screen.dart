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
                            title: 'AI Provider',
                            child: Column(
                              children: <Widget>[
                                _ProviderTile(
                                  title: 'LM Studio',
                                  subtitle: 'Local server',
                                  selected:
                                      settingsState.provider ==
                                      AiProviderType.lmStudio,
                                  onTap: () => controller.changeProvider(
                                    AiProviderType.lmStudio,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _ProviderTile(
                                  title: l10n.openAiCompatible,
                                  subtitle: 'OpenAI-compatible API',
                                  selected:
                                      settingsState.provider ==
                                      AiProviderType.openAiCompatible,
                                  onTap: () => controller.changeProvider(
                                    AiProviderType.openAiCompatible,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _ProviderTile(
                                  title: l10n.openRouter,
                                  subtitle: 'Unified gateway for many models',
                                  selected:
                                      settingsState.provider ==
                                      AiProviderType.openRouter,
                                  onTap: () => controller.changeProvider(
                                    AiProviderType.openRouter,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _ProviderTile(
                                  title: l10n.deepSeek,
                                  subtitle: 'Official DeepSeek API',
                                  selected:
                                      settingsState.provider ==
                                      AiProviderType.deepSeek,
                                  onTap: () => controller.changeProvider(
                                    AiProviderType.deepSeek,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _ProviderTile(
                                  title: l10n.sberGigaChat,
                                  subtitle: l10n.sberGigaChatSubtitle,
                                  selected:
                                      settingsState.provider ==
                                      AiProviderType.sberGigaChat,
                                  onTap: () => controller.changeProvider(
                                    AiProviderType.sberGigaChat,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: responsive.sectionSpacing),
                          _SettingsSection(
                            title: 'Connection',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                if (settingsState
                                    .provider
                                    .hidesConnectionSecrets)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Text(
                                      l10n.sberManagedConnectionNotice,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                  ),
                                if (!settingsState
                                    .provider
                                    .hidesConnectionSecrets)
                                  TextField(
                                    controller: _baseUrlController,
                                    onChanged: controller.setBaseUrl,
                                    decoration: InputDecoration(
                                      labelText: l10n.baseUrl,
                                    ),
                                  ),
                                if (!settingsState
                                    .provider
                                    .hidesConnectionSecrets)
                                  const SizedBox(height: 12),
                                if (!settingsState.provider.hidesModelField)
                                  TextField(
                                    controller: _modelController,
                                    onChanged: controller.setModel,
                                    decoration: InputDecoration(
                                      labelText: l10n.model,
                                    ),
                                  ),
                                if (!settingsState.provider.hidesModelField)
                                  const SizedBox(height: 12),
                                if (!settingsState
                                    .provider
                                    .hidesConnectionSecrets)
                                  TextField(
                                    controller: _apiKeyController,
                                    onChanged: controller.setApiKey,
                                    decoration: InputDecoration(
                                      labelText: l10n.apiKey,
                                      hintText: l10n.apiKeyHint,
                                    ),
                                  ),
                                if (!settingsState
                                    .provider
                                    .hidesConnectionSecrets)
                                  const SizedBox(height: 12),
                                TextField(
                                  controller: _timeoutController,
                                  onChanged: controller.setTimeoutText,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: l10n.timeoutSeconds,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                SwitchListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(l10n.fastModeTitle),
                                  subtitle: Text(l10n.fastModeSubtitle),
                                  value: settingsState.fastResponses,
                                  onChanged:
                                      settingsState
                                          .provider
                                          .supportsFastResponses
                                      ? controller.setFastResponses
                                      : null,
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
                                  settingsState.status!.contains(
                                            'СѓСЃРїРµС€РЅРѕ',
                                          ) ||
                                          settingsState.status!.contains(
                                            'successful',
                                          )
                                      ? Icons.check_circle_outline_rounded
                                      : Icons.info_outline_rounded,
                                  size: 18,
                                  color:
                                      settingsState.status!.contains(
                                            'СѓСЃРїРµС€РЅРѕ',
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
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: <Widget>[
                              OutlinedButton(
                                onPressed: settingsState.isChecking
                                    ? null
                                    : () => controller.checkConnection(
                                        l10n: l10n,
                                      ),
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
                              OutlinedButton(
                                onPressed:
                                    !settingsState
                                            .provider
                                            .supportsModelAutoDetect ||
                                        settingsState.isDetectingModel
                                    ? null
                                    : controller.detectAndApplyLmStudioModel,
                                child: Text(
                                  settingsState.isDetectingModel
                                      ? l10n.detectingModel
                                      : l10n.detectModel,
                                ),
                              ),
                            ],
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

class _ProviderTile extends StatelessWidget {
  const _ProviderTile({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(final BuildContext context) => AetherCard(
    padding: EdgeInsets.all(context.responsive.cardPadding),
    highlight: selected,
    child: SizedBox(
      width: double.infinity,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: context.responsive.isCompact ? 48 : 56,
          ),
          child: Row(
            children: <Widget>[
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected
                    ? AetherPalette.accent
                    : AetherPalette.textMuted,
              ),
              SizedBox(width: context.responsive.isCompact ? 12 : 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
