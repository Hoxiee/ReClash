import 'dart:convert';
import 'dart:js_interop';

import 'package:reclash/subscriptions/metadata/provider_config.dart';

@JS('reclashKernel')
external set _kernel(JSObject value);

extension type _Kernel._(JSObject _) implements JSObject {
  external factory _Kernel({JSFunction parse});
}

void main() {
  _kernel = _Kernel(parse: _parse.toJS);
}

String _parse(String source, String locale) {
  final result = parseProviderConfig(source, locale);
  return jsonEncode({'ok': result.config != null, 'warnings': result.warnings});
}
