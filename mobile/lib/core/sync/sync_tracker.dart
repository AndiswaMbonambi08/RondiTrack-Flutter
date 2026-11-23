import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ronditrack/core/failure/failure.dart';
import 'package:ronditrack/core/failure/failure_mapper.dart';
import 'package:ronditrack/core/session/session.dart';

/// What happened to the last fetch. The banner comes from this, from what
/// happened to a request, never from the connection type.
class SyncState {
  const new({this.refreshing = false, this.failure});

  final bool refreshing;
  final Failure? failure;
}

class SyncTracker extends Notifier<Map<String, SyncState>> {
  @override
  Map<String, SyncState> build() {
    ref.watch(sessionScopeProvider);
    return const {};
  }

  /// Fetches and stores. The server answer goes into the cache, never to a
  /// widget. A failure stays until something brings fresh data.
  Future<void> run(String key, Future<void> Function() fetchAndStore) async {
    final before = state[key];
    if (before?.refreshing ?? false) return;
    state = {
      ...state,
      key: SyncState(refreshing: true, failure: before?.failure),
    };
    try {
      await fetchAndStore();
      state = {...state, key: const SyncState()};
    } on Object catch (error) {
      state = {...state, key: SyncState(failure: toFailure(error))};
    }
  }
}

final syncTrackerProvider =
    NotifierProvider<SyncTracker, Map<String, SyncState>>(SyncTracker.new);

// Reason: the family's type is in a private riverpod library, so it cannot be
// written here without importing from lib/src.
// ignore: specify_nonobvious_property_types
final syncStateProvider = Provider.family<SyncState, String>(
  (ref, key) =>
      ref.watch(syncTrackerProvider.select((all) => all[key])) ??
      const SyncState(),
);
