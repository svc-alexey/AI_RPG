import 'dart:convert';

import 'package:ai_prg/src/core/models/ai_settings.dart';
import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  static const String _aiSettingsKey = 'settings.ai';
  static const String _appLanguageKey = 'settings.app_language';

  /// Loads provider-scoped settings (for Settings screen).
  Future<ProviderScopedSettings> loadProviderScopedSettings() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String? raw = preferences.getString(_aiSettingsKey);
    if (raw == null || raw.isEmpty) {
      return ProviderScopedSettings(
        activeProvider: AiProviderType.lmStudio,
        profiles: <AiProviderType, ProviderProfile>{
          for (final AiProviderType p in AiProviderType.values)
            p: ProviderProfile.defaultsFor(p),
        },
        fastResponses: true,
      );
    }

    final Object? decoded = jsonDecode(raw);
    if (decoded is! Map<String, Object?>) {
      return ProviderScopedSettings(
        activeProvider: AiProviderType.lmStudio,
        profiles: <AiProviderType, ProviderProfile>{
          for (final AiProviderType p in AiProviderType.values)
            p: ProviderProfile.defaultsFor(p),
        },
        fastResponses: true,
      );
    }

    return ProviderScopedSettings.fromJson(decoded);
  }

  /// Loads effective AI settings for the active provider (for Chat, GameEngine).
  Future<AiSettings> loadAiSettings() async {
    final ProviderScopedSettings scoped = await loadProviderScopedSettings();
    return scoped.toEffectiveSettings();
  }

  /// Saves provider-scoped settings (from Settings screen).
  Future<void> saveProviderScopedSettings(
    final ProviderScopedSettings settings,
  ) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _aiSettingsKey,
      jsonEncode(settings.toJson()),
    );
  }

  /// Saves AI settings by updating the active provider's profile.
  /// Used by LmStudioAutoConfig and other callers that only have AiSettings.
  Future<void> saveAiSettings(final AiSettings settings) async {
    final ProviderScopedSettings scoped = await loadProviderScopedSettings();
    final ProviderProfile current = scoped.profileFor(settings.provider);
    final ProviderProfile updated = current.copyWith(
      baseUrl: settings.baseUrl,
      model: settings.model,
      apiKey: settings.apiKey,
      timeoutSeconds: settings.timeoutSeconds,
    );
    final Map<AiProviderType, ProviderProfile> newProfiles =
        Map<AiProviderType, ProviderProfile>.from(scoped.profiles);
    newProfiles[settings.provider] = updated;
    await saveProviderScopedSettings(
      scoped.copyWith(
        activeProvider: settings.provider,
        profiles: newProfiles,
        fastResponses: settings.fastResponses,
      ),
    );
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
}
