import 'package:ai_prg/src/core/data/isar/app_database.dart';
import 'package:ai_prg/src/core/data/isar/settings_local_data_source.dart';
import 'package:ai_prg/src/core/data/shared_preferences/settings_local_data_source.dart';
import 'package:ai_prg/src/core/data/storage/adaptive_settings_storage.dart';
import 'package:ai_prg/src/core/data/storage/settings_storage.dart';
import 'package:ai_prg/src/core/models/ai_settings.dart';
import 'package:ai_prg/src/core/models/app_language.dart';

class SettingsRepository {
  SettingsRepository({
    final AppDatabase? database,
    final SettingsLocalDataSource? isarDataSource,
    final SettingsPreferencesDataSource? preferencesDataSource,
    final SettingsStorage? storage,
  }) : _storage =
           storage ??
           AdaptiveSettingsStorage(
             database: database ?? AppDatabase.instance,
             isarDataSource: isarDataSource ?? const SettingsLocalDataSource(),
             preferencesDataSource:
                 preferencesDataSource ?? const SettingsPreferencesDataSource(),
           );

  final SettingsStorage _storage;

  Future<void> initialize() async {}

  /// Loads provider-scoped settings (for Settings screen).
  Future<ProviderScopedSettings> loadProviderScopedSettings() =>
      _storage.loadProviderScopedSettings();

  /// Loads effective AI settings for the active provider (for Chat, GameEngine).
  Future<AiSettings> loadAiSettings() async {
    final ProviderScopedSettings scoped = await loadProviderScopedSettings();
    return scoped.toEffectiveSettings();
  }

  /// Saves provider-scoped settings (from Settings screen).
  Future<void> saveProviderScopedSettings(
    final ProviderScopedSettings settings,
  ) => _storage.saveProviderScopedSettings(settings);

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
      runtimeSettings: settings.runtimeSettings,
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

  Future<AppLanguage> loadAppLanguage() => _storage.loadAppLanguage();

  Future<void> saveAppLanguage(final AppLanguage language) =>
      _storage.saveAppLanguage(language);
}
