import 'dart:convert';
import 'dart:developer' as developer;

import 'package:ai_prg/src/core/config/symmetry_runtime_env.dart';
import 'package:ai_prg/src/core/models/ai_settings.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:ai_prg/src/core/models/literary_genre_model.dart';
import 'package:ai_prg/src/core/models/story_template_model.dart';
import 'package:ai_prg/src/core/models/symmetry_models.dart';
import 'package:ai_prg/src/core/services/location_origin_stub.dart'
    if (dart.library.js_interop) 'package:ai_prg/src/core/services/location_origin_web.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Symmetry mounts REST routes under `/v1`. If the user saved `http://127.0.0.1:8080`
/// without the prefix, all API calls (including PUT …/cover) return 404.
String normalizeSymmetryApiBaseUrl(String raw) {
  final String trimmed = raw.trim();
  if (trimmed.isEmpty) {
    return SymmetryRuntimeEnv.defaultBaseUrl;
  }
  final String noTrailingSlash = trimmed.endsWith('/')
      ? trimmed.substring(0, trimmed.length - 1)
      : trimmed;
  if (noTrailingSlash.endsWith('/v1')) {
    return noTrailingSlash;
  }
  final Uri? u = Uri.tryParse(noTrailingSlash);
  if (u == null || !u.hasScheme || u.host.isEmpty) {
    return noTrailingSlash;
  }
  final bool loopback =
      u.host == 'localhost' ||
      u.host == '127.0.0.1' ||
      u.host == '::1';
  final bool pathEmptyOrRoot = u.path.isEmpty || u.path == '/';
  if (loopback && pathEmptyOrRoot) {
    return '$noTrailingSlash/v1';
  }
  return noTrailingSlash;
}

class SymmetryApiClient {
  SymmetryApiClient({
    String baseUrl = SymmetryRuntimeEnv.defaultBaseUrl,
    this.httpClient,
  }) : baseUrl = normalizeSymmetryApiBaseUrl(baseUrl);

  final String baseUrl;
  final http.Client? httpClient;

