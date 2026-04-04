import 'package:ai_prg/src/app/app_localizations.dart';
import 'package:ai_prg/src/app/app_providers.dart';
import 'package:ai_prg/src/core/config/ai_runtime_env.dart';
import 'package:ai_prg/src/core/models/ai_settings.dart';
import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/repositories/settings_repository.dart';
import 'package:ai_prg/src/core/services/ai_client.dart';
import 'package:ai_prg/src/core/services/ai_service_factory.dart';
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
  });

  factory SettingsViewState.initial() => SettingsViewState(
    appLanguage: AppLanguage.ru,
    confirmed18Plus: false,
    isLoading: true,
    isSaving: false,
    isChecking: false,
    baseUrl: AiRuntimeEnv.defaultBaseUrl,
    model: AiRuntimeEnv.defaultModel,
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
  );

  static const Object _unset = Object();

  final AppLanguage appLanguage;
  final bool confirmed18Plus;
  final bool isLoading;
  final bool isSaving;
  final bool isChecking;
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

  SettingsViewState copyWith({
    final AppLanguage? appLanguage,
    final bool? confirmed18Plus,
    final bool? isLoading,
    final bool? isSaving,
    final bool? isChecking,
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
  }) => SettingsViewState(
    appLanguage: appLanguage ?? this.appLanguage,
    confirmed18Plus: confirmed18Plus ?? this.confirmed18Plus,
    isLoading: isLoading ?? this.isLoading,
    isSaving: isSaving ?? this.isSaving,
    isChecking: isChecking ?? this.isChecking,
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

    final AiSettings persisted =
        await _settingsRepository.loadAiSettingsPersisted();
    final AiSettings effective = AiSettings.withEnvFallbacks(persisted);
    final AppLanguage appLanguage = await _settingsRepository.loadAppLanguage();

    state = state.copyWith(
      appLanguage: appLanguage,
      confirmed18Plus: effective.confirmed18Plus,
      isLoading: false,
      baseUrl: effective.baseUrl,
      model: effective.model,
      apiKey: persisted.apiKey.trim().isNotEmpty ? persisted.apiKey : '',
      showApiKeyFromBuildHint: persisted.apiKey.trim().isEmpty,
      timeoutText: effective.timeoutSeconds.toString(),
      runtimeProfile: effective.runtimeSettings.profile,
      maxResponseTokensText: effective.runtimeSettings.maxResponseTokens
          .toString(),
      contextWindowSizeText: effective.runtimeSettings.contextWindowSize
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
    _ref.read(appLanguageListenableProvider).value = state.appLanguage;

    state = state.copyWith(isSaving: false, status: l10n.settingsSaved);
  }

  Future<void> checkConnection({required final AppLocalizations l10n}) async {
    state = state.copyWith(isChecking: true, status: null);

    try {
      final AiSettings effective = AiSettings.withEnvFallbacks(currentSettings);
      final AiClient client = _aiServiceFactory.create(effective);
      await client.checkConnection(settings: effective);
      state = state.copyWith(status: l10n.connectionOk);
    } catch (error) {
      state = state.copyWith(status: l10n.connectionFailed(error));
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

  AiServiceFactory get _aiServiceFactory => _ref.read(aiServiceFactoryProvider);
}
