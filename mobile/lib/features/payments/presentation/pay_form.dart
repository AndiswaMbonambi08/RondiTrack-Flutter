import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ronditrack/core/failure/failure.dart';
import 'package:ronditrack/core/money/cents.dart';
import 'package:ronditrack/core/money/money_format.dart';
import 'package:ronditrack/core/money/money_parse.dart';
import 'package:ronditrack/core/session/session.dart';
import 'package:ronditrack/features/home/application/home_cache_providers.dart';
import 'package:ronditrack/features/payments/application/payment_providers.dart';
import 'package:ronditrack/features/payments/domain/payment_outcome.dart';
import 'package:ronditrack/features/payments/domain/pending_payment.dart';
import 'package:ronditrack/features/stokvel/application/stokvel_cache_providers.dart';
import 'package:ronditrack/l10n/generated/app_localizations.dart';
import 'package:ronditrack/l10n/labels.dart';

const _maxCents = 100000000;

Future<void> showPayForm(
  BuildContext context, {
  required String stokvelId,
  required String cycleId,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (_) => PayForm(stokvelId: stokvelId, cycleId: cycleId),
);

/// The member types rands. The phone parses them to cents with integers,
/// writes the payment and its key to the outbox, then sends it. A payment
/// that is waiting replaces the form, so a second tap cannot pay twice.
class PayForm extends ConsumerStatefulWidget {
  const new({required this.stokvelId, required this.cycleId, super.key});

  final String stokvelId;
  final String cycleId;

  @override
  ConsumerState<PayForm> createState() => _PayFormState();
}

class _PayFormState extends ConsumerState<PayForm> {
  final _amount = TextEditingController();
  bool _busy = false;
  String? _fieldError;
  String? _message;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Cents? _parse(AppLocalizations l) {
    final result = parseRands(_amount.text);
    if (result is MoneyRejected) {
      setState(
        () => _fieldError = switch (result.reason) {
          MoneyParseFailure.empty => l.payErrorEmpty,
          MoneyParseFailure.tooManyDecimals => l.payErrorDecimals,
          MoneyParseFailure.invalid => l.payErrorInvalid,
        },
      );
      return null;
    }
    final amount = (result as MoneyParsed).amount;
    if (amount.value <= 0) {
      setState(() => _fieldError = l.payErrorZero);
      return null;
    }
    if (amount.value > _maxCents) {
      setState(() => _fieldError = l.payErrorTooLarge);
      return null;
    }
    return amount;
  }

  Future<void> _submit() async {
    if (_busy) return;
    final l = AppLocalizations.of(context);
    final userId = ref.read(currentUserIdProvider);
    setState(() {
      _fieldError = null;
      _message = null;
    });
    final amount = _parse(l);
    if (amount == null || userId == null) return;
    setState(() => _busy = true);
    final outcome = await ref
        .read(paymentServiceProvider)
        .pay(
          stokvelId: widget.stokvelId,
          cycleId: widget.cycleId,
          userId: userId,
          amount: amount,
        );
    await _handle(outcome);
  }

  Future<void> _retry(String id) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    await _handle(await ref.read(paymentServiceProvider).send(id));
  }

  Future<void> _handle(PaymentOutcome outcome) async {
    if (!mounted) return;
    final l = AppLocalizations.of(context);
    switch (outcome) {
      case PaymentPaid():
        // Anything that brings fresh data tells the screens, so the
        // banner goes.
        unawaited(ref.read(homeRefreshProvider)());
        unawaited(ref.read(stokvelRefreshProvider)(widget.stokvelId));
        final messenger = ScaffoldMessenger.of(context);
        Navigator.of(context).pop();
        messenger.showSnackBar(SnackBar(content: Text(l.payPaidSnack)));
      case PaymentRefused(:final failure):
        setState(() {
          _busy = false;
          _applyRefusal(l, failure);
        });
      case PaymentWaiting(:final until):
        final seconds = math.max(
          1,
          until.difference(DateTime.now().toUtc()).inSeconds,
        );
        setState(() {
          _busy = false;
          _message = l.payWaiting(seconds);
        });
      case PaymentPending():
        setState(() {
          _busy = false;
          _message = l.payNotSent;
        });
      case PaymentExpired():
        setState(() {
          _busy = false;
          _message = l.payExpired;
        });
      case PaymentGone():
        setState(() => _busy = false);
    }
  }

  void _applyRefusal(AppLocalizations l, Failure failure) {
    if (failure is ValidationFailure) {
      final errors = failure.fieldErrors;
      final forAmount = errors['amountInCents'] ?? errors['amount'];
      if (forAmount != null && forAmount.isNotEmpty) {
        _fieldError = forAmount.first;
        return;
      }
    }
    _message = switch (failure) {
      ConflictFailure(code: 'cycle-closed') => l.payRefusedClosed,
      ConflictFailure(code: 'cycle-paid-out') => l.payRefusedPaidOut,
      ConflictFailure(:final detail?) => detail,
      RuleFailure(:final detail?) => detail,
      ForbiddenFailure(:final detail?) => detail,
      _ => failureText(l, failure),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final pending =
        ref.watch(pendingPaymentsProvider(widget.stokvelId)).value ??
        const <PendingPayment>[];
    final waiting = pending
        .where((p) => p.cycleId == widget.cycleId)
        .firstOrNull;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.payTitle, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            if (waiting != null) ...[
              Text(
                l.payPendingLabel(formatRands(waiting.amount)),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(l.payNotSent),
              const SizedBox(height: 12),
              FilledButton(
                key: const Key('retry-payment-button'),
                onPressed: _busy ? null : () => unawaited(_retry(waiting.id)),
                child: Text(l.tryAgain),
              ),
            ] else ...[
              Semantics(
                liveRegion: _fieldError != null,
                child: TextField(
                  key: const Key('pay-amount-field'),
                  controller: _amount,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => unawaited(_submit()),
                  decoration: InputDecoration(
                    labelText: l.payAmountLabel,
                    hintText: l.payAmountHint,
                    prefixText: 'R\u00A0',
                    errorText: _fieldError,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                key: const Key('pay-button'),
                onPressed: _busy ? null : () => unawaited(_submit()),
                child: _busy
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l.payButton),
              ),
            ],
            if (_message != null)
              Semantics(
                liveRegion: true,
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(_message!),
                ),
              ),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l.closeLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
