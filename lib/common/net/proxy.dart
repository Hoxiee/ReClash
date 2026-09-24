import 'package:reclash/common/desktop/system.dart';
import 'package:proxy/proxy.dart';

final proxy = system.isDesktop ? Proxy() : null;

String proxyEnvCommand(int port, {required bool isWindows}) {
  final url = 'http://127.0.0.1:$port';
  return isWindows ? 'set \$env:all_proxy=$url' : 'export all_proxy=$url';
}
