import 'package:reclash/enum/enum.dart';

import '../cause.dart';
import '../environment/catalogue.dart';
import '../environment/reader.dart';
import '../finding.dart';
import '../snapshot.dart';

const hostsLargeLines = 10000;

List<String> _hostsRemedies(bool? useSystemHosts, {required bool ignorable}) =>
    [
      if (useSystemHosts != false && ignorable) 'dns.ignoreSystemHosts',
      'system.openHosts',
    ];

/// An entry for the subscription's host breaks our own downloads whatever the
/// Core reads; one for the test host matters only while the Core reads `hosts`.
Finding? hostsServerRule(DiagnosticSnapshot snapshot) {
  final hosts = snapshot.valueOf(Facts.hosts);
  if (hosts == null) return null;
  final useSystemHosts = snapshot.valueOf(Facts.useSystemHosts);
  final relevant = [
    for (final entry in hosts.entries)
      if (entry.role == DomainRole.subscription ||
          (entry.role == DomainRole.test && useSystemHosts != false))
        entry,
  ];
  if (relevant.isEmpty) return null;
  return Finding(
    id: 'env.hostsServer',
    severity: CheckSeverity.critical,
    cause: FailureCause.hostsOverride,
    evidence: [Facts.hosts.id, Facts.useSystemHosts.id],
    titleKey: 'doctorHostsServerTitle',
    detailKey: 'doctorHostsServerDetail',
    args: {'domain': relevant.first.domain, 'count': relevant.length},
    remedyIds: _hostsRemedies(
      useSystemHosts,
      ignorable: relevant.every((entry) => entry.role == DomainRole.test),
    ),
  );
}

Finding? hostsServicesRule(DiagnosticSnapshot snapshot) {
  final hosts = snapshot.valueOf(Facts.hosts);
  if (hosts == null) return null;
  final useSystemHosts = snapshot.valueOf(Facts.useSystemHosts);
  if (useSystemHosts == false && snapshot.valueOf(Facts.tunEnabled) != true) {
    return null;
  }
  final domains = {
    for (final entry in hosts.entries)
      if (entry.role == DomainRole.service) entry.domain,
  };
  if (domains.isEmpty) return null;
  return Finding(
    id: 'env.hostsServices',
    severity: CheckSeverity.warning,
    cause: FailureCause.hostsOverride,
    evidence: [Facts.hosts.id, Facts.useSystemHosts.id, Facts.tunEnabled.id],
    titleKey: 'doctorHostsServicesTitle',
    detailKey: 'doctorHostsServicesDetail',
    args: {'domains': domains.take(3).join(', '), 'count': domains.length},
    // Under TUN apps resolve through the OS hosts, so ignoring them in the
    // Core cannot clear this.
    remedyIds: _hostsRemedies(
      useSystemHosts,
      ignorable: snapshot.valueOf(Facts.tunEnabled) != true,
    ),
  );
}

Finding? hostsLargeRule(DiagnosticSnapshot snapshot) {
  final hosts = snapshot.valueOf(Facts.hosts);
  if (hosts == null || hosts.lineCount <= hostsLargeLines) return null;
  return Finding(
    id: 'env.hostsLarge',
    severity: CheckSeverity.tip,
    evidence: [Facts.hosts.id],
    titleKey: 'doctorHostsLargeTitle',
    detailKey: 'doctorHostsLargeDetail',
    args: {'lines': hosts.lineCount},
    remedyIds: const ['system.openHosts'],
  );
}

ConflictEntry? _interceptorIn(Iterable<ConflictEntry> entries) =>
    entries.where((entry) => entry.kind == ConflictKind.dpiBypass).firstOrNull;

Finding? interceptorRule(DiagnosticSnapshot snapshot) {
  final software = snapshot.valueOf(Facts.software);
  final hosts = snapshot.valueOf(Facts.hosts);
  final named =
      (software == null ? null : _interceptorIn(matchSoftware(software))) ??
      (hosts == null
          ? null
          : _interceptorIn([?matchHostsMarkers(hosts.markers)]));
  final unnamed =
      named == null && software != null && interceptorDriverLoaded(software);
  if (named == null && !unnamed) return null;
  return Finding(
    id: 'env.interceptor',
    severity: CheckSeverity.warning,
    cause: FailureCause.trafficIntercepted,
    evidence: [Facts.software.id, Facts.hosts.id],
    titleKey: 'doctorInterceptorTitle',
    detailKey: named == null
        ? 'doctorInterceptorUnknownDetail'
        : 'doctorInterceptorDetail',
    args: {if (named != null) 'name': named.name},
  );
}

String adapterLabel(TunnelAdapter adapter) =>
    matchAdapter(adapter)?.name ??
    (adapter.description.isNotEmpty ? adapter.description : adapter.name);

/// Needs the Core up: a stopped app has no tunnel to lose.
Finding? foreignTunnelRule(DiagnosticSnapshot snapshot) {
  final tunnels = snapshot.valueOf(Facts.tunnels);
  if (tunnels == null ||
      snapshot.valueOf(Facts.tunEnabled) != true ||
      snapshot.valueOf(Facts.coreStatus) != CoreStatus.connected) {
    return null;
  }
  final holder = tunnels.foreign.where((a) => a.defaultRoute).firstOrNull;
  if (holder == null ||
      (tunnels.ours != null && tunnels.routedThroughOurs != false)) {
    return null;
  }
  return Finding(
    id: 'env.foreignTunnel',
    severity: CheckSeverity.critical,
    cause: FailureCause.tunnelTaken,
    evidence: [Facts.tunnels.id, Facts.tunEnabled.id, Facts.coreStatus.id],
    titleKey: 'doctorForeignTunnelTitle',
    detailKey: 'doctorForeignTunnelDetail',
    args: {'name': adapterLabel(holder)},
    remedyIds: const ['tunnel.restart'],
  );
}

