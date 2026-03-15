import 'dart:convert';

import 'package:ai_prg/src/core/models/ai_settings.dart';
import 'package:ai_prg/src/core/repositories/settings_repository.dart';
import 'package:http/http.dart' as http;

class LmStudioAutoConfig {
  const LmStudioAutoConfig();

  Future<AiSettings> sync(final SettingsRepository repository) async {
    final AiSettings current = await repository.loadAiSettings();
    if (current.provider != AiProviderType.lmStudio) {
      return current;
    }

    final String baseUrl = current.baseUrl.trim().isEmpty
        ? const AiSettings.defaults().baseUrl
        : current.baseUrl.trim();

    try {
      final Uri uri = Uri.parse('${_normalizeBaseUrl(baseUrl)}/models');
      final http.Response response = await http
          .get(
            uri,
            headers: const <String, String>{'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return current;
      }

      final Object? decoded = jsonDecode(response.body);
      if (decoded is! Map<String, Object?>) {
        return current;
      }

      final List<Object?> items =
          (decoded['data'] as List<Object?>?) ?? const <Object?>[];
      final List<String> modelIds = items
          .map((item) => item as Map<String, Object?>?)
          .whereType<Map<String, Object?>>()
          .map((item) => (item['id'] as String?)?.trim() ?? '')
          .where((item) => item.isNotEmpty)
          .toList();

      final String selected = _selectPreferredModel(modelIds);
      if (selected.isEmpty) {
        return current;
      }

      final AiSettings next = current.copyWith(
        baseUrl: baseUrl,
        model: selected,
      );
      if (next.baseUrl == current.baseUrl && next.model == current.model) {
        return current;
      }

      await repository.saveAiSettings(next);
      return next;
    } catch (_) {
      return current;
    }
  }

  String _selectPreferredModel(final List<String> modelIds) {
    if (modelIds.isEmpty) {
      return '';
    }

    final Iterable<String> chatModels = modelIds.where((modelId) {
      final String normalized = modelId.toLowerCase();
      return !normalized.contains('embedding') &&
          !normalized.contains('embed') &&
          !normalized.contains('rerank');
    });

    if (chatModels.isNotEmpty) {
      return chatModels.first;
    }

    return modelIds.first;
  }

  String _normalizeBaseUrl(final String baseUrl) => baseUrl.endsWith('/')
      ? baseUrl.substring(0, baseUrl.length - 1)
      : baseUrl;
}
