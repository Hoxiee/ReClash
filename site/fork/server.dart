import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as p;

import '../../tool/src/fork/git.dart';
import 'src/http.dart';

Future<void> main(List<String> arguments) async {
  final siteRoot = p.dirname(File.fromUri(Platform.script).absolute.path);
  final parser = ArgParser()
    ..addOption('root', defaultsTo: p.normalize(p.join(siteRoot, '../..')))
    ..addOption('port', defaultsTo: '8788')
    ..addFlag('help', abbr: 'h', negatable: false);
  try {
    final options = parser.parse(arguments);
    if (options.flag('help')) {
      stdout.writeln(
        'Fork Atlas — a local read-only maintenance workspace.\n\nUsage: dart run site/fork/server.dart [options]\n${parser.usage}',
      );
      return;
    }
    final port = int.tryParse(options.option('port')!);
    if (port == null || port < 0 || port > 65535) {
      throw const FormatException('Port must be between 0 and 65535');
    }
    final root = ForkGit(options.option('root')!).root;
    final server = AtlasServer(root: root, siteRoot: siteRoot);
    await server.start(port: port);
    stdout.writeln(
      'Fork Atlas: http://127.0.0.1:${server.port}/fork/\nRepository: $root\nRead-only. No fetch, checks, Git writes or remote services.',
    );
    for (final signal in [
      ProcessSignal.sigint,
      if (!Platform.isWindows) ProcessSignal.sigterm,
    ]) {
      signal.watch().listen((_) async {
        await server.close();
        exit(0);
      });
    }
  } on FormatException catch (error) {
    stderr.writeln('atlas: ${error.message}');
    exitCode = 2;
  } on SocketException catch (error) {
    stderr.writeln('atlas: ${error.message}; choose another --port');
    exitCode = 3;
  }
}