Finding? tunnelNameRule(DiagnosticSnapshot snapshot) {
  final tunnels = snapshot.valueOf(Facts.tunnels);
  final device = snapshot.valueOf(Facts.tunDevice);
  if (tunnels == null ||
      device == null ||
      snapshot.valueOf(Facts.tunEnabled) != true) {
    return null;
  }
  final taker = tunnels.foreign
      .where((a) => a.name.toLowerCase() == device.toLowerCase())
      .firstOrNull;
  if (taker == null) return null;
  return Finding(
    id: 'env.tunnelName',
    severity: CheckSeverity.critical,
    cause: FailureCause.tunnelTaken,
    evidence: [Facts.tunnels.id, Facts.tunDevice.id, Facts.tunEnabled.id],
    titleKey: 'doctorTunnelNameTitle',
    detailKey: 'doctorTunnelNameDetail',
    args: {'name': taker.name},
    remedyIds: const ['tunnel.freeDeviceName'],
  );
}

Finding? deadProxyRule(DiagnosticSnapshot snapshot) {
  final proxy = snapshot.valueOf(Facts.systemProxy);
  final status = snapshot.valueOf(Facts.coreStatus);
  final port = proxy?.port;
  if (proxy == null ||
      port == null ||
      !proxy.enabled ||
      proxy.reachable != false ||
      status == null ||
      status == CoreStatus.connecting) {
    return null;
  }
  // A connected Core may report before its listener accepts; a real bind
  // failure on the port is portTakenRule's finding.
  if (status == CoreStatus.connected &&
      isLoopbackHost(proxy.host) &&
      port == snapshot.valueOf(Facts.mixedPort)) {
    return null;
  }
  final ours =
      isLoopbackHost(proxy.host) &&
      port == snapshot.valueOf(Facts.ownProxyPort);
  return Finding(
    id: 'env.deadProxy',
    severity: CheckSeverity.critical,
    cause: FailureCause.systemProxyBroken,
    evidence: [
      Facts.systemProxy.id,
      Facts.coreStatus.id,
      Facts.ownProxyPort.id,
      Facts.mixedPort.id,
    ],
    titleKey: 'doctorDeadProxyTitle',
    detailKey: 'doctorDeadProxyDetail',
    args: {'address': '${proxy.host}:$port'},
    remedyIds: [ours ? 'proxy.clearOwn' : 'proxy.clear'],
  );
}

/// An empty address means the proxy is off although the app turned it on.
Finding? proxyTakenRule(DiagnosticSnapshot snapshot) {
  final proxy = snapshot.valueOf(Facts.systemProxy);
  final mixedPort = snapshot.valueOf(Facts.mixedPort);
  if (proxy == null ||
      mixedPort == null ||
      snapshot.valueOf(Facts.systemProxyWanted) != true ||
      snapshot.valueOf(Facts.coreStatus) != CoreStatus.connected) {
    return null;
  }
  final intact =
      proxy.enabled && isLoopbackHost(proxy.host) && proxy.port == mixedPort;
  if (intact) return null;
  return Finding(
    id: 'env.proxyTaken',
    severity: CheckSeverity.critical,
    cause: FailureCause.systemProxyBroken,
    evidence: [
      Facts.systemProxy.id,
      Facts.systemProxyWanted.id,
      Facts.mixedPort.id,
      Facts.coreStatus.id,
    ],
    titleKey: 'doctorProxyTakenTitle',
    detailKey: proxy.enabled
        ? 'doctorProxyTakenDetail'
        : 'doctorProxyOffDetail',
    args: {if (proxy.enabled) 'address': '${proxy.host}:${proxy.port}'},
    remedyIds: const ['proxy.reapply'],
  );
}

Finding? portTakenRule(DiagnosticSnapshot snapshot) {
  final ports = snapshot.valueOf(Facts.ports);
  if (ports == null) return null;
  final blocked = [
    for (final port in ports)
      if ((port.listening && !port.ours) || port.reserved) port,
  ];
  if (blocked.isEmpty) return null;
  final port =
      blocked.where((p) => p.role == PortRole.mixed).firstOrNull ??
      blocked.first;
  return Finding(
    id: 'env.portTaken',
    severity: CheckSeverity.critical,
    cause: FailureCause.portTaken,
    evidence: [Facts.ports.id],
    titleKey: 'doctorPortTakenTitle',
    detailKey: port.reserved
        ? 'doctorPortReservedDetail'
        : 'doctorPortTakenDetail',
    args: {'port': port.port, if (!port.reserved) 'owner': port.owner},
    remedyIds: port.role == PortRole.mixed
        ? const ['config.freePort']
        : const [],
  );
}

Finding? deadDnsRule(DiagnosticSnapshot snapshot) {
  if (snapshot.valueOf(Facts.systemDns)?.deadLoopback != true) return null;
  return Finding(
    id: 'env.deadDns',
    severity: CheckSeverity.critical,
    cause: FailureCause.dnsFailed,
    evidence: [Facts.systemDns.id],
    titleKey: 'doctorDeadDnsTitle',
    detailKey: 'doctorDeadDnsDetail',
  );
}
