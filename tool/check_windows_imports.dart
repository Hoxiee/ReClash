import 'dart:io';

import 'src/pe_image.dart';
import 'src/windows_system_libraries.dart';

void main(List<String> args) {
  if (args.isEmpty) {
    stderr.writeln('usage: dart tool/check_windows_imports.dart <image>...');
    exit(64);
  }
  var failed = false;
  for (final path in args) {
    final image = PeImage(File(path).readAsBytesSync());
    final unknown = {
      for (final symbol in image.imports)
        if (!isWindowsSystemLibrary(symbol.library)) symbol.library,
    };
    if (unknown.isEmpty) continue;
    failed = true;
    stderr.writeln(
      '$path imports libraries missing from windowsSystemLibraries: '
      '${(unknown.toList()..sort()).join(', ')}',
    );
  }
  if (failed) exit(1);
}
