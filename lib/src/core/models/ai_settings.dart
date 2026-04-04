import 'package:ai_prg/src/core/config/ai_runtime_env.dart';

enum AiProviderType { openAiCompatible }

enum ModelRuntimeProfile { cheap, fast, smart, custom }

class ModelRuntimeSettings {
  const ModelRuntimeSettings({
    required this.maxResponseTokens,
    required this.contextWindowSize,
    required this.profile,
  });

  factory ModelRuntimeSettings.fromJson(final Map<String, Object?> json) {
    final ModelRuntimeProfile profile = ModelRuntimeProfile.values.firstWhere(
      (final item) => item.name == json['profile'],
      orElse: () => ModelRuntimeProfile.smart,
    );
    final ModelRuntimeSettings fallback = preset(profile);
    return ModelRuntimeSettings(
      maxResponseTokens: _normalizeMaxResponseTokens(
        json['maxResponseTokens'] as int?,
        fallback: fallback.maxResponseTokens,
      ),
      contextWindowSize: _normalizeContextWindowSize(
        json['contextWindowSize'] as int?,
        fallback: fallback.contextWindowSize,
      ),
      profile: profile,
    );
  }

  static const int minMaxResponseTokens = 64;
  static const int maxMaxResponseTokens = 4096;
  static const int minContextWindowSize = 512;
  static const int maxContextWindowSize = 16000;

  static const ModelRuntimeSettings cheapPreset = ModelRuntimeSettings(
    maxResponseTokens: 160,
    contextWindowSize: 1024,
    profile: ModelRuntimeProfile.cheap,
  );

  static const ModelRuntimeSettings fastPreset = ModelRuntimeSettings(
    maxResponseTokens: 256,
    contextWindowSize: 1536,
    profile: ModelRuntimeProfile.fast,
  );

  static const ModelRuntimeSettings smartPreset = ModelRuntimeSettings(
    maxResponseTokens: 512,
    contextWindowSize: 3072,
    profile: ModelRuntimeProfile.smart,
  );

  final int maxResponseTokens;
  final int contextWindowSize;
  final ModelRuntimeProfile profile;

  static const ModelRuntimeSettings defaults = smartPreset;

  static ModelRuntimeSettings preset(final ModelRuntimeProfile profile) =>
      switch (profile) {
        ModelRuntimeProfile.cheap => cheapPreset,
        ModelRuntimeProfile.fast => fastPreset,
        ModelRuntimeProfile.smart => smartPreset,
        ModelRuntimeProfile.custom => smartPreset,
      };

  static ModelRuntimeProfile resolveProfile({
    required final int maxResponseTokens,
    required final int contextWindowSize,
  }) {
    for (final ModelRuntimeProfile profile in <ModelRuntimeProfile>[
      ModelRuntimeProfile.cheap,
      ModelRuntimeProfile.fast,
      ModelRuntimeProfile.smart,
    ]) {
      final ModelRuntimeSettings presetSettings = preset(profile);
      if (presetSettings.maxResponseTokens == maxResponseTokens &&
          presetSettings.contextWindowSize == contextWindowSize) {
        return profile;
      }
    }
    return ModelRuntimeProfile.custom;
  }

  ModelRuntimeSettings copyWith({
    final int? maxResponseTokens,
    final int? contextWindowSize,
    final ModelRuntimeProfile? profile,
  }) {
    final int nextMaxResponseTokens = _normalizeMaxResponseTokens(
      maxResponseTokens,
      fallback: this.maxResponseTokens,
    );
    final int nextContextWindowSize = _normalizeContextWindowSize(
      contextWindowSize,
      fallback: this.contextWindowSize,
    );
    final ModelRuntimeProfile nextProfile =
        profile ??
        resolveProfile(
          maxResponseTokens: nextMaxResponseTokens,
          contextWindowSize: nextContextWindowSize,
        );
    return ModelRuntimeSettings(
      maxResponseTokens: nextMaxResponseTokens,
      contextWindowSize: nextContextWindowSize,
      profile: nextProfile,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'maxResponseTokens': maxResponseTokens,
    'contextWindowSize': contextWindowSize,
    'profile': profile.name,
  };

  static int _normalizeMaxResponseTokens(
    final int? value, {
    required final int fallback,
  }) {
    final int resolved = value ?? fallback;
    return resolved.clamp(minMaxResponseTokens, maxMaxResponseTokens);
  }

  static int _normalizeContextWindowSize(
    final int? value, {
    required final int fallback,
  }) {
    final int resolved = value ?? fallback;
    return resolved.clamp(minContextWindowSize, maxContextWindowSize);
  }
}

class AiSettings {
  factory AiSettings.fromJson(final Map<String, Object?> json) => AiSettings(
    baseUrl: (json['baseUrl'] as String?) ?? defaultBaseUrl,
    model: (json['model'] as String?) ?? '',
    apiKey: (json['apiKey'] as String?) ?? '',
    timeoutSeconds: (json['timeoutSeconds'] as int?) ?? 60,
    confirmed18Plus: (json['confirmed18Plus'] as bool?) ?? false,
    runtimeSettings: json['runtimeSettings'] is Map<String, Object?>
        ? ModelRuntimeSettings.fromJson(
            json['runtimeSettings'] as Map<String, Object?>,
          )
        : ModelRuntimeSettings.defaults,
  );

