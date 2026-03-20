import 'dart:convert';

import 'package:ai_prg/src/app/app_localizations.dart';
import 'package:ai_prg/src/app/app_providers.dart';
import 'package:ai_prg/src/core/models/ai_settings.dart';
import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/repositories/settings_repository.dart';
import 'package:ai_prg/src/core/services/ai_client.dart';
import 'package:ai_prg/src/core/services/ai_service_factory.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final settingsControllerProvider =
    StateNotifierProvider.autoDispose<SettingsController, SettingsViewState>(
      (final ref) => SettingsController(ref)..load(),
    );

class SettingsViewState {
  const SettingsViewState({
    required this.provider,
    required this.profiles,
    required this.appLanguage,
    required this.fastResponses,
    required this.confirmed18Plus,
    required this.isLoading,
    required this.isSaving,
    required this.isChecking,
    required this.isDetectingModel,
    required this.baseUrl,
    required this.model,
    required this.apiKey,
    required this.timeoutText,
    required this.runtimeProfile,
    required this.maxResponseTokensText,
    required this.contextWindowSizeText,
    required this.status,
    required this.formRevision,
  });

  factory SettingsViewState.initial() => SettingsViewState(
    provider: AiProviderType.lmStudio,
    profiles: <AiProviderType, ProviderProfile>{
      for (final AiProviderType provider in AiProviderType.values)
        provider: ProviderProfile.defaultsFor(provider),
    },
    appLanguage: AppLanguage.ru,
    fastResponses: true,
    confirmed18Plus: false,
    isLoading: true,
    isSaving: false,
    isChecking: false,
    isDetectingModel: false,
    baseUrl: AiSettings.defaultBaseUrlFor(AiProviderType.lmStudio),
    model: AiProviderType.lmStudio.defaultModel,
    apiKey: '',
    timeoutText: '60',
    runtimeProfile: ModelRuntimeSettings.fastPreset.profile,
    maxResponseTokensText: ModelRuntimeSettings.fastPreset.maxResponseTokens
        .toString(),
    contextWindowSizeText: ModelRuntimeSettings.fastPreset.contextWindowSize
        .toString(),
    status: null,
    formRevision: 0,
  );

  static const Object _unset = Object();

  final AiProviderType provider;
  final Map<AiProviderType, ProviderProfile> profiles;
  final AppLanguage appLanguage;
  final bool fastResponses;
  final bool confirmed18Plus;
  final bool isLoading;
  final bool isSaving;
  final bool isChecking;
  final bool isDetectingModel;
  final String baseUrl;
  final String model;
  final String apiKey;
  final String timeoutText;
  final ModelRuntimeProfile runtimeProfile;
  final String maxResponseTokensText;
  final String contextWindowSizeText;
  final String? status;
  final int formRevision;

  SettingsViewState copyWith({
    final AiProviderType? provider,
    final Map<AiProviderType, ProviderProfile>? profiles,
    final AppLanguage? appLanguage,
    final bool? fastResponses,
    final bool? confirmed18Plus,
    final bool? isLoading,
    final bool? isSaving,
    final bool? isChecking,
    final bool? isDetectingModel,
    final String? baseUrl,
    final String? model,
    final String? apiKey,
    final String? timeoutText,
    final ModelRuntimeProfile? runtimeProfile,
    final String? maxResponseTokensText,
    final String? contextWindowSizeText,
    final Object? status = _unset,
    final int? formRevision,
  }) => SettingsViewState(
    provider: provider ?? this.provider,
    profiles: profiles ?? this.profiles,
    appLanguage: appLanguage ?? this.appLanguage,
    fastResponses: fastResponses ?? this.fastResponses,
    confirmed18Plus: confirmed18Plus ?? this.confirmed18Plus,
    isLoading: isLoading ?? this.isLoading,
    isSaving: isSaving ?? this.isSaving,
    isChecking: isChecking ?? this.isChecking,
    isDetectingModel: isDetectingModel ?? this.isDetectingModel,
    baseUrl: baseUrl ?? this.baseUrl,
    model: model ?? this.model,
    apiKey: apiKey ?? this.apiKey,
    timeoutText: timeoutText ?? this.timeoutText,
    runtimeProfile: runtimeProfile ?? this.runtimeProfile,
    maxResponseTokensText: maxResponseTokensText ?? this.maxResponseTokensText,
    contextWindowSizeText: contextWindowSizeText ?? this.contextWindowSizeText,
    status: identical(status, _unset) ? this.status : status as String?,
    formRevision: formRevision ?? this.formRevision,
  );
}

