import 'dart:io';

import 'package:reclash/models/models.dart';

bool sessionCrossedNewYear(DateTime previous, DateTime now, int runtimeMillis) {
  if (now.year != previous.year + 1 ||
      now.month != 1 ||
      now.day != 1 ||
      !now.isAfter(previous)) {
    return false;
  }
  final midnight = DateTime(now.year);
  return previous.isBefore(midnight) &&
      runtimeMillis > now.difference(midnight).inMilliseconds &&
      now.difference(previous) <= const Duration(seconds: 5);
}

bool allDoctorLayersFailed(DoctorSnapshot snapshot) {
  if (!snapshot.supported ||
      !snapshot.isFresh ||
      snapshot.state != DoctorExamState.complete ||
      snapshot.health != DoctorHealth.broken) {
    return false;
  }
  const requiredStages = {'app', 'ingress', 'route', 'internet', 'response'};
  return snapshot.stages.any(
        (stage) => stage.state == DoctorStageState.failed,
      ) &&
      requiredStages.every((id) {
        final stages = snapshot.stages.where((stage) => stage.id == id);
        return stages.length == 1 &&
            (stages.single.state == DoctorStageState.failed ||
                stages.single.state == DoctorStageState.consequence);
      });
}

bool profilePointsToListener(String url, int port) {
  final uri = Uri.tryParse(url);
  if (uri == null ||
      !['http', 'https'].contains(uri.scheme) ||
      port <= 0 ||
      uri.port != port) {
    return false;
  }
  final host = uri.host.replaceAll('[', '').replaceAll(']', '').toLowerCase();
  return host == 'localhost' ||
      host == 'localhost.' ||
      (InternetAddress.tryParse(host)?.isLoopback ?? false);
}
