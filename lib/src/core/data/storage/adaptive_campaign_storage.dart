import 'package:ai_prg/src/core/data/isar/app_database.dart';
import 'package:ai_prg/src/core/data/isar/campaign_local_data_source.dart';
import 'package:ai_prg/src/core/data/isar/storage_backend.dart';
import 'package:ai_prg/src/core/data/shared_preferences/campaign_local_data_source.dart';
import 'package:ai_prg/src/core/data/storage/campaign_storage.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';

class AdaptiveCampaignStorage implements CampaignStorage {
  AdaptiveCampaignStorage({
    required AppDatabase database,
    required CampaignLocalDataSource isarDataSource,
    required CampaignPreferencesDataSource preferencesDataSource,
  }) : _database = database,
       _isarDataSource = isarDataSource,
       _preferencesDataSource = preferencesDataSource;

  final AppDatabase _database;
  final CampaignLocalDataSource _isarDataSource;
  final CampaignPreferencesDataSource _preferencesDataSource;

  @override
  Future<List<CampaignState>> loadAllCampaigns() async {
    await _database.ensureReady();
    if (_database.backend != StorageBackend.isar) {
      return _preferencesDataSource.loadAllCampaigns();
    }
    final isar = await _database.isar;
    return _isarDataSource.loadAllCampaigns(isar);
  }

  @override
  Future<CampaignState?> loadCampaign(final String id) async {
    await _database.ensureReady();
    if (_database.backend != StorageBackend.isar) {
      return _preferencesDataSource.loadCampaign(id);
    }
    final isar = await _database.isar;
    return _isarDataSource.loadCampaign(isar, id);
  }

  @override
  Future<void> saveCampaign(final CampaignState campaign) async {
    await _database.ensureReady();
    if (_database.backend != StorageBackend.isar) {
      await _preferencesDataSource.saveCampaign(campaign);
      return;
    }
    final isar = await _database.isar;
    await _isarDataSource.saveCampaign(isar, campaign);
  }

  @override
  Future<void> deleteCampaign(final String id) async {
    await _database.ensureReady();
    if (_database.backend != StorageBackend.isar) {
      await _preferencesDataSource.deleteCampaign(id);
      return;
    }
    final isar = await _database.isar;
    await _isarDataSource.deleteCampaign(isar, id);
  }
}
