import 'package:ai_prg/src/core/models/campaign_models.dart';

class CampaignLocalDataSource {
  const CampaignLocalDataSource();

  Never _unsupported() =>
      throw UnsupportedError('CampaignLocalDataSource is not used on web.');

  Future<List<CampaignState>> loadAllCampaigns(final Object isar) async =>
      _unsupported();

  Future<CampaignState?> loadCampaign(
    final Object isar,
    final String id,
  ) async => _unsupported();

  Future<void> saveCampaign(
    final Object isar,
    final CampaignState campaign,
  ) async => _unsupported();

  Future<void> saveCampaignInTxn(
    final Object isar,
    final CampaignState campaign,
  ) async => _unsupported();

  Future<void> deleteCampaign(final Object isar, final String id) async =>
      _unsupported();
}
