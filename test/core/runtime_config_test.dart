import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/core/core.dart';

/// A concrete handler so the real [CoreHandlerActions.getAppliedConfigContent]
/// runs; any core round-trip would hit [invokeMethod] and flip [touchedCore].
class _FakeHandler extends CoreHandlerInterface {
  bool touchedCore = false;

  @override
  Future<T?> invokeMethod<T>({
    required CoreMethod method,
    Object? arguments,
    Duration? timeout,
  }) async {
    touchedCore = true;
    throw StateError('unexpected core call: ${method.name}');
  }

  @override
  Future<CoreLifecycleResult> start() => throw UnimplementedError();

  @override
  Future<CoreLifecycleResult> restart() => throw UnimplementedError();

  @override
  Future<CoreLifecycleResult> stop() => throw UnimplementedError();

  @override
  Future<CoreLifecycleResult> close() => throw UnimplementedError();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory directory;
  late Completer<Directory> originalDataDir;
  late _FakeHandler controller;

  setUp(() {
    directory = Directory.systemTemp.createTempSync('runtime-config-test-');
    originalDataDir = appPath.dataDir;
    appPath.dataDir = Completer<Directory>()..complete(directory);
    controller = _FakeHandler();
  });

  tearDown(() {
    appPath.dataDir = originalDataDir;
    directory.deleteSync(recursive: true);
  });

  test(
    'reads the generated YAML verbatim without consulting the core',
    () async {
      const yaml =
          '# generated config\nmode: rule\nmixed-port: 17890\n'
          'rules: ["MATCH,DIRECT"]\n';
      final file = File(await appPath.configFilePath);
      await file.writeAsString(yaml);

      expect(await controller.getAppliedConfigContent(), yaml);
      expect(await file.readAsString(), yaml);
      expect(controller.touchedCore, isFalse);
    },
  );

  test('a missing generated configuration remains a read error', () async {
    await expectLater(
      controller.getAppliedConfigContent(),
      throwsA(isA<FileSystemException>()),
    );
    expect(controller.touchedCore, isFalse);
  });
}
