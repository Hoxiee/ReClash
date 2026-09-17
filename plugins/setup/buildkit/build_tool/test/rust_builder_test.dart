import 'package:build_tool/src/error.dart';
import 'package:build_tool/src/rust_builder.dart';
import 'package:build_tool/src/target.dart';
import 'package:test/test.dart';

void main() {
  test('Linux amd64 selects its service feature and explicit target', () {
    expect(RustBuilder.cargoArguments(Target.linuxAmd64), [
      'build',
      '--features',
      'linux-service',
      '--release',
      '--target',
      'x86_64-unknown-linux-gnu',
    ]);
  });

  test('Linux arm64 cannot silently build the host architecture', () {
    expect(
      RustBuilder.cargoTarget(Target.linuxArm64),
      'aarch64-unknown-linux-gnu',
    );
    expect(RustBuilder.cargoArguments(Target.linuxArm64), [
      'build',
      '--features',
      'linux-service',
      '--release',
      '--target',
      'aarch64-unknown-linux-gnu',
    ]);
  });

  test('Windows retains its existing service build command', () {
    for (final target in [Target.windowsAmd64, Target.windowsArm64]) {
      expect(RustBuilder.cargoTarget(target), isNull);
      expect(RustBuilder.cargoArguments(target), [
        'build',
        '--features',
        'windows-service',
        '--release',
      ]);
    }
  });

  test('rejects unsupported Helper platforms and architectures', () {
    for (final target in [
      Target.macosArm64,
      Target.androidAmd64,
      const Target(goos: 'linux', goarch: 'arm'),
    ]) {
      expect(
        () => RustBuilder.cargoArguments(target),
        throwsA(isA<BuildException>()),
      );
    }
  });
}
