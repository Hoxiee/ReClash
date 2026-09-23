library;

import 'package:reclash/models/models.dart';

// Suffixes (RFC 6762/2606/6761) no public DNS answers: panel-stub territory.
const _undialableHostSuffixes = {
  '.local',
  '.invalid',
  '.example',
  '.test',
  '.localhost',
};

const _subscriptionStubHosts = {
  '0.0.0.0',
  '0',
  '::',
  '::0',
  '0:0:0:0:0:0:0:0',
  '::1',
  '0:0:0:0:0:0:0:1',
  'localhost',
};

bool hasDialableNode(ConfigInspection inspection) {
  if (inspection.error != null) return true;
  if (inspection.providers) return true;
  return inspection.servers.any(_isDialableHost);
}

bool _isDialableHost(String server) {
  var host = server.trim().toLowerCase();
  if (host.isEmpty) return false;
  if (host.startsWith('[') && host.endsWith(']')) {
    host = host.substring(1, host.length - 1);
  }
  if (host.endsWith('.')) host = host.substring(0, host.length - 1);
  if (_subscriptionStubHosts.contains(host)) return false;
  if (_loopbackV4.hasMatch(host)) return false;
  return !_undialableHostSuffixes.any(host.endsWith);
}

final _loopbackV4 = RegExp(r'^127(\.\d{1,3}){3}$');
