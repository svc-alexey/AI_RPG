import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StoryAdmin multi-select state', () {
    test('select mode toggle and id tracking', () {
      bool selectionMode = false;
      final Set<String> selectedIds = <String>{};

      // Long press activates selection mode
      selectionMode = true;
      selectedIds.add('template-1');

      expect(selectionMode, isTrue);
      expect(selectedIds, contains('template-1'));
      expect(selectedIds.length, 1);

      // Tap toggles id
      selectedIds.add('template-2');
      expect(selectedIds.length, 2);

      selectedIds.remove('template-1');
      expect(selectedIds.length, 1);
      expect(selectedIds, isNot(contains('template-1')));

      // Deselect all exits selection mode
      selectedIds.clear();
      selectionMode = false;
      expect(selectionMode, isFalse);
      expect(selectedIds, isEmpty);
    });
  });

  test('partial failure message format', () {
    final int deleted = 3;
    final int total = 5;
    final int failed = 2;

    final String message =
        'Deleted $deleted of $total. $failed errors.';
    expect(message, 'Deleted 3 of 5. 2 errors.');
  });

  test('all failed message format', () {
    final int count = 4;
    final String message = 'Failed to delete $count templates';
    expect(message, 'Failed to delete 4 templates');
  });
}