  Future<void> checkHealth() async {
    final http.Client client = httpClient ?? http.Client();
    final String url = _join('/health', apiPrefix: false);
    _logDev('request', <String, Object?>{'method': 'GET', 'url': url});
    try {
      final http.Response response = await client.get(Uri.parse(url));
      _logDev('response', <String, Object?>{
        'method': 'GET',
        'url': url,
        'statusCode': response.statusCode,
      });
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw _buildException(
          response: response,
          fallbackMessage: 'symmetry_unreachable',
        );
      }
    } catch (error) {
      _logDev('error', <String, Object?>{
        'method': 'GET',
        'url': url,
        'error': error.toString(),
      });
      rethrow;
    } finally {
      if (httpClient == null) {
        client.close();
      }
    }
  }

  Future<SymmetryAuthResponse> login({
    required final String email,
    required final String password,
  }) async {
    final Map<String, Object?> response = await _post(
      '/auth/login',
      body: <String, Object?>{'email': email, 'password': password},
    );
    return SymmetryAuthResponse.fromJson(response);
  }

  Future<SymmetryAuthResponse> guestLogin() async {
    final Map<String, Object?> response = await _post(
      '/auth/guest',
      body: const <String, Object?>{},
    );
    return SymmetryAuthResponse.fromJson(response);
  }

  Future<SymmetryAuthResponse> register({
    required final String email,
    required final String password,
    final String displayName = '',
  }) async {
    final Map<String, Object?> response = await _post(
      '/auth/register',
      body: <String, Object?>{
        'email': email,
        'password': password,
        'display_name': displayName,
      },
    );
    return SymmetryAuthResponse.fromJson(response);
  }

  Future<SymmetryAuthResponse> refresh({
    required final String refreshToken,
  }) async {
    final Map<String, Object?> response = await _post(
      '/auth/refresh',
      body: <String, Object?>{'refresh_token': refreshToken},
    );
    return SymmetryAuthResponse.fromJson(response);
  }

  Uri buildYandexStartUri() => Uri.parse(_join('/auth/yandex/start'));

  Future<SymmetryAuthResponse> completeYandexHandoff({
    required final String handoffId,
  }) async {
    final Map<String, Object?> response = await _post(
      '/auth/yandex/complete',
      body: <String, Object?>{'handoff_id': handoffId},
    );
    return SymmetryAuthResponse.fromJson(response);
  }

  Future<void> logout({required final String refreshToken}) async {
    await _post(
      '/auth/logout',
      body: <String, Object?>{'refresh_token': refreshToken},
    );
  }

  Future<void> verifyEmail({required final String token}) async {
    await _get(
      '/auth/verify-email?token=${Uri.encodeQueryComponent(token)}',
    );
  }

  Future<Map<String, Object?>> resendVerification({
    required final String accessToken,
  }) async {
    return _post(
      '/auth/resend-verification',
      body: const <String, Object?>{},
      bearerToken: accessToken,
    );
  }

  Future<void> forgotPassword({required final String email}) async {
    await _post(
      '/auth/forgot-password',
      body: <String, Object?>{'email': email},
    );
  }

  Future<void> changePassword({
    required final String accessToken,
    required final String currentPassword,
    required final String newPassword,
  }) async {
    await _post(
      '/auth/change-password',
      body: <String, Object?>{
        'current_password': currentPassword,
        'new_password': newPassword,
      },
      bearerToken: accessToken,
    );
  }

  Future<SymmetryUser> getCurrentUser({
    required final String accessToken,
  }) async {
    final Object? decoded = await _get(
      '/auth/me',
      bearerToken: accessToken,
    );
    if (decoded is! Map<Object?, Object?>) {
      throw StateError('symmetry_invalid_response');
    }
    return SymmetryUser.fromJson(
      decoded.map(
        (final key, final value) =>
            MapEntry(key.toString(), value),
      ),
    );
  }

  Future<void> checkProviderConnection({
    required final String accessToken,
    required final AiSettings aiSettings,
  }) async {
    await _post(
      '/providers/check',
      bearerToken: accessToken,
      body: <String, Object?>{
        'allow_server_fallback': true,
        if (aiSettings.baseUrl.trim().isNotEmpty &&
            aiSettings.model.trim().isNotEmpty &&
            aiSettings.apiKey.trim().isNotEmpty)
          'provider_credentials': <String, Object?>{
            'base_url': aiSettings.baseUrl.trim(),
            'model': aiSettings.model.trim(),
            'api_key': aiSettings.apiKey.trim(),
          },
      },
    );
  }

  Future<SymmetryGeneratedPrompts> generatePrompts({
    required final String accessToken,
    required final CampaignSetting setting,
    required final LiteraryGenre literaryGenre,
    required final StoryMode mode,
    required final DifficultyLevel difficulty,
    required final String languageCode,
    required final String storyWish,
    required final AiSettings aiSettings,
    final CharacterProfile? characterProfile,
  }) async {
    final Map<String, Object?> response = await _post(
      '/prompts/generate',
      bearerToken: accessToken,
      body: <String, Object?>{
        'setting': setting.name,
        'literary_genre': literaryGenre.name,
        'mode': mode.name,
        'difficulty': difficulty.name,
        'language': languageCode,
        'story_wish': storyWish,
        if (characterProfile != null) 'character': characterProfile.toJson(),
        if (aiSettings.baseUrl.trim().isNotEmpty &&
            aiSettings.model.trim().isNotEmpty &&
            aiSettings.apiKey.trim().isNotEmpty)
          'provider_credentials': <String, Object?>{
            'base_url': aiSettings.baseUrl.trim(),
            'model': aiSettings.model.trim(),
            'api_key': aiSettings.apiKey.trim(),
          },
      },
    );
    return SymmetryGeneratedPrompts.fromJson(response);
  }

  Future<SymmetryCampaignStateResponse> createCampaign({
    required final String accessToken,
    required final Map<String, Object?> payload,
  }) async {
    final Map<String, Object?> response = await _post(
      '/campaigns',
      bearerToken: accessToken,
      body: payload,
    );
    return SymmetryCampaignStateResponse.fromJson(response);
  }

  Future<List<SymmetryCampaignSummary>> listCampaigns({
    required final String accessToken,
  }) async {
    final Object? decoded = await _get('/campaigns', bearerToken: accessToken);
    if (decoded is! List<Object?>) {
      throw StateError('symmetry_invalid_response');
    }
    return decoded
        .whereType<Map<Object?, Object?>>()
        .map(
          (final item) => SymmetryCampaignSummary.fromJson(
            item.map(
              (final key, final value) => MapEntry(key.toString(), value),
            ),
          ),
        )
        .toList();
  }

  Future<SymmetryCampaignStateResponse> getCampaignState({
    required final String accessToken,
    required final String campaignId,
  }) async {
    final Object? decoded = await _get(
      '/campaigns/$campaignId/state',
      bearerToken: accessToken,
    );
    if (decoded is! Map<Object?, Object?>) {
      throw StateError('symmetry_invalid_response');
    }
    return SymmetryCampaignStateResponse.fromJson(
      decoded.map((final key, final value) => MapEntry(key.toString(), value)),
    );
  }

  Future<void> deleteCampaign({
    required final String accessToken,
    required final String campaignId,
  }) async {
    await _delete('/campaigns/$campaignId', bearerToken: accessToken);
  }

  Future<SymmetryVersionInfo> getVersionInfo({
    final String? currentVersion,
    final String? currentAssetVersion,
  }) async {
    final List<String> queryParts = <String>[
      if (currentVersion != null && currentVersion.trim().isNotEmpty)
        'current_version=${Uri.encodeQueryComponent(currentVersion.trim())}',
      if (currentAssetVersion != null && currentAssetVersion.trim().isNotEmpty)
        'current_asset_version=${Uri.encodeQueryComponent(currentAssetVersion.trim())}',
    ];
    final String path = queryParts.isEmpty
        ? '/version'
        : '/version?${queryParts.join('&')}';
    final Object? decoded = await _get(path, apiPrefix: false);
    if (decoded is! Map<Object?, Object?>) {
      throw StateError('symmetry_invalid_response');
    }
    return SymmetryVersionInfo.fromJson(
      decoded.map((final key, final value) => MapEntry(key.toString(), value)),
    );
  }

  Future<List<SymmetryWorldRumor>> getCampaignRumors({
    required final String accessToken,
    required final String campaignId,
    final int limit = 5,
  }) async {
    final Object? decoded = await _get(
      '/campaigns/$campaignId/rumors?limit=$limit',
      bearerToken: accessToken,
    );
    if (decoded is! List<Object?>) {
      throw StateError('symmetry_invalid_response');
    }
    return decoded
        .whereType<Map<Object?, Object?>>()
        .map(
          (final item) => SymmetryWorldRumor.fromJson(
            item.map(
              (final key, final value) => MapEntry(key.toString(), value),
            ),
          ),
        )
        .toList();
  }

  Future<SymmetryTurnResponse> processTurn({
    required final String accessToken,
    required final String campaignId,
    required final String playerAction,
    required final String languageCode,
    required final AiSettings aiSettings,
    final String triggerSource = 'manual',
    final int? diceRoll,
  }) async {
    final Map<String, Object?> response = await _post(
      '/campaigns/$campaignId/turns/process',
      bearerToken: accessToken,
      body: <String, Object?>{
        'player_action': playerAction,
        'language': languageCode,
        'trigger_source': triggerSource,
        if (diceRoll != null) 'dice_roll': diceRoll,
        if (aiSettings.baseUrl.trim().isNotEmpty &&
            aiSettings.model.trim().isNotEmpty &&
            aiSettings.apiKey.trim().isNotEmpty)
          'provider_credentials': <String, Object?>{
            'base_url': aiSettings.baseUrl.trim(),
            'model': aiSettings.model.trim(),
            'api_key': aiSettings.apiKey.trim(),
          },
      },
    );
    return SymmetryTurnResponse.fromJson(response);
  }

  Future<List<LiteraryGenreCatalogItem>> listLiteraryGenres({
    required final String accessToken,
  }) async {
    final Object? decoded = await _get(
      '/literary-genres',
      bearerToken: accessToken,
    );
    if (decoded is! List<Object?>) {
      throw StateError('symmetry_invalid_response');
    }
    return decoded
        .whereType<Map<Object?, Object?>>()
        .map(
          (final item) => LiteraryGenreCatalogItem.fromJson(
            item.map(
              (final key, final value) => MapEntry(key.toString(), value),
            ),
          ),
        )
        .toList();
  }

  Future<List<StoryTemplate>> listStoryTemplates({
    required final String accessToken,
    final String? tag,
    final String? genre,
    final String sort = 'new',
    final String scope = 'all',
  }) async {
    final List<String> queryParts = <String>[
      'sort=${Uri.encodeQueryComponent(sort)}',
      'scope=${Uri.encodeQueryComponent(scope)}',
      if (tag != null && tag.trim().isNotEmpty)
        'tag=${Uri.encodeQueryComponent(tag.trim())}',
      if (genre != null && genre.trim().isNotEmpty)
        'genre=${Uri.encodeQueryComponent(genre.trim())}',
    ];
    final Object? decoded = await _get(
      '/story-templates?${queryParts.join('&')}',
      bearerToken: accessToken,
    );
    if (decoded is! List<Object?>) {
      throw StateError('symmetry_invalid_response');
    }
    return decoded
        .whereType<Map<Object?, Object?>>()
        .map(
          (final item) => StoryTemplate.fromJson(
            item.map(
              (final key, final value) => MapEntry(key.toString(), value),
            ),
          ),
        )
        .toList();
  }

  Future<StoryTemplate> createStoryTemplate({
    required final String accessToken,
    required final Map<String, Object?> body,
  }) async {
    final Map<String, Object?> response = await _post(
      '/story-templates',
      bearerToken: accessToken,
      body: body,
    );
    return StoryTemplate.fromJson(response);
  }

  Future<StoryTemplate> getStoryTemplate({
    required final String accessToken,
    required final String templateId,
  }) async {
    final Object? decoded = await _get(
      '/story-templates/$templateId',
      bearerToken: accessToken,
    );
    if (decoded is! Map<Object?, Object?>) {
      throw StateError('symmetry_invalid_response');
    }
    return StoryTemplate.fromJson(
      decoded.map((final key, final value) => MapEntry(key.toString(), value)),
    );
  }

  Future<void> postStoryTemplateView({
    required final String accessToken,
    required final String templateId,
  }) async {
    await _post(
      '/story-templates/$templateId/view',
      bearerToken: accessToken,
      body: const <String, Object?>{},
    );
  }

  Future<void> postStoryTemplateLike({
    required final String accessToken,
    required final String templateId,
  }) async {
    await _post(
      '/story-templates/$templateId/like',
      bearerToken: accessToken,
      body: const <String, Object?>{},
    );
  }

  Future<List<StoryTemplate>> adminListStoryTemplates({
    required final String accessToken,
    final String? tag,
    final String? genre,
    final String sort = 'new',
  }) async {
    final List<String> queryParts = <String>[
      'sort=${Uri.encodeQueryComponent(sort)}',
      if (tag != null && tag.trim().isNotEmpty)
        'tag=${Uri.encodeQueryComponent(tag.trim())}',
      if (genre != null && genre.trim().isNotEmpty)
        'genre=${Uri.encodeQueryComponent(genre.trim())}',
    ];
    final String q = queryParts.isEmpty ? '' : '?${queryParts.join('&')}';
    final Object? decoded = await _get(
      '/admin/story-templates$q',
      bearerToken: accessToken,
    );
    if (decoded is! List<Object?>) {
      throw StateError('symmetry_invalid_response');
    }
    return decoded
        .whereType<Map<Object?, Object?>>()
        .map(
          (final item) => StoryTemplate.fromJson(
            item.map(
              (final key, final value) => MapEntry(key.toString(), value),
            ),
          ),
        )
        .toList();
  }

  Future<StoryTemplate> adminUpsertStoryTemplate({
    required final String accessToken,
    required final Map<String, Object?> body,
    final String? templateId,
  }) async {
    if (templateId != null && templateId.trim().isNotEmpty) {
      final Map<String, Object?> response = await _patch(
        '/admin/story-templates/${templateId.trim()}',
        bearerToken: accessToken,
        body: body,
      );
      return StoryTemplate.fromJson(response);
    }
    final Map<String, Object?> response = await _post(
      '/admin/story-templates',
      bearerToken: accessToken,
      body: body,
    );
    return StoryTemplate.fromJson(response);
  }

  Future<void> adminDeleteStoryTemplate({
    required final String accessToken,
    required final String templateId,
  }) async {
    await _delete(
      '/admin/story-templates/${templateId.trim()}',
      bearerToken: accessToken,
    );
  }

  Future<Map<String, Object?>> adminBulkDeleteStoryTemplates({
    required final String accessToken,
    required final List<String> ids,
  }) async {
    return _post(
      '/admin/story-templates/bulk-delete',
      body: <String, Object?>{'ids': ids},
      bearerToken: accessToken,
    );
  }

  Future<List<StoryTemplate>> listMyStoryTemplates({
    required final String accessToken,
  }) async {
    final Object? decoded = await _get(
      '/story-templates/my',
      bearerToken: accessToken,
    );
    if (decoded is! List<Object?>) {
      throw StateError('symmetry_invalid_response');
    }
    return decoded
        .whereType<Map<Object?, Object?>>()
        .map(
          (final item) => StoryTemplate.fromJson(
            item.map((k, v) => MapEntry(k.toString(), v)),
          ),
        )
        .toList();
  }

  Future<void> deleteMyStoryTemplate({
    required final String accessToken,
    required final String templateId,
  }) async {
    await _delete(
      '/story-templates/${templateId.trim()}',
      bearerToken: accessToken,
    );
  }

  Future<void> adminPutStoryTemplateCoverRaw({
    required final String accessToken,
    required final String templateId,
    required final List<int> bytes,
    required final String contentType,
  }) async {
    await _putBytes(
      '/admin/story-templates/${templateId.trim()}/cover',
      body: bytes,
      contentType: contentType,
      bearerToken: accessToken,
    );
  }

  Future<void> adminDeleteStoryTemplateCover({
    required final String accessToken,
    required final String templateId,
  }) async {
    await _delete(
      '/admin/story-templates/${templateId.trim()}/cover',
      bearerToken: accessToken,
    );
  }

  Future<Map<String, Object?>> _post(
    final String path, {
    required final Map<String, Object?> body,
    final String? bearerToken,
  }) async {
    final http.Client client = httpClient ?? http.Client();
    final String url = _join(path);
    _logDev('request', <String, Object?>{
      'method': 'POST',
      'url': url,
      'hasBearerToken': bearerToken != null && bearerToken.trim().isNotEmpty,
      'body': _redactBody(body),
    });
    try {
      final http.Response response = await client.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
          if (bearerToken != null && bearerToken.trim().isNotEmpty)
            'Authorization': 'Bearer $bearerToken',
        },
        body: jsonEncode(body),
      );
      final Object? decoded = _tryDecode(response.body);
      _logDev('response', <String, Object?>{
        'method': 'POST',
        'url': url,
        'statusCode': response.statusCode,
        'body': _redactDecoded(decoded),
      });
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw _buildException(
          response: response,
          decoded: decoded,
          fallbackMessage: 'symmetry_request_failed_${response.statusCode}',
        );
      }
      if (decoded is Map<Object?, Object?>) {
        return decoded.map(
          (final key, final value) => MapEntry(key.toString(), value),
        );
      }
      throw const SymmetryApiException(message: 'symmetry_invalid_response');
    } catch (error) {
      _logDev('error', <String, Object?>{
        'method': 'POST',
        'url': url,
        'error': error.toString(),
      });
      rethrow;
    } finally {
      if (httpClient == null) {
        client.close();
      }
    }
  }

  Future<Map<String, Object?>> _patch(
    final String path, {
    required final Map<String, Object?> body,
    final String? bearerToken,
  }) async {
    final http.Client client = httpClient ?? http.Client();
    final String url = _join(path);
    _logDev('request', <String, Object?>{
      'method': 'PATCH',
      'url': url,
      'hasBearerToken': bearerToken != null && bearerToken.trim().isNotEmpty,
      'body': _redactBody(body),
    });
    try {
      final http.Response response = await client.patch(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
          if (bearerToken != null && bearerToken.trim().isNotEmpty)
            'Authorization': 'Bearer $bearerToken',
        },
        body: jsonEncode(body),
      );
      final Object? decoded = _tryDecode(response.body);
      _logDev('response', <String, Object?>{
        'method': 'PATCH',
        'url': url,
        'statusCode': response.statusCode,
        'body': _redactDecoded(decoded),
      });
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw _buildException(
          response: response,
          decoded: decoded,
          fallbackMessage: 'symmetry_request_failed_${response.statusCode}',
        );
      }
      if (decoded is Map<Object?, Object?>) {
        return decoded.map(
          (final key, final value) => MapEntry(key.toString(), value),
        );
      }
      throw const SymmetryApiException(message: 'symmetry_invalid_response');
    } catch (error) {
      _logDev('error', <String, Object?>{
        'method': 'PATCH',
        'url': url,
        'error': error.toString(),
      });
      rethrow;
    } finally {
      if (httpClient == null) {
        client.close();
      }
    }
  }

  Future<void> _putBytes(
    final String path, {
    required final List<int> body,
    required final String contentType,
    final String? bearerToken,
  }) async {
    final http.Client client = httpClient ?? http.Client();
    final String url = _join(path);
    _logDev('request', <String, Object?>{
      'method': 'PUT',
      'url': url,
      'hasBearerToken': bearerToken != null && bearerToken.trim().isNotEmpty,
      'body': 'bytes(${body.length})',
    });
    try {
      final http.Response response = await client.put(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': contentType,
          if (bearerToken != null && bearerToken.trim().isNotEmpty)
            'Authorization': 'Bearer $bearerToken',
        },
        body: body,
      );
      _logDev('response', <String, Object?>{
        'method': 'PUT',
        'url': url,
        'statusCode': response.statusCode,
      });
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw _buildException(
          response: response,
          decoded: _tryDecode(response.body),
          fallbackMessage: 'symmetry_request_failed_${response.statusCode}',
        );
      }
    } catch (error) {
      _logDev('error', <String, Object?>{
        'method': 'PUT',
        'url': url,
        'error': error.toString(),
      });
      rethrow;
    } finally {
      if (httpClient == null) {
        client.close();
      }
    }
  }

  // ── Campaign Map ──

  Future<Map<String, dynamic>> getCampaignMap({
    required final String accessToken,
    required final String campaignId,
  }) async {
    final decoded = await _get(
      '/campaigns/$campaignId/map',
      bearerToken: accessToken,
    );
    if (decoded is! Map<Object?, Object?>) {
      throw StateError('symmetry_invalid_map_response');
    }
    return decoded.map((k, v) => MapEntry(k.toString(), v));
  }

  Future<Map<String, dynamic>> getReturnSummary({
    required final String accessToken,
    required final String campaignId,
  }) async {
    final decoded = await _get(
      '/campaigns/$campaignId/return-summary',
      bearerToken: accessToken,
    );
    if (decoded is! Map<Object?, Object?>) {
      throw StateError('symmetry_invalid_return_summary');
    }
    return decoded.map((k, v) => MapEntry(k.toString(), v));
  }

  Future<Map<String, dynamic>> seedCampaignMap({
    required final String accessToken,
    required final String campaignId,
  }) async {
    final decoded = await _post(
      '/campaigns/$campaignId/map/seed',
      body: const <String, Object?>{},
      bearerToken: accessToken,
    );
    return decoded.map((k, v) => MapEntry(k, v));
  }

  Future<Map<String, dynamic>> submitMapProposals({
    required final String accessToken,
    required final String campaignId,
    required final List<Map<String, dynamic>> proposals,
  }) async {
    final decoded = await _post(
      '/campaigns/$campaignId/map/proposals',
      body: <String, Object?>{'proposals': proposals},
      bearerToken: accessToken,
    );
    return decoded.map((k, v) => MapEntry(k, v));
  }

  Future<void> markMapSeen({
    required final String accessToken,
    required final String campaignId,
  }) async {
    await _post(
      '/campaigns/$campaignId/map/mark-seen',
      body: const <String, Object?>{},
      bearerToken: accessToken,
    );
  }

  Future<Object?> _get(
    final String path, {
    final String? bearerToken,
    final bool apiPrefix = true,
  }) async {
    final http.Client client = httpClient ?? http.Client();
    final String url = _join(path, apiPrefix: apiPrefix);
    _logDev('request', <String, Object?>{
      'method': 'GET',
      'url': url,
      'hasBearerToken': bearerToken != null && bearerToken.trim().isNotEmpty,
    });
    try {
      final http.Response response = await client.get(
        Uri.parse(url),
        headers: <String, String>{
          if (bearerToken != null && bearerToken.trim().isNotEmpty)
            'Authorization': 'Bearer $bearerToken',
        },
      );
      final Object? decoded = _tryDecode(response.body);
      _logDev('response', <String, Object?>{
        'method': 'GET',
        'url': url,
        'statusCode': response.statusCode,
        'body': _redactDecoded(decoded),
      });
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw _buildException(
          response: response,
          decoded: decoded,
          fallbackMessage: 'symmetry_request_failed_${response.statusCode}',
        );
      }
      return decoded;
    } catch (error) {
      _logDev('error', <String, Object?>{
        'method': 'GET',
        'url': url,
        'error': error.toString(),
      });
      rethrow;
    } finally {
      if (httpClient == null) {
        client.close();
      }
    }
  }

  Future<void> _delete(final String path, {final String? bearerToken}) async {
    final http.Client client = httpClient ?? http.Client();
    final String url = _join(path);
    _logDev('request', <String, Object?>{
      'method': 'DELETE',
      'url': url,
      'hasBearerToken': bearerToken != null && bearerToken.trim().isNotEmpty,
    });
    try {
      final http.Response response = await client.delete(
        Uri.parse(url),
        headers: <String, String>{
          if (bearerToken != null && bearerToken.trim().isNotEmpty)
            'Authorization': 'Bearer $bearerToken',
        },
      );
      _logDev('response', <String, Object?>{
        'method': 'DELETE',
        'url': url,
        'statusCode': response.statusCode,
      });
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw _buildException(
          response: response,
          decoded: _tryDecode(response.body),
          fallbackMessage: 'symmetry_request_failed_${response.statusCode}',
        );
      }
    } catch (error) {
      _logDev('error', <String, Object?>{
        'method': 'DELETE',
        'url': url,
        'error': error.toString(),
      });
      rethrow;
    } finally {
      if (httpClient == null) {
        client.close();
      }
    }
  }

  String _join(final String path, {final bool apiPrefix = true}) {
    final String normalizedBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final String relative;
    if (!apiPrefix) {
      final String withoutApi = normalizedBase.endsWith('/v1')
          ? normalizedBase.substring(0, normalizedBase.length - 3)
          : normalizedBase;
      relative = '$withoutApi$path';
    } else {
      relative = '$normalizedBase$path';
    }
    // Dart2JS can miscompile Uri.base as a file:// URL on Windows.
    // Use the browser's location.origin directly for absolute URLs.
    if (kIsWeb && relative.startsWith('/')) {
      try {
        return '${getLocationOrigin()}$relative';
      } catch (_) {
        return relative; // fallback: let the browser resolve it
      }
    }
    return relative;
  }

  Object? _tryDecode(final String body) {
    if (body.trim().isEmpty) {
      return null;
    }
    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
  }

  SymmetryApiException _buildException({
    required final http.Response response,
    required final String fallbackMessage,
    final Object? decoded,
  }) {
    String? detailCode;
    List<String> validationErrors = const <String>[];

    if (decoded is Map<Object?, Object?>) {
      final Object? detail = decoded['detail'];
      if (detail is String && detail.trim().isNotEmpty) {
        detailCode = detail.trim();
      } else if (detail is List<Object?>) {
        validationErrors = detail
            .whereType<Map<Object?, Object?>>()
            .map(_validationMessageFromDetail)
            .where((final item) => item.isNotEmpty)
            .toList();
      }
    }

    return SymmetryApiException(
      message: fallbackMessage,
      statusCode: response.statusCode,
      detailCode: detailCode,
      validationErrors: validationErrors,
    );
  }

  String _validationMessageFromDetail(final Map<Object?, Object?> item) {
    final List<Object?> location =
        (item['loc'] as List<Object?>?) ?? const <Object?>[];
    final String field = location.isNotEmpty ? location.last.toString() : '';
    final String message = (item['msg'] as String?)?.trim() ?? '';
    if (field.isEmpty) {
      return message;
    }
    return '$field: $message';
  }

  // ── Billing ───────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getBillingCatalog() async {
    final Object? decoded = await _get('/billing/catalog');
    if (decoded is! List<Object?>) {
      throw StateError('symmetry_invalid_response');
    }
    return decoded
        .whereType<Map<Object?, Object?>>()
        .map((final m) => m.map((final k, final v) => MapEntry(k.toString(), v)))
        .toList()
        .cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> getBillingWallet({
    required final String accessToken,
  }) async {
    final Object? decoded = await _get(
      '/billing/me',
      bearerToken: accessToken,
    );
    if (decoded is! Map<Object?, Object?>) {
      throw StateError('symmetry_invalid_response');
    }
    return decoded.map(
      (final k, final v) => MapEntry(k.toString(), v),
    );
  }

  Future<Map<String, dynamic>> postBillingCheckout({
    required final String accessToken,
    required final String planCode,
    final String returnUrl = '/',
  }) async {
    final Object? decoded = await _post(
      '/billing/checkout',
      body: <String, Object?>{
        'plan_code': planCode,
        'return_url': returnUrl,
      },
      bearerToken: accessToken,
    );
    if (decoded is! Map<Object?, Object?>) {
      throw StateError('symmetry_invalid_response');
    }
    return decoded.map(
      (final k, final v) => MapEntry(k.toString(), v),
    );
  }

  Future<List<Map<String, dynamic>>> getBillingTransactions({
    required final String accessToken,
    final int limit = 20,
  }) async {
    final Object? decoded = await _get(
      '/billing/transactions?limit=$limit',
      bearerToken: accessToken,
    );
    if (decoded is List<Object?>) {
      return decoded
          .whereType<Map<Object?, Object?>>()
          .map((final m) => m.map(
                (final k, final v) => MapEntry(k.toString(), v),
              ))
          .toList();
    }
    return <Map<String, dynamic>>[];
  }

  Future<Map<String, dynamic>> postClaimWelcome({
    required final String accessToken,
  }) async {
    final Object? decoded = await _post(
      '/billing/claim-welcome',
      body: <String, Object?>{},
      bearerToken: accessToken,
    );
    if (decoded is! Map<Object?, Object?>) {
      throw StateError('symmetry_invalid_response');
    }
    return decoded.map(
      (final k, final v) => MapEntry(k.toString(), v),
    );
  }

  Future<Map<String, dynamic>> getBillingOrder({
    required final String accessToken,
    required final String orderId,
  }) async {
    final Object? decoded = await _get(
      '/billing/orders/$orderId',
      bearerToken: accessToken,
    );
    if (decoded is! Map<Object?, Object?>) {
      throw StateError('symmetry_invalid_response');
    }
    return decoded.map(
      (final k, final v) => MapEntry(k.toString(), v),
    );
  }

  Future<void> postMigrateGuest({
    required final String accessToken,
    required final String guestUserId,
  }) async {
    await _post(
      '/auth/migrate-guest',
      body: <String, Object?>{'guest_user_id': guestUserId},
      bearerToken: accessToken,
    );
  }

  void _logDev(final String event, final Map<String, Object?> payload) {
    if (!kDebugMode) {
      return;
    }
    developer.log(jsonEncode(payload), name: 'SymmetryApiClient.$event');
  }

  Object? _redactBody(final Object? payload) {
    if (payload is Map<String, Object?>) {
      return payload.map((final key, final value) {
        if (key == 'provider_credentials') {
          return MapEntry(key, _redactProviderCredentials(value));
        }
        return MapEntry(key, _redactBody(value));
      });
    }
    if (payload is List<Object?>) {
      return payload.map(_redactBody).toList();
    }
    return payload;
  }

  Object? _redactDecoded(final Object? payload) {
    if (payload is Map<Object?, Object?>) {
      return payload.map((final key, final value) {
        if (key.toString() == 'provider_credentials') {
          return MapEntry(key, _redactProviderCredentials(value));
        }
        return MapEntry(key, _redactDecoded(value));
      });
    }
    if (payload is List<Object?>) {
      return payload.map(_redactDecoded).toList();
    }
    return payload;
  }

  Object? _redactProviderCredentials(final Object? payload) {
    if (payload is! Map<Object?, Object?>) {
      return payload;
    }
    return payload.map((final key, final value) {
      if (key.toString() == 'api_key') {
        return MapEntry(key, '***');
      }
      return MapEntry(key, value);
    });
  }
}
