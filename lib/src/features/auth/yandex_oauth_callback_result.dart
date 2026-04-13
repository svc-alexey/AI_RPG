class YandexOAuthCallbackResult {
  const YandexOAuthCallbackResult._({
    required this.handoffId,
    required this.errorCode,
    required this.legacyCode,
    required this.legacyState,
  });

  factory YandexOAuthCallbackResult.fromUri(final Uri uri) =>
      YandexOAuthCallbackResult._(
        handoffId: uri.queryParameters['handoff']?.trim() ?? '',
        errorCode: uri.queryParameters['oauth_error']?.trim() ?? '',
        legacyCode: uri.queryParameters['code']?.trim() ?? '',
        legacyState: uri.queryParameters['state']?.trim() ?? '',
      );

  final String handoffId;
  final String errorCode;
  final String legacyCode;
  final String legacyState;

  bool get hasHandoff => handoffId.isNotEmpty;
  bool get hasError => errorCode.isNotEmpty;
  bool get hasLegacyCode => legacyCode.isNotEmpty;
  bool get hasLegacyState => legacyState.isNotEmpty;
  bool get hasLegacyOAuthCallback => hasLegacyCode && hasLegacyState;
}
