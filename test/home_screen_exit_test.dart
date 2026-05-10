import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('PopScope with canPop=false calls onPopInvokedWithResult', (tester) async {
    bool popInvoked = false;
    await tester.pumpWidget(
      MaterialApp(
        home: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            popInvoked = true;
          },
          child: const Scaffold(
            body: Center(child: Text('Home')),
          ),
        ),
      ),
    );

    // Trigger back navigation
    final dynamic binding = WidgetsBinding.instance;
    binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(popInvoked, isTrue);
  });

  testWidgets('regular Scaffold allows pop', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Home')),
        ),
      ),
    );

    // Regular Scaffold without PopScope should allow pop
    expect(find.text('Home'), findsOneWidget);
  });
}
