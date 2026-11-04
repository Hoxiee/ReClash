import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/features/speed_test/history.dart';
import 'package:reclash/features/speed_test/types.dart';

import 'speed_test_fakes.dart';

void main() {
  ProviderContainer mount(MemorySpeedHistory store) {
    final container = ProviderContainer(
      overrides: [speedTestHistoryStoreProvider.overrideWithValue(store)],
    );
    addTearDown(container.dispose);
    return container;
  }

  SpeedTestState completed({int daysAgo = 0, double rate = 100}) =>
      SpeedTestState(
        phase: SpeedTestPhase.done,
        checkedAt: DateTime.now().subtract(Duration(days: daysAgo)),
        downloadMbps: rate,
        byteLimit: 104857600,
      );

  test(
    'reads only valid completed records within the retention window',
    () async {
      final store = MemorySpeedHistory([
        'malformed',
        jsonEncode(completed(daysAgo: 15).toRecord()),
        jsonEncode(completed(daysAgo: 1).toRecord()),
        jsonEncode(
          completed().copyWith(phase: SpeedTestPhase.cancelled).toRecord(),
        ),
      ]);
      final values = await mount(store).read(speedTestHistoryProvider.future);
      expect(values, hasLength(1));
      expect(values.single.downloadMbps, 100);
    },
  );

  test('keeps at most 200 summaries without per-frame samples', () async {
    final store = MemorySpeedHistory();
    final container = mount(store);
    final history = container.read(speedTestHistoryProvider.notifier);
    for (var index = 0; index < 203; index++) {
      await history.add(
        completed(rate: index.toDouble()).copyWith(
          downloadSamples: const [SpeedTestSample(elapsedMs: 200, mbps: 10)],
        ),
      );
    }
    expect(store.records, hasLength(200));
    final records = container.read(speedTestHistoryProvider).requireValue;
    expect(records.first.downloadMbps, 202);
    expect(records.every((record) => record.downloadSamples.isEmpty), isTrue);
  });

  test('failed and cancelled runs do not enter history', () async {
    final store = MemorySpeedHistory();
    final history = mount(store).read(speedTestHistoryProvider.notifier);
    await history.add(completed().copyWith(phase: SpeedTestPhase.failed));
    await history.add(completed().copyWith(phase: SpeedTestPhase.cancelled));
    await history.add(completed().copyWith(errors: {SpeedTestStage.upload}));
    expect(store.writes, 0);
  });

  test(
    'a storage failure is visible and does not poison subsequent writes',
    () async {
      final store = MemorySpeedHistory()..saveError = StateError('disk full');
      final container = mount(store);
      final history = container.read(speedTestHistoryProvider.notifier);
      await expectLater(history.add(completed()), throwsStateError);
      expect(container.read(speedTestHistoryProvider).requireValue, isEmpty);
      store.saveError = null;
      await history.add(completed());
      expect(store.records, hasLength(1));
    },
  );

  test('concurrent add then clear leaves no persisted records', () async {
    final store = MemorySpeedHistory();
    final container = mount(store);
    final history = container.read(speedTestHistoryProvider.notifier);
    await Future.wait([history.add(completed()), history.clear()]);
    expect(store.records, isEmpty);
    expect(container.read(speedTestHistoryProvider).requireValue, isEmpty);
  });
}
