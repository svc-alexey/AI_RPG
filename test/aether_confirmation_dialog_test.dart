import 'package:ai_prg/src/app/aether_shell.dart';
import 'package:ai_prg/src/core/widgets/aether_confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildDialog({
    bool destructive = false,
  }) {
    return MaterialApp(
      home: Builder(
        builder: (context) => Center(
          child: ElevatedButton(
            onPressed: () {
              showAetherConfirmationDialog(
                context,
                title: 'Test Title',
                message: 'Test Message',
                confirmLabel: 'Confirm',
                cancelLabel: 'Cancel',
                destructive: destructive,
              );
            },
            child: const Text('Open'),
          ),
        ),
      ),
    );
  }

  testWidgets('renders title, message, cancel and confirm buttons', (tester) async {
    await tester.pumpWidget(buildDialog());
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Test Title'), findsOneWidget);
    expect(find.text('Test Message'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Confirm'), findsOneWidget);
  });

  testWidgets('confirm returns true via Navigator.pop', (tester) async {
    await tester.pumpWidget(buildDialog());
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(find.text('Test Title'), findsNothing);
  });

  testWidgets('cancel dismisses dialog', (tester) async {
    await tester.pumpWidget(buildDialog());
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Test Title'), findsNothing);
  });

  testWidgets('destructive mode renders without errors', (tester) async {
    await tester.pumpWidget(buildDialog(destructive: true));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Test Title'), findsOneWidget);
    expect(find.text('Confirm'), findsOneWidget);
  });
}
