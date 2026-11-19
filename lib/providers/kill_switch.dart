import 'package:reclash/common/common.dart';
import 'package:reclash/core/desktop/helper_client.dart';
import 'package:reclash/core/desktop/kill_switch_policy.dart';
import 'package:reclash/enum/enum.dart';
import 'package:flutter/foundation.dart' show protected;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'app.dart';
import 'config.dart';

part 'generated/kill_switch.g.dart';

/// Whether this platform has the Helper's host kill switch.
bool get killSwitchHostLayer => system.isLinux || system.isWindows;

/// What the configuration the Helper should hold is, or null for none.
@Riverpod(keepAlive: true)
KillSwitchConfig? killSwitchWanted(Ref ref) {
  if (!killSwitchHostLayer) return null;
  final (mode, allowLan) = ref.watch(
    networkSettingProvider.select(
      (state) => (state.killSwitch, state.killSwitchAllowLan),
    ),
  );
  if (mode == null) return null;
  final tun = ref.watch(patchClashConfigProvider.select((s) => s.tun.device));
  return (mode: mode, tun: tun, allowLan: allowLan);
}

/// What the Helper last reported about its kill switch; null until the host
/// policy has asked once.
@Riverpod(keepAlive: true)
class KillSwitchHostState extends _$KillSwitchHostState {
  @override
  KillSwitchHostSnapshot? build() => null;

  void set(KillSwitchHostSnapshot snapshot) => state = snapshot;

  /// Lifts a standard-mode block after a deliberate user stop: the user turned
  /// TUN or the proxy off, or quit. Restarts, recovery and update relaunches
  /// never call it, since the block is what holds traffic while the Core
  /// comes back. Always mode keeps blocking by design, so it is not asked.
  Future<void> disarmOnUserStop() async {
    if (!killSwitchHostLayer ||
        ref.read(networkSettingProvider).killSwitch !=
            KillSwitchMode.standard) {
      return;
    }
    try {
      await disarm().timeout(const Duration(seconds: 2));
    } catch (error) {
      commonPrint.log(
        'Kill switch disarm failed: ${compactError(error)}',
        logLevel: LogLevel.warning,
      );
    }
  }

  @protected
  Future<void> disarm() => helperClient.disarmKillSwitch();

  /// The notice's unblock action; errors reach the caller.
  Future<void> unblock() async {
    await disarm();
    await refresh();
  }

  Future<void> refresh() async {
    final readiness = await helperClient.readiness(logFailure: false);
    if (!ref.mounted) return;
    if (readiness != HelperReadiness.ready) {
      state = (readiness: readiness, info: null);
      return;
    }
    final info = await helperClient.killSwitch();
    if (ref.mounted) state = (readiness: readiness, info: info);
  }
}

/// Whether the kill switch currently blocks the internet with no tunnel to
/// carry it: armed and applied while the Core runs without TUN.
@riverpod
bool killSwitchBlocking(Ref ref) {
  final info = ref.watch(killSwitchHostStateProvider)?.info;
  if (info == null || !info.armed || !info.active) return false;
  final tunUp =
      ref.watch(coreStatusProvider) == CoreStatus.connected &&
      ref.watch(tunAppliedProvider);
  return !tunUp;
}
