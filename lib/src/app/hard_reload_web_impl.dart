// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

Future<void> triggerHardReload({final String? cacheBustToken}) async {
  try {
    final registrations = await html.window.navigator.serviceWorker
        ?.getRegistrations();
    if (registrations != null) {
      for (final registration in registrations) {
        try {
          await registration.unregister();
        } catch (_) {}
      }
    }
  } catch (_) {}

  try {
    final caches = html.window.caches;
    if (caches != null) {
      final dynamic rawNames = await caches.keys();
      if (rawNames is Iterable) {
        for (final String cacheName in rawNames.cast<String>()) {
          try {
            await caches.delete(cacheName);
          } catch (_) {}
        }
      }
    }
  } catch (_) {}

  final Uri reloadUri = Uri.base.replace(
    queryParameters: <String, String>{
      ...Uri.base.queryParameters,
      'v': cacheBustToken ?? DateTime.now().millisecondsSinceEpoch.toString(),
    },
  );
  html.window.location.replace(reloadUri.toString());
}
