import 'dart:convert';
import 'dart:io';

import 'package:reclash/core/method.dart';
import 'package:reclash/core/spill.dart';
import 'package:reclash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';

import '../helpers/app_paths.dart';

/// A model an isolate can be sent, so a spilled answer can prove it ran there.
Object? _tagged(Object? result) => {'tagged': result};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory home;
  late Directory spillDirectory;

  setUp(() async {
    home = Directory.systemTemp.createTempSync('spill_test');
    await useAppPaths(home);
    spillDirectory = Directory(join(home.path, coreSpillDirectoryName))
      ..createSync();
  });

  tearDown(() => home.deleteSync(recursive: true));

  File spill(Directory directory, Map<String, Object?> envelope) {
    return File(join(directory.path, '1.json'))
      ..writeAsStringSync(json.encode(envelope));
  }

  test('an answer sent inline passes through', () async {
    const response = CoreMethodResponse(id: '1', result: 'inline');

    expect(await resolveSpilledResponse(response), same(response));
  });

  test('reads a spilled answer and deletes its file', () async {
    final file = spill(spillDirectory, {
      'id': '2',
      'result': {'mode': 'rule'},
    });

    final response = await resolveSpilledResponse(
      CoreMethodResponse(id: '2', file: file.path),
    );

    expect(response.id, '2');
    expect(response.unwrap<Map<String, dynamic>>(), {'mode': 'rule'});
    expect(file.existsSync(), isFalse);
  });

  test('a spilled connection list arrives parsed', () async {
    final file = spill(spillDirectory, {
      'id': '4',
      'result': {
        'connections': [
          {
            'id': 'c1',
            'metadata': {'network': 'tcp'},
            'start': '2026-01-01',
            'chains': ['DIRECT'],
            'rule': 'MATCH',
            'rulePayload': '',
          },
        ],
      },
    });

    final response = await resolveSpilledResponse(
      CoreMethodResponse(id: '4', file: file.path),
      model: coreResultModelOf(CoreMethod.getConnections),
    );

    expect(response.unwrap<List<TrackerInfo>>()?.single.id, 'c1');
  });

  test('a model decodes a result its transport read inline', () {
    final response = withResultModel(
      coreResultModelOf(CoreMethod.getConnections),
      {
        'id': '9',
        'result': {
          'connections': [
            {
              'id': 'c9',
              'metadata': {'network': 'tcp'},
              'start': '2026-01-01',
              'chains': ['DIRECT'],
              'rule': 'MATCH',
              'rulePayload': '',
            },
          ],
        },
      },
    );

    expect(response['result'], isA<List<TrackerInfo>>());
    expect((response['result'] as List<TrackerInfo>).single.id, 'c9');
  });

  test('a model leaves an error or a spilled envelope untouched', () {
    final model = coreResultModelOf(CoreMethod.getConnections);
    const failed = <String, Object?>{
      'error': {'code': 'unavailable', 'message': 'core down'},
      'result': 'inline',
    };
    const spilled = <String, Object?>{'file': '1.json', 'result': null};

    final plain = <String, Object?>{
      'result': {'mode': 'rule'},
    };

    expect(withResultModel(model, failed), same(failed));
    expect(withResultModel(model, spilled), same(spilled));
    expect(withResultModel(null, plain), same(plain));
  });

  test('only a method with a model has one', () {
    expect(coreResultModelOf(CoreMethod.getConnections), isNotNull);
    expect(coreResultModelOf(CoreMethod.getConfig), isNull);
  });

  test('the isolate threshold is 50 KiB', () {
    expect(coreIsolateDecodeBytes, 50 * 1024);
  });

  test('a spilled answer runs the model it was handed', () async {
    final file = spill(spillDirectory, {
      'id': '10',
      'result': {'mode': 'rule'},
    });

    final response = await resolveSpilledResponse(
      CoreMethodResponse(id: '10', file: file.path),
      model: _tagged,
    );

    expect(response.unwrap<Map<String, dynamic>>(), {
      'tagged': {'mode': 'rule'},
    });
  });

  test('refuses a file outside the spill directory', () async {
    final file = spill(home, {'id': '3', 'result': 'secret'});

    final response = await resolveSpilledResponse(
      CoreMethodResponse(id: '3', file: file.path),
    );

    expect(
      () => response.unwrap<Object?>(),
      throwsA(
        isA<CoreMethodException>().having((e) => e.code, 'code', 'spill_error'),
      ),
    );
    expect(file.existsSync(), isTrue);
  });

  test('a missing file fails the call instead of the transport', () async {
    final response = await resolveSpilledResponse(
      CoreMethodResponse(id: '4', file: join(spillDirectory.path, 'gone.json')),
    );

    expect(response.error?.code, 'spill_error');
  });

  test('reads a file the Core built there as text and deletes it', () async {
    final built = File(join(spillDirectory.path, 'built.yaml'))
      ..writeAsStringSync('mode: rule\n');

    expect(await readSpilledText(built.path), 'mode: rule\n');
    expect(built.existsSync(), isFalse);
  });

  test('refuses to read text outside the spill directory', () async {
    final outside = File(join(home.path, 'built.yaml'))
      ..writeAsStringSync('secret');

    await expectLater(
      readSpilledText(outside.path),
      throwsA(
        isA<CoreMethodException>().having((e) => e.code, 'code', 'spill_error'),
      ),
    );
    expect(outside.existsSync(), isTrue);
  });

  test('discarding deletes only a spilled file', () async {
    final spilled = spill(spillDirectory, {'id': '5', 'result': null});
    final outside = spill(home, {'id': '6', 'result': null});

    await discardSpilledResponse(CoreMethodResponse(file: spilled.path));
    await discardSpilledResponse(CoreMethodResponse(file: outside.path));

    expect(spilled.existsSync(), isFalse);
    expect(outside.existsSync(), isTrue);
  });

  test('discarding a late built profile deletes the file it names', () async {
    final built = File(join(spillDirectory.path, 'built.yaml'))
      ..writeAsStringSync('proxies: []');

    await discardSpilledResponse(
      CoreMethodResponse(id: '7', result: built.path),
    );
    await discardSpilledResponse(
      const CoreMethodResponse(id: '8', result: 'not a path'),
    );

    expect(built.existsSync(), isFalse);
  });
}
