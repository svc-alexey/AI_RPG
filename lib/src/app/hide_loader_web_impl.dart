import 'dart:async';
// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

/// Removes the HTML loader immediately.
void hideHtmlLoader() {
  html.document.getElementById('loading-container')?.remove();
}

/// Notifies the landing page that Flutter has painted its first frame.
void notifyHtmlLoaderFirstFrame() {
  html.window.dispatchEvent(html.CustomEvent('codex:flutter-first-frame'));
}

/// Notifies the landing page that Flutter finished rendering the ready UI.
void completeHtmlLoaderTransition() {
  html.window.dispatchEvent(html.CustomEvent('codex:flutter-ready'));
  Timer(const Duration(milliseconds: 900), () {
    html.document.getElementById('loading-container')?.remove();
  });
}
