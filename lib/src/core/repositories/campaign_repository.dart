import 'dart:convert';

import 'package:ai_prg/src/core/data/isar/app_database.dart';
import 'package:ai_prg/src/core/data/isar/campaign_local_data_source.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CampaignRepository {
  CampaignRepository({
    final AppDatabase? database,
    final CampaignLocalDataSource? localDataSource,
  }) : _database = database ?? AppDatabase.instance,
       _localDataSource = localDataSource ?? const CampaignLocalDataSource();

  final AppDatabase _database;
  final CampaignLocalDataSource _localDataSource;

  Future<void> initialize() => _database.ensureReady();

  Future<List<CampaignState>> loadAllCampaigns() async {
    final isar = await _database.maybeIsar;
    if (isar == null) {
      return _loadAllCampaignsLegacy();
    }
    return _localDataSource.loadAllCampaigns(isar);
  }

  Future<CampaignState?> loadCampaign(final String id) async {
    final isar = await _database.maybeIsar;
    if (isar == null) {
      return _loadCampaignLegacy(id);
    }
    return _localDataSource.loadCampaign(isar, id);
  }

  Future<void> saveCampaign(final CampaignState campaign) async {
    final isar = await _database.maybeIsar;
    if (isar == null) {
      await _saveCampaignLegacy(campaign);
      return;
    }
    await _localDataSource.saveCampaign(isar, campaign);
  }

  Future<void> deleteCampaign(final String id) async {
    final isar = await _database.maybeIsar;
    if (isar == null) {
      await _deleteCampaignLegacy(id);
      return;
    }
    await _localDataSource.deleteCampaign(isar, id);
  }

  Future<List<CampaignState>> _loadAllCampaignsLegacy() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final List<String> ids =
        preferences.getStringList(_campaignIdsKey) ?? const <String>[];

    final List<CampaignState> campaigns = <CampaignState>[];
    for (final String id in ids) {
      final CampaignState? state = await _loadCampaignLegacy(id);
      if (state != null) {
        campaigns.add(state);
      }
    }

    campaigns.sort((final a, final b) => b.updatedAt.compareTo(a.updatedAt));
    return campaigns;
  }

  Future<CampaignState?> _loadCampaignLegacy(final String id) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String? raw = preferences.getString(_campaignKey(id));
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final Object? decoded = jsonDecode(raw);
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

  Future<void> _saveCampaignLegacy(final CampaignState campaign) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final List<String> ids =
        preferences.getStringList(_campaignIdsKey) ?? <String>[];
    if (!ids.contains(campaign.id)) {
      ids.add(campaign.id);
      await preferences.setStringList(_campaignIdsKey, ids);
    }

    await preferences.setString(
      _campaignKey(campaign.id),
      jsonEncode(campaign.toJson()),
    );
  }

  Future<void> _deleteCampaignLegacy(final String id) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final List<String> ids = <String>[
      ...(preferences.getStringList(_campaignIdsKey) ?? <String>[]),
    ]..remove(id);
    await preferences.setStringList(_campaignIdsKey, ids);
    await preferences.remove(_campaignKey(id));
  }

  static const String _campaignIdsKey = 'campaign.ids';

  String _campaignKey(final String id) => 'campaign.$id';
}
