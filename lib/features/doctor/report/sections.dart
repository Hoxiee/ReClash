import 'dart:io';

import '../finding.dart';
import '../journal.dart';
import '../path.dart';
import '../snapshot.dart';
import 'sources.dart';

String _iso(DateTime time) => time.toUtc().toIso8601String();

/// Any fact or argument as plain JSON.
Object? plainJson(Object? value) => switch (value) {
  null || bool() || num() || String() => value,
  Enum(:final name) => name,
  Duration() => value.inMilliseconds,
  DateTime() => _iso(value),
  Map() => {
    for (final MapEntry(:key, :value) in value.entries)
      '$key': plainJson(value),
  },
  Iterable() => [for (final item in value) plainJson(item)],
  SubscriptionFact() => {
    'profileId': value.profileId,
    'expiresAt': plainJson(value.expiresAt),
    'used': value.used,
    'total': value.total,
  },
  HostsFact() => {
    'path': value.path,
    'lineCount': value.lineCount,
    'entries': [
      for (final entry in value.entries)
        {
          'line': entry.line,
          'text': entry.text,
          'domain': entry.domain,
          'address': entry.address,
          'role': entry.role.name,
          'blackhole': entry.blackhole,
        },
    ],
    'markers': value.markers,
  },
  SoftwareFact() => {
    'services': value.services,
    'drivers': value.drivers,
    'processes': value.processes,
    'processesScanned': value.processesScanned,
  },
  TunnelAdapter() => {
    'name': value.name,
    'kind': value.kind.name,
    'description': value.description,
    'defaultRoute': value.defaultRoute,
    'metric': value.metric,
  },
  TunnelsFact() => {
    'ours': plainJson(value.ours),
    'foreign': plainJson(value.foreign),
    'routedThroughOurs': value.routedThroughOurs,
  },
  SystemProxyFact() => {
    'enabled': value.enabled,
    'host': value.host,
    'port': value.port,
    'pac': value.pac,
    'reachable': value.reachable,
  },
  PortFact() => {
    'port': value.port,
    'role': value.role.name,
    'listening': value.listening,
    'ours': value.ours,
    'reserved': value.reserved,
    'owner': value.owner,
  },
  SystemDnsFact() => {
    'servers': value.servers,
    'deadLoopback': value.deadLoopback,
  },
  _ => value.toString(),
};

Map<String, Object?> environmentJson(
  DiagnosticSnapshot snapshot, {
  List<NetworkInterface> interfaces = const [],
}) {
  final addresses = [for (final i in interfaces) ...i.addresses];
  return {
    'takenAt': _iso(snapshot.takenAt),
    'facts': {
      for (final id in snapshot.factIds)
        if (snapshot.fact<Object>(FactKey<Object>(id)) case final fact?)
          id: {
            'value': plainJson(fact.value),
            'at': _iso(fact.at),
            if (!fact.isFreshAt(snapshot.takenAt)) 'stale': true,
          },
    },
    'interfaces': [
      for (final i in interfaces)
        {
          'name': i.name,
          'addresses': [for (final a in i.addresses) a.address],
        },
    ],
    'ipv6': addresses.any(
      (a) => a.type == InternetAddressType.IPv6 && !a.isLinkLocal,
    ),
  };
}

const _remedyKinds = {
  DiagnosticEventKind.remedyApplied,
  DiagnosticEventKind.remedyUndone,
};

Map<String, Object?> incidentJson(DiagnosticEvent event) => {
  'kind': event.kind.name,
  'at': _iso(event.at),
  'subject': event.subject,
  'severity': ?event.severity?.name,
  'cause': ?event.cause?.id,
  'outcome': ?event.outcome,
  'detail': ?event.detail,
};

List<Map<String, Object?>> findingsJson(
  List<Finding> findings,
  List<DiagnosticEvent> incidents,
) => [
  for (final finding in [...findings]..sort(compareFindings))
    {
      'id': finding.id,
      'severity': finding.severity.name,
      'cause': finding.cause?.id,
      'title': finding.titleKey,
      'detail': finding.detailKey,
      'args': plainJson(finding.args),
      'evidence': finding.evidence,
      'remedies': finding.remedyIds,
      'tried': [
        for (final event in incidents)
          if (_remedyKinds.contains(event.kind) &&
              finding.remedyIds.contains(event.subject))
            {
              'remedy': event.subject,
              'action': event.kind == DiagnosticEventKind.remedyApplied
                  ? 'apply'
                  : 'undo',
              'outcome': event.outcome,
              'at': _iso(event.at),
              'detail': ?event.detail,
            },
      ],
    },
];

String pathVerdict(PathResult? path) {
  if (path == null || path.cancelled || !path.complete) return 'unknown';
  return path.failed == null ? 'pass' : 'fail';
}

Map<String, Object?> pathJson(PathResult path, {required bool fresh}) => {
  'scope': path.scope.name,
  'fresh': fresh,
  'verdict': pathVerdict(path),
  'startedAt': _iso(path.startedAt),
  if (path.finishedAt case final at?) 'finishedAt': _iso(at),
  'cancelled': path.cancelled,
  'durationMs': path.duration.inMilliseconds,
  'steps': [
    for (final step in path.steps)
      {
        'step': step.step.name,
        'status': step.status.name,
        'durationMs': ?step.duration?.inMilliseconds,
        'detail': ?step.detail,
        'cause': ?step.cause?.id,
      },
  ],
};

Map<String, Object?> sweepRowJson(SweepRow row) => {
  'node': row.node,
  'group': row.group,
  'type': row.type,
  'server': row.server,
  'port': row.port,
  'status': row.status.name,
  'resolveMs': row.resolveMs,
  'tcpMs': row.tcpMs,
  'delayMs': row.delayMs,
  'lastDelayMs': row.lastDelayMs,
};

const _eventGroups = {
  'heal': 'heals',
  'pathRun': 'pathRuns',
  'coreCrash': 'coreCrashes',
  'profileUpdate': 'profileUpdates',
};

Map<String, Object?> historyJson({
  required DateTime since,
  required List<DiagnosticEvent> incidents,
  required List<PassiveEvent> events,
}) {
  final groups = <String, List<Map<String, Object?>>>{
    for (final group in _eventGroups.values) group: [],
    'other': [],
  };
  for (final event in events) {
    groups[_eventGroups[event.kind] ?? 'other']!.add({
      'at': _iso(event.time),
      if (!_eventGroups.containsKey(event.kind)) 'kind': event.kind,
      ...event.data,
    });
  }
  if (groups['other']!.isEmpty) groups.remove('other');
  return {
    'since': _iso(since),
    'incidents': [
      for (final event in incidents)
        if (!event.at.isBefore(since)) incidentJson(event),
    ],
    ...groups,
  };
}
