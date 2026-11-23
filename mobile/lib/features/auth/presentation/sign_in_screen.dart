import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ronditrack/app/config_provider.dart';
import 'package:ronditrack/app/redirect.dart';
import 'package:ronditrack/app/routes.dart';
import 'package:ronditrack/core/session/session.dart';
import 'package:ronditrack/l10n/generated/app_localizations.dart';

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

  String _message(AppLocalizations l, AuthFailure failure) => switch (failure) {
    WrongCredentials() => l.signInWrongCredentials,
    RateLimited(:final retryAfter) => l.signInRateLimited(retryAfter.inSeconds),
    NetworkDown() => l.signInNetworkDown,
    FieldErrors() => l.signInFieldErrors,
    EmailTaken() || ServerFailure() || AccountCreated() => l.signInGenericError,
  };

  Future<void> _submit() async {
    if (_busy || _wait > 0) return;
    final l = AppLocalizations.of(context);
    final email = _email.text.trim();
    final password = _password.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = l.signInEnterBoth);
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
        _error = _message(l, failure);
      });
      if (failure is RateLimited) _startWait(failure.retryAfter);
      return;
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final dev = ref.watch(appConfigProvider).devToolsEnabled;
    final joining = joinCodeOf(widget.from) != null;
    return Scaffold(
      appBar: AppBar(title: Text(l.signInTitle)),
      body: AutofillGroup(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (joining)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(l.signInJoining),
              )
            else if (widget.from != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(l.signInFollowLink),
              ),
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [
                AutofillHints.username,
                AutofillHints.email,
              ],
              decoration: InputDecoration(labelText: l.emailLabel),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _password,
              obscureText: _obscure,
              autofillHints: const [AutofillHints.password],
              decoration: InputDecoration(
                labelText: l.passwordLabel,
                suffixIcon: IconButton(
                  tooltip: _obscure ? l.showPassword : l.hidePassword,
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
                  : Text(_wait > 0 ? l.signInWait(_wait) : l.signInButton),
            ),
            TextButton(
              onPressed: () => RegisterRoute(from: widget.from).go(context),
              child: Text(l.createAccount),
            ),
            if (dev) ...[
              const SizedBox(height: 24),
              Text(l.signInDemoHint),
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
