enum AiProviderType { lmStudio, openAiCompatible, openRouter, deepSeek }

extension AiProviderTypeCapabilities on AiProviderType {
  String get defaultBaseUrl => AiSettings.defaultBaseUrlFor(this);

  String get defaultModel => AiSettings.defaultModelFor(this);

  bool get supportsFastResponses => this == AiProviderType.lmStudio;

  bool get supportsModelAutoDetect => this == AiProviderType.lmStudio;
}

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
  }) => AiSettings(
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
