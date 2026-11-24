import 'dart:convert';
import 'dart:io';

const _profile = 'reclash';
const _caBundle = 'component/ca/ca-certificates.crt';
const _assetCa = 'assets/ca/ca-certificates.crt';
const _usage = '''
Prepares the patched mihomo source used by the Go Core.

Usage: dart tool/mihomo.dart <apply|revert|status|verify>

  apply   Clone the pinned upstream source into core/.mihomo and apply the
          reclash patch profile. Safe to repeat; the generated tree is reset.
  revert  Reset the generated tree to the pinned upstream commit.
  status  Print the pinned commit and the current generated-tree state.
  verify  Apply the profile and check that it changed the generated tree.
''';

Future<void> main(List<String> arguments) async {
  if (arguments.contains('--help') || arguments.contains('-h')) {
    stdout.write(_usage);
    return;
  }
  final command = arguments.isEmpty ? 'apply' : arguments.first;
  try {
    switch (command) {
      case 'apply':
        _apply();
      case 'revert':
        _revert();
      case 'status':
        _status();
      case 'verify':
        _verify();
      default:
        stderr.write(_usage);
        exitCode = 64;
    }
  } on _MihomoException catch (error) {
    stderr.writeln('mihomo: ${error.message}');
    exitCode = 1;
  } on ProcessException catch (error) {
    stderr.writeln('mihomo: cannot run ${error.executable}: ${error.message}');
    exitCode = 1;
  }
}

String get _root => File.fromUri(Platform.script).parent.parent.path;

String _join(String base, String child) =>
    '$base${Platform.pathSeparator}$child';

Directory get _patches => Directory(_join(_root, 'core/mihomo-patches'));

Directory get _source => Directory(_join(_root, 'core/mihomo'));

Directory get _target => Directory(_join(_root, 'core/.mihomo'));

File get _stateFile =>
    File(_join(_join(_root, '.dart_tool'), 'mihomo_patches.json'));

void _apply() {
  final base = _base();
  final patches = _profilePatches();
  if (_isPrepared(base.commit, patches)) {
    stdout.writeln('mihomo: core/.mihomo is already prepared');
    return;
  }
  _checkSource(base.commit);
  final ca = File(_join(_target.path, _caBundle));
  final assetCa = File(_join(_root, _assetCa));
  final cachedCa = assetCa.existsSync() && assetCa.lengthSync() > 0
      ? assetCa.readAsBytesSync()
      : null;
  if (_target.existsSync() &&
      (!_isRepository(_target) || !_hasCommit(base.commit))) {
    _target.deleteSync(recursive: true);
  }
  if (!_target.existsSync()) {
    _git([
      'clone',
      '--quiet',
      '--local',
      '--no-hardlinks',
      _source.path,
      _target.path,
    ]);
  }
  _reset(base.commit);
  try {
    for (final patch in patches) {
      _git(['apply', '--whitespace=nowarn', patch], cwd: _target.path);
    }
  } catch (_) {
    _reset(base.commit);
    rethrow;
  }
  if (cachedCa != null) {
    ca.parent.createSync(recursive: true);
    ca.writeAsBytesSync(cachedCa);
  }
  if (_git([
    'status',
    '--porcelain',
  ], cwd: _target.path).stdout.toString().trim().isEmpty) {
    throw const _MihomoException('the patch profile changed no files');
  }
  _stateFile.parent.createSync(recursive: true);
  _stateFile.writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert({
      'base': base.commit,
      'profile': _profile,
      'patches': patches.length,
      'patch_repo': _git([
        'rev-parse',
        'HEAD',
      ], cwd: _patches.path).stdout.toString().trim(),
      'diff_hash': _generatedStateHash(),
    }),
  );
  stdout.writeln(
    'mihomo: core/.mihomo at ${_short(base.commit)} with '
    '${patches.length} patches',
  );
}

bool _isPrepared(String base, List<String> patches) {
  if (!_target.existsSync() ||
      !_stateFile.existsSync() ||
      !_isRepository(_target)) {
    return false;
  }
  if (_git(['rev-parse', 'HEAD'], cwd: _target.path).stdout.toString().trim() !=
      base) {
    return false;
  }
  try {
    final decoded = jsonDecode(_stateFile.readAsStringSync());
    if (decoded is! Map<String, dynamic>) return false;
    final state = decoded;
    if (state['base'] != base ||
        state['profile'] != _profile ||
        state['patches'] != patches.length) {
      return false;
    }
    if (state['patch_repo'] !=
        _git([
          'rev-parse',
          'HEAD',
        ], cwd: _patches.path).stdout.toString().trim()) {
      return false;
    }
    if (state['diff_hash'] != _generatedStateHash()) return false;
  } on FormatException {
    return false;
  }
  if (_git([
    'status',
    '--porcelain',
  ], cwd: _patches.path).stdout.toString().trim().isNotEmpty) {
    return false;
  }
  final assetCa = File(_join(_root, _assetCa));
  final targetCa = File(_join(_target.path, _caBundle));
  final expected = assetCa.existsSync()
      ? assetCa.readAsBytesSync()
      : const <int>[];
  final actual = targetCa.existsSync()
      ? targetCa.readAsBytesSync()
      : const <int>[];
  return _sameBytes(expected, actual);
}

void _revert() {
  if (!_target.existsSync()) {
    stdout.writeln('mihomo: core/.mihomo is not prepared');
    return;
  }
  final base = _base();
  if (!_isRepository(_target) || !_hasCommit(base.commit)) {
    _target.deleteSync(recursive: true);
    stdout.writeln('mihomo: removed an unprepared core/.mihomo');
    return;
  }
  _reset(base.commit);
  if (_stateFile.existsSync()) _stateFile.deleteSync();
  stdout.writeln('mihomo: core/.mihomo reset to the pinned upstream commit');
}

