import 'dart:io';

import 'package:setup_hooks/src/error.dart';
import 'package:setup_hooks/src/options.dart';
import 'package:setup_hooks/src/rust_builder.dart';
import 'package:setup_hooks/src/target.dart';
import 'package:test/test.dart';

void main() {
  group('resolve', () {
    test('finds the target for a platform and GOARCH', () {
      expect(
        Target.resolve(platform: 'linux', goarch: 'arm64'),
        Target.linuxArm64,
      );
      expect(
        Target.resolve(platform: 'macos', goarch: 'arm64'),
        Target.macosArm64,
      );
      expect(
        Target.resolve(platform: 'windows', goarch: 'amd64'),
        Target.windowsAmd64,
      );
    });

    test('rejects a GOARCH or platform without a Core', () {
      expect(
        () => Target.resolve(platform: 'linux', goarch: 'riscv64'),
        throwsA(isA<BuildException>()),
      );
      expect(
        () => Target.resolve(platform: 'ios', goarch: 'arm64'),
        throwsA(isA<BuildException>()),
      );
    });
  });

  test('Linux and Windows ship the Rust service Helper', () {
    expect(Target.all.where((target) => target.hasHelper), [
      Target.linuxArm64,
      Target.linuxAmd64,
      Target.windowsAmd64,
      Target.windowsArm64,
    ]);
  });

  test('names the Helper and its protocol per platform', () {
    final root = Directory.systemTemp.createTempSync('setup_target_test_');
    addTearDown(() => root.deleteSync(recursive: true));
    final config = BuildConfig.load(rootDir: root.path);

    expect(config.helperFileName(Target.linuxAmd64), 'ReClashHelperService');
    expect(config.helperFileName(Target.windowsArm64), 'ReClashService.exe');
    expect(Target.linuxArm64.helperProtocolVersion, '9');
    expect(Target.windowsAmd64.helperProtocolVersion, '10');
    expect(
      () => Target.macosArm64.helperProtocolVersion,
      throwsA(isA<BuildException>()),
    );
  });

  test('names the Rust target triple for Helper platforms', () {
    expect(Target.windowsAmd64.rustTriple, 'x86_64-pc-windows-msvc');
    expect(Target.linuxArm64.rustTriple, 'aarch64-unknown-linux-gnu');
    expect(() => Target.macosArm64.rustTriple, throwsA(isA<BuildException>()));
  });

  test('links the Windows service CRT statically and leaves Linux alone', () {
    const crtStatic = '["-C", "target-feature=+crt-static"]';
    expect(RustBuilder.cargoArguments(Target.linuxAmd64), [
      'build',
      '--target',
      'x86_64-unknown-linux-gnu',
      '--release',
    ]);
    expect(RustBuilder.cargoArguments(Target.windowsArm64), [
      'build',
      '--target',
      'aarch64-pc-windows-msvc',
      '--features',
      'windows-service',
      '--config',
      'target.aarch64-pc-windows-msvc.rustflags=$crtStatic',
      '--release',
    ]);
  });
}