class SettingsController extends StateNotifier<SettingsViewState> {
  SettingsController(this._ref) : super(SettingsViewState.initial());

  final Ref _ref;

  bool _didLoad = false;

  Future<void> load() async {
    if (_didLoad) {
      return;
    }
    _didLoad = true;

    final ProviderScopedSettings scoped = await _settingsRepository
        .loadProviderScopedSettings();
    final AppLanguage appLanguage = await _settingsRepository.loadAppLanguage();
    final ProviderProfile profile = scoped.profileFor(scoped.activeProvider);

    state = state.copyWith(
      provider: scoped.activeProvider,
      profiles: Map<AiProviderType, ProviderProfile>.from(scoped.profiles),
      appLanguage: appLanguage,
      fastResponses: scoped.fastResponses,
      confirmed18Plus: scoped.confirmed18Plus,
      isLoading: false,
      baseUrl: _resolvedBaseUrl(scoped.activeProvider, profile),
      model: _resolvedModel(scoped.activeProvider, profile),
      apiKey: profile.apiKey,
      timeoutText: profile.timeoutSeconds.toString(),
      runtimeProfile: profile.runtimeSettings.profile,
      maxResponseTokensText: profile.runtimeSettings.maxResponseTokens
          .toString(),
      contextWindowSizeText: profile.runtimeSettings.contextWindowSize
          .toString(),
      formRevision: state.formRevision + 1,
    );

    if (state.provider == AiProviderType.lmStudio) {
      await detectAndApplyLmStudioModel(silentWhenUnavailable: true);
    }
  }

  AiSettings get currentSettings => AiSettings(
    provider: state.provider,
    baseUrl: state.baseUrl.trim(),
    model: state.model.trim(),
    apiKey: state.apiKey.trim(),
    timeoutSeconds: int.tryParse(state.timeoutText.trim()) ?? 60,
    fastResponses: state.fastResponses,
    runtimeSettings: _currentRuntimeSettings(),
    confirmed18Plus: state.confirmed18Plus,
  );

  void setConfirmed18Plus(final bool value) {
    state = state.copyWith(confirmed18Plus: value);
  }

  void setAppLanguage(final AppLanguage language) {
    state = state.copyWith(appLanguage: language);
  }

  void setBaseUrl(final String value) {
    state = state.copyWith(baseUrl: value);
  }

  void setModel(final String value) {
    state = state.copyWith(model: value);
  }

  void setApiKey(final String value) {
    state = state.copyWith(apiKey: value);
  }

  void setTimeoutText(final String value) {
    state = state.copyWith(timeoutText: value);
  }

  void applyRuntimeProfile(final ModelRuntimeProfile profile) {
    if (profile == ModelRuntimeProfile.custom) {
      return;
    }
    final ModelRuntimeSettings preset = ModelRuntimeSettings.preset(profile);
    state = state.copyWith(
      runtimeProfile: profile,
      maxResponseTokensText: preset.maxResponseTokens.toString(),
      contextWindowSizeText: preset.contextWindowSize.toString(),
    );
  }

  void setMaxResponseTokensText(final String value) {
    state = state.copyWith(
      maxResponseTokensText: value,
      runtimeProfile: _resolveRuntimeProfile(maxResponseTokensText: value),
    );
  }

  void setContextWindowSizeText(final String value) {
    state = state.copyWith(
      contextWindowSizeText: value,
      runtimeProfile: _resolveRuntimeProfile(contextWindowSizeText: value),
    );
  }

