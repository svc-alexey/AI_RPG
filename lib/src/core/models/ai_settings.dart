enum AiProviderType { lmStudio, openAiCompatible, openRouter, deepSeek }

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
  });

  factory ProviderProfile.fromJson(final Map<String, Object?> json) =>
      ProviderProfile(
        baseUrl: (json['baseUrl'] as String?) ?? '',
        model: (json['model'] as String?) ?? '',
        apiKey: (json['apiKey'] as String?) ?? '',
        timeoutSeconds: (json['timeoutSeconds'] as int?) ?? 60,
      );

  factory ProviderProfile.defaultsFor(final AiProviderType provider) =>
      ProviderProfile(
        baseUrl: AiSettings.defaultBaseUrlFor(provider),
        model: provider.defaultModel,
        apiKey: '',
        timeoutSeconds: provider == AiProviderType.openRouter ? 120 : 60,
      );

  final String baseUrl;
  final String model;
  final String apiKey;
  final int timeoutSeconds;

  ProviderProfile copyWith({
    final String? baseUrl,
    final String? model,
    final String? apiKey,
    final int? timeoutSeconds,
  }) =>
      ProviderProfile(
        baseUrl: baseUrl ?? this.baseUrl,
        model: model ?? this.model,
        apiKey: apiKey ?? this.apiKey,
        timeoutSeconds: timeoutSeconds ?? this.timeoutSeconds,
      );

  Map<String, Object?> toJson() => <String, Object?>{
        'baseUrl': baseUrl,
        'model': model,
        'apiKey': apiKey,
        'timeoutSeconds': timeoutSeconds,
      };
}

/// Provider-scoped settings: each provider keeps its own profile.
class ProviderScopedSettings {
  const ProviderScopedSettings({
    required this.activeProvider,
    required this.profiles,
    required this.fastResponses,
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
        profiles[p] = ProviderProfile.fromJson(raw);
      } else {
        profiles[p] = ProviderProfile.defaultsFor(p);
      }
    }
    return ProviderScopedSettings(
      activeProvider: active,
      profiles: profiles,
      fastResponses: (json['fastResponses'] as bool?) ?? true,
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
    );
  }

  final AiProviderType activeProvider;
  final Map<AiProviderType, ProviderProfile> profiles;
  final bool fastResponses;

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
    );
  }

  ProviderScopedSettings copyWith({
    final AiProviderType? activeProvider,
    final Map<AiProviderType, ProviderProfile>? profiles,
    final bool? fastResponses,
  }) =>
      ProviderScopedSettings(
        activeProvider: activeProvider ?? this.activeProvider,
        profiles: profiles ?? Map<AiProviderType, ProviderProfile>.from(this.profiles),
        fastResponses: fastResponses ?? this.fastResponses,
      );

  Map<String, Object?> toJson() => <String, Object?>{
        'activeProvider': activeProvider.name,
        'profiles': <String, Object?>{
          for (final AiProviderType p in AiProviderType.values)
            p.name: profiles[p]?.toJson() ?? ProviderProfile.defaultsFor(p).toJson(),
        },
        'fastResponses': fastResponses,
      };
}

/// Effective settings for the active provider (used by AiClient, GameEngine).
class AiSettings {
  factory AiSettings.fromJson(final Map<String, Object?> json) => AiSettings(
        provider: AiProviderType.values.firstWhere(
          (final item) => item.name == json['provider'],
          orElse: () => AiProviderType.lmStudio,
        ),
        baseUrl: (json['baseUrl'] as String?) ??
            AiSettings.defaultBaseUrlFor(AiProviderType.lmStudio),
        model: (json['model'] as String?) ?? '',
        apiKey: (json['apiKey'] as String?) ?? '',
        timeoutSeconds: (json['timeoutSeconds'] as int?) ?? 60,
        fastResponses: (json['fastResponses'] as bool?) ?? true,
      );

  const AiSettings({
    required this.provider,
    required this.baseUrl,
    required this.model,
    required this.apiKey,
    required this.timeoutSeconds,
    required this.fastResponses,
  });

  const AiSettings.defaults()
      : provider = AiProviderType.lmStudio,
        baseUrl = 'http://127.0.0.1:1234/v1',
        model = '',
        apiKey = '',
        timeoutSeconds = 60,
        fastResponses = true;

  final AiProviderType provider;
  final String baseUrl;
  final String model;
  final String apiKey;
  final int timeoutSeconds;
  final bool fastResponses;

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
  }) =>
      AiSettings(
        provider: provider ?? this.provider,
        baseUrl: baseUrl ?? this.baseUrl,
        model: model ?? this.model,
        apiKey: apiKey ?? this.apiKey,
        timeoutSeconds: timeoutSeconds ?? this.timeoutSeconds,
        fastResponses: fastResponses ?? this.fastResponses,
      );

  Map<String, Object?> toJson() => <String, Object?>{
        'provider': provider.name,
        'baseUrl': baseUrl,
        'model': model,
        'apiKey': apiKey,
        'timeoutSeconds': timeoutSeconds,
        'fastResponses': fastResponses,
      };
}
