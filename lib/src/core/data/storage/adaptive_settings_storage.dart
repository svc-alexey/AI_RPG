import 'package:ai_prg/src/core/data/isar/app_database.dart';
import 'package:ai_prg/src/core/data/isar/settings_local_data_source.dart';
import 'package:ai_prg/src/core/data/isar/storage_backend.dart';
import 'package:ai_prg/src/core/data/shared_preferences/settings_local_data_source.dart';
import 'package:ai_prg/src/core/data/storage/settings_storage.dart';
import 'package:ai_prg/src/core/models/ai_settings.dart';
import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/models/symmetry_models.dart';

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

  AiSettings _withFixedRuntime(final AiSettings settings) =>
      settings.copyWith(runtimeSettings: ModelRuntimeSettings.defaults);

  Future<AiSettings> _loadAiSettingsPersistedBody() async {
    await _database.ensureReady();
    if (_database.backend == StorageBackend.isar) {
      final isar = await _database.isar;
      final AiSettings? settings = await _isarDataSource.loadAiSettings(isar);
      if (settings != null) {
        return _withFixedRuntime(settings);
      }
    }
    return _withFixedRuntime(await _preferencesDataSource.loadAiSettings());
  }

  @override
  Future<AiSettings> loadAiSettingsPersisted() async =>
      _loadAiSettingsPersistedBody();

  @override
  Future<AiSettings> loadAiSettings() async =>
      AiSettings.withEnvFallbacks(await _loadAiSettingsPersistedBody());

  @override
  Future<void> saveAiSettings(final AiSettings settings) async {
    final AiSettings normalized = _withFixedRuntime(settings);
    await _database.ensureReady();
    if (_database.backend == StorageBackend.isar) {
      final isar = await _database.isar;
      await _isarDataSource.saveAiSettings(isar, normalized);
    }
    await _preferencesDataSource.saveAiSettings(normalized);
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

  @override
  Future<String?> loadSymmetryBaseUrl() async {
    await _database.ensureReady();
    if (_database.backend == StorageBackend.isar) {
      final isar = await _database.isar;
      final String? baseUrl = await _isarDataSource.loadSymmetryBaseUrl(isar);
      if (baseUrl != null && baseUrl.trim().isNotEmpty) {
        return baseUrl;
      }
    }
    return _preferencesDataSource.loadSymmetryBaseUrl();
  }

  @override
  Future<void> saveSymmetryBaseUrl(final String baseUrl) async {
    await _database.ensureReady();
    if (_database.backend == StorageBackend.isar) {
      final isar = await _database.isar;
      await _isarDataSource.saveSymmetryBaseUrl(isar, baseUrl);
    }
    await _preferencesDataSource.saveSymmetryBaseUrl(baseUrl);
  }

  @override
  Future<SymmetrySession?> loadSymmetrySession() async {
    await _database.ensureReady();
    if (_database.backend == StorageBackend.isar) {
      final isar = await _database.isar;
      final SymmetrySession? session = await _isarDataSource
          .loadSymmetrySession(isar);
      if (session != null) {
        return session;
      }
    }
    return _preferencesDataSource.loadSymmetrySession();
  }

  @override
  Future<void> saveSymmetrySession(final SymmetrySession? session) async {
    await _database.ensureReady();
    if (_database.backend == StorageBackend.isar) {
      final isar = await _database.isar;
      await _isarDataSource.saveSymmetrySession(isar, session);
    }
    await _preferencesDataSource.saveSymmetrySession(session);
  }

  @override
  Future<Map<String, String>> loadCampaignMapMarks(
    final String campaignId,
  ) async {
    await _database.ensureReady();
    if (_database.backend == StorageBackend.isar) {
      final isar = await _database.isar;
      final Map<String, String> marks = await _isarDataSource
          .loadCampaignMapMarks(isar, campaignId);
      if (marks.isNotEmpty) {
        return marks;
      }
    }
    return _preferencesDataSource.loadCampaignMapMarks(campaignId);
  }

  @override
  Future<void> saveCampaignMapMarks(
    final String campaignId,
    final Map<String, String> marks,
  ) async {
    await _database.ensureReady();
    if (_database.backend == StorageBackend.isar) {
      final isar = await _database.isar;
      await _isarDataSource.saveCampaignMapMarks(isar, campaignId, marks);
    }
    await _preferencesDataSource.saveCampaignMapMarks(campaignId, marks);
  }
}
