import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/providers/config.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi_ssid/wifi_ssid.dart';

typedef SsidReader = Future<String?> Function();

typedef ConnectivityReader = Future<List<ConnectivityResult>> Function();

class ConnectivityManager extends ConsumerStatefulWidget {
  final Function(List<ConnectivityResult> results)? onConnectivityChanged;
  final Stream<List<ConnectivityResult>>? connectivityStream;
  final SsidReader? readSsid;
  final ConnectivityReader? readConnectivity;
  final Widget child;

  const ConnectivityManager({
    super.key,
    this.onConnectivityChanged,
    this.connectivityStream,
    this.readSsid,
    this.readConnectivity,
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
  Timer? _pollTimer;

  int _ssidRequestId = 0;
  int _ipv4RequestId = 0;
  bool _onWifi = false;

  @override
  void initState() {
    super.initState();
    final stream =
        widget.connectivityStream ?? Connectivity().onConnectivityChanged;
    subscription = stream.listen(_handleResults);
    ref.listenManual(
      vpnSettingProvider.select(
        (state) => state.smartPauseEnabled && state.smartPauseNetworks.isNotEmpty,
      ),
      (previous, next) {
        // The fireImmediately call runs inside initState, where a provider write throws.
        if (previous == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _syncRules(previous, next);
            }
          });
        } else {
          _syncRules(previous, next);
        }
      },
      fireImmediately: true,
    );
    unawaited(_bootstrap());
  }

  Future<void> _bootstrap() async {
    unawaited(_updateIpv4s());
    final readConnectivity =
        widget.readConnectivity ?? Connectivity().checkConnectivity;
    try {
      _handleResults(await readConnectivity());
    } catch (_) {}
  }

  void _handleResults(List<ConnectivityResult> results) {
    _onWifi = results.contains(ConnectivityResult.wifi);
    unawaited(_updateSsid());
    unawaited(_updateIpv4s());
    widget.onConnectivityChanged?.call(results);
  }

  void _syncRules(bool? previous, bool next) {
    unawaited(_updateSsid());
    unawaited(_updateIpv4s());
    // A Wi-Fi-to-Wi-Fi roam can pass without a connectivity event, so the
    // rules are re-read on a timer while any rule exists.
    if (next) {
      _pollTimer ??= Timer.periodic(_pollInterval, (_) {
        unawaited(_updateSsid());
        unawaited(_updateIpv4s());
      });
    } else {
      _pollTimer?.cancel();
      _pollTimer = null;
    }
  }

  bool get _needsSsid {
    final vpn = ref.read(vpnSettingProvider);
    return vpn.smartPauseEnabled &&
        vpn.smartPauseNetworks.any((network) => !isSubnetRule(network));
  }

  Future<void> _updateSsid() async {
    final requestId = ++_ssidRequestId;
    // The SSID costs a blocking platform call and a location permission on
    // Android and macOS, and nothing reads it until an SSID rule exists.
    if (!_onWifi || !_needsSsid) {
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
      if (!_onWifi) {
        _publishSsid(requestId, null);
      }
    }
  }

  bool _publishSsid(int requestId, String? ssid) {
    if (requestId != _ssidRequestId || !mounted) {
      return false;
    }
    ref.read(currentSSIDProvider.notifier).value = ssid;
    return true;
  }

  Future<void> _updateIpv4s() async {
    final requestId = ++_ipv4RequestId;
    try {
      final ipv4s = await getLocalIPv4s();
      if (ipv4s.isEmpty || requestId != _ipv4RequestId || !mounted) {
        return;
      }
      ref.read(currentIPv4sProvider.notifier).value = ipv4s;
    } catch (error) {
      commonPrint.log(
        'Unable to enumerate local addresses: $error',
        logLevel: LogLevel.warning,
      );
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  static const _pollInterval = Duration(seconds: 25);
}
