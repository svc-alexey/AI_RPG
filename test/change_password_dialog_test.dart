import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('change password - empty current password shows error', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: _ChangePasswordTestForm()));

    final FormState form = tester.state(find.byType(Form));
    form.validate();
    await tester.pump();

    // Both fields have the same error text when empty
    expect(find.text('Enter your password.'), findsAtLeast(1));
  });

  testWidgets('change password - new password too short shows error', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: _ChangePasswordTestForm()));

    await tester.enterText(find.byType(TextFormField).first, 'currentpass');
    await tester.enterText(find.byType(TextFormField).at(1), 'short');
    final FormState form = tester.state(find.byType(Form));
    form.validate();
    await tester.pump();

    expect(find.text('Password must be at least 8 characters long.'), findsOneWidget);
  });
}

class _ChangePasswordTestForm extends StatefulWidget {
  const _ChangePasswordTestForm();

  @override
  State<_ChangePasswordTestForm> createState() =>
      _ChangePasswordTestFormState();
}

class _ChangePasswordTestFormState extends State<_ChangePasswordTestForm> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        child: Column(
          children: <Widget>[
            TextFormField(
              decoration: const InputDecoration(labelText: 'Current'),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Enter your password.';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: const InputDecoration(labelText: 'New'),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Enter your password.';
                if (v.length < 8) {
                  return 'Password must be at least 8 characters long.';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}
