import 'package:ai_prg/src/core/models/map_models.dart';
import 'package:ai_prg/src/core/repositories/symmetry_auth_repository.dart';
import 'package:ai_prg/src/core/services/symmetry_api_client.dart';

class MapRepository {
  MapRepository({required SymmetryAuthRepository authRepository})
    : _authRepository = authRepository;

  final SymmetryAuthRepository _authRepository;

  SymmetryApiClient _client(final String baseUrl) =>
      SymmetryApiClient(baseUrl: baseUrl);

  Future<CampaignMap> getMap(final String campaignId) async {
    final json = await _authRepository.runWithAuthorizedSession(
      (final session) => _client(session.baseUrl).getCampaignMap(
        accessToken: session.tokens.accessToken,
        campaignId: campaignId,
      ),
    );
    return CampaignMap.fromJson(json);
  }

  Future<ReturnSummary> getReturnSummary(final String campaignId) async {
    final json = await _authRepository.runWithAuthorizedSession(
      (final session) => _client(session.baseUrl).getReturnSummary(
        accessToken: session.tokens.accessToken,
        campaignId: campaignId,
      ),
    );
    return ReturnSummary.fromJson(json);
  }

  Future<String> seedMap(final String campaignId) async {
    final json = await _authRepository.runWithAuthorizedSession(
      (final session) => _client(session.baseUrl).seedCampaignMap(
        accessToken: session.tokens.accessToken,
        campaignId: campaignId,
      ),
    );
    return (json['node_id'] as String?) ?? '';
  }

  Future<List<Map<String, dynamic>>> submitProposals(
    final String campaignId,
    final List<Map<String, dynamic>> proposals,
  ) async {
    final json = await _authRepository.runWithAuthorizedSession(
      (final session) => _client(session.baseUrl).submitMapProposals(
        accessToken: session.tokens.accessToken,
        campaignId: campaignId,
        proposals: proposals,
      ),
    );
    final list = json['proposals'] as List<dynamic>? ?? [];
    return list.map((p) => p as Map<String, dynamic>).toList();
  }

  Future<void> markSeen(final String campaignId) async {
    await _authRepository.runWithAuthorizedSession(
      (final session) => _client(session.baseUrl).markMapSeen(
        accessToken: session.tokens.accessToken,
        campaignId: campaignId,
      ),
    );
  }
}
