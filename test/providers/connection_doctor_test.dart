import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:reclash/core/controller.dart';
import 'package:reclash/core/interface.dart';
import 'package:reclash/core/method.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/connection_doctor.dart';
import 'package:reclash/providers/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockCoreHandler extends Mock implements CoreHandlerInterface {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const DoctorStartParams(mode: DoctorExamMode.standard),
    );
    registerFallbackValue(const DoctorCancelParams(examId: 'exam'));
    registerFallbackValue(const DoctorHealParams(examId: 'exam', revision: 1));
  });

  ProviderContainer buildContainer(_MockCoreHandler core) {
    final container = ProviderContainer(
      overrides: [
        coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  for (final hidden in [
    AppLifecycleState.hidden,
    AppLifecycleState.paused,
    AppLifecycleState.detached,
  ]) {
    test('defers Android status snapshots while $hidden', () async {
      final core = _MockCoreHandler();
      var revision = 9;
      when(() => core.doctorSnapshot()).thenAnswer(
        (_) async => DoctorSnapshot(revision: revision++, supported: true),
      );
      final container = buildContainer(core);
      final notifier = container.read(connectionDoctorProvider.notifier);
      await notifier.updateActivity(lifecycleState: hidden, isAndroid: true);
      await notifier.refreshFromStatus(minimumRevision: 10);
      await notifier.refreshFromStatus(minimumRevision: 4);
      verifyNever(() => core.doctorSnapshot());

      final snapshot = await notifier.updateActivity(
        lifecycleState: AppLifecycleState.resumed,
        isAndroid: true,
      );
      expect(snapshot.revision, 10);
      verify(() => core.doctorSnapshot()).called(2);
      await notifier.updateActivity(
        lifecycleState: AppLifecycleState.resumed,
        isAndroid: true,
      );
      verifyNever(() => core.doctorSnapshot());
    });
  }

  for (final lifecycle in [null, AppLifecycleState.inactive]) {
    test('keeps Android status refresh enabled for $lifecycle', () async {
      final core = _MockCoreHandler();
      when(() => core.doctorSnapshot()).thenAnswer(
        (_) async => const DoctorSnapshot(revision: 4, supported: true),
      );
      final notifier = buildContainer(
        core,
      ).read(connectionDoctorProvider.notifier);
      await notifier.updateActivity(lifecycleState: lifecycle, isAndroid: true);
      await notifier.refreshFromStatus(minimumRevision: 4);
      verify(() => core.doctorSnapshot()).called(1);
    });
  }

  test('desktop status refresh continues while hidden', () async {
    final core = _MockCoreHandler();
    when(() => core.doctorSnapshot()).thenAnswer(
      (_) async => const DoctorSnapshot(revision: 4, supported: true),
    );
    final notifier = buildContainer(
      core,
    ).read(connectionDoctorProvider.notifier);
    await notifier.updateActivity(
      lifecycleState: AppLifecycleState.hidden,
      isAndroid: false,
    );
    await notifier.refreshFromStatus(minimumRevision: 4);
    verify(() => core.doctorSnapshot()).called(1);
  });

  test('hiding during refresh stops catch-up until resume', () async {
    final core = _MockCoreHandler();
    final first = Completer<DoctorSnapshot>();
    when(() => core.doctorSnapshot()).thenAnswer((_) => first.future);
    final notifier = buildContainer(
      core,
    ).read(connectionDoctorProvider.notifier);
    final request = notifier.refreshFromStatus(minimumRevision: 8);
    await notifier.updateActivity(
      lifecycleState: AppLifecycleState.hidden,
      isAndroid: true,
    );
    first.complete(const DoctorSnapshot(revision: 2, supported: true));
    expect((await request).revision, 2);
    verify(() => core.doctorSnapshot()).called(1);
    var revision = 7;
    when(() => core.doctorSnapshot()).thenAnswer(
      (_) async => DoctorSnapshot(revision: revision++, supported: true),
    );
    expect(
      (await notifier.updateActivity(
        lifecycleState: AppLifecycleState.resumed,
        isAndroid: true,
      )).revision,
      8,
    );
    verify(() => core.doctorSnapshot()).called(2);
  });

  test(
    'hidden reconnect drops old revision but preserves visibility',
    () async {
      final core = _MockCoreHandler();
      when(() => core.doctorSnapshot()).thenAnswer(
        (_) async => const DoctorSnapshot(revision: 1, supported: true),
      );
      final notifier = buildContainer(
        core,
      ).read(connectionDoctorProvider.notifier);
      await notifier.updateActivity(
        lifecycleState: AppLifecycleState.hidden,
        isAndroid: true,
      );
      await notifier.refreshFromStatus(minimumRevision: 99);
      notifier.resetForCoreConnection();
      await notifier.refreshFromStatus();
      verifyNever(() => core.doctorSnapshot());
      final snapshot = await notifier.updateActivity(
        lifecycleState: AppLifecycleState.resumed,
        isAndroid: true,
      );
      expect(snapshot.revision, 1);
      verify(() => core.doctorSnapshot()).called(1);
    },
  );

  test('explicit exam and snapshot are not blocked while hidden', () async {
    final core = _MockCoreHandler();
    when(() => core.startDoctor(any())).thenAnswer(
      (_) async => const DoctorSnapshot(
        revision: 4,
        supported: true,
        state: DoctorExamState.examining,
      ),
    );
    when(() => core.doctorSnapshot()).thenAnswer(
      (_) async => const DoctorSnapshot(revision: 5, supported: true),
    );
    final notifier = buildContainer(
      core,
    ).read(connectionDoctorProvider.notifier);
    await notifier.updateActivity(
      lifecycleState: AppLifecycleState.hidden,
      isAndroid: true,
    );
    expect(
      (await notifier.start(DoctorExamMode.standard)).state,
      DoctorExamState.examining,
    );
    expect((await notifier.refresh()).revision, 5);
    verify(() => core.startDoctor(any())).called(1);
    verify(() => core.doctorSnapshot()).called(1);
  });

  test('maps an old Core to an unsupported snapshot', () async {
    final core = _MockCoreHandler();
    when(() => core.doctorSnapshot()).thenThrow(
      const CoreMethodException(
        code: 'not_implemented',
        message: 'method is unavailable',
      ),
    );
    final container = buildContainer(core);

    final snapshot = await container
        .read(connectionDoctorProvider.notifier)
        .refresh();

    expect(snapshot, unsupportedDoctorSnapshot);
    expect(container.read(connectionDoctorProvider).supported, isFalse);
  });

  test('keeps the last snapshot after a transient refresh failure', () async {
    final core = _MockCoreHandler();
    when(() => core.doctorSnapshot()).thenAnswer(
      (_) async => const DoctorSnapshot(
        revision: 4,
        supported: true,
        health: DoctorHealth.healthy,
      ),
    );
    final container = buildContainer(core);
    final notifier = container.read(connectionDoctorProvider.notifier);
    await notifier.refresh();
    when(() => core.doctorSnapshot()).thenThrow(StateError('disconnected'));

    await expectLater(notifier.refresh(), throwsStateError);

    expect(container.read(connectionDoctorProvider).revision, 4);
    expect(
      container.read(connectionDoctorProvider).health,
      DoctorHealth.healthy,
    );
  });

  test('coalesces refreshes and catches up to the event revision', () async {
    final core = _MockCoreHandler();
    final first = Completer<DoctorSnapshot>();
    var calls = 0;
    when(() => core.doctorSnapshot()).thenAnswer((_) {
      calls++;
      if (calls == 1) return first.future;
      return Future.value(const DoctorSnapshot(revision: 7, supported: true));
    });
    final container = buildContainer(core);
    final notifier = container.read(connectionDoctorProvider.notifier);

    final initial = notifier.refresh();
    final eventRefresh = notifier.refresh(minimumRevision: 7);
    first.complete(const DoctorSnapshot(revision: 6, supported: true));

    expect((await initial).revision, 7);
    expect((await eventRefresh).revision, 7);
    expect(calls, 2);
  });

  test('keeps refreshing until the advertised revision arrives', () async {
    final core = _MockCoreHandler();
    var revision = 5;
    when(() => core.doctorSnapshot()).thenAnswer(
      (_) async => DoctorSnapshot(revision: revision++, supported: true),
    );
    final container = buildContainer(core);
    final notifier = container.read(connectionDoctorProvider.notifier);

    final snapshot = await notifier.refresh(minimumRevision: 7);

    expect(snapshot.revision, 7);
    verify(() => core.doctorSnapshot()).called(3);
  });

  test('stops catch-up when an advertised revision is unreachable', () async {
    final core = _MockCoreHandler();
    when(() => core.doctorSnapshot()).thenAnswer(
      (_) async => const DoctorSnapshot(revision: 1, supported: true),
    );
    final container = buildContainer(core);
    final notifier = container.read(connectionDoctorProvider.notifier);

    final snapshot = await notifier.refresh(minimumRevision: 100);

    expect(snapshot.revision, 1);
    verify(() => core.doctorSnapshot()).called(2);
  });

  test('does not replace a newer snapshot with a stale response', () async {
    final core = _MockCoreHandler();
    when(() => core.startDoctor(any())).thenAnswer(
      (_) async => const DoctorSnapshot(
        revision: 8,
        supported: true,
        state: DoctorExamState.examining,
        examId: 'exam-8',
      ),
    );
    when(() => core.doctorSnapshot()).thenAnswer(
      (_) async => const DoctorSnapshot(revision: 7, supported: true),
    );
    final container = buildContainer(core);
    final notifier = container.read(connectionDoctorProvider.notifier);
    await notifier.start(DoctorExamMode.standard);

    final snapshot = await notifier.refresh();

    expect(snapshot.revision, 8);
    expect(snapshot.examId, 'exam-8');
  });

  test('accepts a lower revision from a new Core connection', () async {
    final core = _MockCoreHandler();
    when(() => core.doctorSnapshot()).thenAnswer(
      (_) async => const DoctorSnapshot(revision: 48, supported: true),
    );
    final container = buildContainer(core);
    final notifier = container.read(connectionDoctorProvider.notifier);
    await notifier.refresh();

    notifier.resetForCoreConnection();
    when(() => core.doctorSnapshot()).thenAnswer(
      (_) async => const DoctorSnapshot(revision: 1, supported: true),
    );

    final snapshot = await notifier.refresh();

    expect(snapshot.revision, 1);
    expect(snapshot.supported, isTrue);
  });

  test('ignores a response from the previous Core connection', () async {
    final core = _MockCoreHandler();
    final stale = Completer<DoctorSnapshot>();
    when(() => core.doctorSnapshot()).thenAnswer((_) => stale.future);
    final container = buildContainer(core);
    final notifier = container.read(connectionDoctorProvider.notifier);

    final request = notifier.refresh();
    notifier.resetForCoreConnection();
    when(() => core.doctorSnapshot()).thenAnswer(
      (_) async => const DoctorSnapshot(revision: 1, supported: true),
    );
    final currentRequest = notifier.refresh();
    stale.complete(const DoctorSnapshot(revision: 99, supported: true));

    expect((await request).revision, 1);
    expect((await currentRequest).revision, 1);
    expect(container.read(connectionDoctorProvider).revision, 1);
  });

  test('ignores old Core unsupported response after reconnect', () async {
    final core = _MockCoreHandler();
    final stale = Completer<DoctorSnapshot>();
    when(() => core.doctorSnapshot()).thenAnswer((_) => stale.future);
    final container = buildContainer(core);
    final notifier = container.read(connectionDoctorProvider.notifier);

    final oldRequest = notifier.refresh();
    notifier.resetForCoreConnection();
    when(() => core.doctorSnapshot()).thenAnswer(
      (_) async => const DoctorSnapshot(revision: 1, supported: true),
    );
    await notifier.refresh();
    stale.completeError(
      const CoreMethodException(code: 'not_implemented', message: 'old core'),
    );

    expect((await oldRequest).revision, 1);
    expect(container.read(connectionDoctorProvider).supported, isTrue);
  });

  test('resets stale verdicts between tunnel sessions', () async {
    final core = _MockCoreHandler();
    when(() => core.doctorSnapshot()).thenAnswer(
      (_) async => const DoctorSnapshot(
        revision: 4,
        supported: true,
        health: DoctorHealth.broken,
      ),
    );
    final container = buildContainer(core);
    final notifier = container.read(connectionDoctorProvider.notifier);
    await notifier.refresh();

    notifier.resetForTunnelSession();

    expect(container.read(connectionDoctorProvider), unsupportedDoctorSnapshot);
  });

  test('publishes freshness expiry without another Core event', () async {
    final core = _MockCoreHandler();
    final freshUntil = DateTime.now().millisecondsSinceEpoch + 500;
    when(() => core.doctorSnapshot()).thenAnswer(
      (_) async => DoctorSnapshot(
        revision: 4,
        supported: true,
        health: DoctorHealth.broken,
        freshUntil: freshUntil,
      ),
    );
    final container = buildContainer(core);
    final notifier = container.read(connectionDoctorProvider.notifier);
    final revisions = <DoctorSnapshot>[];
    container.listen(
      connectionDoctorProvider,
      (_, next) => revisions.add(next),
    );

    await notifier.refresh();
    await Future<void>.delayed(const Duration(milliseconds: 750));

    expect(container.read(connectionDoctorProvider).isFresh, isFalse);
    expect(revisions.length, greaterThanOrEqualTo(2));
  });

  test('does not apply DNS healing from an expired diagnosis', () async {
    final core = _MockCoreHandler();
    when(() => core.startDoctor(any())).thenAnswer(
      (_) async => DoctorSnapshot(
        revision: 4,
        supported: true,
        examId: 'expired',
        freshUntil: DateTime.now().millisecondsSinceEpoch - 1,
        actions: const [DoctorAction(id: 'flushDns', eligible: true)],
      ),
    );
    final container = buildContainer(core);
    final notifier = container.read(connectionDoctorProvider.notifier);

    await notifier.start(DoctorExamMode.standard);
    await notifier.flushDns();

    verifyNever(() => core.flushDoctorDns(any()));
  });

  test('sends action parameters and enforces DNS eligibility', () async {
    final core = _MockCoreHandler();
    when(() => core.startDoctor(any())).thenAnswer(
      (_) async => const DoctorSnapshot(
        revision: 2,
        supported: true,
        examId: 'exam-2',
        state: DoctorExamState.examining,
      ),
    );
    when(() => core.cancelDoctor(any())).thenAnswer(
      (_) async => const DoctorSnapshot(
        revision: 3,
        supported: true,
        state: DoctorExamState.cancelled,
      ),
    );
    when(() => core.flushDoctorDns(any())).thenAnswer(
      (_) async => const DoctorSnapshot(revision: 5, supported: true),
    );
    final container = buildContainer(core);
    final notifier = container.read(connectionDoctorProvider.notifier);

    await notifier.start(DoctorExamMode.deep);
    final start = verify(() => core.startDoctor(captureAny())).captured.single;
    expect(start, const DoctorStartParams(mode: DoctorExamMode.deep));

    await notifier.cancel();
    final cancel = verify(
      () => core.cancelDoctor(captureAny()),
    ).captured.single;
    expect(cancel, const DoctorCancelParams(examId: 'exam-2'));

    await notifier.start(DoctorExamMode.standard);
    await notifier.flushDns();
    verifyNever(() => core.flushDoctorDns(any()));

    when(() => core.startDoctor(any())).thenAnswer(
      (_) async => const DoctorSnapshot(
        revision: 4,
        supported: true,
        examId: 'exam-4',
        actions: [DoctorAction(id: 'flushDns', eligible: true)],
      ),
    );
    await notifier.start(DoctorExamMode.standard);
    await notifier.flushDns();
    final heal = verify(
      () => core.flushDoctorDns(captureAny()),
    ).captured.single;
    expect(heal, const DoctorHealParams(examId: 'exam-4', revision: 4));
  });
}
