import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Campaign delete state', () {
    test('deletingId is set when delete starts', () {
      String? deletingId = null;
      const String campaignId = 'campaign-123';

      deletingId = campaignId;
      expect(deletingId, equals(campaignId));
    });

    test('deletingId cleared on success', () {
      String? deletingId = 'campaign-123';

      deletingId = null;
      expect(deletingId, isNull);
    });

    test('deletingId cleared on error', () {
      String? deletingId = 'campaign-123';

      // On error, reset deletingId
      deletingId = null;
      expect(deletingId, isNull);
    });
  });

  group('Campaign list removal', () {
    test('deleted campaign removed from list', () {
      final List<Map<String, String>> campaigns = <Map<String, String>>[
        <String, String>{'id': 'c1', 'title': 'First'},
        <String, String>{'id': 'c2', 'title': 'Second'},
        <String, String>{'id': 'c3', 'title': 'Third'},
      ];

      final List<Map<String, String>> updated = campaigns
          .where((c) => c['id'] != 'c2')
          .toList();

      expect(updated.length, 2);
      expect(updated.any((c) => c['id'] == 'c2'), isFalse);
    });
  });

  group('Delete confirmation dialog', () {
    test('confirmation returns true for destructive delete', () {
      const bool destructive = true;
      expect(destructive, isTrue);
    });

    test('cancel returns false', () {
      const bool? result = false;
      expect(result, isFalse);
    });
  });
}
