import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ronditrack/app/redirect.dart';
import 'package:ronditrack/app/routes.dart';
import 'package:ronditrack/core/session/session.dart';

const _knownFields = {'fullname', 'email', 'password'};

class RegisterScreen extends ConsumerStatefulWidget {
  const new({this.from, super.key});

  final String? from;

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  bool _obscure = true;
  Map<String, String> _errors = const {};
  String? _form;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _show(AuthFailure failure) {
    final errors = <String, String>{};
    String? form;
    switch (failure) {
      case FieldErrors(errors: final found):
        errors.addAll(found);
      case EmailTaken():
        errors['email'] = 'That email is already in use.';
      case NetworkDown():
        form = 'Could not reach RondiTrack. Check your connection.';
      case RateLimited(:final retryAfter):
        form =
            'Too many attempts. Try again in ${retryAfter.inSeconds} seconds.';
      case AccountCreated():
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your account is ready. Sign in to continue.'),
          ),
        );
        SignInRoute(from: widget.from).go(context);
        return;
      case WrongCredentials() || ServerFailure():
        form = 'Something went wrong. Try again.';
    }
    final leftover = errors.entries
        .where((e) => !_knownFields.contains(e.key))
        .map((e) => e.value)
        .toList();
    if (leftover.isNotEmpty) form = leftover.join(' ');
    setState(() {
      _busy = false;
      _errors = errors;
      _form = form;
    });
  }

  Future<void> _submit() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _errors = const {};
      _form = null;
    });
    final auth = ref.read(authProvider.notifier);
    final pending = ref.read(pendingJoinProvider.notifier);
    final code = joinCodeOf(widget.from);
    if (code != null) pending.set(code);
    try {
      await auth.register(
        fullName: _name.text.trim(),
        email: _email.text.trim(),
        password: _password.text,
      );
    } on AuthFailure catch (failure) {
      pending.clear();
      if (!mounted) return;
      _show(failure);
      return;
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create an account')),
      body: AutofillGroup(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _name,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              decoration: InputDecoration(
                labelText: 'Full name',
                errorText: _errors['fullname'],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              decoration: InputDecoration(
                labelText: 'Email',
                errorText: _errors['email'],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _password,
              obscureText: _obscure,
              autofillHints: const [AutofillHints.newPassword],
              decoration: InputDecoration(
                labelText: 'Password',
                helperText: 'At least 12 characters.',
                errorText: _errors['password'],
                suffixIcon: IconButton(
                  tooltip: _obscure ? 'Show password' : 'Hide password',
                  icon: Icon(
                    _obscure ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              onSubmitted: (_) => unawaited(_submit()),
            ),
            if (_form != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    _form!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('register-button'),
              onPressed: _busy ? null : () => unawaited(_submit()),
              child: _busy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Create account'),
            ),
            TextButton(
              onPressed: () => SignInRoute(from: widget.from).go(context),
              child: const Text('I already have an account'),
            ),
          ],
        ),
      ),
    );
  }
}
