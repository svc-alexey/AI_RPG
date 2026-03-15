import 'package:ai_prg/src/app/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Приложение открывается на главном экране', (
    final WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AiRpgApp());
    await tester.pumpAndSettle();

    expect(find.text('AI RPG MVP'), findsOneWidget);
    expect(find.text('Новая кампания'), findsOneWidget);
  });
}
