import 'dart:convert';

import 'package:flutter/foundation.dart';

/// JSON coercion and safe decode for OpenAI-compatible HTTP payloads.
class OpenAiCompatibleJsonHelpers {
  OpenAiCompatibleJsonHelpers._();

  static Map<String, Object?> dynamicMap(final Object? value) {
    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), item));
    }
    return const <String, Object?>{};
  }

  static List<Object?> dynamicList(final Object? value) =>
      value is List ? List<Object?>.from(value) : const <Object?>[];

  static String stringValue(final Object? value) =>
      value == null ? '' : '$value';

  static Object? safeDecode(final String raw) {
    try {
      return jsonDecode(raw);
    } catch (error) {
      debugPrint('JSON decode failed: $error');
      return null;
    }
  }
}
