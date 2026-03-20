import 'dart:convert';

import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CampaignPreferencesDataSource {
  const CampaignPreferencesDataSource();

  static const String _campaignIdsKey = 'campaign.ids';

  Future<List<CampaignState>> loadAllCampaigns() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final List<String> ids =
        preferences.getStringList(_campaignIdsKey) ?? const <String>[];

    final List<CampaignState> campaigns = <CampaignState>[];
    for (final String id in ids) {
      final CampaignState? state = await loadCampaign(id);
      if (state != null) {
        campaigns.add(state);
      }
    }

    campaigns.sort((final a, final b) => b.updatedAt.compareTo(a.updatedAt));
    return campaigns;
  }

  Future<CampaignState?> loadCampaign(final String id) async {
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

  Future<void> saveCampaign(final CampaignState campaign) async {
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

  Future<void> deleteCampaign(final String id) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final List<String> ids = <String>[
      ...(preferences.getStringList(_campaignIdsKey) ?? <String>[]),
    ]..remove(id);
    await preferences.setStringList(_campaignIdsKey, ids);
    await preferences.remove(_campaignKey(id));
  }

  String _campaignKey(final String id) => 'campaign.$id';
}
