import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('forgot password - empty email shows validation error', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: _ForgotPasswordTestForm()));

    final FormState form = tester.state(find.byType(Form));
    form.validate();
    await tester.pump();

    expect(find.text('Enter your email.'), findsOneWidget);
  });

  testWidgets('forgot password - invalid email shows error', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: _ForgotPasswordTestForm()));

    await tester.enterText(find.byType(TextFormField), 'notanemail');
    final FormState form = tester.state(find.byType(Form));
    form.validate();
    await tester.pump();

    expect(find.text('Enter a valid email.'), findsOneWidget);
  });
}

class _ForgotPasswordTestForm extends StatefulWidget {
  const _ForgotPasswordTestForm();

  @override
  State<_ForgotPasswordTestForm> createState() => _ForgotPasswordTestFormState();
}

class _ForgotPasswordTestFormState extends State<_ForgotPasswordTestForm> {
  bool _looksLikeEmail(final String value) {
    final int atIndex = value.indexOf('@');
    if (atIndex <= 0 || atIndex >= value.length - 3) return false;
    return value.substring(atIndex + 1).contains('.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        child: Column(
          children: <Widget>[
            TextFormField(
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Enter your email.';
                if (!_looksLikeEmail(v.trim())) return 'Enter a valid email.';
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}
