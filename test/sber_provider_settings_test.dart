import 'package:ai_prg/src/core/models/ai_settings.dart';
import 'package:ai_prg/src/core/services/ai_service_factory.dart';
import 'package:ai_prg/src/core/services/openai_compatible_ai_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Sber GigaChat defaults are proxy-backed and managed by app', () {
    expect(
      AiSettings.defaultBaseUrlFor(AiProviderType.sberGigaChat),
      'http://127.0.0.1:8787/v1',
    );
    expect(
      AiSettings.defaultModelFor(AiProviderType.sberGigaChat),
      'GigaChat-2',
    );
    expect(AiProviderType.sberGigaChat.supportsFastResponses, isFalse);
    expect(AiProviderType.sberGigaChat.supportsModelAutoDetect, isFalse);
    expect(AiProviderType.sberGigaChat.hidesConnectionSecrets, isTrue);
    expect(AiProviderType.sberGigaChat.hidesModelField, isTrue);
  });

  test('Provider-scoped settings preserve Sber GigaChat profile', () {
    final ProviderScopedSettings settings = ProviderScopedSettings(
      activeProvider: AiProviderType.sberGigaChat,
      profiles: <AiProviderType, ProviderProfile>{
        for (final AiProviderType provider in AiProviderType.values)
          provider: ProviderProfile.defaultsFor(provider),
      },
      fastResponses: false,
    );

    final Map<String, Object?> json = settings.toJson();
    final ProviderScopedSettings restored = ProviderScopedSettings.fromJson(
      json,
    );

    expect(restored.activeProvider, AiProviderType.sberGigaChat);
    final ProviderProfile profile = restored.profileFor(
      AiProviderType.sberGigaChat,
    );
    expect(profile.baseUrl, 'http://127.0.0.1:8787/v1');
    expect(profile.model, 'GigaChat-2');
  });

  test('AiServiceFactory uses the OpenAI-compatible client for Sber proxy', () {
    const AiSettings settings = AiSettings(
      provider: AiProviderType.sberGigaChat,
      baseUrl: 'http://127.0.0.1:8787/v1',
      model: 'GigaChat-2',
      apiKey: '',
      timeoutSeconds: 60,
      fastResponses: false,
      runtimeSettings: ModelRuntimeSettings.smartPreset,
    );

    final Object client = const AiServiceFactory().create(settings);
    expect(client, isA<OpenAiCompatibleAiClient>());
  });

  test('Sber proxy path disables streaming requests', () {
    final OpenAiCompatibleAiClient client = OpenAiCompatibleAiClient();
    const AiSettings settings = AiSettings(
      provider: AiProviderType.sberGigaChat,
      baseUrl: 'http://127.0.0.1:8787/v1',
      model: 'GigaChat-2',
      apiKey: '',
      timeoutSeconds: 60,
      fastResponses: false,
      runtimeSettings: ModelRuntimeSettings.smartPreset,
    );

    expect(client.supportsStreamingForTesting(settings), isFalse);
  });
}
