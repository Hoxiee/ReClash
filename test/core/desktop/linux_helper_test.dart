import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/common/util/constant.dart';
import 'package:reclash/core/desktop/helper_client.dart';
import 'package:reclash/core/desktop/linux_helper.dart';

void main() {
  late Directory bundle;
  late LinuxHelperEnvironment environment;
  late String helperHash;

  setUp(() async {
    bundle = await Directory.systemTemp.createTemp('linux-helper-test-');
    environment = LinuxHelperEnvironment(
      uid: 1000,
      bundleDirectory: bundle.path,
    );
    final helper = utf8.encode('helper fixture');
    final core = utf8.encode('core fixture');
    helperHash = sha256.convert(helper).toString();
    await File('${bundle.path}/$appHelperService').writeAsBytes(helper);
    await File('${bundle.path}/${appName}Core').writeAsBytes(core);
    await File('${bundle.path}/manifest.json').writeAsString(
      jsonEncode({
        'coreSha256': sha256.convert(core).toString(),
        'helperSha256': helperHash,
      }),
    );
  });

  tearDown(() => bundle.delete(recursive: true));

  test('resolves a stable installed path outside the AppImage mount', () async {
    expect(environment.socketPath, '/run/reclash-helper-1000/helper.sock');
    expect(
      await environment.installedHelperPath(),
      '/opt/reclash-helper/1000/$helperHash/$appHelperService',
    );
  });

  test('stages both verified binaries without modifying the bundle', () async {
    final stage = await environment.stageBundle();
    addTearDown(() => stage.delete(recursive: true));
    expect(stage.path, isNot(startsWith(bundle.path)));
    for (final name in [appHelperService, '${appName}Core']) {
      expect(
        await File('${stage.path}/$name').readAsBytes(),
        await File('${bundle.path}/$name').readAsBytes(),
      );
    }
  });

  test('rejects a corrupted Core before elevation', () async {
    await File('${bundle.path}/${appName}Core').writeAsString('corrupt');
    await expectLater(environment.stageBundle(), throwsFormatException);
  });

  test('rejects a corrupted Helper before elevation', () async {
    await File('${bundle.path}/$appHelperService').writeAsString('corrupt');
    await expectLater(environment.stageBundle(), throwsFormatException);
  });

  test('rejects missing Helper metadata', () async {
    await File('${bundle.path}/manifest.json').writeAsString('{}');
    await expectLater(environment.installedHelperPath(), throwsFormatException);
    await expectLater(environment.stageBundle(), throwsFormatException);
  });

  test('speaks protocol 6 over a Unix socket without a TCP listener', () async {
    final socket = '${bundle.path}/helper.sock';
    final server = await HttpServer.bind(
      InternetAddress(socket, type: InternetAddressType.unix),
      0,
    );
    addTearDown(() => server.close(force: true));
    final expectedPath = await environment.installedHelperPath();
    final coreHash = sha256.convert(utf8.encode('core fixture')).toString();
    server.listen((request) async {
      expect(request.uri.path, '/ping');
      expect(request.uri.queryParameters['coreSha256'], coreHash);
      request.response.headers.set(
        helperProtocolVersionHeader,
        helperProtocolVersion,
      );
      request.response.write(expectedPath);
      await request.response.close();
    });
    final client = HelperClient(
      unixSocketPath: socket,
      expectedHelperPath: environment.installedHelperPath,
      readCoreSha256: () async => coreHash,
    );
    expect(
      await client.readiness(timeout: const Duration(seconds: 2)),
      HelperReadiness.ready,
    );
  }, skip: !Platform.isLinux);

  test('never installs for root', () async {
    final root = LinuxHelperEnvironment(uid: 0, bundleDirectory: bundle.path);
    await expectLater(root.installedHelperPath(), throwsFormatException);
    await expectLater(root.stageBundle(), throwsFormatException);
  });
}
