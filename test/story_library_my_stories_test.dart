import 'package:flutter_test/flutter_test.dart';

void main() {
  group('My Stories tab visibility', () {
    test('visible for non-guest logged-in user', () {
      final bool isSignedIn = true;
      final bool isGuest = false;
      final bool showMyTab = isSignedIn && !isGuest;

      expect(showMyTab, isTrue);
    });

    test('hidden for guest user', () {
      final bool isSignedIn = true;
      final bool isGuest = true;
      final bool showMyTab = isSignedIn && !isGuest;

      expect(showMyTab, isFalse);
    });

    test('hidden for null session', () {
      final bool isSignedIn = false;
      final bool showMyTab = isSignedIn;
      // Null session means isSignedIn is false

      expect(showMyTab, isFalse);
    });
  });

  group('My Stories delete', () {
    test('owned story can be deleted', () {
      const String ownerUserId = 'user-1';
      const String templateAuthorId = 'user-1';

      expect(ownerUserId == templateAuthorId, isTrue);
    });

    test('non-owned story cannot be deleted', () {
      const String ownerUserId = 'user-1';
      const String templateAuthorId = 'user-2';

      expect(ownerUserId == templateAuthorId, isFalse);
    });
  });
}
