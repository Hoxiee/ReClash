import 'dart:io';

import 'src/release_version.dart';

void main(List<String> args) {
  final version = ReleaseVersion.read(Directory.current.path);
  final tag = args.isEmpty ? '' : args.single;
  if (tag.isNotEmpty && tag != 'v${version.name}') {
    stderr.writeln('Tag $tag does not match pubspec version ${version.name}');
    exitCode = 1;
    return;
  }
  stdout.writeln(version.name);
}
