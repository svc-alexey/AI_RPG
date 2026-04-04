import 'package:ai_prg/src/core/data/isar/app_database.dart';
import 'package:ai_prg/src/core/data/isar/settings_local_data_source.dart';
import 'package:ai_prg/src/core/data/isar/storage_backend.dart';
import 'package:ai_prg/src/core/data/shared_preferences/settings_local_data_source.dart';
import 'package:ai_prg/src/core/data/storage/settings_storage.dart';
import 'package:ai_prg/src/core/models/ai_settings.dart';
import 'package:ai_prg/src/core/models/app_language.dart';

class AdaptiveSettingsStorage implements SettingsStorage {
  AdaptiveSettingsStorage({
    required AppDatabase database,
    required SettingsLocalDataSource isarDataSource,
    required SettingsPreferencesDataSource preferencesDataSource,
  }) : _database = database,
       _isarDataSource = isarDataSource,
       _preferencesDataSource = preferencesDataSource;

  final AppDatabase _database;
  final SettingsLocalDataSource _isarDataSource;
  final SettingsPreferencesDataSource _preferencesDataSource;

  Future<AiSettings> _loadAiSettingsPersistedBody() async {
    await _database.ensureReady();
    if (_database.backend == StorageBackend.isar) {
      final isar = await _database.isar;
      final AiSettings? settings = await _isarDataSource.loadAiSettings(isar);
      if (settings != null) {
        return settings;
      }
    }
    return _preferencesDataSource.loadAiSettings();
  }

  @override
  Future<AiSettings> loadAiSettingsPersisted() async =>
      _loadAiSettingsPersistedBody();

  @override
  Future<AiSettings> loadAiSettings() async =>
      AiSettings.withEnvFallbacks(await _loadAiSettingsPersistedBody());

  @override
  Future<void> saveAiSettings(final AiSettings settings) async {
    await _database.ensureReady();
    if (_database.backend == StorageBackend.isar) {
      final isar = await _database.isar;
      await _isarDataSource.saveAiSettings(isar, settings);
    }
    await _preferencesDataSource.saveAiSettings(settings);
  }

  @override
  Future<AppLanguage> loadAppLanguage() async {
    await _database.ensureReady();
    if (_database.backend == StorageBackend.isar) {
      final isar = await _database.isar;
      final AppLanguage? language = await _isarDataSource.loadAppLanguage(isar);
      if (language != null) {
        return language;
      }
    }
    return _preferencesDataSource.loadAppLanguage();
  }

  @override
  Future<void> saveAppLanguage(final AppLanguage language) async {
    await _database.ensureReady();
    if (_database.backend == StorageBackend.isar) {
      final isar = await _database.isar;
      await _isarDataSource.saveAppLanguage(isar, language);
    }
    await _preferencesDataSource.saveAppLanguage(language);
  }
}
