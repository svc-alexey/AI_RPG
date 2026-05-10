import 'package:ai_prg/src/features/chat/widgets/d20_roll_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('D20RollWidget renders without errors', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: D20RollWidget(result: 15)),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(D20RollWidget), findsOneWidget);
  });

  testWidgets('D20ChatBubble renders with roll widget and label',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: D20ChatBubble(result: 17)),
        ),
      ),
    );
    await tester.pump();
    // D20ResultLabel has a 1400ms delay; pump past it to clear pending timers
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pump();

    expect(find.byType(D20ChatBubble), findsOneWidget);
    expect(find.byType(D20RollWidget), findsOneWidget);
    expect(find.byType(D20ResultLabel), findsOneWidget);
  });

  testWidgets('D20RollWidget with size 120 renders correct SizedBox',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: D20RollWidget(result: 10, size: 120)),
        ),
      ),
    );
    await tester.pump();

    final box = tester.widget<SizedBox>(find.byType(SizedBox).first);
    expect(box.width, 120);
    expect(box.height, 120);
  });

  testWidgets('D20ResultLabel renders after delay for crit success',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: D20ResultLabel(result: 20)),
        ),
      ),
    );
    // Pump past the 1400ms delay
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pump();

    expect(find.byType(D20ResultLabel), findsOneWidget);
  });
}
