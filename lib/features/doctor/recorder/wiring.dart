import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reclash/features/doctor/providers.dart';

import 'provider.dart';

/// Starts the recorder and feeds it the events that already surface as
/// providers. Called once from the long-lived app manager.
void startPassiveRecording(WidgetRef ref) {
  final recorder = ref.read(passiveRecorderProvider)..start();
  ref.listenManual(environmentHealNoticesProvider, (_, next) {
    final notice = next.value;
    if (notice == null) return;
    recorder.addEvent('heal', {
      'finding': notice.findingId,
      'remedy': notice.remedyId,
      'undoable': notice.undoable,
    });
  });
  ref.listenManual(pathProvider, (prev, next) {
    final path = next.value;
    if (path == null || !path.complete || path.cancelled) return;
    if (prev?.value?.startedAt == path.startedAt && prev!.value!.complete) {
      return;
    }
    final failed = path.failed;
    recorder.addEvent('pathRun', {
      'scope': path.scope.name,
      'verdict': failed == null ? 'pass' : 'fail',
      if (failed != null) 'step': failed.step.name,
      'detail': ?failed?.detail,
      'cause': ?failed?.cause?.id,
    });
  });
}
