import 'dart:convert';
import 'dart:developer' as developer;

import 'package:ai_prg/src/core/config/symmetry_runtime_env.dart';
import 'package:ai_prg/src/core/models/ai_settings.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:ai_prg/src/core/models/symmetry_models.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class SymmetryApiClient {
  const SymmetryApiClient({
    this.baseUrl = SymmetryRuntimeEnv.defaultBaseUrl,
    this.httpClient,
  });

  final String baseUrl;
  final http.Client? httpClient;

  Future<void> checkHealth() async {
    final http.Client client = httpClient ?? http.Client();
    final String url = _join('/health', apiPrefix: false);
    _logDev('request', <String, Object?>{
      'method': 'GET',
      'url': url,
    });
    try {
      final http.Response response = await client.get(
        Uri.parse(url),
      );
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

  Future<void> logout({required final String refreshToken}) async {
    await _post(
      '/auth/logout',
      body: <String, Object?>{'refresh_token': refreshToken},
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
    required final DifficultyLevel difficulty,
    required final String languageCode,
    required final String storyWish,
    required final AiSettings aiSettings,
  }) async {
    final Map<String, Object?> response = await _post(
      '/prompts/generate',
      bearerToken: accessToken,
      body: <String, Object?>{
        'setting': setting.name,
        'literary_genre': literaryGenre.name,
        'difficulty': difficulty.name,
        'language': languageCode,
        'story_wish': storyWish,
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

  Future<SymmetryTurnResponse> processTurn({
    required final String accessToken,
    required final String campaignId,
    required final String playerAction,
    required final String languageCode,
    required final AiSettings aiSettings,
    final String triggerSource = 'manual',
  }) async {
    final Map<String, Object?> response = await _post(
      '/campaigns/$campaignId/turns/process',
      bearerToken: accessToken,
      body: <String, Object?>{
        'player_action': playerAction,
        'language': languageCode,
        'trigger_source': triggerSource,
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

  Future<Object?> _get(final String path, {final String? bearerToken}) async {
    final http.Client client = httpClient ?? http.Client();
    final String url = _join(path);
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
    if (!apiPrefix) {
      final String withoutApi = normalizedBase.endsWith('/v1')
          ? normalizedBase.substring(0, normalizedBase.length - 3)
          : normalizedBase;
      return '$withoutApi$path';
    }
    return '$normalizedBase$path';
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

  void _logDev(final String event, final Map<String, Object?> payload) {
    if (!kDebugMode) {
      return;
    }
    developer.log(
      jsonEncode(payload),
      name: 'SymmetryApiClient.$event',
    );
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
