import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

const _nativeLibraries = ['dart:ffi', 'dart:io', 'dart:isolate'];

/// App dependencies with no web implementation, or whose web build would
/// pull native code or a database into the preview.
const _nativePackages = [
  'window',
  'proxy',
  'tray',
  'wifi_ssid',
  'rust_api',
  'setup',
  'code_forge',
  'win32',
  'win32_registry',
  'ffi',
  'webview_flutter',
  'drift',
  'drift_flutter',
  'file_picker',
  'mobile_scanner',
  'image_picker',
  'launch_at_startup',
  'screen_retriever',
  'path_provider',
  'shared_preferences',
  'flutter_cache_manager',
  'dio',
  'cryptography',
  'flutter_riverpod',
  'riverpod',
];

/// What the parser may use: it runs as plain JavaScript in the site's form,
/// where no Flutter engine is loaded.
const _kernelPackages = [
  'collection',
  'crypto',
  'meta',
  'source_span',
  'string_scanner',
  'term_glyph',
  'typed_data',
  'yaml',
];

final _directive = RegExp(
  r'''^\s*(?:import|export|part)\s+['"]([^'"]+)['"]''',
  multiLine: true,
);

String _resolve(String uri, String from) {
  if (uri.startsWith('package:reclash/')) {
    return 'lib/${uri.substring('package:reclash/'.length)}';
  }
  if (uri.startsWith('dart:') || uri.startsWith('package:')) return uri;
  return p.normalize(p.join(p.dirname(from), uri));
}

String? _packageOf(String uri) => uri.startsWith('package:')
    ? uri.substring('package:'.length, uri.indexOf('/'))
    : null;

/// The chain from [root] to the first file it reaches that [forbidden]
/// rejects, or null when there is none.
List<String>? _violation(String root, bool Function(String uri) forbidden) {
  final parents = <String, String>{};
  final queue = [root];
  final seen = {root};
  while (queue.isNotEmpty) {
    final current = queue.removeAt(0);
    final file = File(current);
    if (!file.existsSync()) continue;
    for (final match in _directive.allMatches(file.readAsStringSync())) {
      final next = _resolve(match.group(1)!, current);
      if (!seen.add(next)) continue;
      parents[next] = current;
      if (forbidden(next)) {
        final chain = [next];
        while (parents.containsKey(chain.first)) {
          chain.insert(0, parents[chain.first]!);
        }
        return chain;
      }
      if (!next.startsWith('dart:') && !next.startsWith('package:')) {
        queue.add(next);
      }
    }
  }
  return null;
}

void main() {
  test('the builder kernel stays plain Dart', () {
    const entry = 'site_preview/lib/kernel.dart';
    expect(File(entry).existsSync(), isTrue, reason: '$entry is gone.');
    final chain = _violation(entry, (uri) {
      if (uri.startsWith('dart:')) {
        return _nativeLibraries.contains(uri) || uri == 'dart:ui';
      }
      final package = _packageOf(uri);
      return package != null && !_kernelPackages.contains(package);
    });
    expect(
      chain,
      isNull,
      reason:
          'kernel.js is compiled with dart2js for the site form and may only '
          'reach dart: core libraries and ${_kernelPackages.join(', ')}:\n'
          '${chain?.join(' -> ')}',
    );
  });

  test('the builder preview reaches no native code or app state', () {
    const entry = 'site_preview/lib/main.dart';
    expect(File(entry).existsSync(), isTrue, reason: '$entry is gone.');
    final chain = _violation(
      entry,
      (uri) =>
          _nativeLibraries.contains(uri) ||
          _nativePackages.contains(_packageOf(uri)) ||
          uri.startsWith('lib/providers/') ||
          uri == 'lib/common/common.dart',
    );
    expect(
      chain,
      isNull,
      reason:
          'The preview is a Flutter web build of the app widgets. It renders '
          'the pure views with manifest data and reaches neither native '
          'plugins nor lib/providers and the lib/common/common.dart barrel, '
          'which bind them to app state; split the view from its binding '
          'instead:\n${chain?.join(' -> ')}',
    );
  });
}
