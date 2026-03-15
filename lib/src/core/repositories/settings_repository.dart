import 'dart:convert';

import 'package:ai_prg/src/core/models/ai_settings.dart';
import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  static const String _aiSettingsKey = 'settings.ai';
  static const String _appLanguageKey = 'settings.app_language';

  Future<AiSettings> loadAiSettings() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String? raw = preferences.getString(_aiSettingsKey);
    if (raw == null || raw.isEmpty) {
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
    final String raw = preferences.getString(_appLanguageKey) ?? AppLanguage.ru.code;
    return AppLanguage.values.firstWhere(
      (final item) => item.code == raw,
      orElse: () => AppLanguage.ru,
    );
  }

  Future<void> saveAppLanguage(final AppLanguage language) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(_appLanguageKey, language.code);
  }
}
