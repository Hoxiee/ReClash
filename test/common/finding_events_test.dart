import 'package:reclash/common/milestones/finding_events.dart';
import 'package:reclash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('New Year requires a continuous session across midnight', () {
    final before = DateTime(2026, 12, 31, 23, 59, 59);
    final after = DateTime(2027, 1, 1, 0, 0, 1);
    expect(sessionCrossedNewYear(before, after, 5000), isTrue);
    expect(sessionCrossedNewYear(before, after, 500), isFalse);
    expect(
      sessionCrossedNewYear(
        before,
        after.add(const Duration(minutes: 1)),
        90000,
      ),
      isFalse,
    );
    expect(sessionCrossedNewYear(after, before, 5000), isFalse);
  });

  test('only HTTP URLs on our exact loopback port match', () {
    for (final host in [
      '127.0.0.1',
      '127.0.0.2',
      'localhost',
      'localhost.',
      '[::1]',
    ]) {
      expect(
        profilePointsToListener('http://$host:7890/profile', 7890),
        isTrue,
      );
    }
    for (final url in [
      'http://127.0.0.1:7891',
      'https://example.org:7890',
      'http://localhost.example.org:7890',
      'file:///tmp/profile',
      'not a url',
    ]) {
      expect(profilePointsToListener(url, 7890), isFalse);
    }
    expect(profilePointsToListener('http://localhost:0', 0), isFalse);
  });

  test('storm requires every real path stage to be unavailable', () {
    final snapshot = DoctorSnapshot(
      supported: true,
      state: DoctorExamState.complete,
      health: DoctorHealth.broken,
      stages: [
        const DoctorStage(id: 'app', state: DoctorStageState.failed),
        for (final id in ['ingress', 'route', 'internet', 'response'])
          DoctorStage(id: id, state: DoctorStageState.consequence),
      ],
    );
    expect(allDoctorLayersFailed(snapshot), isTrue);
    expect(allDoctorLayersFailed(snapshot.copyWith(stages: [])), isFalse);
    expect(
      allDoctorLayersFailed(
        snapshot.copyWith(state: DoctorExamState.examining),
      ),
      isFalse,
    );
    expect(
      allDoctorLayersFailed(
        snapshot.copyWith(
          stages: [
            ...snapshot.stages.skip(1),
            const DoctorStage(id: 'app', state: DoctorStageState.passed),
          ],
        ),
      ),
      isFalse,
    );
    expect(allDoctorLayersFailed(snapshot.copyWith(freshUntil: 1)), isFalse);
  });
}
