import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/providers/on_demand.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi_ssid/wifi_ssid.dart';

typedef SsidReader = Future<String?> Function();

class ConnectivityManager extends ConsumerStatefulWidget {
  final Function(List<ConnectivityResult> results)? onConnectivityChanged;
  final Stream<List<ConnectivityResult>>? connectivityStream;
  final SsidReader? readSsid;

  /// Android owns on-demand natively, so its UI poll can pause while hidden.
  final bool? pollsWhileHidden;
  final Widget child;

  const ConnectivityManager({
    super.key,
    this.onConnectivityChanged,
    this.connectivityStream,
    this.readSsid,
    this.pollsWhileHidden,
    required this.child,
  });

  @override
  ConsumerState<ConnectivityManager> createState() =>
      _ConnectivityManagerState();
}

class _ConnectivityManagerState extends ConsumerState<ConnectivityManager> {
  late final StreamSubscription subscription;
  late final SsidReader _readSsid =
      widget.readSsid ?? WifiSsidManager.instance.getSsid;
  late final bool _pollsWhileHidden =
      widget.pollsWhileHidden ?? !system.isAndroid;

  int _ssidRequestId = 0;
  bool _onWifi = false;
  bool _needsSsid = false;
  int _addressRequestId = 0;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    final stream =
        widget.connectivityStream ?? Connectivity().onConnectivityChanged;
    subscription = stream.listen(_handleResults);
    if (widget.connectivityStream == null) {
      unawaited(
        Connectivity().checkConnectivity().then((results) {
          if (mounted) _handleResults(results);
        }),
      );
    }
    ref.listenManual(
      vpnSettingProvider.select((s) => s.onDemandEnabled),
      (_, _) => _syncPolicy(),
    );
    ref.listenManual(excludeSSIDsProvider, (_, _) => _syncPolicy());
    if (!_pollsWhileHidden) {
      ref.listenManual(appVisibleProvider, (previous, next) {
        if (previous != next) _syncPolicy();
      });
    }
    _syncPolicy();
    ref.listenManual(
      locationPermissionsProvider.select(
        (permission) => permission == WifiSsidPermission.granted,
      ),
      (previous, next) {
        if (previous != next) {
          unawaited(_updateSsid());
        }
      },
    );
  }

  void _handleResults(List<ConnectivityResult> results) {
    _onWifi = results.contains(ConnectivityResult.wifi);
    unawaited(_updateSsid());
    unawaited(_updateAddresses());
    widget.onConnectivityChanged?.call(results);
  }

  Future<void> _updateSsid() async {
    final requestId = ++_ssidRequestId;
    // The SSID costs a blocking platform call and a location permission on
    // Android and macOS, and nothing reads it until a network is excluded.
    if (!_onWifi || ref.read(safeModeProvider) || !_needsSsid) {
      _publishSsid(requestId, null);
      return;
    }
    try {
      final ssid = await _readSsid();
      if (_publishSsid(requestId, ssid)) {
        commonPrint.log('Wi-fi SSID: $ssid', logLevel: LogLevel.info);
      }
    } catch (error) {
      commonPrint.log(
        'Unable to read the Wi-Fi SSID: $error',
        logLevel: LogLevel.warning,
      );
      _publishSsid(requestId, null);
    }
  }

  void _syncPolicy() {
    final enabled = ref.read(vpnSettingProvider).onDemandEnabled;
    final rules = ref.read(excludeSSIDsProvider);
    final needsSsid = enabled && rules.any((rule) => !isSubnetRule(rule));
    if (_needsSsid != needsSsid) {
      _needsSsid = needsSsid;
      unawaited(_updateSsid());
    }

    _pollTimer?.cancel();
    _pollTimer = null;
    if (ref.read(safeModeProvider) ||
        !ref.read(vpnSettingProvider).onDemandEnabled ||
        ref.read(excludeSSIDsProvider).isEmpty ||
        !_pollsWhileHidden && !ref.read(appVisibleProvider)) {
      return;
    }
    if (!_pollsWhileHidden) unawaited(_updateSsid());
    unawaited(_updateAddresses());
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      unawaited(_updateSsid());
      unawaited(_updateAddresses());
    });
  }

  Future<void> _updateAddresses() async {
    final requestId = ++_addressRequestId;
    if (ref.read(safeModeProvider) ||
        !ref.read(vpnSettingProvider).onDemandEnabled ||
        ref.read(excludeSSIDsProvider).isEmpty) {
      return;
    }
    try {
      final addresses = await getPhysicalNetworkAddresses();
      if (mounted &&
          requestId == _addressRequestId &&
          !listEquals(addresses, ref.read(physicalAddressesProvider))) {
        ref.read(physicalAddressesProvider.notifier).value = addresses;
      }
    } catch (error) {
      commonPrint.log(
        'Unable to read physical addresses: $error',
        logLevel: LogLevel.warning,
      );
    }
  }

  bool _publishSsid(int requestId, String? ssid) {
    if (requestId != _ssidRequestId || !mounted) {
      return false;
    }
    ref.read(currentSSIDProvider.notifier).value = ssid;
    return true;
  }

  @override
  void dispose() {
    subscription.cancel();
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