  const AiSettings({
    required this.baseUrl,
    required this.model,
    required this.apiKey,
    required this.timeoutSeconds,
    required this.runtimeSettings,
    this.provider = AiProviderType.openAiCompatible,
    this.confirmed18Plus = false,
    this.fastResponses = false,
  });

  const AiSettings.defaults()
    : provider = AiProviderType.openAiCompatible,
      baseUrl = defaultBaseUrl,
      model = '',
      apiKey = '',
      timeoutSeconds = 60,
      runtimeSettings = ModelRuntimeSettings.defaults,
      confirmed18Plus = false,
      fastResponses = false;

  static const String defaultBaseUrl = '';
  static const String defaultModel = '';

  final AiProviderType provider;
  final String baseUrl;
  final String model;
  final String apiKey;
  final int timeoutSeconds;
  final bool confirmed18Plus;
  final bool fastResponses;
  final ModelRuntimeSettings runtimeSettings;

  int get maxResponseTokens => runtimeSettings.maxResponseTokens;

  int get contextWindowSize => runtimeSettings.contextWindowSize;

  ModelRuntimeProfile get runtimeProfile => runtimeSettings.profile;

  bool get isConfigured =>
      baseUrl.trim().isNotEmpty &&
      model.trim().isNotEmpty &&
      apiKey.trim().isNotEmpty;

  /// Fills empty [baseUrl], [model], or [apiKey] from [AiRuntimeEnv] so the app
  /// works without prior settings; non-empty stored values win (user settings).
  static AiSettings withEnvFallbacks(final AiSettings stored) {
    final String base = stored.baseUrl.trim().isNotEmpty
        ? stored.baseUrl.trim()
        : AiRuntimeEnv.defaultBaseUrl.trim();
    final String model = stored.model.trim().isNotEmpty
        ? stored.model.trim()
        : AiRuntimeEnv.defaultModel.trim();
    final String key = stored.apiKey.trim().isNotEmpty
        ? stored.apiKey.trim()
        : AiRuntimeEnv.defaultApiKey.trim();
    return stored.copyWith(baseUrl: base, model: model, apiKey: key);
  }

  AiSettings copyWith({
    final String? baseUrl,
    final String? model,
    final String? apiKey,
    final int? timeoutSeconds,
    final bool? confirmed18Plus,
    final bool? fastResponses,
    final ModelRuntimeSettings? runtimeSettings,
  }) => AiSettings(
    baseUrl: baseUrl ?? this.baseUrl,
    model: model ?? this.model,
    apiKey: apiKey ?? this.apiKey,
    timeoutSeconds: timeoutSeconds ?? this.timeoutSeconds,
    confirmed18Plus: confirmed18Plus ?? this.confirmed18Plus,
    fastResponses: fastResponses ?? this.fastResponses,
    runtimeSettings: runtimeSettings ?? this.runtimeSettings,
  );

  Map<String, Object?> toJson() => <String, Object?>{
    'baseUrl': baseUrl,
    'model': model,
    'apiKey': apiKey,
    'timeoutSeconds': timeoutSeconds,
    'runtimeSettings': runtimeSettings.toJson(),
    'confirmed18Plus': confirmed18Plus,
  };
}