void _status() {
  final base = _base();
  stdout.writeln('base: ${base.tag} ${base.commit}');
  stdout.writeln('patches: ${_patches.path}');
  stdout.writeln('generated: ${_target.path}');
  if (!_target.existsSync() || !_isRepository(_target)) {
    stdout.writeln('state: not prepared');
    return;
  }
  final head = _git([
    'rev-parse',
    'HEAD',
  ], cwd: _target.path).stdout.toString().trim();
  final changed = _git(['status', '--porcelain'], cwd: _target.path).stdout
      .toString()
      .trim()
      .split('\n')
      .where((line) => line.isNotEmpty)
      .length;
  stdout.writeln('head: ${_short(head)}');
  stdout.writeln('changed: $changed');
  stdout.writeln(
    'record: ${_stateFile.existsSync() ? _stateFile.readAsStringSync().trim() : 'none'}',
  );
}

void _verify() {
  _apply();
  final changed = _git([
    'status',
    '--porcelain',
  ], cwd: _target.path).stdout.toString().trim();
  if (changed.isEmpty) throw const _MihomoException('no patched files');
  _git(['diff', '--check'], cwd: _target.path);
  stdout.writeln('mihomo: patch profile verified');
}

({String tag, String commit}) _base() {
  final file = File(_join(_patches.path, 'base.env'));
  if (!file.existsSync()) {
    throw _MihomoException(
      '${file.path} is missing; run git submodule update --init --recursive',
    );
  }
  String? tag;
  String? commit;
  for (final line in file.readAsLinesSync()) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
    final split = trimmed.indexOf('=');
    if (split <= 0) continue;
    final key = trimmed.substring(0, split).trim();
    final value = trimmed.substring(split + 1).trim();
    if (key == 'MIHOMO_TAG') tag = value;
    if (key == 'MIHOMO_COMMIT') commit = value;
  }
  if (commit == null || commit.isEmpty) {
    throw _MihomoException('${file.path} has no MIHOMO_COMMIT');
  }
  return (tag: tag ?? '', commit: commit);
}

void _checkSource(String commit) {
  if (!_source.existsSync()) {
    throw const _MihomoException(
      'core/mihomo is missing; run git submodule update --init --recursive',
    );
  }
  final head = _git([
    'rev-parse',
    'HEAD',
  ], cwd: _source.path).stdout.toString().trim();
  if (head != commit) {
    throw _MihomoException(
      'core/mihomo is at ${_short(head)}, expected ${_short(commit)}; '
      'run git submodule update --init core/mihomo',
    );
  }
}

List<String> _profilePatches() {
  final files = <String>[];
  final seen = <String>{};
  void read(String name) {
    if (!seen.add(name)) {
      throw _MihomoException('profile include cycle at $name');
    }
    final file = File(_join(_join(_patches.path, 'profiles'), name));
    if (!file.existsSync()) {
      throw _MihomoException('missing profile ${file.path}');
    }
    for (final line in file.readAsLinesSync()) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
      if (trimmed.startsWith('include ')) {
        read(trimmed.substring('include '.length).trim());
        continue;
      }
      final patch = _join(_join(_patches.path, 'patches'), trimmed);
      if (!File(patch).existsSync()) {
        throw _MihomoException('missing patch $patch');
      }
      files.add(patch);
    }
  }

  read('$_profile.txt');
  if (files.isEmpty) throw const _MihomoException('the profile has no patches');
  return files;
}

void _reset(String commit) {
  _git(['reset', '--hard', '--quiet', commit], cwd: _target.path);
  _git(['clean', '-fdxq'], cwd: _target.path);
}

bool _hasCommit(String commit) =>
    _git(
      ['cat-file', '-e', '$commit^{commit}'],
      cwd: _target.path,
      check: false,
    ).exitCode ==
    0;

String _generatedStateHash() {
  final status = _git([
    'status',
    '--porcelain',
    '--untracked-files=all',
  ], cwd: _target.path).stdout.toString();
  final diff = _git(['diff', '--binary'], cwd: _target.path).stdout.toString();
  // No package import here: this runs before `flutter pub get` on a fresh
  // checkout. FNV-1a is enough to detect a changed generated tree.
  var hash = 0xcbf29ce484222325;
  for (final byte in utf8.encode('$status\n$diff')) {
    hash ^= byte;
    hash = (hash * 0x100000001b3) & 0xFFFFFFFFFFFFFFFF;
  }
  return hash.toRadixString(16).padLeft(16, '0');
}

bool _sameBytes(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

bool _isRepository(Directory directory) {
  final marker = Directory(_join(directory.path, '.git'));
  return marker.existsSync() ||
      File(_join(directory.path, '.git')).existsSync();
}

String _short(String commit) =>
    commit.length <= 12 ? commit : commit.substring(0, 12);

ProcessResult _git(List<String> arguments, {String? cwd, bool check = true}) {
  final result = Process.runSync(
    'git',
    arguments,
    workingDirectory: cwd,
    stdoutEncoding: utf8,
    stderrEncoding: utf8,
  );
  if (check && result.exitCode != 0) {
    throw _MihomoException(
      'git ${arguments.join(' ')} failed:\n${result.stderr}'.trim(),
    );
  }
  return result;
}

class _MihomoException implements Exception {
  const _MihomoException(this.message);

  final String message;
}
