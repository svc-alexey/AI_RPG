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

  Future<AiSettings> loadAiSettings() => _storage.loadAiSettings();

  Future<void> saveAiSettings(final AiSettings settings) =>
      _storage.saveAiSettings(settings);

  Future<AppLanguage> loadAppLanguage() => _storage.loadAppLanguage();

  Future<void> saveAppLanguage(final AppLanguage language) =>
      _storage.saveAppLanguage(language);
}
