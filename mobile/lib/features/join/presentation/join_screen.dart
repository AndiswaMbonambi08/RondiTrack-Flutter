import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ronditrack/app/routes.dart';
import 'package:ronditrack/core/money/money_format.dart';
import 'package:ronditrack/core/widgets.dart';
import 'package:ronditrack/features/join/application/join_providers.dart';
import 'package:ronditrack/features/join/domain/invite.dart';

class JoinScreen extends ConsumerWidget {
  const new({required this.code, super.key});

  final String code;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invite = ref.watch(invitePreviewProvider(code));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invitation'),
        leading: IconButton(
          tooltip: 'Close',
          icon: const Icon(Icons.close),
          onPressed: () => const HomeRoute().go(context),
        ),
      ),
      body: switch (invite) {
        AsyncData(value: final Invite found) => _Preview(invite: found),
        AsyncData() => const Center(child: Text('Invitation not found')),
        AsyncError() => FailureView(
          message: 'Could not load the invitation.',
          onRetry: () => ref.invalidate(invitePreviewProvider(code)),
        ),
        _ => const LoadingView(),
      },
    );
  }
}

class _Preview extends StatelessWidget {
  const new({required this.invite});

  final Invite invite;

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
            FilledButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Request sent to the treasurer'),
                  ),
                );
                const HomeRoute().go(context);
              },
              child: const Text('Join'),
            ),
        ],
      ),
    );
  }
}
