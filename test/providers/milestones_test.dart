import 'dart:async';

import 'package:reclash/core/controller.dart';
import 'package:reclash/core/interface.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockCoreHandler extends Mock implements CoreHandlerInterface {}

void main() {
  ProviderContainer buildContainer(_MockCoreHandler core) {
    final container = ProviderContainer(
      overrides: [
        coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('routing reward reads at most 24 recent core decisions', () async {
    final core = _MockCoreHandler();
    const day = 24 * 60 * 60 * 1000;
    when(
      () => core.odometerReport(),
    ).thenAnswer((_) async => const OdometerSnapshot());
    when(() => core.smartRoutingReport()).thenAnswer(
      (_) async => RcxReport(
        at: day * 3,
        history: [
          const RcxSwitchReport(to: 'old', at: 1),
          for (var index = 0; index < 30; index++)
            RcxSwitchReport(to: '$index', at: day * 2 + index),
        ],
      ),
    );
    final container = buildContainer(core);
    await container.read(milestonesProvider.notifier).refresh();
    expect(
      await container.read(milestoneRoutingHistoryProvider.future),
      isEmpty,
    );
    verifyNever(() => core.smartRoutingReport());
    container
        .read(milestoneSettingProvider.notifier)
        .update((state) => state.copyWith(unlocked: {'silentAutopilot'}));
    final history = await container.read(
      milestoneRoutingHistoryProvider.future,
    );
    expect(history.length, 24);
    expect(history.first.to, '29');
    expect(history.last.to, '6');
    container
        .read(milestoneSettingProvider.notifier)
        .update((state) => state.copyWith(findingsEnabled: false));
    expect(
      await container.read(milestoneRoutingHistoryProvider.future),
      isEmpty,
    );
    verify(() => core.smartRoutingReport()).called(1);
  });

  test('refresh queues only newly earned relics', () async {
    final core = _MockCoreHandler();
    when(() => core.odometerReport()).thenAnswer(
      (_) async => const OdometerSnapshot(
        streakMillis: 90 * 24 * 60 * 60 * 1000,
        ladderCompleted: true,
      ),
    );
    final container = buildContainer(core);

    await container.read(milestonesProvider.notifier).refresh();
    final settings = container.read(milestoneSettingProvider);

    expect(settings.unlocked, {'vigil', 'fullLadder'});
    expect(settings.revealQueue, containsAll(['vigil', 'fullLadder']));
  });

  test('reveals at most once per session and records the date', () {
    final core = _MockCoreHandler();
    final container = buildContainer(core);
    container
        .read(milestoneSettingProvider.notifier)
        .update(
          (_) => const MilestoneProps(
            unlocked: {'vigil', 'fullLadder'},
            revealQueue: ['vigil', 'fullLadder'],
          ),
        );
    final notifier = container.read(milestonesProvider.notifier);

    expect(notifier.takeReveal(calm: true), 'vigil');
    expect(notifier.takeReveal(calm: true), isNull);
    final settings = container.read(milestoneSettingProvider);
    expect(settings.revealQueue, ['fullLadder']);
    expect(settings.revealedAt['vigil'], isNotNull);
  });

  test('discovers a local finding once and queues its reveal', () {
    final core = _MockCoreHandler();
    final container = buildContainer(core);
    final notifier = container.read(milestonesProvider.notifier);

    expect(notifier.discover('marks'), isTrue);
    expect(notifier.discover('marks'), isFalse);
    final settings = container.read(milestoneSettingProvider);
    expect(settings.unlocked, {'marks'});
    expect(settings.revealQueue, ['marks']);
  });

  test('does not discover findings while they are disabled', () {
    final core = _MockCoreHandler();
    final container = buildContainer(core);
    container
        .read(milestoneSettingProvider.notifier)
        .update((state) => state.copyWith(findingsEnabled: false));

    expect(
      container.read(milestonesProvider.notifier).discover('marks'),
      isFalse,
    );
    expect(container.read(milestoneSettingProvider).unlocked, isEmpty);
  });

  test('reset preserves unlocks and queues discovery moments again', () {
    final core = _MockCoreHandler();
    final container = buildContainer(core);
    container
        .read(milestoneSettingProvider.notifier)
        .update(
          (_) => const MilestoneProps(
            unlocked: {'vigil', 'marks'},
            revealedAt: {'vigil': 1, 'marks': 2},
          ),
        );

    container.read(milestonesProvider.notifier).resetFindings();
    final settings = container.read(milestoneSettingProvider);

    expect(settings.unlocked, {'vigil', 'marks'});
    expect(settings.revealedAt, isEmpty);
    expect(settings.revealQueue, containsAll(['vigil', 'marks']));
  });

  test('disconnect invalidates an in-flight refresh', () async {
    final core = _MockCoreHandler();
    final report = Completer<OdometerSnapshot?>();
    when(() => core.odometerReport()).thenAnswer((_) => report.future);
    final container = buildContainer(core);
    final notifier = container.read(milestonesProvider.notifier);

    final refresh = notifier.refresh();
    notifier.coreDisconnected();
    report.complete(
      const OdometerSnapshot(streakMillis: 90 * 24 * 60 * 60 * 1000),
    );
    await refresh;

    expect(container.read(milestonesProvider), isNull);
    expect(container.read(milestoneSettingProvider).unlocked, isEmpty);
  });
}
