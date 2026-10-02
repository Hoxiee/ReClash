import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/core/controller.dart';
import 'package:reclash/core/interface.dart';

class _MockHandler extends Mock implements CoreHandlerInterface {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory directory;
  late Completer<Directory> originalDataDir;
  late CoreController controller;
  late _MockHandler handler;

  setUp(() {
    directory = Directory.systemTemp.createTempSync('runtime-config-test-');
    originalDataDir = appPath.dataDir;
    appPath.dataDir = Completer<Directory>()..complete(directory);
    handler = _MockHandler();
    controller = CoreController.scoped(handler);
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
      verifyZeroInteractions(handler);
    },
  );

  test('a missing generated configuration remains a read error', () async {
    await expectLater(
      controller.getAppliedConfigContent(),
      throwsA(isA<FileSystemException>()),
    );
    verifyZeroInteractions(handler);
  });
}
