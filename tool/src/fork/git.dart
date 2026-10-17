import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

import 'model.dart';

class TreeEntry {
  const TreeEntry(this.mode, this.oid, this.path);
  final String mode;
  final String oid;
  final String path;
  bool get blob => mode == '100644' || mode == '100755';
  Map<String, String> toJson() => {'mode': mode, 'oid': oid, 'path': path};
}

class ForkGit {
  ForkGit(String directory)
    : root = Directory(directory).resolveSymbolicLinksSync();
  final String root;

  ProcessResult result(
    List<String> args, {
    Map<String, String>? environment,
    bool binary = false,
  }) => Process.runSync(
    'git',
    [
      '-c',
      'core.hooksPath=${Platform.isWindows ? 'NUL' : '/dev/null'}',
      '-c',
      'rerere.autoupdate=false',
      '-c',
      'commit.gpgSign=false',
      ...args,
    ],
    workingDirectory: root,
    environment: {
      'GIT_OPTIONAL_LOCKS': '0',
      'GIT_LFS_SKIP_SMUDGE': '1',
      ...?environment,
    },
    stdoutEncoding: binary ? null : utf8,
  );

  String run(List<String> args, {Map<String, String>? environment}) {
    final r = result(args, environment: environment);
    if (r.exitCode != 0) {
      throw ForkException(
        'git ${args.first}: ${r.stderr.toString().trim()}',
        code: 3,
      );
    }
    return r.stdout as String;
  }

  bool exists(String rev) =>
      result(['rev-parse', '--verify', '--quiet', '$rev^{object}']).exitCode ==
      0;
  String oid(String rev) =>
      run(['rev-parse', '--verify', '$rev^{commit}']).trim();
  String tree(String rev) =>
      run(['rev-parse', '--verify', '$rev^{tree}']).trim();
  bool get rebaseInProgress => ['rebase-merge', 'rebase-apply'].any((name) {
    final path = run(['rev-parse', '--git-path', name]).trim();
    return Directory(
      p.isAbsolute(path) ? path : p.join(root, path),
    ).existsSync();
  });
  bool ancestor(String old, String next) =>
      result(['merge-base', '--is-ancestor', old, next]).exitCode == 0;
  bool firstParentAncestor(String old, String next) => run([
    'rev-list',
    '--first-parent',
    next,
  ]).trim().split('\n').contains(old);
  String get common =>
      run(['rev-parse', '--path-format=absolute', '--git-common-dir']).trim();
  String get stateRoot => p.join(common, 'reclash-fork');
  String read(String rev, String path) =>
      run(['show', '$rev:${safePath(path)}']);
  List<int> blob(String id) {
    final r = result(['cat-file', 'blob', id], binary: true);
    if (r.exitCode != 0) reject('Missing blob $id');
    return r.stdout as List<int>;
  }

  List<TreeEntry> entries(String rev) =>
      split(run(['ls-tree', '-rz', '--full-tree', rev])).map((line) {
        final tab = line.indexOf('\t');
        final fields = line.substring(0, tab).split(' ');
        return TreeEntry(fields[0], fields[2], line.substring(tab + 1));
      }).toList();
  List<String> files(String rev, [String? path]) => split(
    run([
      'ls-tree',
      '-rz',
      '--name-only',
      rev,
      if (path != null) '--',
      if (path != null) safePath(path),
    ]),
  );
  List<String> changed(String old, String next) => split(
    run(['diff', '--name-only', '--no-renames', '-z', tree(old), tree(next)]),
  );
  List<Map<String, dynamic>> changes(String old, String next) {
    final before = {for (final e in entries(old)) e.path: e};
    final after = {for (final e in entries(next)) e.path: e};
    return [
      for (final path in changed(old, next))
        {
          'path': path,
          'status': before[path] == null
              ? 'add'
              : after[path] == null
              ? 'delete'
              : 'modify',
          'old': before[path]?.toJson(),
          'new': after[path]?.toJson(),
          'modeChanged':
              before[path] != null &&
              after[path] != null &&
              before[path]!.mode != after[path]!.mode,
          'kind': [before[path], after[path]].any((e) => e?.mode == '160000')
              ? 'gitlink'
              : [before[path], after[path]].any((e) => e?.mode == '120000')
              ? 'symlink'
              : [
                  before[path],
                  after[path],
                ].any((e) => e != null && e.blob && blob(e.oid).contains(0))
              ? 'binary'
              : 'text',
        },
    ];
  }

  List<String> get dirty =>
      split(run(['status', '--porcelain=v1', '-z', '--untracked-files=all']));
  List<String> get changedPaths => {
    ...split(run(['diff', '--name-only', '--no-renames', '-z', 'HEAD'])),
    ...split(run(['ls-files', '--others', '--exclude-standard', '-z'])),
  }.toList()..sort();
  List<String> get stagedPaths =>
      split(run(['diff', '--cached', '--name-only', '--no-renames', '-z']));
  String blobId(List<int> bytes) {
    final hash = run(['rev-parse', '--show-object-format']).trim() == 'sha256'
        ? sha256
        : sha1;
    return hash.convert([
      ...utf8.encode('blob ${bytes.length}\u0000'),
      ...bytes,
    ]).toString();
  }

  void createRef(String ref, String target) {
    if (!ref.startsWith('refs/reclash/') &&
        !ref.startsWith('refs/heads/sync/')) {
      reject('Not an owned create-only ref: $ref');
    }
    if (exists(ref)) {
      reject(
        'Ref already exists: $ref; use a new ID or inspect the existing candidate',
      );
    }
    run(['update-ref', ref, target, '']);
  }

  String commitTree(String treeId, List<String> parents, String message) => run(
    [
      'commit-tree',
      treeId,
      for (final parent in parents) ...['-p', parent],
      '-m',
      message,
    ],
    environment: const {
      'GIT_AUTHOR_NAME': 'ReClash maintenance',
      'GIT_AUTHOR_EMAIL': 'maintenance@localhost',
      'GIT_COMMITTER_NAME': 'ReClash maintenance',
      'GIT_COMMITTER_EMAIL': 'maintenance@localhost',
    },
  ).trim();

  void assertClean() {
    if (dirty.isNotEmpty) reject('Checkout is dirty: $root');
  }

  Map<String, String> worktrees() {
    final found = <String, String>{};
    String? path;
    for (final line in run(['worktree', 'list', '--porcelain']).split('\n')) {
      if (line.startsWith('worktree ')) path = line.substring(9);
      if (line.startsWith('branch ') && path != null) {
        found[line.substring(7)] = path;
      }
    }
    return found;
  }

  static List<String> split(String value) =>
      value.split('\u0000').where((part) => part.isNotEmpty).toList();
}

void rejectSymlinks(String path) {
  var current = p.absolute(path);
  while (true) {
    if (FileSystemEntity.isLinkSync(current)) {
      reject('Refusing symlink: $current');
    }
    final parent = p.dirname(current);
    if (parent == current) return;
    current = parent;
  }
}

void atomicJson(File file, Object value) {
  rejectSymlinks(file.path);
  file.parent.createSync(recursive: true);
  final directory = file.parent.createTempSync('.fork-state-');
  try {
    final temp = File(p.join(directory.path, 'receipt.json'));
    temp.writeAsStringSync(
      '${const JsonEncoder.withIndent('  ').convert(value)}\n',
      flush: true,
    );
    temp.renameSync(file.path);
  } finally {
    directory.deleteSync(recursive: true);
  }
}

Map<String, dynamic> readJson(File file) {
  rejectSymlinks(file.path);
  return object(jsonDecode(file.readAsStringSync()), file.path);
}
