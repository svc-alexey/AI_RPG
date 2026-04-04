import 'dart:convert';

import 'package:ai_prg/src/core/data/isar/campaign_local_data_source.dart';
import 'package:ai_prg/src/core/data/isar/isar_collections.dart';
import 'package:ai_prg/src/core/data/isar/settings_local_data_source.dart';
import 'package:ai_prg/src/core/data/isar/storage_backend.dart';
import 'package:ai_prg/src/core/models/ai_settings.dart';
import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class AppDatabase {
  AppDatabase({
    final String? directoryPath,
    final String name = 'ai_prg_storage',
  }) : _directoryPath = directoryPath,
       _name = name;

  static final AppDatabase instance = AppDatabase();

  static const String _schemaVersionKey = 'storage.schema_version';
  static const int _currentSchemaVersion = 6;
  static const String _legacyAiSettingsKey = 'settings.ai';
  static const CampaignLocalDataSource _campaignLocal =
      CampaignLocalDataSource();
  static const SettingsLocalDataSource _settingsLocal =
      SettingsLocalDataSource();

  final String? _directoryPath;
  final String _name;

  Isar? _isar;
  Future<Isar>? _openFuture;
  Future<void>? _readyFuture;
  Object? _openError;

  StorageBackend get backend =>
      _isar != null ? StorageBackend.isar : StorageBackend.sharedPreferences;

  Future<void> ensureReady() {
    _readyFuture ??= _ensureReadyInternal();
    return _readyFuture!;
  }

  Future<Isar> get isar async {
    await ensureReady();
    return _isar!;
  }

  Future<Isar?> get maybeIsar async {
    await ensureReady();
    return _isar;
  }

  Future<void> close({final bool deleteFromDisk = false}) async {
    final Isar? current = _isar;
    _isar = null;
    _openFuture = null;
    _readyFuture = null;
    if (current != null) {
      await current.close(deleteFromDisk: deleteFromDisk);
    }
  }

  Future<void> _ensureReadyInternal() async {
    Isar? current;
    try {
      current = await _open();
    } catch (error) {
      _openError = error;
      debugPrint('Isar unavailable, falling back to legacy storage: $error');
      return;
    }

    final AppSettingRecord? versionRecord = await current.appSettingRecords
        .filter()
        .keyEqualTo(_schemaVersionKey)
        .findFirst();
    if (versionRecord == null) {
      await _bootstrapEmptyIsar(current);
      return;
    }

    final int version = int.tryParse(versionRecord.stringValue ?? '') ?? 1;
    if (version < _currentSchemaVersion) {
      await _migrateStructuredStorage(current);
    }
  }

  Future<Isar> _open() async {
    if (_openError != null) {
      throw _openError!;
    }
    if (_isar != null) {
      return _isar!;
    }
    if (_openFuture != null) {
      return _openFuture!;
    }

    _openFuture = () async {
      final String directory = await _resolveDirectory();
      final List<CollectionSchema<dynamic>> schemas =
          <CollectionSchema<dynamic>>[
            CampaignRecordSchema,
            WorldStateRecordSchema,
            MessageRecordSchema,
            InventoryItemRecordSchema,
            CompanionRecordSchema,
            ProviderProfileRecordSchema,
            ModelControlRecordSchema,
            AppSettingRecordSchema,
          ];
      final Isar opened = await Isar.open(
        schemas,
        name: _name,
        directory: directory,
        inspector: false,
      );
      _isar = opened;
      return opened;
    }();

    return _openFuture!;
  }

  Future<String> _resolveDirectory() async {
    if (kIsWeb) {
      return '';
    }
    if (_directoryPath != null && _directoryPath.trim().isNotEmpty) {
      return _directoryPath;
    }
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  /// Pre-prod: no import from legacy SharedPreferences; fresh Isar only.
  Future<void> _bootstrapEmptyIsar(final Isar isar) async {
    await isar.writeTxn(() async {
      await isar.appSettingRecords.put(
        AppSettingRecord()
          ..key = _schemaVersionKey
          ..stringValue = _currentSchemaVersion.toString()
          ..updatedAt = DateTime.now(),
      );
    });
  }

  Future<void> _migrateStructuredStorage(final Isar isar) async {
    final AiSettings? typedSettings = await _settingsLocal.loadAiSettings(isar);
    if (typedSettings == null) {
      final AppSettingRecord? legacySettings = await isar.appSettingRecords
          .filter()
          .keyEqualTo(_legacyAiSettingsKey)
          .findFirst();
      if (legacySettings?.jsonValue != null) {
        final Object? decoded = jsonDecode(legacySettings!.jsonValue!);
        if (decoded is Map<String, Object?>) {
          await _settingsLocal.saveAiSettings(isar, AiSettings.fromJson(decoded));
        }
      }
    }

    final AppLanguage? language = await _settingsLocal.loadAppLanguage(isar);
    if (language == null) {
      await _settingsLocal.saveAppLanguage(isar, AppLanguage.ru);
    }

    if ((await isar.campaignRecords.where().count()) > 0) {
      final List<CampaignState> campaigns = await _campaignLocal
          .loadAllCampaigns(isar);
      for (final CampaignState campaign in campaigns) {
        await _campaignLocal.saveCampaign(
          isar,
          campaign.copyWith(
            schemaVersion: campaign.schemaVersion < 4
                ? 4
                : campaign.schemaVersion,
          ),
        );
      }
    }

    await isar.writeTxn(() async {
      await isar.appSettingRecords.put(
        AppSettingRecord()
          ..key = _schemaVersionKey
          ..stringValue = _currentSchemaVersion.toString()
          ..updatedAt = DateTime.now(),
      );
    });
  }

}
