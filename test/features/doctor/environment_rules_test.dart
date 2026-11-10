import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/features/doctor/cause.dart';
import 'package:reclash/features/doctor/finding.dart';
import 'package:reclash/features/doctor/rules/rules.dart';
import 'package:reclash/features/doctor/snapshot.dart';

final _now = DateTime(2026, 11, 3, 12);

DiagnosticSnapshot _with(Map<FactKey<Object>, Object> facts) {
  var snapshot = DiagnosticSnapshot(takenAt: _now);
  for (final MapEntry(:key, :value) in facts.entries) {
    snapshot = _put(snapshot, key, value);
  }
  return snapshot;
}

DiagnosticSnapshot _put(
  DiagnosticSnapshot snapshot,
  FactKey<Object> key,
  Object value,
) {
  DiagnosticSnapshot typed<T extends Object>() =>
      snapshot.withFact(FactKey<T>(key.id), Fact<T>(value as T, at: _now));
  return switch (value) {
    bool() => typed<bool>(),
    int() => typed<int>(),
    String() => typed<String>(),
    CoreStatus() => typed<CoreStatus>(),
    HostsFact() => typed<HostsFact>(),
    SoftwareFact() => typed<SoftwareFact>(),
    TunnelsFact() => typed<TunnelsFact>(),
    SystemProxyFact() => typed<SystemProxyFact>(),
    SystemDnsFact() => typed<SystemDnsFact>(),
    List<PortFact>() => typed<List<PortFact>>(),
    _ => throw ArgumentError('unsupported fact $key'),
  };
}

HostsEntry _entry(String domain, DomainRole role, {int line = 1}) => HostsEntry(
  line: line,
  text: '1.2.3.4 $domain',
  domain: domain,
  address: '1.2.3.4',
  role: role,
);

HostsFact _hosts(
  List<HostsEntry> entries, {
  int lines = 10,
  List<String>? markers,
}) => HostsFact(
  path: '/etc/hosts',
  lineCount: lines,
  entries: entries,
  markers: markers ?? const [],
);

const _theirs = TunnelAdapter(
  name: 'Wintun',
  kind: TunnelKind.wintun,
  description: 'Foo Tunnel',
  defaultRoute: true,
);
const _ours = TunnelAdapter(name: 'ReClash', kind: TunnelKind.wintun);

