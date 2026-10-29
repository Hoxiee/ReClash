import 'dart:async';

import 'package:reclash/common/common.dart';
import 'package:reclash/state.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/plugins/battery.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi_ssid/wifi_ssid.dart';

import 'app.dart';
import 'config.dart';
import 'package:reclash/plugins/service.dart';

part 'generated/on_demand.g.dart';

@Riverpod(keepAlive: true)
class LocationPermissions extends _$LocationPermissions {
  bool _requesting = false;
  bool _autoRequested = false;

  @override
  WifiSsidPermission build() => WifiSsidPermission.denied;

  /// Only a request can tell a permanent denial apart, so a check leaves that
  /// answer in place until it sees the grant.
  Future<void> refresh() async {
    if (ref.read(safeModeProvider)) {
      return;
    }
    final WifiSsidPermission permission;
    try {
      permission = await wifiSsidManager.checkPermission();
    } catch (error) {
      commonPrint.log(
        'checkPermission error $error',
        logLevel: LogLevel.warning,
      );
      return;
    }
    if (permission == WifiSsidPermission.granted ||
        state != WifiSsidPermission.permanentlyDenied) {
      state = permission;
    }
    if (!ref.read(onDemandNeedsSsidProvider)) {
      _autoRequested = false;
      return;
    }
    if (permission != WifiSsidPermission.denied || _autoRequested) {
      return;
    }
    try {
      _autoRequested = await request() != null;
    } on PlatformException catch (error) {
      commonPrint.log(
        'requestPermission error $error',
        logLevel: LogLevel.warning,
      );
    }
  }

  /// Null while another request is showing, so only the caller that raised
  /// the prompt follows up on the answer.
  Future<WifiSsidPermission?> request() async {
    if (_requesting) {
      return null;
    }
    _requesting = true;
    try {
      final permission = await wifiSsidManager.requestPermission();
      state = permission;
      return permission;
    } finally {
      _requesting = false;
    }
  }
}

@riverpod
class BatteryOptimizationIgnored extends _$BatteryOptimizationIgnored {
  bool _requesting = false;

  @protected
  BatteryOptimization? get plugin => batteryOptimization;

  @override
  Stream<bool?> build() => plugin?.onChanged ?? Stream.value(true);

  Future<void> request() async {
    final plugin = this.plugin;
    if (plugin == null || _requesting) {
      return;
    }
    _requesting = true;
    try {
      await plugin.requestIgnore();
    } on PlatformException catch (error) {
      commonPrint.log(
        'requestIgnoreOptimizations error $error',
        logLevel: LogLevel.warning,
      );
    } finally {
      _requesting = false;
    }
  }
}

@riverpod
bool onDemandNeedsSsid(Ref ref) =>
    ref.watch(vpnSettingProvider.select((s) => s.onDemandEnabled)) &&
    ref.watch(excludeSSIDsProvider).any((rule) => !isSubnetRule(rule));

@Riverpod(keepAlive: true)
class PhysicalAddresses extends _$PhysicalAddresses
    with AutoDisposeNotifierMixin {
  @override
  List<String> build() => const [];
}

@Riverpod(keepAlive: true)
class NativeOnDemandPause extends _$NativeOnDemandPause
    with AutoDisposeNotifierMixin {
  @override
  bool build() => false;
}

@Riverpod(keepAlive: true)
class OnDemandOverride extends _$OnDemandOverride
    with AutoDisposeNotifierMixin {
  @override
  ({bool? paused, List<String> anchor}) build() =>
      (paused: null, anchor: const []);

  Future<void> setPaused(bool paused) async {
    final previous = state;
    state = (paused: paused, anchor: ref.read(onDemandNetworkAnchorProvider));
    final intent = state;
    await globalState.safeRun(() async {
      try {
        await service?.setOnDemandPaused(paused);
      } catch (_) {
        if (ref.mounted && state == intent) state = previous;
        rethrow;
      }
    });
  }

  void clear() => state = (paused: null, anchor: const []);
}

@riverpod
List<String> onDemandNetworkAnchor(Ref ref) => [
  ?ref.watch(currentSSIDProvider),
  ...ref
      .watch(physicalAddressesProvider)
      .map(
        (ip) => ip.contains(':') ? ipv6ToSubnetCidr(ip) : ipv4ToSubnetCidr(ip),
      )
      .toSet()
      .toList()
    ..sort(),
];

@riverpod
List<String> onDemandMatchedNetworks(Ref ref) {
  final vpn = ref.watch(vpnSettingProvider);
  if (!vpn.onDemandEnabled) return const [];
  final addresses = ref.watch(physicalAddressesProvider);
  return onDemandMatchedRules(
    ref.watch(excludeSSIDsProvider),
    ssid: ref.watch(currentSSIDProvider),
    ipv4s: addresses.where((ip) => !ip.contains(':')).toList(),
    ipv6s: addresses.where((ip) => ip.contains(':')).toList(),
    strict: vpn.onDemandStrict,
  );
}
