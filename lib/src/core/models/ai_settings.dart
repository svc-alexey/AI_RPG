enum AiProviderType { lmStudio, openAiCompatible }

class AiSettings {
  const AiSettings({
    required this.provider,
    required this.baseUrl,
    required this.model,
    required this.apiKey,
    required this.timeoutSeconds,
  });

  const AiSettings.defaults()
    : provider = AiProviderType.lmStudio,
      baseUrl = 'http://127.0.0.1:1234/v1',
      model = '',
      apiKey = '',
      timeoutSeconds = 60;

  final AiProviderType provider;
  final String baseUrl;
  final String model;
  final String apiKey;
  final int timeoutSeconds;

  bool get isConfigured => baseUrl.trim().isNotEmpty && model.trim().isNotEmpty;

  AiSettings copyWith({
    final AiProviderType? provider,
    final String? baseUrl,
    final String? model,
    final String? apiKey,
    final int? timeoutSeconds,
  }) {
    return AiSettings(
      provider: provider ?? this.provider,
      baseUrl: baseUrl ?? this.baseUrl,
      model: model ?? this.model,
      apiKey: apiKey ?? this.apiKey,
      timeoutSeconds: timeoutSeconds ?? this.timeoutSeconds,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'provider': provider.name,
      'baseUrl': baseUrl,
      'model': model,
      'apiKey': apiKey,
      'timeoutSeconds': timeoutSeconds,
    };
  }

  factory AiSettings.fromJson(final Map<String, Object?> json) {
    return AiSettings(
      provider: AiProviderType.values.firstWhere(
        (final AiProviderType item) => item.name == json['provider'],
        orElse: () => AiProviderType.lmStudio,
      ),
      baseUrl: (json['baseUrl'] as String?) ?? 'http://127.0.0.1:1234/v1',
      model: (json['model'] as String?) ?? '',
      apiKey: (json['apiKey'] as String?) ?? '',
      timeoutSeconds: (json['timeoutSeconds'] as int?) ?? 60,
    );
  }
}
