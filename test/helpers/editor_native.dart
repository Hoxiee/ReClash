import 'dart:io';

import 'package:flutter/services.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart'
    show ExternalLibrary;
import 'package:flutter_test/flutter_test.dart';
import 'package:rust_api/rust_api.dart' show RustLib;

const _libraryStem = 'rust_api';

String get _libraryFile {
  if (Platform.isWindows) return '$_libraryStem.dll';
  if (Platform.isMacOS) return 'lib$_libraryStem.dylib';
  return 'lib$_libraryStem.so';
}

// `flutter test` runs the build hooks and copies their output to
// build/native_assets/<os>/; a plain cargo build leaves it under target/debug.
List<String> get _libraryCandidates => [
  'build/native_assets/${Platform.operatingSystem}/$_libraryFile',
  '.dart_tool/lib/$_libraryFile',
  'plugins/rust_api/rust/target/debug/$_libraryFile',
  'plugins/rust_api/rust/target/release/$_libraryFile',
];

Future<void>? _nativeInit;

/// Loads the host `rust_api` library once so the editor's native rope backend
/// is available in tests.
Future<void> initEditorNative() => _nativeInit ??= () async {
  final overrideDir =
      Platform.environment['FRB_DART_LOAD_EXTERNAL_LIBRARY_NATIVE_LIB_DIR'];
  if (overrideDir != null) return RustLib.init();
  final path = _libraryCandidates.firstWhere(
    (path) => File(path).existsSync(),
    orElse: () => throw StateError(
      'Editor native library not found; tried ${_libraryCandidates.join(', ')}'
      ' from ${Directory.current.path}. Build it with'
      ' `cargo build --manifest-path plugins/rust_api/rust/Cargo.toml` or set'
      ' FRB_DART_LOAD_EXTERNAL_LIBRARY_NATIVE_LIB_DIR to its directory.',
    ),
  );
  await RustLib.init(
    externalLibrary: ExternalLibrary.open(File(path).absolute.path),
  );
}();

// The editor uses a DeltaTextInputClient, so it takes text as editing deltas on
// the input connection it opened, not through WidgetTester.enterText.
Future<void> typeInEditor(WidgetTester tester, String text) async {
  final setClient = tester.testTextInput.log.lastWhere(
    (call) => call.method == 'TextInput.setClient',
    orElse: () => throw StateError('The editor opened no input connection'),
  );
  final client = (setClient.arguments as List)[0] as int;
  await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
    SystemChannels.textInput.name,
    SystemChannels.textInput.codec.encodeMethodCall(
      MethodCall('TextInputClient.updateEditingStateWithDeltas', [
        client,
        {
          'deltas': [
            {
              'oldText': '',
              'deltaText': text,
              'deltaStart': 0,
              'deltaEnd': 0,
              'selectionBase': text.length,
              'selectionExtent': text.length,
              'selectionAffinity': 'TextAffinity.downstream',
              'selectionIsDirectional': false,
              'composingBase': -1,
              'composingExtent': -1,
            },
          ],
        },
      ]),
    ),
    (_) {},
  );
  await tester.pump();
}
