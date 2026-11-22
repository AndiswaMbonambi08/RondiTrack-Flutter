import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ronditrack/app/routes.dart';
import 'package:ronditrack/core/money/money_format.dart';
import 'package:ronditrack/core/session/session.dart';
import 'package:ronditrack/core/widgets.dart';
import 'package:ronditrack/features/join/application/join_action.dart';
import 'package:ronditrack/features/join/application/join_providers.dart';
import 'package:ronditrack/features/join/domain/invite.dart';
import 'package:ronditrack/features/join/domain/join_outcome.dart';

class JoinScreen extends ConsumerStatefulWidget {
  const new({required this.code, super.key});

  final String code;

  @override
  ConsumerState<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends ConsumerState<JoinScreen> {
  late bool _started;
  bool _left = false;

  @override
  void initState() {
    super.initState();
    // A link followed before signing in joins once, right after sign-in. The
    // intent is consumed here, so going back, rotating or a rebuild never
    // sends the join again.
    _started = ref.read(pendingJoinProvider) == widget.code;
    if (_started) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) ref.read(pendingJoinProvider.notifier).clear();
      });
    }
  }

  Widget _go(String stokvelId) {
    if (!_left) {
      _left = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) StokvelRoute(id: stokvelId).go(context);
      });
    }
    return const LoadingView();
  }

  Widget _joining(String code) {
    final outcome = ref.watch(joinProvider(code));
    return switch (outcome) {
      AsyncData(value: Joined(:final stokvelId)) => _go(stokvelId),
      AsyncData(value: AlreadyMember(stokvelId: final String id)) => _go(id),
      AsyncData(value: AlreadyMember()) => const _Message(
        'You are already a member.',
      ),
      AsyncData(value: InvalidInvite()) => const _Message(
        'This invitation is wrong or has expired.',
      ),
      AsyncData() || AsyncError() => FailureView(
        message: 'Could not join. Check your connection and try again.',
        onRetry: () => ref.invalidate(joinProvider(code)),
      ),
      _ => const LoadingView(),
    };
  }

  Widget _preview(String code) {
    final invite = ref.watch(invitePreviewProvider(code));
    return switch (invite) {
      AsyncData(value: final Invite found) => _Preview(
        invite: found,
        onJoin: () => setState(() => _started = true),
      ),
      AsyncData() => const _Message('Invitation not found'),
      AsyncError() => FailureView(
        message: 'Could not load the invitation.',
        onRetry: () => ref.invalidate(invitePreviewProvider(code)),
      ),
      _ => const LoadingView(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final code = widget.code;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invitation'),
        leading: IconButton(
          tooltip: 'Close',
          icon: const Icon(Icons.close),
          onPressed: () => const HomeRoute().go(context),
        ),
      ),
      body: _started ? _joining(code) : _preview(code),
    );
  }
}

class _Message extends StatelessWidget {
  const new(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(text, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => const HomeRoute().go(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  const new({required this.invite, required this.onJoin});

  final Invite invite;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            invite.stokvelName,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text('Contribution: ${formatRands(invite.contribution)}'),
          const SizedBox(height: 16),
          if (invite.alreadyMember) ...[
            const Text('You are already a member.'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => StokvelRoute(id: invite.stokvelId).go(context),
              child: const Text('Open stokvel'),
            ),
          ] else
            FilledButton(onPressed: onJoin, child: const Text('Join')),
        ],
      ),
    );
  }
}
