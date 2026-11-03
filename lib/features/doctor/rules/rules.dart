import 'config.dart';
import 'device.dart';
import 'engine.dart';
import 'environment.dart';
import 'network.dart';
import 'profile.dart';
import 'tunnel.dart';

export 'config.dart';
export 'device.dart';
export 'engine.dart';
export 'environment.dart';
export 'network.dart';
export 'profile.dart';
export 'tunnel.dart';

const List<Rule> defaultRules = [
  clockSkewRule,
  batteryOptimizationRule,
  subscriptionRule,
  directModeRule,
  vpnPermissionRule,
  otherVpnRule,
  alwaysOnVpnRule,
  privateDnsRule,
  captivePortalRule,
  hostsServerRule,
  hostsServicesRule,
  hostsLargeRule,
  interceptorRule,
  foreignTunnelRule,
  tunnelNameRule,
  deadProxyRule,
  proxyTakenRule,
  portTakenRule,
  deadDnsRule,
];
