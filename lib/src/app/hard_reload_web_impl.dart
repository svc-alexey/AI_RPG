// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

Future<void> triggerHardReload({final String? cacheBustToken}) async {
  try {
    final html.ServiceWorkerContainer? serviceWorker =
        html.window.navigator.serviceWorker;
    final List<html.ServiceWorkerRegistration>? registrations =
        serviceWorker == null
        ? null
        : (await serviceWorker.getRegistrations())
              .cast<html.ServiceWorkerRegistration>();
    if (registrations != null) {
      for (final registration in registrations) {
        try {
          await registration.unregister();
        } catch (_) {}
      }
    }
  } catch (_) {}

  try {
    final html.CacheStorage? caches = html.window.caches;
    final Object? rawCacheNames = caches == null ? null : await caches.keys();
    final List<String>? cacheNames = rawCacheNames is List
        ? rawCacheNames.cast<String>()
        : null;
    if (cacheNames != null) {
      for (final cacheName in cacheNames) {
        try {
          await caches?.delete(cacheName);
        } catch (_) {}
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
