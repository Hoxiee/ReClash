import 'package:reclash/common/common.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/state.dart';
import 'package:flutter/services.dart';

// TODO: companion-gate-probe removal — GATE B proof a retained engine answers a native call, no Activity.
void registerCompanionGateProbe() {
  const channel = MethodChannel('$packageName/companion_gate');
  channel.setMethodCallHandler((call) async {
    if (call.method != 'probeEngine') {
      throw MissingPluginException();
    }
    final container = globalState.container;
    return {
      'alive': true,
      'profileId': container.read(currentProfileIdProvider),
      'at': DateTime.now().microsecondsSinceEpoch,
    };
  });
}
