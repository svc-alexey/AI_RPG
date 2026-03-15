import 'dart:convert';

import 'package:ai_prg/src/app/aether_shell.dart';
import 'package:ai_prg/src/app/app_localizations.dart';
import 'package:ai_prg/src/app/app_scope.dart';
import 'package:ai_prg/src/core/models/ai_settings.dart';
import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/services/ai_client.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _baseUrlController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _timeoutController = TextEditingController();

  AiProviderType _provider = AiProviderType.lmStudio;
  Map<AiProviderType, ProviderProfile> _profiles =
      <AiProviderType, ProviderProfile>{};
  AppLanguage _appLanguage = AppLanguage.ru;
  bool _fastResponses = true;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isChecking = false;
  bool _isDetectingModel = false;
  bool _didLoad = false;
  String? _status;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoad) {
      return;
    }
    _didLoad = true;
    _load();
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    _modelController.dispose();
    _apiKeyController.dispose();
    _timeoutController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.aiSettings)),
      body: AetherBackdrop(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 920),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: AetherPageReveal(
                      child: ListView(
                        children: <Widget>[
                          Text(
                            l10n.aiSettings,
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                          const SizedBox(height: 26),
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
                              selected: <AppLanguage>{_appLanguage},
                              onSelectionChanged: (final selection) {
                                setState(() => _appLanguage = selection.first);
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                          _SettingsSection(
                            title: 'AI Provider',
                            child: Column(
                              children: <Widget>[
                                _ProviderTile(
                                  title: 'LM Studio',
                                  subtitle: 'Local server',
                                  selected: _provider == AiProviderType.lmStudio,
                                  onTap: () => _handleProviderChanged(
                                    AiProviderType.lmStudio,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _ProviderTile(
                                  title: l10n.openAiCompatible,
                                  subtitle: 'OpenAI-compatible API',
                                  selected: _provider ==
                                      AiProviderType.openAiCompatible,
                                  onTap: () => _handleProviderChanged(
                                    AiProviderType.openAiCompatible,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _ProviderTile(
                                  title: l10n.openRouter,
                                  subtitle: 'Unified gateway for many models',
                                  selected: _provider == AiProviderType.openRouter,
                                  onTap: () => _handleProviderChanged(
                                    AiProviderType.openRouter,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _ProviderTile(
                                  title: l10n.deepSeek,
                                  subtitle: 'Official DeepSeek API',
                                  selected: _provider == AiProviderType.deepSeek,
                                  onTap: () => _handleProviderChanged(
                                    AiProviderType.deepSeek,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          _SettingsSection(
                            title: 'Connection',
                            child: Column(
                              children: <Widget>[
                                TextField(
                                  controller: _baseUrlController,
                                  decoration: InputDecoration(
                                    labelText: l10n.baseUrl,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                TextField(
                                  controller: _modelController,
                                  decoration: InputDecoration(
                                    labelText: l10n.model,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                TextField(
                                  controller: _apiKeyController,
                                  decoration: InputDecoration(
                                    labelText: l10n.apiKey,
                                    hintText: l10n.apiKeyHint,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                TextField(
                                  controller: _timeoutController,
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
                                  value: _fastResponses,
                                  onChanged: _provider.supportsFastResponses
                                      ? (final value) {
                                          setState(() => _fastResponses = value);
                                        }
                                      : null,
                                ),
                              ],
                            ),
                          ),
                          if (_status != null) ...<Widget>[
                            const SizedBox(height: 16),
                            Text(
                              _status!,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                          const SizedBox(height: 28),
                          FilledButton(
                            onPressed: _isSaving ? null : _save,
                            child: _isSaving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(l10n.saveSettings),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: <Widget>[
                              OutlinedButton(
                                onPressed: _isChecking ? null : _checkConnection,
                                child: _isChecking
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
                                onPressed: !_provider.supportsModelAutoDetect ||
                                        _isDetectingModel
                                    ? null
                                    : _detectAndApplyLmStudioModel,
                                child: Text(
                                  _isDetectingModel
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

  Future<void> _load() async {
    final AppScope scope = AppScope.of(context);
    final ProviderScopedSettings scoped =
        await scope.settingsRepository.loadProviderScopedSettings();
    final AppLanguage appLanguage =
        await scope.settingsRepository.loadAppLanguage();

    if (!mounted) {
      return;
    }

    _provider = scoped.activeProvider;
    _profiles = Map<AiProviderType, ProviderProfile>.from(scoped.profiles);
    _appLanguage = appLanguage;
    _fastResponses = scoped.fastResponses;
    _applyProfileToForm(scoped.profileFor(_provider));

    setState(() => _isLoading = false);

    if (_provider == AiProviderType.lmStudio) {
      await _detectAndApplyLmStudioModel(silentWhenUnavailable: true);
    }
  }

  void _applyProfileToForm(final ProviderProfile profile) {
    _baseUrlController.text = profile.baseUrl.trim().isEmpty
        ? AiSettings.defaultBaseUrlFor(_provider)
        : profile.baseUrl;
    _modelController.text = profile.model.trim().isEmpty
        ? _provider.defaultModel
        : profile.model;
    _apiKeyController.text = profile.apiKey;
    _timeoutController.text = profile.timeoutSeconds.toString();
  }

  void _saveCurrentFormToProfile() {
    final ProviderProfile current = _profiles[_provider] ??
        ProviderProfile.defaultsFor(_provider);
    _profiles[_provider] = current.copyWith(
      baseUrl: _baseUrlController.text.trim(),
      model: _modelController.text.trim(),
      apiKey: _apiKeyController.text.trim(),
      timeoutSeconds: int.tryParse(_timeoutController.text.trim()) ?? 60,
    );
  }

  Future<void> _save() async {
    setState(() {
      _isSaving = true;
      _status = null;
    });

    _saveCurrentFormToProfile();
    final AppScope scope = AppScope.of(context);
    final ProviderScopedSettings toSave = ProviderScopedSettings(
      activeProvider: _provider,
      profiles: Map<AiProviderType, ProviderProfile>.from(_profiles),
      fastResponses: _fastResponses,
    );
    await scope.settingsRepository.saveProviderScopedSettings(toSave);
    await scope.settingsRepository.saveAppLanguage(_appLanguage);
    scope.appLanguageListenable.value = _appLanguage;

    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = false;
      _status = context.l10n.settingsSaved;
    });
  }

  Future<void> _checkConnection() async {
    setState(() {
      _isChecking = true;
      _status = null;
    });

    try {
      final AppScope scope = AppScope.of(context);
      final AiSettings settings = _buildSettings();
      final AiClient client = scope.aiServiceFactory.create(settings);
      await client.checkConnection(settings: settings);
      if (!mounted) {
        return;
      }
      setState(() => _status = context.l10n.connectionOk);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _status = context.l10n.connectionFailed(error));
    } finally {
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  AiSettings _buildSettings() => AiSettings(
        provider: _provider,
        baseUrl: _baseUrlController.text.trim(),
        model: _modelController.text.trim(),
        apiKey: _apiKeyController.text.trim(),
        timeoutSeconds: int.tryParse(_timeoutController.text.trim()) ?? 60,
        fastResponses: _fastResponses,
      );

  Future<void> _handleProviderChanged(final AiProviderType provider) async {
    _saveCurrentFormToProfile();

    setState(() {
      _provider = provider;
      _status = null;
      final ProviderProfile profile = _profiles[provider] ??
          ProviderProfile.defaultsFor(provider);
      _applyProfileToForm(profile);
      if (provider == AiProviderType.openRouter) {
        final int? currentTimeout = int.tryParse(_timeoutController.text.trim());
        if (currentTimeout == null || currentTimeout < 120) {
          _timeoutController.text = '120';
        }
      }
      if (!provider.supportsFastResponses) {
        _fastResponses = false;
      } else if (!_fastResponses) {
        _fastResponses = true;
      }
    });

    if (provider == AiProviderType.lmStudio) {
      await _detectAndApplyLmStudioModel(silentWhenUnavailable: true);
    }
  }

  Future<void> _detectAndApplyLmStudioModel({
    final bool silentWhenUnavailable = false,
  }) async {
    if (_provider != AiProviderType.lmStudio) {
      return;
    }

    final AppScope scope = AppScope.of(context);
    final AppLocalizations l10n = context.l10n;
    setState(() {
      _isDetectingModel = true;
      if (!silentWhenUnavailable) {
        _status = null;
      }
    });

    final String baseUrl = _baseUrlController.text.trim().isEmpty
        ? const AiSettings.defaults().baseUrl
        : _baseUrlController.text.trim();

    try {
      final List<String> modelIds = await _fetchModelIds(baseUrl, l10n);
      final String modelId = _selectPreferredModel(modelIds);
      if (modelId.isEmpty) {
        if (!silentWhenUnavailable && mounted) {
          setState(() => _status = l10n.noLmStudioModel);
        }
        return;
      }

      _baseUrlController.text = baseUrl;
      _modelController.text = modelId;
      _saveCurrentFormToProfile();
      await scope.settingsRepository.saveProviderScopedSettings(
        ProviderScopedSettings(
          activeProvider: _provider,
          profiles: Map<AiProviderType, ProviderProfile>.from(_profiles),
          fastResponses: _fastResponses,
        ),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _status = l10n.selectedLmStudioModel(modelId);
      });
    } catch (error) {
      if (!mounted || silentWhenUnavailable) {
        return;
      }
      setState(() {
        _status = l10n.detectLmStudioFailed(error);
      });
    } finally {
      if (mounted) {
        setState(() => _isDetectingModel = false);
      }
    }
  }

  Future<List<String>> _fetchModelIds(
    final String baseUrl,
    final AppLocalizations l10n,
  ) async {
    final Uri uri = Uri.parse('${_normalizeBaseUrl(baseUrl)}/models');
    final http.Response response = await http
        .get(
          uri,
          headers: const <String, String>{'Content-Type': 'application/json'},
        )
        .timeout(const Duration(seconds: 5));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(l10n.serverReturned(response.statusCode));
    }

    final Object? decoded = jsonDecode(response.body);
    if (decoded is! Map<String, Object?>) {
      throw Exception(l10n.unexpectedResponseFormat);
    }

    final List<Object?> items =
        (decoded['data'] as List<Object?>?) ?? const <Object?>[];

    return items
        .map((item) => item as Map<String, Object?>?)
        .whereType<Map<String, Object?>>()
        .map((item) => (item['id'] as String?) ?? '')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  String _selectPreferredModel(final List<String> modelIds) {
    if (modelIds.isEmpty) {
      return '';
    }

    final Iterable<String> chatModels = modelIds.where((modelId) {
      final String normalized = modelId.toLowerCase();
      return !normalized.contains('embedding') &&
          !normalized.contains('embed') &&
          !normalized.contains('rerank');
    });

    if (chatModels.isNotEmpty) {
      return chatModels.first;
    }

    return modelIds.first;
  }

  String _normalizeBaseUrl(final String baseUrl) => baseUrl.endsWith('/')
      ? baseUrl.substring(0, baseUrl.length - 1)
      : baseUrl;
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(final BuildContext context) => AetherCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AetherPalette.textMuted,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 16),
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
      highlight: selected,
      child: SizedBox(
        width: double.infinity,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Row(
              children: <Widget>[
                Icon(
                  selected ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: selected
                      ? AetherPalette.accent
                      : AetherPalette.textMuted,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
}
