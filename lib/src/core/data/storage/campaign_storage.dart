import 'package:ai_prg/src/core/models/campaign_models.dart';

abstract class CampaignStorage {
  Future<List<CampaignState>> loadAllCampaigns();

  Future<CampaignState?> loadCampaign(String id);

  Future<void> saveCampaign(CampaignState campaign);

  Future<void> deleteCampaign(String id);
}
