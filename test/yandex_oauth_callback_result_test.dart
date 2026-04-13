import 'package:ai_prg/src/features/auth/yandex_oauth_callback_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses handoff callback parameters', () {
    final YandexOAuthCallbackResult result = YandexOAuthCallbackResult.fromUri(
      Uri.parse('https://example.com/auth/yandex/callback?handoff=abc123'),
    );

    expect(result.hasHandoff, isTrue);
    expect(result.handoffId, 'abc123');
    expect(result.hasError, isFalse);
    expect(result.hasLegacyCode, isFalse);
  });

  test('parses oauth error and legacy code callback parameters', () {
    final YandexOAuthCallbackResult
    errorResult = YandexOAuthCallbackResult.fromUri(
      Uri.parse(
        'https://example.com/auth/yandex/callback?oauth_error=provider_auth_failed',
      ),
    );
    final YandexOAuthCallbackResult
    legacyResult = YandexOAuthCallbackResult.fromUri(
      Uri.parse(
        'https://example.com/auth/yandex/callback?code=legacy-code&state=legacy-state',
      ),
    );

    expect(errorResult.hasError, isTrue);
    expect(errorResult.errorCode, 'provider_auth_failed');
    expect(legacyResult.hasLegacyCode, isTrue);
    expect(legacyResult.legacyCode, 'legacy-code');
    expect(legacyResult.hasLegacyState, isTrue);
    expect(legacyResult.legacyState, 'legacy-state');
    expect(legacyResult.hasLegacyOAuthCallback, isTrue);
  });
}
