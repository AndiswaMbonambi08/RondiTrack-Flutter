import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ronditrack/core/session/session.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const new({this.from, super.key});

  final String? from;

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _email = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _submit() {
    final ok = ref.read(authProvider.notifier).signInWithEmail(_email.text);
    if (!ok) setState(() => _error = 'We do not recognise that email.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (widget.from != null)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text('Sign in to open the link you followed.'),
            ),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            decoration: InputDecoration(labelText: 'Email', errorText: _error),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 12),
          FilledButton(
            key: const Key('sign-in-button'),
            onPressed: _submit,
            child: const Text('Sign in'),
          ),
          const SizedBox(height: 24),
          const Text('Demo accounts (made-up data)'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final email in personaEmails.keys)
                ActionChip(
                  label: Text(email),
                  onPressed: () => _email.text = email,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
