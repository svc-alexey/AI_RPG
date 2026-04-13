// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

void replaceBrowserUrl(final String url) {
  html.window.history.replaceState(null, '', url);
}

void navigateBrowserUrl(final String url) {
  html.window.location.replace(url);
}
