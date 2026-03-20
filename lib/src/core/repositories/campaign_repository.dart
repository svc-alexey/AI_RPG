import 'package:ai_prg/src/core/data/isar/app_database.dart';
import 'package:ai_prg/src/core/data/isar/campaign_local_data_source.dart';
import 'package:ai_prg/src/core/data/shared_preferences/campaign_local_data_source.dart';
import 'package:ai_prg/src/core/data/storage/adaptive_campaign_storage.dart';
import 'package:ai_prg/src/core/data/storage/campaign_storage.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';

class CampaignRepository {
  CampaignRepository({
    final AppDatabase? database,
    final CampaignLocalDataSource? isarDataSource,
    final CampaignPreferencesDataSource? preferencesDataSource,
    final CampaignStorage? storage,
  }) : _storage =
           storage ??
           AdaptiveCampaignStorage(
             database: database ?? AppDatabase.instance,
             isarDataSource: isarDataSource ?? const CampaignLocalDataSource(),
             preferencesDataSource:
                 preferencesDataSource ?? const CampaignPreferencesDataSource(),
           );

  final CampaignStorage _storage;

  Future<void> initialize() async {}

  Future<List<CampaignState>> loadAllCampaigns() => _storage.loadAllCampaigns();

  Future<CampaignState?> loadCampaign(final String id) =>
      _storage.loadCampaign(id);

  Future<void> saveCampaign(final CampaignState campaign) =>
      _storage.saveCampaign(campaign);

  Future<void> deleteCampaign(final String id) => _storage.deleteCampaign(id);
}
