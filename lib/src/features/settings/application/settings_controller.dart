import 'package:ai_prg/src/app/app_localizations.dart';
import 'package:ai_prg/src/app/app_providers.dart';
import 'package:ai_prg/src/core/config/ai_runtime_env.dart';
import 'package:ai_prg/src/core/config/symmetry_runtime_env.dart';
import 'package:ai_prg/src/core/models/ai_settings.dart';
import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/repositories/settings_repository.dart';
import 'package:ai_prg/src/core/repositories/symmetry_auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final settingsControllerProvider =
    StateNotifierProvider.autoDispose<SettingsController, SettingsViewState>(
      (final ref) => SettingsController(ref)..load(),
    );

class SettingsViewState {
  const SettingsViewState({
    required this.appLanguage,
    required this.confirmed18Plus,
    required this.isLoading,
    required this.isSaving,
    required this.isChecking,
    required this.backendBaseUrl,
    required this.baseUrl,
    required this.model,
    required this.apiKey,
    required this.timeoutText,
    required this.runtimeProfile,
    required this.maxResponseTokensText,
    required this.contextWindowSizeText,
    required this.status,
    required this.formRevision,
    required this.showApiKeyFromBuildHint,
    required this.showEndpointBuildDefaultsHint,
  });

  factory SettingsViewState.initial() => SettingsViewState(
    appLanguage: AppLanguage.ru,
    confirmed18Plus: false,
    isLoading: true,
    isSaving: false,
    isChecking: false,
    backendBaseUrl: '',
    baseUrl: '',
    model: '',
    apiKey: '',
    timeoutText: '60',
    runtimeProfile: ModelRuntimeSettings.defaults.profile,
    maxResponseTokensText: ModelRuntimeSettings.defaults.maxResponseTokens
        .toString(),
    contextWindowSizeText: ModelRuntimeSettings.defaults.contextWindowSize
        .toString(),
    status: null,
    formRevision: 0,
    showApiKeyFromBuildHint: false,
    showEndpointBuildDefaultsHint: false,
  );

  static const Object _unset = Object();

  final AppLanguage appLanguage;
  final bool confirmed18Plus;
  final bool isLoading;
  final bool isSaving;
  final bool isChecking;
  final String backendBaseUrl;
  final String baseUrl;
  final String model;
  final String apiKey;
  final String timeoutText;
  final ModelRuntimeProfile runtimeProfile;
  final String maxResponseTokensText;
  final String contextWindowSizeText;
  final String? status;
  final int formRevision;
  final bool showApiKeyFromBuildHint;
  final bool showEndpointBuildDefaultsHint;

  SettingsViewState copyWith({
    final AppLanguage? appLanguage,
    final bool? confirmed18Plus,
    final bool? isLoading,
    final bool? isSaving,
    final bool? isChecking,
    final String? backendBaseUrl,
    final String? baseUrl,
    final String? model,
    final String? apiKey,
    final String? timeoutText,
    final ModelRuntimeProfile? runtimeProfile,
    final String? maxResponseTokensText,
    final String? contextWindowSizeText,
    final Object? status = _unset,
    final int? formRevision,
    final bool? showApiKeyFromBuildHint,
    final bool? showEndpointBuildDefaultsHint,
  }) => SettingsViewState(
    appLanguage: appLanguage ?? this.appLanguage,
    confirmed18Plus: confirmed18Plus ?? this.confirmed18Plus,
    isLoading: isLoading ?? this.isLoading,
    isSaving: isSaving ?? this.isSaving,
    isChecking: isChecking ?? this.isChecking,
    backendBaseUrl: backendBaseUrl ?? this.backendBaseUrl,
    baseUrl: baseUrl ?? this.baseUrl,
    model: model ?? this.model,
    apiKey: apiKey ?? this.apiKey,
    timeoutText: timeoutText ?? this.timeoutText,
    runtimeProfile: runtimeProfile ?? this.runtimeProfile,
    maxResponseTokensText: maxResponseTokensText ?? this.maxResponseTokensText,
    contextWindowSizeText: contextWindowSizeText ?? this.contextWindowSizeText,
    status: identical(status, _unset) ? this.status : status as String?,
    formRevision: formRevision ?? this.formRevision,
    showApiKeyFromBuildHint:
        showApiKeyFromBuildHint ?? this.showApiKeyFromBuildHint,
    showEndpointBuildDefaultsHint:
        showEndpointBuildDefaultsHint ?? this.showEndpointBuildDefaultsHint,
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

    final AiSettings persisted = await _settingsRepository
        .loadAiSettingsPersisted();
    final AppLanguage appLanguage = await _settingsRepository.loadAppLanguage();
    final String? backendBaseUrl = await _settingsRepository
        .loadSymmetryBaseUrl();

    state = state.copyWith(
      appLanguage: appLanguage,
      confirmed18Plus: persisted.confirmed18Plus,
      isLoading: false,
      backendBaseUrl: backendBaseUrl ?? SymmetryRuntimeEnv.defaultBaseUrl,
      baseUrl: persisted.baseUrl.trim(),
      model: persisted.model.trim(),
      apiKey: persisted.apiKey.trim().isNotEmpty ? persisted.apiKey : '',
      showApiKeyFromBuildHint:
          persisted.apiKey.trim().isEmpty && AiRuntimeEnv.hasCompileTimeApiKey,
      showEndpointBuildDefaultsHint: _endpointBuildHintForForm(
        persisted.baseUrl,
        persisted.model,
      ),
      timeoutText: persisted.timeoutSeconds.toString(),
      runtimeProfile: persisted.runtimeSettings.profile,
      maxResponseTokensText: persisted.runtimeSettings.maxResponseTokens
          .toString(),
      contextWindowSizeText: persisted.runtimeSettings.contextWindowSize
          .toString(),
      formRevision: state.formRevision + 1,
    );
  }

