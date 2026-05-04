import 'dart:convert';

import 'package:ai_prg/src/core/models/ai_settings.dart';
import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:ai_prg/src/core/services/ai_client.dart';
import 'package:ai_prg/src/core/services/ai_user_messages.dart';
import 'package:ai_prg/src/core/services/openai_compatible_json_helpers.dart';

class AiResponseParser {
  const AiResponseParser({required this.messages});

  final AiUserMessages messages;

  // --- JSON extraction ---

  String extractJson(String raw, AppLanguage language) {
    final String trimmed = raw.trim();
    if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
      return trimmed;
    }

    final int start = trimmed.indexOf('{');
    final int end = trimmed.lastIndexOf('}');
    if (start == -1 || end == -1 || end <= start) {
      throw AiTurnException(
        userMessage: messages.modelDidNotReturnJson(language),
        rawResponse: raw,
        recoverable: true,
      );
    }
    return trimmed.substring(start, end + 1);
  }

  // --- Turn response parsing ---

  TurnResult parseTurnResponse({
    required String rawResponse,
    required Map<String, Object?> responseMap,
    required AppLanguage language,
  }) {
    final List<Object?> choices = OpenAiCompatibleJsonHelpers.dynamicList(
      responseMap['choices'],
    );
    if (choices.isEmpty) {
      throw AiTurnException(
        userMessage: messages.providerNoChoices(language),
        rawResponse: rawResponse,
        recoverable: true,
      );
    }

    final Map<String, Object?> choice = OpenAiCompatibleJsonHelpers.dynamicMap(
      choices.first,
    );
    final String content = extractChoiceContent(choice).trim();
    if (content.isEmpty) {
      final String nestedText = extractResponseLevelText(responseMap).trim();
      if (nestedText.isNotEmpty) {
        return parseRawTurnContent(rawContent: nestedText, language: language);
      }
    }
    return parseRawTurnContent(rawContent: content, language: language);
  }

  TurnResult parseRawTurnContent({
    required String rawContent,
    required AppLanguage language,
  }) {
    try {
      final String jsonString = extractJson(rawContent, language);
      final Object? turnDecoded = OpenAiCompatibleJsonHelpers.safeDecode(
        jsonString,
      );
      if (turnDecoded is Map) {
        final Map<String, Object?> turnMap =
            OpenAiCompatibleJsonHelpers.dynamicMap(turnDecoded);
        if (hasMeaningfulTurnPayload(turnMap)) {
          return TurnResult.fromJson(turnMap);
        }
      }
    } on AiTurnException {
      // Fall back to heuristic parsing for providers that ignore structured output.
    }

    final TurnResult? structuredRecovery = recoverTurnResultFromStructuredText(
      rawContent: rawContent,
      language: language,
    );
    if (structuredRecovery != null) {
      return structuredRecovery;
    }

    final TurnResult? recovered = recoverTurnResultFromPlainText(
      rawContent: rawContent,
      language: language,
    );
    if (recovered != null) {
      return recovered;
    }

    throw AiTurnException(
      userMessage: messages.invalidJson(language),
      rawResponse: rawContent,
      recoverable: true,
    );
  }

  // --- Recovery ---

  TurnResult? recoverTurnResultFromPlainText({
    required String rawContent,
    required AppLanguage language,
  }) {
    final String cleaned = rawContent
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();
    if (cleaned.isEmpty) {
      return null;
    }
    if (cleaned.startsWith('{') || cleaned.startsWith('[')) {
      return null;
    }

    final List<String> lines = cleaned
        .split(RegExp(r'\r?\n'))
        .map((final item) => item.trim())
        .where((final item) => item.isNotEmpty)
        .toList();
    if (lines.isEmpty) {
      return null;
    }

    final List<String> narrationParts = <String>[];
    final List<String> recoveredChoices = <String>[];
    bool readingChoices = false;

    for (final String line in lines) {
      final String lower = line.toLowerCase();
      final bool isChoicesHeader =
          lower == 'choices:' ||
          lower == 'options:' ||
          lower == 'actions:' ||
          lower == 'варианты:' ||
          lower == 'выбор:' ||
          lower == 'действия:';
      if (isChoicesHeader) {
        readingChoices = true;
        continue;
      }

      final String? normalizedChoice = normalizeChoiceLine(line);
      if (normalizedChoice != null) {
        recoveredChoices.add(normalizedChoice);
        readingChoices = true;
        continue;
      }

      if (!readingChoices) {
        narrationParts.add(line);
      }
    }

    final String narration = narrationParts.join('\n\n').trim();
    final List<String> choices = recoveredChoices.take(3).toList();
    if (narration.isEmpty && choices.isEmpty) {
      return null;
    }

    final List<String> fallbackChoices = choices.isNotEmpty
        ? choices
        : switch (language) {
            AppLanguage.ru => const <String>[
              'Осмотреться',
              'Действовать осторожно',
              'Сделать шаг',
            ],
            AppLanguage.en => const <String>[
              'Look around',
              'Move carefully',
              'Take action',
            ],
          };

    final String resolvedNarration = narration.isNotEmpty
        ? narration
        : switch (language) {
            AppLanguage.ru => 'История продолжается.',
            AppLanguage.en => 'The story continues.',
          };

    return TurnResult(
      narration: resolvedNarration,
      choices: fallbackChoices,
      stateChanges: const StateChanges.empty(),
      memoryEntry: resolvedNarration,
    );
  }

  TurnResult? recoverTurnResultFromStructuredText({
    required String rawContent,
    required AppLanguage language,
  }) {
    final String cleaned = rawContent
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();
    if (cleaned.isEmpty) {
      return null;
    }

    final String narration = firstMatchedValue(cleaned, <String>[
      'narration',
      'naration',
      'scene',
      'story',
      'description',
      'text',
      'response',
      'memory_entry',
    ]);
    final String incompleteNarration = firstTruncatedStringValue(
      cleaned,
      const <String>[
        'narration',
        'naration',
        'scene',
        'story',
        'description',
        'text',
        'response',
      ],
    );
    final String location = firstMatchedValue(cleaned, <String>[
      'location',
      'current_location',
      'place',
      'scene_location',
    ]);
    final String incompleteLocation = firstTruncatedStringValue(
      cleaned,
      const <String>['location', 'current_location', 'place', 'scene_location'],
    );
    final List<String> choices = extractStructuredChoices(cleaned);
    final String resolvedStructuredNarration = narration.isNotEmpty
        ? narration
        : incompleteNarration;
    final String resolvedStructuredLocation = location.isNotEmpty
        ? location
        : incompleteLocation;
    if (resolvedStructuredNarration.isEmpty &&
        resolvedStructuredLocation.isEmpty) {
      return null;
    }

    final List<String> fallbackChoices = choices.isNotEmpty
        ? choices.take(3).toList()
        : switch (language) {
            AppLanguage.ru => const <String>[
              'Осмотреться',
              'Действовать осторожно',
              'Сделать шаг',
            ],
            AppLanguage.en => const <String>[
              'Look around',
              'Move carefully',
              'Take action',
            ],
          };

    final String resolvedNarration = resolvedStructuredNarration.isNotEmpty
        ? resolvedStructuredNarration
        : switch (language) {
            AppLanguage.ru => 'История продолжается.',
            AppLanguage.en => 'The story continues.',
          };

    return TurnResult.fromJson(<String, Object?>{
      'narration': resolvedNarration,
      'choices': fallbackChoices,
      'state_changes': <String, Object?>{
        'location': resolvedStructuredLocation,
      },
      'memory_entry': resolvedNarration,
    });
  }

  // --- Structured extraction helpers ---

  List<String> extractStructuredChoices(String rawContent) {
    final RegExp arrayPattern = RegExp(
      r'"(?:choices|options|actions|variants)"\s*:\s*\[(.*?)\]',
      dotAll: true,
    );
    final Match? match = arrayPattern.firstMatch(rawContent);
    if (match == null) {
      return const <String>[];
    }

    final String body = match.group(1) ?? '';
    final RegExp stringPattern = RegExp(r'"((?:\\.|[^"\\])*)"');
    final List<String> directStrings = stringPattern
        .allMatches(body)
        .map((final item) => unescapeJsonString(item.group(1) ?? ''))
        .where((final item) => item.trim().isNotEmpty)
        .toList();

    final List<String> labels = <String>[];
    for (int i = 0; i < directStrings.length; i++) {
      final String current = directStrings[i];
      if (current == 'label' ||
          current == 'title' ||
          current == 'text' ||
          current == 'choice' ||
          current == 'name') {
        if (i + 1 < directStrings.length) {
          labels.add(directStrings[i + 1].trim());
        }
      }
    }

    if (labels.isNotEmpty) {
      return labels;
    }
    return directStrings;
  }

  String firstMatchedValue(String rawContent, List<String> keys) {
    for (final String key in keys) {
      final RegExp pattern = RegExp(
        '"${RegExp.escape(key)}"\\s*:\\s*(?:"((?:\\\\.|[^"\\\\])*)"|\\{[^\\}]*"text"\\s*:\\s*"((?:\\\\.|[^"\\\\])*)")',
        dotAll: true,
      );
      final Match? match = pattern.firstMatch(rawContent);
      if (match == null) {
        continue;
      }
      final String resolved = unescapeJsonString(
        match.group(1) ?? match.group(2) ?? '',
      ).trim();
      if (resolved.isNotEmpty) {
        return resolved;
      }
    }
    return '';
  }

  String firstTruncatedStringValue(String rawContent, List<String> keys) {
    for (final String key in keys) {
      final String resolved = extractTruncatedStringField(rawContent, key);
      if (resolved.trim().isNotEmpty) {
        return resolved.trimRight();
      }
    }
    return '';
  }

  String extractTruncatedStringField(String rawContent, String key) {
    final int fieldStart = rawContent.indexOf('"$key"');
    if (fieldStart == -1) {
      return '';
    }

    int index = fieldStart + key.length + 2;
    while (index < rawContent.length &&
        isWhitespace(rawContent.codeUnitAt(index))) {
      index++;
    }
    if (index >= rawContent.length || rawContent[index] != ':') {
      return '';
    }
    index++;
    while (index < rawContent.length &&
        isWhitespace(rawContent.codeUnitAt(index))) {
      index++;
    }
    if (index >= rawContent.length || rawContent[index] != '"') {
      return '';
    }
    index++;

    final StringBuffer buffer = StringBuffer();
    while (index < rawContent.length) {
      final String char = rawContent[index];
      if (char == '"') {
        return buffer.toString();
      }
      if (char == r'\') {
        if (index + 1 >= rawContent.length) {
          return buffer.toString();
        }
        final String escape = rawContent[index + 1];
        switch (escape) {
          case '"':
          case r'\':
          case '/':
            buffer.write(escape);
            break;
          case 'b':
            buffer.write('\b');
            break;
          case 'f':
            buffer.write('\f');
            break;
          case 'n':
            buffer.write('\n');
            break;
          case 'r':
            buffer.write('\r');
            break;
          case 't':
            buffer.write('\t');
            break;
          case 'u':
            if (index + 5 >= rawContent.length) {
              return buffer.toString();
            }
            final String codeUnit = rawContent.substring(index + 2, index + 6);
            final int? parsed = int.tryParse(codeUnit, radix: 16);
            if (parsed != null) {
              buffer.writeCharCode(parsed);
              index += 4;
            }
            break;
          default:
            buffer.write(escape);
            break;
        }
        index += 2;
        continue;
      }
      buffer.write(char);
      index++;
    }
    return buffer.toString();
  }

  String unescapeJsonString(String value) {
    try {
      return jsonDecode('"$value"') as String;
    } catch (_) {
      return value
          .replaceAll(r'\"', '"')
          .replaceAll(r'\n', '\n')
          .replaceAll(r'\r', '\r')
          .replaceAll(r'\t', '\t');
    }
  }

  String? normalizeChoiceLine(String line) {
    final RegExp prefixPattern = RegExp(
      r'^(?:[-*•]|\d+[.)]|[A-Za-zА-Яа-я][.)])\s+',
    );
    if (!prefixPattern.hasMatch(line)) {
      return null;
    }
    final String normalized = line.replaceFirst(prefixPattern, '').trim();
    return normalized.isEmpty ? null : normalized;
  }

  // --- Response-level text extraction ---

  bool hasMeaningfulTurnPayload(Map<String, Object?> turnMap) {
    final String narration = extractResponseLevelText(turnMap).trim();
    if (narration.isNotEmpty) {
      return true;
    }
    final String location = firstMatchedValue(jsonEncode(turnMap), <String>[
      'location',
      'current_location',
      'place',
      'scene_location',
    ]).trim();
    return location.isNotEmpty;
  }

  String extractResponseLevelText(Map<String, Object?> map) {
    final String direct = firstNonEmptyJsonString(map, const <String>[
      'narration',
      'naration',
      'scene',
      'story',
      'description',
      'text',
      'response',
      'memory_entry',
      'memoryEntry',
      'output_text',
      'content',
    ]);
    if (direct.isNotEmpty) {
      return direct;
    }

    final Map<String, Object?> message = OpenAiCompatibleJsonHelpers.dynamicMap(
      map['message'],
    );
    final String messageContent = extractMessageContent(message);
    if (messageContent.isNotEmpty) {
      return messageContent;
    }

    final List<Object?> output = OpenAiCompatibleJsonHelpers.dynamicList(
      map['output'],
    );
    for (final Object? item in output) {
      final Map<String, Object?> outputItem =
          OpenAiCompatibleJsonHelpers.dynamicMap(item);
      final String itemText = firstNonEmptyJsonString(
        outputItem,
        const <String>['text', 'content', 'output_text'],
      );
      if (itemText.isNotEmpty) {
        return itemText;
      }
      final List<Object?> content = OpenAiCompatibleJsonHelpers.dynamicList(
        outputItem['content'],
      );
      for (final Object? contentItem in content) {
        final Map<String, Object?> contentMap =
            OpenAiCompatibleJsonHelpers.dynamicMap(contentItem);
        final String contentText = firstNonEmptyJsonString(
          contentMap,
          const <String>['text', 'content', 'output_text'],
        );
        if (contentText.isNotEmpty) {
          return contentText;
        }
      }
    }
    return '';
  }

  String extractChoiceContent(Map<String, Object?> choice) {
    final Map<String, Object?> message = OpenAiCompatibleJsonHelpers.dynamicMap(
      choice['message'],
    );
    final String messageContent = extractMessageContent(message);
    if (messageContent.isNotEmpty) {
      return messageContent;
    }

    final String text = OpenAiCompatibleJsonHelpers.stringValue(
      choice['text'],
    ).trim();
    if (text.isNotEmpty) {
      return text;
    }

    return extractResponseLevelText(choice);
  }

  String extractMessageContent(Map<String, Object?> message) {
    final List<Object?> contentItems = OpenAiCompatibleJsonHelpers.dynamicList(
      message['content'],
    );
    if (contentItems.isNotEmpty) {
      final List<String> textParts = <String>[];
      for (final Object? item in contentItems) {
        if (item is String) {
          final String value = item.trim();
          if (value.isNotEmpty) {
            textParts.add(value);
          }
          continue;
        }
        final Map<String, Object?> contentMap =
            OpenAiCompatibleJsonHelpers.dynamicMap(item);
        final String text = firstNonEmptyJsonString(contentMap, const <String>[
          'text',
          'content',
          'output_text',
        ]);
        if (text.isNotEmpty) {
          textParts.add(text);
        }
      }
      return textParts.join('\n').trim();
    }

    final Object? rawContent = message['content'];
    if (rawContent is Map || rawContent is List) {
      return '';
    }

    final String direct = OpenAiCompatibleJsonHelpers.stringValue(
      rawContent,
    ).trim();
    if (direct.isNotEmpty && direct != '[]' && direct != '{}') {
      return direct;
    }
    return '';
  }

  // --- Stream helpers ---

  String mergeStreamChunk({
    required String existing,
    required String incoming,
  }) {
    if (incoming.isEmpty) {
      return existing;
    }
    if (existing.isEmpty) {
      return incoming;
    }
    if (incoming == existing) {
      return existing;
    }
    if (incoming.startsWith(existing)) {
      return incoming;
    }
    if (existing.startsWith(incoming)) {
      return existing;
    }

    final int maxOverlap = existing.length < incoming.length
        ? existing.length
        : incoming.length;
    for (int overlap = maxOverlap; overlap > 0; overlap -= 1) {
      if (existing.endsWith(incoming.substring(0, overlap))) {
        return '$existing${incoming.substring(overlap)}';
      }
    }
    return '$existing$incoming';
  }

  String firstNonEmptyJsonString(
    Map<String, Object?> map,
    List<String> keys,
  ) {
    for (final String key in keys) {
      final Object? value = map[key];
      if (value is Map || value is List) {
        continue;
      }
      final String text = OpenAiCompatibleJsonHelpers.stringValue(value).trim();
      if (text.isNotEmpty) {
        return text;
      }
    }
    return '';
  }

  String extractStreamChunk(Map<String, Object?> event) {
    final List<Object?> choices = OpenAiCompatibleJsonHelpers.dynamicList(
      event['choices'],
    );
    if (choices.isEmpty) {
      return '';
    }

    final Map<String, Object?> choice = OpenAiCompatibleJsonHelpers.dynamicMap(
      choices.first,
    );
    final Map<String, Object?> delta = OpenAiCompatibleJsonHelpers.dynamicMap(
      choice['delta'],
    );
    final String deltaContent = OpenAiCompatibleJsonHelpers.stringValue(
      delta['content'],
    );
    if (deltaContent.isNotEmpty) {
      return deltaContent;
    }

    final Map<String, Object?> message = OpenAiCompatibleJsonHelpers.dynamicMap(
      choice['message'],
    );
    final String messageContent = OpenAiCompatibleJsonHelpers.stringValue(
      message['content'],
    );
    if (messageContent.isNotEmpty) {
      return messageContent;
    }

    return OpenAiCompatibleJsonHelpers.stringValue(choice['text']);
  }

  String? extractNarrationPreview(String rawContent) {
    for (final String key in const <String>['narration', 'naration']) {
      final String? preview = extractQuotedJsonStringFieldPreview(
        rawContent,
        key,
      );
      if (preview != null) {
        return preview;
      }
    }
    return null;
  }

  String? extractQuotedJsonStringFieldPreview(
    String rawContent,
    String key,
  ) {
    final String quotedKey = '"$key"';
    final int fieldStart = rawContent.indexOf(quotedKey);
    if (fieldStart == -1) {
      return null;
    }

    int index = fieldStart + quotedKey.length;
    while (index < rawContent.length &&
        isWhitespace(rawContent.codeUnitAt(index))) {
      index++;
    }
    if (index >= rawContent.length || rawContent[index] != ':') {
      return null;
    }
    index++;
    while (index < rawContent.length &&
        isWhitespace(rawContent.codeUnitAt(index))) {
      index++;
    }
    if (index >= rawContent.length || rawContent[index] != '"') {
      return null;
    }
    index++;

    final StringBuffer buffer = StringBuffer();
    while (index < rawContent.length) {
      final String char = rawContent[index];
      if (char == '"') {
        return buffer.toString();
      }
      if (char == r'\') {
        if (index + 1 >= rawContent.length) {
          return buffer.toString();
        }
        final String escape = rawContent[index + 1];
        switch (escape) {
          case '"':
          case r'\':
          case '/':
            buffer.write(escape);
            break;
          case 'b':
            buffer.write('\b');
            break;
          case 'f':
            buffer.write('\f');
            break;
          case 'n':
            buffer.write('\n');
            break;
          case 'r':
            buffer.write('\r');
            break;
          case 't':
            buffer.write('\t');
            break;
          case 'u':
            if (index + 5 >= rawContent.length) {
              return buffer.toString();
            }
            final String hex = rawContent.substring(index + 2, index + 6);
            final int? codePoint = int.tryParse(hex, radix: 16);
            if (codePoint == null) {
              return buffer.toString();
            }
            buffer.write(String.fromCharCode(codePoint));
            index += 4;
            break;
          default:
            buffer.write(escape);
            break;
        }
        index += 2;
        continue;
      }
      buffer.write(char);
      index++;
    }

    return buffer.toString();
  }

  bool isWhitespace(int codeUnit) =>
      codeUnit == 0x20 ||
      codeUnit == 0x0A ||
      codeUnit == 0x0D ||
      codeUnit == 0x09;

  // --- Provider error detail ---

  String? extractProviderErrorDetail(String rawResponse) {
    final Object? decoded = OpenAiCompatibleJsonHelpers.safeDecode(rawResponse);
    if (decoded is! Map) {
      return null;
    }

    final Map<String, Object?> map = OpenAiCompatibleJsonHelpers.dynamicMap(
      decoded,
    );
    final Map<String, Object?> error = OpenAiCompatibleJsonHelpers.dynamicMap(
      map['error'],
    );
    final String message =
        OpenAiCompatibleJsonHelpers.stringValue(
          error['message'],
        ).trim().isNotEmpty
        ? OpenAiCompatibleJsonHelpers.stringValue(error['message']).trim()
        : OpenAiCompatibleJsonHelpers.stringValue(map['message']).trim();
    final String code = OpenAiCompatibleJsonHelpers.stringValue(
      error['code'],
    ).trim();

    if (message.isEmpty && code.isEmpty) {
      return null;
    }
    if (message.isNotEmpty && code.isNotEmpty) {
      return '$message ($code)';
    }
    return message.isNotEmpty ? message : code;
  }

  // --- Token limit detection ---

  bool responseHitTokenLimit(Map<String, Object?> responseMap) {
    final List<Object?> choices = OpenAiCompatibleJsonHelpers.dynamicList(
      responseMap['choices'],
    );
    if (choices.isEmpty) {
      return false;
    }

    for (final Object? rawChoice in choices) {
      final Map<String, Object?> choice =
          OpenAiCompatibleJsonHelpers.dynamicMap(rawChoice);
      final String finishReason = normalizedFinishReason(
        choice['finish_reason'] ?? choice['finishReason'],
      );
      if (isTokenLimitFinishReason(finishReason)) {
        return true;
      }
    }
    return false;
  }

  int expandedMaxTokens(int currentMaxTokens) {
    final int cappedCurrent = currentMaxTokens.clamp(
      ModelRuntimeSettings.minMaxResponseTokens,
      ModelRuntimeSettings.maxMaxResponseTokens,
    );
    final int expanded = cappedCurrent * 2;
    return expanded.clamp(
      ModelRuntimeSettings.minMaxResponseTokens,
      ModelRuntimeSettings.maxMaxResponseTokens,
    );
  }

  String normalizedFinishReason(Object? value) =>
      OpenAiCompatibleJsonHelpers.stringValue(value).trim().toLowerCase();

  bool isTokenLimitFinishReason(String finishReason) =>
      finishReason == 'length' ||
      finishReason == 'max_tokens' ||
      finishReason == 'max_output_tokens' ||
      finishReason == 'token_limit' ||
      finishReason == 'model_length';
}
