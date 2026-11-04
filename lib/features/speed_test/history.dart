import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reclash/common/preferences.dart';

import 'types.dart';

abstract interface class SpeedTestHistoryStore {
  Future<List<String>> load();
  Future<void> save(List<String> records);
}

class _PreferencesHistoryStore implements SpeedTestHistoryStore {
  @override
  Future<List<String>> load() => preferences.getSpeedTestHistory();

  @override
  Future<void> save(List<String> records) =>
      preferences.saveSpeedTestHistory(records);
}

final speedTestHistoryStoreProvider = Provider<SpeedTestHistoryStore>(
  (ref) => _PreferencesHistoryStore(),
);

class SpeedTestHistory extends AsyncNotifier<List<SpeedTestState>> {
  static const limit = 200;
  static const retention = Duration(days: 14);
  Future<void> _writes = Future.value();

  @override
  Future<List<SpeedTestState>> build() async {
    final rows = await ref.watch(speedTestHistoryStoreProvider).load();
    final records = <SpeedTestState>[];
    for (final row in rows.take(limit)) {
      if (row.length > 16384) continue;
      try {
        final json = jsonDecode(row);
        if (json is! Map<String, dynamic>) continue;
        final record = SpeedTestState.fromJson(json);
        if (_completed(record)) records.add(record);
      } on Object {
        continue;
      }
    }
    return _retained(records);
  }

  static bool _completed(SpeedTestState record) =>
      record.phase == SpeedTestPhase.done &&
      record.failure == null &&
      record.errors.isEmpty &&
      record.checkedAt != null;

  static List<SpeedTestState> _retained(Iterable<SpeedTestState> records) {
    final now = DateTime.now();
    final cutoff = now.subtract(retention);
    final kept = records.where((record) {
      final time = record.checkedAt;
      return time != null && !time.isBefore(cutoff) && !time.isAfter(now);
    }).toList()..sort((a, b) => b.checkedAt!.compareTo(a.checkedAt!));
    return List.unmodifiable(kept.take(limit));
  }

  Future<void> add(SpeedTestState result) {
    if (!_completed(result)) return Future.value();
    final record = result.copyWith(
      requestId: '',
      liveMbps: null,
      downloadSamples: const [],
      uploadSamples: const [],
      historySaveFailed: false,
    );
    return _update((records) => _retained([record, ...records]));
  }

  Future<void> clear() => _update((_) => const []);

  Future<void> _update(
    List<SpeedTestState> Function(List<SpeedTestState>) change,
  ) {
    final store = ref.read(speedTestHistoryStoreProvider);
    final loaded = future;
    final write = _writes.then((_) async {
      final initial = await loaded;
      if (!ref.mounted) return;
      final records = change(state.value ?? initial);
      await store.save(
        records.map((record) => jsonEncode(record.toRecord())).toList(),
      );
      if (ref.mounted) state = AsyncData(records);
    });
    _writes = write.catchError((Object _) {});
    return write;
  }
}

final speedTestHistoryProvider =
    AsyncNotifierProvider<SpeedTestHistory, List<SpeedTestState>>(
      SpeedTestHistory.new,
    );