  void setFastResponses(final bool value) {
    state = state.copyWith(fastResponses: value);
  }

  Future<void> changeProvider(final AiProviderType provider) async {
    final Map<AiProviderType, ProviderProfile> profiles =
        _withCurrentFormSaved();
    final ProviderProfile nextProfile =
        profiles[provider] ?? ProviderProfile.defaultsFor(provider);

    bool nextFastResponses = state.fastResponses;
    String nextTimeout = nextProfile.timeoutSeconds.toString();
    if (provider == AiProviderType.openRouter) {
      final int? currentTimeout = int.tryParse(nextTimeout);
      if (currentTimeout == null || currentTimeout < 120) {
        nextTimeout = '120';
      }
    }
    if (!provider.supportsFastResponses) {
      nextFastResponses = false;
    } else if (!nextFastResponses) {
      nextFastResponses = true;
    }

    state = state.copyWith(
      provider: provider,
      profiles: profiles,
      fastResponses: nextFastResponses,
      status: null,
      baseUrl: _resolvedBaseUrl(provider, nextProfile),
      model: _resolvedModel(provider, nextProfile),
      apiKey: nextProfile.apiKey,
      timeoutText: nextTimeout,
      runtimeProfile: nextProfile.runtimeSettings.profile,
      maxResponseTokensText: nextProfile.runtimeSettings.maxResponseTokens
          .toString(),
      contextWindowSizeText: nextProfile.runtimeSettings.contextWindowSize
          .toString(),
      formRevision: state.formRevision + 1,
    );

    if (provider == AiProviderType.lmStudio) {
      await detectAndApplyLmStudioModel(silentWhenUnavailable: true);
    }
  }

  Future<void> save({required final AppLocalizations l10n}) async {
    state = state.copyWith(isSaving: true, status: null);

    final ProviderScopedSettings toSave = ProviderScopedSettings(
      activeProvider: state.provider,
      profiles: _withCurrentFormSaved(),
      fastResponses: state.fastResponses,
      confirmed18Plus: state.confirmed18Plus,
    );

    await _settingsRepository.saveProviderScopedSettings(toSave);
    await _settingsRepository.saveAppLanguage(state.appLanguage);
    _ref.read(appLanguageListenableProvider).value = state.appLanguage;

    state = state.copyWith(
      profiles: toSave.profiles,
      isSaving: false,
      status: l10n.settingsSaved,
    );
  }

  Future<void> checkConnection({required final AppLocalizations l10n}) async {
    state = state.copyWith(isChecking: true, status: null);

    try {
      final AiClient client = _aiServiceFactory.create(currentSettings);
      await client.checkConnection(settings: currentSettings);
      state = state.copyWith(status: l10n.connectionOk);
    } catch (error) {
      state = state.copyWith(status: l10n.connectionFailed(error));
    } finally {
      state = state.copyWith(isChecking: false);
    }
  }

