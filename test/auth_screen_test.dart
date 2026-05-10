import 'package:ai_prg/src/app/aether_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('confirm password widget validation - empty field', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: _ConfirmPasswordTestWidget(),
        ),
      ),
    );

    final FormState form = tester.state(find.byType(Form));
    form.validate();
    await tester.pump();

    expect(find.text('Passwords do not match'), findsOneWidget);
  });
}

class _ConfirmPasswordTestWidget extends StatefulWidget {
  const _ConfirmPasswordTestWidget();

  @override
  State<_ConfirmPasswordTestWidget> createState() =>
      _ConfirmPasswordTestWidgetState();
}

class _ConfirmPasswordTestWidgetState extends State<_ConfirmPasswordTestWidget> {
  final TextEditingController _passwordController =
      TextEditingController(text: 'testpass');
  final TextEditingController _confirmController =
      TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Password'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _confirmController,
            decoration: const InputDecoration(labelText: 'Confirm'),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Passwords do not match';
              if (v != _passwordController.text) return 'Passwords do not match';
              return null;
            },
          ),
        ],
      ),
    );
  }
}