void main() {
  group('hostsServerRule', () {
    test('raises for a subscription entry and names the first domain', () {
      final finding = hostsServerRule(
        _with({
          Facts.hosts: _hosts([
            _entry('sub.example.com', DomainRole.subscription),
            _entry('www.gstatic.com', DomainRole.test, line: 2),
          ]),
          Facts.useSystemHosts: true,
        }),
      )!;

      expect(finding.id, 'env.hostsServer');
      expect(finding.severity, CheckSeverity.critical);
      expect(finding.cause, FailureCause.hostsOverride);
      expect(finding.args, {'domain': 'sub.example.com', 'count': 2});
      expect(finding.remedyIds, ['system.openHosts']);
    });

    test('offers ignoring system hosts when only the test host is hit', () {
      final finding = hostsServerRule(
        _with({
          Facts.hosts: _hosts([_entry('www.gstatic.com', DomainRole.test)]),
        }),
      )!;

      expect(finding.remedyIds, ['dns.ignoreSystemHosts', 'system.openHosts']);
    });

    test('ignores the test host once the Core ignores hosts', () {
      expect(
        hostsServerRule(
          _with({
            Facts.hosts: _hosts([_entry('www.gstatic.com', DomainRole.test)]),
            Facts.useSystemHosts: false,
          }),
        ),
        isNull,
      );
    });

    test('is silent without the hosts fact or relevant entries', () {
      expect(hostsServerRule(_with({})), isNull);
      expect(
        hostsServerRule(
          _with({
            Facts.hosts: _hosts([_entry('x.com', DomainRole.service)]),
          }),
        ),
        isNull,
      );
    });
  });

  group('hostsServicesRule', () {
    final services = _hosts([
      for (final (i, d) in ['a.com', 'b.com', 'c.com', 'd.com'].indexed)
        _entry(d, DomainRole.service, line: i + 1),
    ]);

    test('lists up to three domains while the Core reads hosts', () {
      final finding = hostsServicesRule(_with({Facts.hosts: services}))!;

      expect(finding.id, 'env.hostsServices');
      expect(finding.severity, CheckSeverity.warning);
      expect(finding.args, {'domains': 'a.com, b.com, c.com', 'count': 4});
      expect(finding.remedyIds, ['dns.ignoreSystemHosts', 'system.openHosts']);
    });

    test('stays silent when the Core ignores hosts and TUN is off', () {
      expect(
        hostsServicesRule(
          _with({Facts.hosts: services, Facts.useSystemHosts: false}),
        ),
        isNull,
      );
    });

    test('raises under TUN even when the Core ignores hosts', () {
      final finding = hostsServicesRule(
        _with({
          Facts.hosts: services,
          Facts.useSystemHosts: false,
          Facts.tunEnabled: true,
        }),
      )!;

      expect(finding.remedyIds, ['system.openHosts']);
    });

    test('offers no ignore remedy under TUN', () {
      final finding = hostsServicesRule(
        _with({Facts.hosts: services, Facts.tunEnabled: true}),
      )!;

      expect(finding.remedyIds, ['system.openHosts']);
    });

    test('is silent without the hosts fact', () {
      expect(hostsServicesRule(_with({})), isNull);
    });
  });

  group('hostsLargeRule', () {
    test('tips above ten thousand lines only', () {
      final big = hostsLargeRule(
        _with({Facts.hosts: _hosts([], lines: 10001)}),
      )!;

      expect(big.severity, CheckSeverity.tip);
      expect(big.cause, isNull);
      expect(big.args, {'lines': 10001});
      expect(
        hostsLargeRule(_with({Facts.hosts: _hosts([], lines: 10000)})),
        isNull,
      );
      expect(hostsLargeRule(_with({})), isNull);
    });
  });

  group('interceptorRule', () {
    test('names a DPI bypass tool found by its process', () {
      final finding = interceptorRule(
        _with({
          Facts.software: const SoftwareFact(processes: ['goodbyedpi.exe']),
        }),
      )!;

      expect(finding.cause, FailureCause.trafficIntercepted);
      expect(finding.detailKey, 'doctorInterceptorDetail');
      expect(finding.args, {'name': 'GoodbyeDPI'});
      expect(finding.remedyIds, isEmpty);
    });

    test('names it by a hosts marker', () {
      final finding = interceptorRule(
        _with({
          Facts.hosts: _hosts([], markers: ['# zapret block']),
        }),
      )!;

      expect(finding.args, {'name': 'zapret'});
    });

    test('falls back to the unnamed message for a shared driver', () {
      final finding = interceptorRule(
        _with({
          Facts.software: const SoftwareFact(drivers: ['windivert']),
        }),
      )!;

      expect(finding.detailKey, 'doctorInterceptorUnknownDetail');
      expect(finding.args, isEmpty);
    });

    test('ignores a VPN client and a missing fact', () {
      expect(
        interceptorRule(
          _with({
            Facts.software: const SoftwareFact(processes: ['happ.exe']),
          }),
        ),
        isNull,
      );
      expect(interceptorRule(_with({})), isNull);
    });
  });

  group('foreignTunnelRule', () {
    Map<FactKey<Object>, Object> base({TunnelsFact? tunnels}) => {
      Facts.tunEnabled: true,
      Facts.coreStatus: CoreStatus.connected,
      Facts.tunnels: tunnels ?? const TunnelsFact(foreign: [_theirs]),
    };

    test('raises when a foreign adapter holds the default route', () {
      final finding = foreignTunnelRule(_with(base()))!;

      expect(finding.id, 'env.foreignTunnel');
      expect(finding.cause, FailureCause.tunnelTaken);
      expect(finding.args, {'name': 'Foo Tunnel'});
      expect(finding.remedyIds, ['tunnel.restart']);
    });

    test('raises when ours is up but the route leaves elsewhere', () {
      expect(
        foreignTunnelRule(
          _with(
            base(
              tunnels: const TunnelsFact(
                ours: _ours,
                foreign: [_theirs],
                routedThroughOurs: false,
              ),
            ),
          ),
        ),
        isNotNull,
      );
    });

    test('stays silent when our tunnel carries the route', () {
      expect(
        foreignTunnelRule(
          _with(
            base(
              tunnels: const TunnelsFact(
                ours: _ours,
                foreign: [_theirs],
                routedThroughOurs: true,
              ),
            ),
          ),
        ),
        isNull,
      );
    });

    test('stays silent with TUN off, a stopped Core or missing facts', () {
      expect(
        foreignTunnelRule(_with({...base(), Facts.tunEnabled: false})),
        isNull,
      );
      expect(
        foreignTunnelRule(
          _with({...base(), Facts.coreStatus: CoreStatus.disconnected}),
        ),
        isNull,
      );
      expect(foreignTunnelRule(_with({})), isNull);
    });

    test('names a catalogue app by its own name', () {
      final finding = foreignTunnelRule(
        _with(
          base(
            tunnels: const TunnelsFact(
              foreign: [
                TunnelAdapter(
                  name: 'hiddify-tun',
                  kind: TunnelKind.wintun,
                  defaultRoute: true,
                ),
              ],
            ),
          ),
        ),
      )!;

      expect(finding.args, {'name': 'Hiddify'});
    });
  });

  group('tunnelNameRule', () {
    test('raises when a foreign adapter has our device name', () {
      final finding = tunnelNameRule(
        _with({
          Facts.tunEnabled: true,
          Facts.tunDevice: 'wintun',
          Facts.tunnels: const TunnelsFact(foreign: [_theirs]),
        }),
      )!;

      expect(finding.id, 'env.tunnelName');
      expect(finding.args, {'name': 'Wintun'});
      expect(finding.remedyIds, ['tunnel.freeDeviceName']);
    });

    test('stays silent for another name, TUN off or missing facts', () {
      final facts = <FactKey<Object>, Object>{
        Facts.tunEnabled: true,
        Facts.tunDevice: 'ReClash',
        Facts.tunnels: const TunnelsFact(foreign: [_theirs]),
      };
      expect(tunnelNameRule(_with(facts)), isNull);
      expect(
        tunnelNameRule(
          _with({...facts, Facts.tunDevice: 'Wintun', Facts.tunEnabled: false}),
        ),
        isNull,
      );
      expect(tunnelNameRule(_with({})), isNull);
    });
  });

  group('deadProxyRule', () {
    const dead = SystemProxyFact(
      enabled: true,
      host: '127.0.0.1',
      port: 7890,
      reachable: false,
    );
    Map<FactKey<Object>, Object> facts({
      SystemProxyFact proxy = dead,
      CoreStatus status = CoreStatus.disconnected,
    }) => {Facts.systemProxy: proxy, Facts.coreStatus: status};

    test('offers the own-proxy remedy when the record matches', () {
      final finding = deadProxyRule(
        _with({...facts(), Facts.ownProxyPort: 7890}),
      )!;

      expect(finding.id, 'env.deadProxy');
      expect(finding.cause, FailureCause.systemProxyBroken);
      expect(finding.args, {'address': '127.0.0.1:7890'});
      expect(finding.remedyIds, ['proxy.clearOwn']);
    });

    test('offers the foreign remedy for a proxy that is not ours', () {
      expect(deadProxyRule(_with(facts()))!.remedyIds, ['proxy.clear']);
      expect(
        deadProxyRule(_with({...facts(), Facts.ownProxyPort: 7891}))!.remedyIds,
        ['proxy.clear'],
      );
    });

    test('stays silent for the live mixed-port listener while connected', () {
      expect(
        deadProxyRule(
          _with({
            ...facts(status: CoreStatus.connected),
            Facts.mixedPort: 7890,
          }),
        ),
        isNull,
      );
    });

    test('still raises when disconnected or on a foreign port', () {
      expect(
        deadProxyRule(_with({...facts(), Facts.mixedPort: 7890})),
        isNotNull,
      );
      expect(
        deadProxyRule(
          _with({
            ...facts(status: CoreStatus.connected),
            Facts.mixedPort: 7891,
          }),
        ),
        isNotNull,
      );
    });

    test('stays silent while the Core is connecting, or the proxy lives', () {
      expect(
        deadProxyRule(_with(facts(status: CoreStatus.connecting))),
        isNull,
      );
      expect(
        deadProxyRule(
          _with(
            facts(
              proxy: const SystemProxyFact(
                enabled: true,
                host: '127.0.0.1',
                port: 7890,
                reachable: true,
              ),
            ),
          ),
        ),
        isNull,
      );
      expect(deadProxyRule(_with({})), isNull);
    });
  });

  group('proxyTakenRule', () {
    Map<FactKey<Object>, Object> facts(SystemProxyFact proxy) => {
      Facts.systemProxy: proxy,
      Facts.systemProxyWanted: true,
      Facts.mixedPort: 7890,
      Facts.coreStatus: CoreStatus.connected,
    };

    test('raises when another address replaced ours', () {
      final finding = proxyTakenRule(
        _with(
          facts(
            const SystemProxyFact(enabled: true, host: '10.0.0.1', port: 8080),
          ),
        ),
      )!;

      expect(finding.id, 'env.proxyTaken');
      expect(finding.args, {'address': '10.0.0.1:8080'});
      expect(finding.remedyIds, ['proxy.reapply']);
    });

    test('raises when the proxy was switched off', () {
      final finding = proxyTakenRule(
        _with(facts(const SystemProxyFact(enabled: false))),
      )!;

      expect(finding.detailKey, 'doctorProxyOffDetail');
      expect(finding.args, isEmpty);
    });

    test('stays silent when ours is in place or not wanted', () {
      const ours = SystemProxyFact(
        enabled: true,
        host: 'localhost',
        port: 7890,
      );
      expect(proxyTakenRule(_with(facts(ours))), isNull);
      expect(
        proxyTakenRule(
          _with({
            ...facts(const SystemProxyFact(enabled: false)),
            Facts.systemProxyWanted: false,
          }),
        ),
        isNull,
      );
      expect(proxyTakenRule(_with({})), isNull);
    });
  });

  group('portTakenRule', () {
    test('names the owner of a foreign listener', () {
      final finding = portTakenRule(
        _with({
          Facts.ports: const [
            PortFact(
              port: 7890,
              role: PortRole.mixed,
              listening: true,
              owner: 'nginx',
            ),
          ],
        }),
      )!;

      expect(finding.id, 'env.portTaken');
      expect(finding.cause, FailureCause.portTaken);
      expect(finding.titleKey, 'doctorPortTakenTitle');
      expect(finding.detailKey, 'doctorPortTakenDetail');
      expect(finding.args, {'port': 7890, 'owner': 'nginx'});
      expect(finding.remedyIds, ['config.freePort']);
    });

    test('uses the reserved message for an excluded range', () {
      final finding = portTakenRule(
        _with({
          Facts.ports: const [
            PortFact(port: 7890, role: PortRole.mixed, reserved: true),
          ],
        }),
      )!;

      expect(finding.detailKey, 'doctorPortReservedDetail');
      expect(finding.args, {'port': 7890});
    });

    test('offers no port change for the controller port', () {
      final finding = portTakenRule(
        _with({
          Facts.ports: const [
            PortFact(port: 9090, role: PortRole.controller, listening: true),
          ],
        }),
      )!;

      expect(finding.remedyIds, isEmpty);
    });

    test('stays silent for our own listener and missing facts', () {
      expect(
        portTakenRule(
          _with({
            Facts.ports: const [
              PortFact(
                port: 7890,
                role: PortRole.mixed,
                listening: true,
                ours: true,
              ),
            ],
          }),
        ),
        isNull,
      );
      expect(portTakenRule(_with({})), isNull);
    });
  });

  group('deadDnsRule', () {
    test('raises for dead loopback resolvers only', () {
      final finding = deadDnsRule(
        _with({Facts.systemDns: const SystemDnsFact(deadLoopback: true)}),
      )!;

      expect(finding.id, 'env.deadDns');
      expect(finding.cause, FailureCause.dnsFailed);
      expect(finding.remedyIds, isEmpty);
      expect(
        deadDnsRule(_with({Facts.systemDns: const SystemDnsFact()})),
        isNull,
      );
      expect(deadDnsRule(_with({})), isNull);
    });
  });

  test('every environment rule is registered', () {
    for (final rule in [
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
    ]) {
      expect(defaultRules, contains(rule));
    }
  });
}
