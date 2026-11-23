import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ronditrack/app/config_provider.dart';
import 'package:ronditrack/app/redirect.dart';
import 'package:ronditrack/app/routes.dart';
import 'package:ronditrack/core/session/session.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const new({this.from, super.key});

  final String? from;

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  Timer? _timer;
  bool _busy = false;
  bool _obscure = true;
  int _wait = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    final prefill = ref.read(signInPrefillProvider);
    if (prefill != null) {
      _email.text = prefill;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) ref.read(signInPrefillProvider.notifier).clear();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _startWait(Duration wait) {
    _timer?.cancel();
    setState(() => _wait = wait.inSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _wait--);
      if (_wait <= 0) {
        t.cancel();
        setState(() {
          _wait = 0;
          _error = null;
        });
      }
    });
  }

  String _message(AuthFailure failure) => switch (failure) {
    WrongCredentials() => 'The email and password do not match.',
    RateLimited(:final retryAfter) =>
      'Too many attempts. You can try again in ${retryAfter.inSeconds} seconds.',
    NetworkDown() => 'Could not reach RondiTrack. Check your connection.',
    FieldErrors() => 'Check your email and password.',
    EmailTaken() ||
    ServerFailure() ||
    AccountCreated() => 'Something went wrong. Try again.',
  };

  Future<void> _submit() async {
    if (_busy || _wait > 0) return;
    final email = _email.text.trim();
    final password = _password.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Enter your email and password.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final auth = ref.read(authProvider.notifier);
    final pending = ref.read(pendingJoinProvider.notifier);
    final code = joinCodeOf(widget.from);
    if (code != null) pending.set(code);
    try {
      await auth.signIn(email: email, password: password);
    } on AuthFailure catch (failure) {
      pending.clear();
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = _message(failure);
      });
      if (failure is RateLimited) _startWait(failure.retryAfter);
      return;
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final dev = ref.watch(appConfigProvider).devToolsEnabled;
    final joining = joinCodeOf(widget.from) != null;
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: AutofillGroup(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (joining)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text('Sign in to join the stokvel you were invited to.'),
              )
            else if (widget.from != null)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text('Sign in to open the link you followed.'),
              ),
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [
                AutofillHints.username,
                AutofillHints.email,
              ],
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _password,
              obscureText: _obscure,
              autofillHints: const [AutofillHints.password],
              decoration: InputDecoration(
                labelText: 'Password',
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
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('sign-in-button'),
              onPressed: _busy || _wait > 0 ? null : () => unawaited(_submit()),
              child: _busy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_wait > 0 ? 'Try again in ${_wait}s' : 'Sign in'),
            ),
            TextButton(
              onPressed: () => RegisterRoute(from: widget.from).go(context),
              child: const Text('Create an account'),
            ),
            if (dev) ...[
              const SizedBox(height: 24),
              const Text('Demo accounts (made-up data). Type the password.'),
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
          ],
        ),
      ),
    );
  }
}