  AiSettings get currentSettings => AiSettings(
    baseUrl: state.baseUrl.trim(),
    model: state.model.trim(),
    apiKey: state.apiKey.trim(),
    timeoutSeconds: int.tryParse(state.timeoutText.trim()) ?? 60,
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
    state = state.copyWith(
      baseUrl: value,
      showEndpointBuildDefaultsHint: _endpointBuildHintForForm(
        value,
        state.model,
      ),
    );
  }

  void setBackendBaseUrl(final String value) {
    state = state.copyWith(backendBaseUrl: value);
  }

  void setModel(final String value) {
    state = state.copyWith(
      model: value,
      showEndpointBuildDefaultsHint: _endpointBuildHintForForm(
        state.baseUrl,
        value,
      ),
    );
  }

  void setApiKey(final String value) {
    state = state.copyWith(
      apiKey: value,
      showApiKeyFromBuildHint:
          value.trim().isEmpty && AiRuntimeEnv.hasCompileTimeApiKey,
    );
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
      formRevision: state.formRevision + 1,
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

  Future<void> save({required final AppLocalizations l10n}) async {
    state = state.copyWith(isSaving: true, status: null);

    await _settingsRepository.saveAiSettings(currentSettings);
    await _settingsRepository.saveAppLanguage(state.appLanguage);
    await _settingsRepository.saveSymmetryBaseUrl(state.backendBaseUrl.trim());
    _ref.read(appLanguageListenableProvider).value = state.appLanguage;

    state = state.copyWith(isSaving: false, status: l10n.settingsSaved);
  }

  Future<void> checkConnection({required final AppLocalizations l10n}) async {
    state = state.copyWith(isChecking: true, status: null);
    final String backendBaseUrl = state.backendBaseUrl.trim();
    final String effectiveBackendBaseUrl =
        backendBaseUrl.isNotEmpty
        ? backendBaseUrl
        : await _symmetryAuthRepository.loadBaseUrl();

    try {
      final AiSettings effective = AiSettings.withEnvFallbacks(currentSettings);
      if (backendBaseUrl.isNotEmpty) {
        await _settingsRepository.saveSymmetryBaseUrl(backendBaseUrl);
      }
      if (effective.isConfigured) {
        await _symmetryAuthRepository.checkProviderConnection(
          aiSettings: effective,
        );
        state = state.copyWith(status: l10n.connectionOk);
      } else {
        await _symmetryAuthRepository.checkBackendHealth(
          baseUrlOverride: backendBaseUrl,
        );
        state = state.copyWith(status: l10n.symmetryBackendReachableLoginHint);
      }
    } catch (error) {
      state = state.copyWith(
        status: l10n.connectionFailedForUrl(effectiveBackendBaseUrl, error),
      );
    } finally {
      state = state.copyWith(isChecking: false);
    }
  }

  ModelRuntimeSettings _currentRuntimeSettings() {
    final ModelRuntimeSettings normalized = ModelRuntimeSettings.defaults
        .copyWith(
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
    final ModelRuntimeSettings normalized = ModelRuntimeSettings.defaults
        .copyWith(
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

  SettingsRepository get _settingsRepository =>
      _ref.read(settingsRepositoryProvider);

  SymmetryAuthRepository get _symmetryAuthRepository =>
      _ref.read(symmetryAuthRepositoryProvider);

  static bool _endpointBuildHintForForm(
    final String baseUrl,
    final String model,
  ) =>
      (baseUrl.trim().isEmpty && AiRuntimeEnv.hasCompileTimeBaseUrl) ||
      (model.trim().isEmpty && AiRuntimeEnv.hasCompileTimeModel);
}
