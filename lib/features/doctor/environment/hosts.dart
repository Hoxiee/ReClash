import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'domains.dart';
import 'facts.dart';

const _markerLimit = 50;
const _markerLength = 120;

/// Beyond this a blocklist-sized file is parsed off the UI isolate.
const hostsIsolateBytes = 80000;

HostsFact parseHosts(String path, String text, RelevantDomains domains) {
  final lines = const LineSplitter().convert(text);
  final entries = <HostsEntry>[];
  final markers = <String>[];
  for (var i = 0; i < lines.length; i++) {
    final raw = lines[i];
    final trimmed = raw.trim();
    if (trimmed.isEmpty) continue;
    if (trimmed.startsWith('#')) {
      if (markers.length < _markerLimit) {
        markers.add(
          trimmed.length > _markerLength
              ? trimmed.substring(0, _markerLength)
              : trimmed,
        );
      }
      continue;
    }
    final hash = trimmed.indexOf('#');
    final tokens = (hash < 0 ? trimmed : trimmed.substring(0, hash))
        .split(RegExp(r'\s+'))
        .where((token) => token.isNotEmpty)
        .toList();
    if (tokens.length < 2 || InternetAddress.tryParse(tokens.first) == null) {
      continue;
    }
    for (final name in tokens.skip(1)) {
      final role = domains.roleOf(name);
      if (role == null) continue;
      entries.add(
        HostsEntry(
          line: i + 1,
          text: raw,
          domain: name.toLowerCase(),
          address: tokens.first.toLowerCase(),
          role: role,
        ),
      );
    }
  }
  return HostsFact(
    path: path,
    lineCount: lines.length,
    entries: entries,
    markers: markers,
  );
}

HostsFact parseHostsBytes(
  String path,
  Uint8List bytes,
  RelevantDomains domains,
) => parseHosts(path, utf8.decode(bytes, allowMalformed: true), domains);

Future<HostsFact> parseHostsOffIsolate(
  String path,
  Uint8List bytes,
  RelevantDomains domains,
) => bytes.length > hostsIsolateBytes
    ? Isolate.run(() => parseHostsBytes(path, bytes, domains))
    : Future.value(parseHostsBytes(path, bytes, domains));
