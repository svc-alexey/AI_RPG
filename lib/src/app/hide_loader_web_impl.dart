// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

/// Скрывает HTML-лоадер из index.html.
void hideHtmlLoader() {
  html.document.getElementById('loading-container')?.remove();
}
