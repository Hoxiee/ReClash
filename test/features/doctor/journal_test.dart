import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/features/doctor/cause.dart';
import 'package:reclash/features/doctor/finding.dart';
import 'package:reclash/features/doctor/journal.dart';

final _at = DateTime(2026, 10, 29, 12);

DiagnosticEvent _event(
  String subject, {
  DiagnosticEventKind kind = DiagnosticEventKind.findingRaised,
}) => DiagnosticEvent(kind: kind, at: _at, subject: subject);

String _line(DiagnosticEvent event) => jsonEncode(event.toJson());

DiagnosticEvent _decode(DiagnosticEvent event) =>
    DiagnosticEvent.fromJson(jsonDecode(_line(event)) as Map<String, Object?>);

void main() {
  group('DiagnosticJournal', () {
    test('publishes each record at once and persists it in order', () async {
      final store = MemoryIncidentStore();
      final journal = DiagnosticJournal(store);
      final published = <DiagnosticEvent>[];
      final subscription = journal.events.listen(published.add);
      final first = _event('config.directMode');
      final second = _event('device.clockSkew');

      final write = journal.record(first);
      expect(published, [first]);
      await write;
      await journal.record(second);

      expect(published, [first, second]);
      expect(store.incidents, [_line(first), _line(second)]);
      expect(await journal.history(), [first, second]);

      await subscription.cancel();
      await journal.close();
    });

    test('keeps only the newest events up to its capacity', () async {
      final store = MemoryIncidentStore();
      final journal = DiagnosticJournal(store, capacity: 3);
      final events = [for (var i = 0; i < 5; i++) _event('finding.$i')];

      for (final event in events) {
        await journal.record(event);
      }

      final kept = events.sublist(2);
      expect(await journal.history(), kept);
      expect(store.incidents, [for (final event in kept) _line(event)]);

      await journal.close();
    });

    test('loads stored history first and skips lines it cannot read', () async {
      final older = _event('device.clockSkew');
      final newer = _event(
        'config.directMode',
        kind: DiagnosticEventKind.findingCleared,
      );
      final store = MemoryIncidentStore([
        _line(older),
        'not json',
        _line(newer),
      ]);
      final journal = DiagnosticJournal(store);
      final fresh = _event('profile.subscription');

      await journal.record(fresh);

      expect(await journal.history(), [older, newer, fresh]);
      expect(store.incidents, [_line(older), _line(newer), _line(fresh)]);

      await journal.close();
    });

    test('round-trips an event with every optional field', () {
      final event = DiagnosticEvent(
        kind: DiagnosticEventKind.remedyApplied,
        at: _at,
        subject: 'config.ruleMode',
        severity: CheckSeverity.warning,
        cause: FailureCause.timeout,
        outcome: 'notFixed',
        detail: 'StateError: no permission',
      );

      expect(_decode(event), event);
    });

    test('round-trips an event without optional fields', () {
      final event = DiagnosticEvent(
        kind: DiagnosticEventKind.disconnected,
        at: _at,
        subject: 'disconnected',
      );

      expect(_decode(event), event);
    });

    test('ignores records made after close', () async {
      final store = MemoryIncidentStore();
      final journal = DiagnosticJournal(store);
      final published = <DiagnosticEvent>[];
      final subscription = journal.events.listen(published.add);

      await journal.close();
      await journal.record(_event('late'));

      expect(published, isEmpty);
      expect(store.incidents, isEmpty);
      expect(await journal.history(), isEmpty);

      await subscription.cancel();
    });
  });
}
