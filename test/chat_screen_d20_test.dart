import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:ai_prg/src/features/chat/widgets/d20_roll_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final _testNow = DateTime.now();

void main() {
  testWidgets('Message with diceRoll renders D20ChatBubble', (tester) async {
    final message = ChatMessage(
      id: 'msg-d20',
      role: ChatRole.narrator,
      text: 'The blade finds its mark!',
      createdAt: _testNow,
      diceRoll: 18,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: _DiceMessageWrapper(message: message),
        ),
      ),
    );
    // D20ResultLabel has a 1400ms delay; pump past it
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pump();

    expect(find.byType(D20ChatBubble), findsOneWidget);
  });

  testWidgets('Message without diceRoll does not render D20ChatBubble',
      (tester) async {
    final message = ChatMessage(
      id: 'msg-no-dice',
      role: ChatRole.narrator,
      text: 'The mist parts slowly...',
      createdAt: _testNow,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: _DiceMessageWrapper(message: message),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(D20ChatBubble), findsNothing);
  });

  testWidgets('D20ChatBubble contains roll widget and label', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: D20ChatBubble(result: 20),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pump();

    expect(find.byType(D20RollWidget), findsOneWidget);
    expect(find.byType(D20ResultLabel), findsOneWidget);
  });
}

class _DiceMessageWrapper extends StatelessWidget {
  const _DiceMessageWrapper({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final hasDice = message.diceRoll != null;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(message.text),
        if (hasDice) D20ChatBubble(result: message.diceRoll!),
      ],
    );
  }
}
