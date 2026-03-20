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

  @override
  Future<ProviderScopedSettings> loadProviderScopedSettings() async {
    await _database.ensureReady();
    if (_database.backend == StorageBackend.isar) {
      final isar = await _database.isar;
      final ProviderScopedSettings? settings = await _isarDataSource
          .loadProviderScopedSettings(isar);
      if (settings != null) {
        return settings;
      }
    }
    return _preferencesDataSource.loadProviderScopedSettings();
  }

  @override
  Future<void> saveProviderScopedSettings(
    final ProviderScopedSettings settings,
  ) async {
    await _database.ensureReady();
    if (_database.backend == StorageBackend.isar) {
      final isar = await _database.isar;
      await _isarDataSource.saveProviderScopedSettings(isar, settings);
    }
    await _preferencesDataSource.saveProviderScopedSettings(settings);
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