  Future<void> detectAndApplyLmStudioModel({
    final bool silentWhenUnavailable = false,
  }) async {
    if (state.provider != AiProviderType.lmStudio) {
      return;
    }

    final AppLocalizations l10n = AppLocalizations(state.appLanguage);
    state = state.copyWith(
      isDetectingModel: true,
      status: silentWhenUnavailable ? state.status : null,
    );

    final String baseUrl = state.baseUrl.trim().isEmpty
        ? const AiSettings.defaults().baseUrl
        : state.baseUrl.trim();

    try {
      final List<String> modelIds = await _fetchModelIds(baseUrl, l10n);
      final String modelId = _selectPreferredModel(modelIds);
      if (modelId.isEmpty) {
        if (!silentWhenUnavailable) {
          state = state.copyWith(status: l10n.noLmStudioModel);
        }
        return;
      }

      final Map<AiProviderType, ProviderProfile> profiles =
          _withCurrentFormSaved(
            baseUrlOverride: baseUrl,
            modelOverride: modelId,
          );
      await _settingsRepository.saveProviderScopedSettings(
        ProviderScopedSettings(
          activeProvider: state.provider,
          profiles: profiles,
          fastResponses: state.fastResponses,
          confirmed18Plus: state.confirmed18Plus,
        ),
      );

      state = state.copyWith(
        profiles: profiles,
        baseUrl: baseUrl,
        model: modelId,
        status: l10n.selectedLmStudioModel(modelId),
        formRevision: state.formRevision + 1,
      );
    } catch (error) {
      if (!silentWhenUnavailable) {
        state = state.copyWith(status: l10n.detectLmStudioFailed(error));
      }
    } finally {
      state = state.copyWith(isDetectingModel: false);
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
        .map((final item) => item as Map<String, Object?>?)
        .whereType<Map<String, Object?>>()
        .map((final item) => (item['id'] as String?) ?? '')
        .map((final item) => item.trim())
        .where((final item) => item.isNotEmpty)
        .toList();
  }

  String _selectPreferredModel(final List<String> modelIds) {
    if (modelIds.isEmpty) {
      return '';
    }

    final Iterable<String> chatModels = modelIds.where((final modelId) {
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

  Map<AiProviderType, ProviderProfile> _withCurrentFormSaved({
    final String? baseUrlOverride,
    final String? modelOverride,
  }) {
    final Map<AiProviderType, ProviderProfile> profiles =
        Map<AiProviderType, ProviderProfile>.from(state.profiles);
    final ProviderProfile current =
        profiles[state.provider] ?? ProviderProfile.defaultsFor(state.provider);

    profiles[state.provider] = current.copyWith(
      baseUrl: baseUrlOverride ?? state.baseUrl.trim(),
      model: modelOverride ?? state.model.trim(),
      apiKey: state.apiKey.trim(),
      timeoutSeconds: int.tryParse(state.timeoutText.trim()) ?? 60,
      runtimeSettings: _currentRuntimeSettings(),
    );
    return profiles;
  }

  ModelRuntimeSettings _currentRuntimeSettings() {
    final ModelRuntimeSettings defaults = ModelRuntimeSettings.defaultsFor(
      state.provider,
    );
    final ModelRuntimeSettings normalized = defaults.copyWith(
      maxResponseTokens: int.tryParse(state.maxResponseTokensText.trim()),
      contextWindowSize: int.tryParse(state.contextWindowSizeText.trim()),
      profile: state.runtimeProfile,
    );
    return normalized.copyWith(profile: _resolveRuntimeProfile());
  }

  ModelRuntimeProfile _resolveRuntimeProfile({
    final String? maxResponseTokensText,
    final String? contextWindowSizeText,
  }) {
    final ModelRuntimeSettings defaults = ModelRuntimeSettings.defaultsFor(
      state.provider,
    );
    final ModelRuntimeSettings normalized = defaults.copyWith(
      maxResponseTokens: int.tryParse(
        (maxResponseTokensText ?? state.maxResponseTokensText).trim(),
      ),
      contextWindowSize: int.tryParse(
        (contextWindowSizeText ?? state.contextWindowSizeText).trim(),
      ),
    );
    return ModelRuntimeSettings.resolveProfile(
      maxResponseTokens: normalized.maxResponseTokens,
      contextWindowSize: normalized.contextWindowSize,
    );
  }

  String _resolvedBaseUrl(
    final AiProviderType provider,
    final ProviderProfile profile,
  ) => profile.baseUrl.trim().isEmpty
      ? AiSettings.defaultBaseUrlFor(provider)
      : profile.baseUrl;

  String _resolvedModel(
    final AiProviderType provider,
    final ProviderProfile profile,
  ) => profile.model.trim().isEmpty ? provider.defaultModel : profile.model;

  SettingsRepository get _settingsRepository =>
      _ref.read(settingsRepositoryProvider);

  AiServiceFactory get _aiServiceFactory => _ref.read(aiServiceFactoryProvider);
}
