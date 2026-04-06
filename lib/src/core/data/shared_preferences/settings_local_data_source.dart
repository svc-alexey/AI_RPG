import 'dart:convert';

import 'package:ai_prg/src/core/models/ai_settings.dart';
import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/models/symmetry_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPreferencesDataSource {
  const SettingsPreferencesDataSource();

  static const String _aiSettingsKey = 'settings.ai';
  static const String _appLanguageKey = 'settings.app_language';
  static const String _symmetryBaseUrlKey = 'settings.symmetry_base_url';
  static const String _symmetrySessionKey = 'settings.symmetry_session';

  Future<AiSettings> loadAiSettings() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String raw = preferences.getString(_aiSettingsKey) ?? '';
    if (raw.isEmpty) {
      return const AiSettings.defaults();
    }

    final Object? decoded = jsonDecode(raw);
    if (decoded is! Map<String, Object?>) {
      return const AiSettings.defaults();
    }

    return AiSettings.fromJson(decoded);
  }

  Future<void> saveAiSettings(final AiSettings settings) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(_aiSettingsKey, jsonEncode(settings.toJson()));
  }

  Future<AppLanguage> loadAppLanguage() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String raw =
        preferences.getString(_appLanguageKey) ?? AppLanguage.ru.code;
    return AppLanguage.values.firstWhere(
      (final item) => item.code == raw,
      orElse: () => AppLanguage.ru,
    );
  }

  Future<void> saveAppLanguage(final AppLanguage language) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(_appLanguageKey, language.code);
  }

  Future<String?> loadSymmetryBaseUrl() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(_symmetryBaseUrlKey);
  }

  Future<void> saveSymmetryBaseUrl(final String baseUrl) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(_symmetryBaseUrlKey, baseUrl);
  }

  Future<SymmetrySession?> loadSymmetrySession() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String raw = preferences.getString(_symmetrySessionKey) ?? '';
    if (raw.isEmpty) {
      return null;
    }
    final Object? decoded = jsonDecode(raw);
    if (decoded is! Map<String, Object?>) {
      return null;
    }
    return SymmetrySession.fromJson(decoded);
  }

  Future<void> saveSymmetrySession(final SymmetrySession? session) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    if (session == null) {
      await preferences.remove(_symmetrySessionKey);
      return;
    }
    await preferences.setString(
      _symmetrySessionKey,
      jsonEncode(session.toJson()),
    );
  }
}
