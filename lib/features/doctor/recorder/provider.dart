import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reclash/common/path.dart';

import 'recorder.dart';

final Provider<FilePassiveRecorder> passiveRecorderProvider = Provider((ref) {
  final recorder = FilePassiveRecorder(
    directory: () async => Directory(await appPath.homeDirPath),
  );
  ref.onDispose(recorder.dispose);
  return recorder;
});
