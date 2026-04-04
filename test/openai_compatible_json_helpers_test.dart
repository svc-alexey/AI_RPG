import 'package:ai_prg/src/core/services/openai_compatible_json_helpers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OpenAiCompatibleJsonHelpers', () {
    test('dynamicMap converts Map keys to String', () {
      final Map<String, Object?> actualMap = OpenAiCompatibleJsonHelpers.dynamicMap(
        <Object, Object>{1: 'a', 'b': 2},
      );
      expect(actualMap.length, 2);
      expect(actualMap['1'], 'a');
      expect(actualMap['b'], 2);
    });

    test('dynamicMap returns empty map for non-Map', () {
      final Map<String, Object?> actualMap =
          OpenAiCompatibleJsonHelpers.dynamicMap('x');
      expect(actualMap, isEmpty);
    });

    test('dynamicList copies List or returns empty', () {
      expect(
        OpenAiCompatibleJsonHelpers.dynamicList(<Object?>[1, 'z']),
        <Object?>[1, 'z'],
      );
      expect(OpenAiCompatibleJsonHelpers.dynamicList(null), isEmpty);
    });

    test('stringValue handles null', () {
      expect(OpenAiCompatibleJsonHelpers.stringValue(null), '');
      expect(OpenAiCompatibleJsonHelpers.stringValue(3), '3');
    });

    test('safeDecode returns null on invalid JSON', () {
      expect(OpenAiCompatibleJsonHelpers.safeDecode('{'), isNull);
    });

    test('safeDecode parses object', () {
      final Object? decoded =
          OpenAiCompatibleJsonHelpers.safeDecode('{"k":1}');
      expect(decoded, isA<Map<String, dynamic>>());
      final Map<String, Object?> map =
          OpenAiCompatibleJsonHelpers.dynamicMap(decoded);
      expect(map['k'], 1);
    });
  });
}
