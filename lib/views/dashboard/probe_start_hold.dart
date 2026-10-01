import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reclash/providers/route_state.dart';
import 'package:reclash/providers/routed_probe.dart';

/// After a start flips the route to proxied, the config re-apply reruns every
/// probe, so the first results often fail. For a short window those failures
/// read as still probing rather than as a verdict.
mixin ProbeStartHold<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  static const _duration = Duration(seconds: 5);

  Timer? _hold;

  ProbePhase shownPhase(ProbeEntry<Object?> entry) =>
      _hold != null && entry.phase == ProbePhase.failed
      ? ProbePhase.probing
      : entry.phase;

  @override
  void initState() {
    super.initState();
    ref.listenManual(
      routeTrackerProvider.select((state) => state.proxied),
      (_, proxied) => _rearm(proxied),
    );
  }

  @override
  void dispose() {
    _hold?.cancel();
    super.dispose();
  }

  void _rearm(bool proxied) {
    _hold?.cancel();
    setState(() {
      _hold = proxied
          ? Timer(_duration, () {
              if (mounted) setState(() => _hold = null);
            })
          : null;
    });
  }
}
