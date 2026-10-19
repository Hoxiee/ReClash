import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:reclash/common/constant.dart';
import 'package:reclash/core/desktop/helper_client.dart';
import 'package:reclash/core/desktop/linux_helper.dart';

void main() {
  late Directory fixture;

  setUp(() async {
    fixture = await Directory.systemTemp.createTemp(
      'reclash-linux-helper-test-',
    );
  });

  tearDown(() async {
    await fixture.delete(recursive: true);
  });

  Future<Directory> stagedFixture() async {
    final directory = await Directory(p.join(fixture.path, 'stage')).create();
    for (final name in [appHelperService, 'ReClashCore', coreManifestName]) {
      await File(p.join(directory.path, name)).writeAsString(name);
    }
    return directory;
  }

  LinuxHelperInstaller installer({
    LinuxHelperProcessRunner? run,
    HelperReadinessProbe? readiness,
    Future<bool> Function()? wait,
    Future<Directory> Function()? stage,
  }) {
    return LinuxHelperInstaller(
      environment: LinuxHelperEnvironment(
        uid: 1000,
        bundleDirectory: fixture.path,
      ),
      isLinux: true,
      hasSystemd: () => true,
      runProcess: run,
      helperReadiness: readiness ?? () async => HelperReadiness.notReady,
      waitForHelperService: wait,
      stageHelperBundle: stage ?? stagedFixture,
    );
  }

  test('constructors are inert on every platform', () async {
    final environment = LinuxHelperEnvironment(
      uid: 0,
      bundleDirectory: '/missing',
    );
    var probed = false;
    final install = LinuxHelperInstaller(
      environment: environment,
      isLinux: false,
      hasSystemd: () {
        probed = true;
        return true;
      },
      runProcess: (_, _) => throw StateError('must not run'),
    );
    expect(await install.ensureReady(), LinuxHelperInstallResult.unsupported);
    expect(await install.install(), LinuxHelperInstallResult.unsupported);
    expect(probed, isFalse);
  });

  test('uses per-owner private runtime and immutable hash pair path', () async {
    final core = '0' * 64;
    final helper = '1' * 64;
    await File(
      p.join(fixture.path, coreManifestName),
    ).writeAsString(jsonEncode({'coreSha256': core, 'helperSha256': helper}));
    final environment = LinuxHelperEnvironment(
      uid: 1000,
      bundleDirectory: fixture.path,
    );
    expect(environment.socketPath, '/run/reclash-helper-1000/helper.sock');
    expect(
      await environment.installedHelperPath(),
      '/var/lib/reclash-helper/1000/bundles/$core-$helper/$appHelperService',
    );
  });

  test('readiness never prompts or stages a bundle', () async {
    final install = installer(
      readiness: () async => HelperReadiness.notReady,
      run: (_, _) => throw StateError('must not elevate'),
      stage: () => throw StateError('must not stage'),
    );
    expect(await install.ensureReady(), LinuxHelperInstallResult.notReady);
  });

  test('an already-ready Helper is not reinstalled', () async {
    final install = installer(
      readiness: () async => HelperReadiness.ready,
      run: (_, _) => throw StateError('must not elevate'),
    );
    expect(await install.install(), LinuxHelperInstallResult.ready);
  });

  test(
    'absence of systemd never authorizes a setuid or sudo fallback',
    () async {
      final install = LinuxHelperInstaller(
        isLinux: true,
        hasSystemd: () => false,
        runProcess: (_, _) => throw StateError('must not run'),
      );
      expect(
        await install.install(),
        LinuxHelperInstallResult.systemdUnavailable,
      );
    },
  );

  test(
    'pkexec cancellation is final and does not wait or launch Core',
    () async {
      var requests = 0;
      final install = installer(
        run: (executable, args) async {
          requests++;
          expect(executable, '/usr/bin/pkexec');
          expect(args, [
            '--disable-internal-agent',
            p.join(fixture.path, 'stage', appHelperService),
            'install',
            '--bundle',
            p.join(fixture.path, 'stage'),
          ]);
          return ProcessResult(10, 126, '', 'cancelled');
        },
        wait: () => throw StateError('cancelled installation must not wait'),
      );
      expect(await install.install(), LinuxHelperInstallResult.cancelled);
      expect(requests, 1);
      expect(await Directory(p.join(fixture.path, 'stage')).exists(), isFalse);
    },
  );

  test('exit 127 does not universally mean a missing polkit agent', () async {
    final install = installer(
      run: (_, _) async => ProcessResult(10, 127, '', 'Not authorized'),
    );
    expect(await install.install(), LinuxHelperInstallResult.denied);
  });

  test('explicit missing-agent diagnostics remain distinct', () async {
    final install = installer(
      run: (_, _) async =>
          ProcessResult(10, 127, '', 'No authentication agent found'),
    );
    expect(await install.install(), LinuxHelperInstallResult.agentUnavailable);
  });

  test('missing pkexec never triggers a password fallback', () async {
    final install = installer(
      run: (_, _) => throw const ProcessException(
        '/usr/bin/pkexec',
        [],
        'No such file',
        2,
      ),
    );
    expect(await install.install(), LinuxHelperInstallResult.pkexecUnavailable);
  });

  test(
    'successful authorization still requires a protocol readiness witness',
    () async {
      final install = installer(
        run: (_, _) async => ProcessResult(10, 0, '', ''),
        wait: () async => false,
      );
      expect(await install.install(), LinuxHelperInstallResult.notReady);
    },
  );

  test('concurrent install callers share one elevation transaction', () async {
    final result = Completer<ProcessResult>();
    var calls = 0;
    final install = installer(
      run: (_, _) {
        calls++;
        return result.future;
      },
      wait: () async => true,
    );
    final first = install.install();
    final second = install.install();
    expect(identical(first, second), isTrue);
    result.complete(ProcessResult(10, 0, '', ''));
    expect(await first, LinuxHelperInstallResult.installed);
    expect(await second, LinuxHelperInstallResult.installed);
    expect(calls, 1);
  });

  test('invalid bundle fails before elevation', () async {
    final install = installer(
      stage: () => throw const FormatException('mismatch'),
      run: (_, _) => throw StateError('must not elevate'),
    );
    expect(await install.install(), LinuxHelperInstallResult.bundleInvalid);
  });

  test(
    'stages an AppImage-style pair away from its ephemeral source',
    () async {
      if (!Platform.isLinux) return;
      final helper = [0x7f, 0x45, 0x4c, 0x46, ...utf8.encode('helper')];
      final core = [0x7f, 0x45, 0x4c, 0x46, ...utf8.encode('core')];
      await File(p.join(fixture.path, appHelperService)).writeAsBytes(helper);
      await File(p.join(fixture.path, 'ReClashCore')).writeAsBytes(core);
      await File(p.join(fixture.path, coreManifestName)).writeAsString(
        jsonEncode({
          'coreSha256': sha256.convert(core).toString(),
          'helperSha256': sha256.convert(helper).toString(),
          'helperProtocolVersion': '9',
        }),
      );
      final environment = LinuxHelperEnvironment(
        uid: 1000,
        bundleDirectory: fixture.path,
      );
      final staged = await environment.stageBundle();
      try {
        expect(p.isWithin(fixture.path, staged.path), isFalse);
        expect(
          await File(p.join(staged.path, appHelperService)).readAsBytes(),
          helper,
        );
        expect(
          await File(p.join(staged.path, 'ReClashCore')).readAsBytes(),
          core,
        );
        final stagedManifest =
            jsonDecode(
                  await File(
                    p.join(staged.path, coreManifestName),
                  ).readAsString(),
                )
                as Map<String, dynamic>;
        expect(stagedManifest['helperProtocolVersion'], '9');
        expect((await staged.stat()).mode & 0x1ff, 0x1c0);
        expect(
          (await File(p.join(staged.path, appHelperService)).stat()).mode &
              0x1ff,
          0x140,
        );
      } finally {
        await staged.delete(recursive: true);
      }
    },
  );

  test('staging requires the exact string protocol version', () async {
    if (!Platform.isLinux) return;
    final environment = LinuxHelperEnvironment(
      uid: 1000,
      bundleDirectory: fixture.path,
    );
    for (final protocol in <Object?>[9, '8', '6', null]) {
      await File(p.join(fixture.path, coreManifestName)).writeAsString(
        jsonEncode({
          'coreSha256': '0' * 64,
          'helperSha256': '1' * 64,
          if (protocol != null) 'helperProtocolVersion': protocol,
        }),
      );
      await expectLater(environment.stageBundle(), throwsFormatException);
    }
  });

  test('staging rejects symlink members and hash mismatch', () async {
    if (!Platform.isLinux) return;
    final helper = [0x7f, 0x45, 0x4c, 0x46, ...utf8.encode('helper')];
    final core = [0x7f, 0x45, 0x4c, 0x46, ...utf8.encode('core')];
    await File(p.join(fixture.path, appHelperService)).writeAsBytes(helper);
    await File(p.join(fixture.path, 'ReClashCore')).writeAsBytes(core);
    await File(p.join(fixture.path, coreManifestName)).writeAsString(
      jsonEncode({
        'coreSha256': sha256.convert(core).toString(),
        'helperSha256': sha256.convert(helper).toString(),
        'helperProtocolVersion': '9',
      }),
    );
    final environment = LinuxHelperEnvironment(
      uid: 1000,
      bundleDirectory: fixture.path,
    );
    await File(p.join(fixture.path, 'ReClashCore')).delete();
    await Link(
      p.join(fixture.path, 'ReClashCore'),
    ).create(p.join(fixture.path, appHelperService));
    await expectLater(environment.stageBundle(), throwsFormatException);
    await Link(p.join(fixture.path, 'ReClashCore')).delete();
    await File(p.join(fixture.path, 'ReClashCore')).writeAsString('changed');
    await expectLater(environment.stageBundle(), throwsFormatException);
  });
}
