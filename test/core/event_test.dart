import 'package:reclash/core/event.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingListener with CoreEventListener {
  _RecordingListener({this.onLoadedCallback});

  final void Function()? onLoadedCallback;
  final List<String> loaded = [];
  final List<DoctorStatus> doctorStatuses = [];

  @override
  void onLoaded(String providerName) {
    loaded.add(providerName);
    onLoadedCallback?.call();
  }

  @override
  void onDoctorStatus(DoctorStatus status) {
    doctorStatuses.add(status);
  }
}

void main() {
  test(
    'a listener may unregister itself while an event is dispatched',
    () async {
      late _RecordingListener first;
      final second = _RecordingListener();
      first = _RecordingListener(
        onLoadedCallback: () => coreEventManager.removeListener(first),
      );

      coreEventManager.addListener(first);
      coreEventManager.addListener(second);
      addTearDown(() {
        coreEventManager.removeListener(first);
        coreEventManager.removeListener(second);
      });

      coreEventManager.sendEvent(
        const CoreEvent(type: CoreEventType.loaded, data: 'provider-a'),
      );
      await pumpEventQueue();

      expect(first.loaded, ['provider-a']);
      expect(second.loaded, ['provider-a']);

      coreEventManager.sendEvent(
        const CoreEvent(type: CoreEventType.loaded, data: 'provider-b'),
      );
      await pumpEventQueue();

      expect(first.loaded, ['provider-a']);
      expect(second.loaded, ['provider-a', 'provider-b']);
    },
  );
  test('doctor status events decode tolerant projections', () async {
    final listener = _RecordingListener();
    coreEventManager.addListener(listener);
    addTearDown(() => coreEventManager.removeListener(listener));

    coreEventManager.sendEvent(
      const CoreEvent(
        type: CoreEventType.doctorStatus,
        data: {
          'revision': 9,
          'state': 'future-state',
          'health': 'degraded',
          'confidence': 'probable',
          'causeCode': 'resolverFailure',
        },
      ),
    );
    await pumpEventQueue();

    expect(listener.doctorStatuses, hasLength(1));
    expect(listener.doctorStatuses.single.revision, 9);
    expect(listener.doctorStatuses.single.state, DoctorExamState.unknown);
    expect(listener.doctorStatuses.single.health, DoctorHealth.degraded);
    expect(listener.doctorStatuses.single.causeCode, 'resolverFailure');
  });
}
