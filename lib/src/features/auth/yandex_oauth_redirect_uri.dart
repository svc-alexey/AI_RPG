import 'package:flutter/foundation.dart';

/// Redirect URI for Yandex OAuth on web. Must match the server env
/// `SYMMETRY_YANDEX_REDIRECT_URI` and the Yandex OAuth app callback URL.
String? buildYandexOAuthRedirectUriForCurrentOrigin() {
  if (!kIsWeb) {
    return null;
  }
  final Uri current = Uri.base;
  return Uri(
    scheme: current.scheme,
    host: current.host,
    port: current.hasPort ? current.port : null,
    path: '/auth/yandex/callback',
  ).toString();
}
