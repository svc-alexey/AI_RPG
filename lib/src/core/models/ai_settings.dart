enum AiProviderType { lmStudio, openAiCompatible, openRouter, deepSeek }

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
      orElse: () => ModelRuntimeProfile.fast,
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

  factory ModelRuntimeSettings.defaultsFor(final AiProviderType provider) =>
      provider == AiProviderType.lmStudio ? fastPreset : smartPreset;

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

  static ModelRuntimeSettings preset(final ModelRuntimeProfile profile) =>
      switch (profile) {
        ModelRuntimeProfile.cheap => cheapPreset,
        ModelRuntimeProfile.fast => fastPreset,
        ModelRuntimeProfile.smart => smartPreset,
        ModelRuntimeProfile.custom => fastPreset,
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

extension AiProviderTypeCapabilities on AiProviderType {
  String get defaultBaseUrl => AiSettings.defaultBaseUrlFor(this);

  String get defaultModel => AiSettings.defaultModelFor(this);

  bool get supportsFastResponses => this == AiProviderType.lmStudio;

  bool get supportsModelAutoDetect => this == AiProviderType.lmStudio;
}

/// Per-provider profile: baseUrl, model, apiKey, timeoutSeconds.
class ProviderProfile {
  const ProviderProfile({
    required this.baseUrl,
    required this.model,
    required this.apiKey,
    required this.timeoutSeconds,
    required this.runtimeSettings,
  });

  factory ProviderProfile.fromJson(
    final Map<String, Object?> json, {
    required final AiProviderType provider,
  }) => ProviderProfile(
    baseUrl: (json['baseUrl'] as String?) ?? '',
    model: (json['model'] as String?) ?? '',
    apiKey: (json['apiKey'] as String?) ?? '',
    timeoutSeconds: (json['timeoutSeconds'] as int?) ?? 60,
    runtimeSettings: json['runtimeSettings'] is Map<String, Object?>
        ? ModelRuntimeSettings.fromJson(
            json['runtimeSettings'] as Map<String, Object?>,
          )
        : ModelRuntimeSettings.defaultsFor(provider),
  );

  factory ProviderProfile.defaultsFor(final AiProviderType provider) =>
      ProviderProfile(
        baseUrl: AiSettings.defaultBaseUrlFor(provider),
        model: provider.defaultModel,
        apiKey: '',
        timeoutSeconds: provider == AiProviderType.openRouter ? 120 : 60,
        runtimeSettings: ModelRuntimeSettings.defaultsFor(provider),
      );

  final String baseUrl;
  final String model;
  final String apiKey;
  final int timeoutSeconds;
  final ModelRuntimeSettings runtimeSettings;

  ProviderProfile copyWith({
    final String? baseUrl,
    final String? model,
    final String? apiKey,
    final int? timeoutSeconds,
    final ModelRuntimeSettings? runtimeSettings,
  }) => ProviderProfile(
    baseUrl: baseUrl ?? this.baseUrl,
    model: model ?? this.model,
    apiKey: apiKey ?? this.apiKey,
    timeoutSeconds: timeoutSeconds ?? this.timeoutSeconds,
    runtimeSettings: runtimeSettings ?? this.runtimeSettings,
  );

  Map<String, Object?> toJson() => <String, Object?>{
    'baseUrl': baseUrl,
    'model': model,
    'apiKey': apiKey,
    'timeoutSeconds': timeoutSeconds,
    'runtimeSettings': runtimeSettings.toJson(),
  };
}

/// Provider-scoped settings: each provider keeps its own profile.
class ProviderScopedSettings {
  const ProviderScopedSettings({
    required this.activeProvider,
    required this.profiles,
    required this.fastResponses,
    this.confirmed18Plus = false,
  });

  factory ProviderScopedSettings.fromJson(final Map<String, Object?> json) {
    if (json.containsKey('profiles')) {
      return ProviderScopedSettings._fromNewFormat(json);
    }
    return ProviderScopedSettings._fromLegacy(json);
  }

  factory ProviderScopedSettings._fromNewFormat(
    final Map<String, Object?> json,
  ) {
    final AiProviderType active = AiProviderType.values.firstWhere(
      (final item) => item.name == json['activeProvider'],
      orElse: () => AiProviderType.lmStudio,
    );
    final Map<String, Object?> rawProfiles =
        (json['profiles'] as Map<String, Object?>?) ?? <String, Object?>{};
    final Map<AiProviderType, ProviderProfile> profiles =
        <AiProviderType, ProviderProfile>{};
    for (final AiProviderType p in AiProviderType.values) {
      final Object? raw = rawProfiles[p.name];
      if (raw is Map<String, Object?>) {
        profiles[p] = ProviderProfile.fromJson(raw, provider: p);
      } else {
        profiles[p] = ProviderProfile.defaultsFor(p);
      }
    }
    return ProviderScopedSettings(
      activeProvider: active,
      profiles: profiles,
      fastResponses: (json['fastResponses'] as bool?) ?? true,
      confirmed18Plus: (json['confirmed18Plus'] as bool?) ?? false,
    );
  }

  factory ProviderScopedSettings._fromLegacy(final Map<String, Object?> json) {
    final AiSettings legacy = AiSettings.fromJson(json);
    final Map<AiProviderType, ProviderProfile> profiles =
        <AiProviderType, ProviderProfile>{};
    final ProviderProfile legacyProfile = ProviderProfile(
      baseUrl: legacy.baseUrl,
      model: legacy.model,
      apiKey: legacy.apiKey,
      timeoutSeconds: legacy.timeoutSeconds,
      runtimeSettings: legacy.runtimeSettings,
    );
    for (final AiProviderType p in AiProviderType.values) {
      profiles[p] = p == legacy.provider
          ? legacyProfile
          : ProviderProfile.defaultsFor(p);
    }
    return ProviderScopedSettings(
      activeProvider: legacy.provider,
      profiles: profiles,
      fastResponses: legacy.fastResponses,
      confirmed18Plus: legacy.confirmed18Plus,
    );
  }

  final AiProviderType activeProvider;
  final Map<AiProviderType, ProviderProfile> profiles;
  final bool fastResponses;
  final bool confirmed18Plus;

  ProviderProfile profileFor(final AiProviderType p) =>
      profiles[p] ?? ProviderProfile.defaultsFor(p);

  AiSettings toEffectiveSettings() {
    final ProviderProfile p = profileFor(activeProvider);
    return AiSettings(
      provider: activeProvider,
      baseUrl: p.baseUrl.trim().isEmpty
          ? AiSettings.defaultBaseUrlFor(activeProvider)
          : p.baseUrl,
      model: p.model.trim().isEmpty ? activeProvider.defaultModel : p.model,
      apiKey: p.apiKey,
      timeoutSeconds: p.timeoutSeconds,
      fastResponses: fastResponses,
      confirmed18Plus: confirmed18Plus,
      runtimeSettings: p.runtimeSettings,
    );
  }

  ProviderScopedSettings copyWith({
    final AiProviderType? activeProvider,
    final Map<AiProviderType, ProviderProfile>? profiles,
    final bool? fastResponses,
    final bool? confirmed18Plus,
  }) => ProviderScopedSettings(
    activeProvider: activeProvider ?? this.activeProvider,
    profiles:
        profiles ?? Map<AiProviderType, ProviderProfile>.from(this.profiles),
    fastResponses: fastResponses ?? this.fastResponses,
    confirmed18Plus: confirmed18Plus ?? this.confirmed18Plus,
  );

  Map<String, Object?> toJson() => <String, Object?>{
    'activeProvider': activeProvider.name,
    'profiles': <String, Object?>{
      for (final AiProviderType p in AiProviderType.values)
        p.name:
            profiles[p]?.toJson() ?? ProviderProfile.defaultsFor(p).toJson(),
    },
    'fastResponses': fastResponses,
    'confirmed18Plus': confirmed18Plus,
  };
}

/// Effective settings for the active provider (used by AiClient, GameEngine).
class AiSettings {
  factory AiSettings.fromJson(final Map<String, Object?> json) => AiSettings(
    provider: AiProviderType.values.firstWhere(
      (final item) => item.name == json['provider'],
      orElse: () => AiProviderType.lmStudio,
    ),
    baseUrl:
        (json['baseUrl'] as String?) ??
        AiSettings.defaultBaseUrlFor(AiProviderType.lmStudio),
    model: (json['model'] as String?) ?? '',
    apiKey: (json['apiKey'] as String?) ?? '',
    timeoutSeconds: (json['timeoutSeconds'] as int?) ?? 60,
    fastResponses: (json['fastResponses'] as bool?) ?? true,
    confirmed18Plus: (json['confirmed18Plus'] as bool?) ?? false,
    runtimeSettings: json['runtimeSettings'] is Map<String, Object?>
        ? ModelRuntimeSettings.fromJson(
            json['runtimeSettings'] as Map<String, Object?>,
          )
        : ModelRuntimeSettings.defaultsFor(
            AiProviderType.values.firstWhere(
              (final item) => item.name == json['provider'],
              orElse: () => AiProviderType.lmStudio,
            ),
          ),
  );

  const AiSettings({
    required this.provider,
    required this.baseUrl,
    required this.model,
    required this.apiKey,
    required this.timeoutSeconds,
    required this.fastResponses,
    required this.runtimeSettings,
    this.confirmed18Plus = false,
  });

  const AiSettings.defaults()
    : provider = AiProviderType.lmStudio,
      baseUrl = 'http://127.0.0.1:1234/v1',
      model = '',
      apiKey = '',
      timeoutSeconds = 60,
      fastResponses = true,
      runtimeSettings = ModelRuntimeSettings.fastPreset,
      confirmed18Plus = false;

  final AiProviderType provider;
  final String baseUrl;
  final String model;
  final String apiKey;
  final int timeoutSeconds;
  final bool fastResponses;
  final ModelRuntimeSettings runtimeSettings;
  final bool confirmed18Plus;

  int get maxResponseTokens => runtimeSettings.maxResponseTokens;

  int get contextWindowSize => runtimeSettings.contextWindowSize;

  ModelRuntimeProfile get runtimeProfile => runtimeSettings.profile;

  static String defaultBaseUrlFor(final AiProviderType provider) =>
      switch (provider) {
        AiProviderType.lmStudio => 'http://127.0.0.1:1234/v1',
        AiProviderType.openAiCompatible => '',
        AiProviderType.openRouter => 'https://openrouter.ai/api/v1',
        AiProviderType.deepSeek => 'https://api.deepseek.com/v1',
      };

  static String defaultModelFor(final AiProviderType provider) =>
      switch (provider) {
        AiProviderType.deepSeek => 'deepseek-chat',
        _ => '',
      };

  bool get isConfigured => baseUrl.trim().isNotEmpty && model.trim().isNotEmpty;

  AiSettings copyWith({
    final AiProviderType? provider,
    final String? baseUrl,
    final String? model,
    final String? apiKey,
    final int? timeoutSeconds,
    final bool? fastResponses,
    final ModelRuntimeSettings? runtimeSettings,
    final bool? confirmed18Plus,
  }) => AiSettings(
    provider: provider ?? this.provider,
    baseUrl: baseUrl ?? this.baseUrl,
    model: model ?? this.model,
    apiKey: apiKey ?? this.apiKey,
    timeoutSeconds: timeoutSeconds ?? this.timeoutSeconds,
    fastResponses: fastResponses ?? this.fastResponses,
    runtimeSettings: runtimeSettings ?? this.runtimeSettings,
    confirmed18Plus: confirmed18Plus ?? this.confirmed18Plus,
  );

  Map<String, Object?> toJson() => <String, Object?>{
    'provider': provider.name,
    'baseUrl': baseUrl,
    'model': model,
    'apiKey': apiKey,
    'timeoutSeconds': timeoutSeconds,
    'fastResponses': fastResponses,
    'runtimeSettings': runtimeSettings.toJson(),
    'confirmed18Plus': confirmed18Plus,
  };
}
