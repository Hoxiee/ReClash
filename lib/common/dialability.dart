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

bool hasDialableNode(ConfigInspection inspection) {
  if (inspection.error != null) return true;
  if (inspection.providers) return true;
  return inspection.servers.any(_isDialableHost);
}

bool _isDialableHost(String server) {
  var host = server.trim().toLowerCase();
  if (host.isEmpty) return false;
  if (host.endsWith('.')) host = host.substring(0, host.length - 1);
  return !_undialableHostSuffixes.any(host.endsWith);
}
