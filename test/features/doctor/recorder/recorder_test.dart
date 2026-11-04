import 'dart:io';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:reclash/enum/enum.dart';
import 'package:reclash/features/doctor/recorder/recorder.dart';
import 'package:reclash/models/models.dart';

Log _log(String payload, [LogLevel level = LogLevel.info]) =>
    Log(payload: payload, logLevel: level, dateTime: '');

void main() {
  late Directory root;
  late DateTime clock;

  setUp(() {
    root = Directory.systemTemp.createTempSync('recorder_test');
    clock = DateTime.utc(2026, 11, 4, 12);
  });

  tearDown(() => root.deleteSync(recursive: true));

  FilePassiveRecorder make() =>
      FilePassiveRecorder(directory: () async => root, now: () => clock);

  test('batches lines until 30 s pass or an error arrives', () {
    fakeAsync((async) {
      final recorder = make()..start();
      recorder.addLog(_log('one'));
      async.elapse(const Duration(seconds: 29));
      async.flushMicrotasks();
      expect(recorder.writes, 0);

      async.elapse(const Duration(seconds: 2));
      async.flushMicrotasks();
      expect(recorder.writes, 1);

      recorder.addLog(_log('two'));
      recorder.addLog(_log('boom', LogLevel.error));
      async.elapse(const Duration(milliseconds: 900));
      async.flushMicrotasks();
      expect(recorder.writes, 1);
      async.elapse(const Duration(milliseconds: 200));
      async.flushMicrotasks();
      expect(recorder.writes, 2);
      recorder.dispose();
    });
  });

  test('starts no timer before start or with nothing buffered', () {
    fakeAsync((async) {
      final recorder = make()..addLog(_log('early'));
      expect(async.pendingTimers, isEmpty);
      recorder.start();
      expect(async.pendingTimers, hasLength(1));
      async.elapse(const Duration(seconds: 31));
      async.flushMicrotasks();
      expect(async.pendingTimers, isEmpty);
      recorder.dispose();
    });
  });

  test('rotates past 1 MB and keeps at most two segments in order', () async {
    final recorder = make()..start();
    final big = 'x' * 1000;
    for (var i = 0; i < 2500; i++) {
      recorder.addLog(_log('$i $big'));
      if (i % 500 == 499) await recorder.flush();
    }
    await recorder.flush();
    final dir = Directory(p.join(root.path, 'diagnostics', 'logs'));
    final total = dir.listSync().whereType<File>().fold<int>(
      0,
      (sum, file) => sum + file.lengthSync(),
    );
    expect(total, lessThanOrEqualTo(2 * 1024 * 1024 + 2048));
    expect(dir.listSync(), hasLength(2));

    recorder.addLog(_log('tail'));
    final lines = await recorder.logLines();
    expect(lines.last, endsWith('INFO tail'));
    final numbers = [
      for (final line in lines.where((l) => !l.endsWith('tail')))
        int.parse(line.split(' ')[2]),
    ];
    expect(numbers, orderedEquals([...numbers]..sort()));
    expect(numbers.last, 2499);
    recorder.dispose();
  });

  test('prunes events older than seven days', () async {
    final first = make()..start();
    clock = DateTime.utc(2026, 10, 20);
    first.addEvent('heal', {'a': 1});
    await first.flush();
    first.dispose();

    clock = DateTime.utc(2026, 11, 4);
    final second = make()..start();
    second.addEvent('coreExit');
    await second.flush();
    final events = await second.events(since: DateTime.utc(2026, 1, 1));
    expect(events.map((e) => e.kind), ['coreExit']);
    final file = File(p.join(root.path, 'diagnostics', 'events.jsonl'));
    expect(file.readAsLinesSync(), hasLength(1));
    expect(await second.events(since: DateTime.utc(2026, 11, 5)), isEmpty);
    second.dispose();
  });

  test('degrades to memory when the directory throws', () async {
    final recorder = FilePassiveRecorder(
      directory: () async => throw const FileSystemException('denied'),
    )..start();
    recorder.addLog(_log('kept'));
    recorder.addEvent('heal');
    await recorder.flush();
    expect(await recorder.logLines(), [contains('INFO kept')]);
    expect(await recorder.events(since: DateTime(2000)), hasLength(1));
    recorder.dispose();
  });
}
