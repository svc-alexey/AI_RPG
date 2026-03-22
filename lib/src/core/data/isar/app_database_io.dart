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
import 'package:shared_preferences/shared_preferences.dart';

class AppDatabase {
  AppDatabase({
    final String? directoryPath,
    final String name = 'ai_prg_storage',
  }) : _directoryPath = directoryPath,
       _name = name;

  static final AppDatabase instance = AppDatabase();

  static const String _schemaVersionKey = 'storage.schema_version';
  static const int _currentSchemaVersion = 6;
  static const String _legacyCampaignIdsKey = 'campaign.ids';
  static const String _legacyAiSettingsKey = 'settings.ai';
  static const String _legacyAppLanguageKey = 'settings.app_language';
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
      await _migrateLegacySharedPreferences(current);
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

  Future<void> _migrateLegacySharedPreferences(final Isar isar) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String? rawAiSettings = preferences.getString(_legacyAiSettingsKey);
    final String? rawAppLanguage = preferences.getString(_legacyAppLanguageKey);
    final List<String> campaignIds =
        preferences.getStringList(_legacyCampaignIdsKey) ?? const <String>[];

    final List<CampaignState> migratedCampaigns = <CampaignState>[];
    for (final String campaignId in campaignIds) {
      final String? rawCampaign = preferences.getString('campaign.$campaignId');
      if (rawCampaign == null || rawCampaign.trim().isEmpty) {
        continue;
      }
      final CampaignState? state = _decodeLegacyCampaign(rawCampaign);
      if (state != null) {
        migratedCampaigns.add(state);
      }
    }

    await isar.writeTxn(() async {
      if (rawAppLanguage != null && rawAppLanguage.trim().isNotEmpty) {
        await isar.appSettingRecords.put(
          AppSettingRecord()
            ..key = _legacyAppLanguageKey
            ..stringValue = rawAppLanguage
            ..updatedAt = DateTime.now(),
        );
      }
      for (final CampaignState campaign in migratedCampaigns) {
        await _upsertCampaignTxn(isar, campaign);
      }
      if (rawAiSettings != null && rawAiSettings.trim().isNotEmpty) {
        final Object? decoded = jsonDecode(rawAiSettings);
        if (decoded is Map<String, Object?>) {
          await _settingsLocal.saveAiSettingsInTxn(
            isar,
            AiSettings.fromJson(decoded),
          );
        }
      }
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
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      final String rawLanguage =
          preferences.getString(_legacyAppLanguageKey) ?? AppLanguage.ru.code;
      await _settingsLocal.saveAppLanguage(
        isar,
        AppLanguage.values.firstWhere(
          (final item) => item.code == rawLanguage,
          orElse: () => AppLanguage.ru,
        ),
      );
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

  Future<void> _upsertCampaignTxn(
    final Isar isar,
    final CampaignState campaign,
  ) async => _campaignLocal.saveCampaignInTxn(isar, campaign);

  CampaignState? _decodeLegacyCampaign(final String rawCampaign) {
    try {
      final Object? decoded = jsonDecode(rawCampaign);
      if (decoded is! Map) {
        return null;
      }
      return CampaignState.fromJson(
        decoded.map(
          (final key, final value) => MapEntry(key.toString(), value),
        ),
      );
    } catch (_) {
      return null;
    }
  }
}
