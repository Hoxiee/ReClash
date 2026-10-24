import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../tool/database_schema.dart';

void main() {
  late Directory directory;
  late String beforePath;
  late String afterPath;

  void create(String path, String sql) {
    final database = sqlite3.open(path);
    try {
      database.execute(sql);
    } finally {
      database.close();
    }
  }

  setUp(() {
    directory = Directory.systemTemp.createTempSync('schema-tool-');
    beforePath = '${directory.path}/before.db';
    afterPath = '${directory.path}/after.db';
  });
  tearDown(() => directory.deleteSync(recursive: true));

  test(
    'inspects user version, constraints, quoted names and generated columns',
    () {
      create(beforePath, '''
      PRAGMA user_version = 7;
      CREATE TABLE "odd""name" (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL DEFAULT 'guest',
        derived TEXT GENERATED ALWAYS AS (name || '!') VIRTUAL
      );
      CREATE TABLE counter (id INTEGER PRIMARY KEY AUTOINCREMENT);
    ''');
      final schema = inspectDatabaseSchema(beforePath);
      expect(schema['user_version'], 7);
      final tables = schema['tables'] as Map<String, Object?>;
      expect(tables.keys, ['counter', 'odd"name']);
      final columns = tables['odd"name'] as List;
      expect(columns[0]['primary_key'], 1);
      expect(columns[1], containsPair('not_null', true));
      expect(columns[1]['default'], "'guest'");
      expect(columns[2]['hidden'], 2);
    },
  );

  test('reports missing, added and changed columns and tables', () {
    create(beforePath, '''
      PRAGMA user_version = 1;
      CREATE TABLE profiles (id INTEGER PRIMARY KEY, name TEXT, removed TEXT);
      CREATE TABLE gone (x TEXT);
    ''');
    create(afterPath, '''
      PRAGMA user_version = 2;
      CREATE TABLE profiles (id INTEGER PRIMARY KEY, name TEXT NOT NULL DEFAULT '', added BLOB);
      CREATE TABLE fresh (y INTEGER);
    ''');
    final diff = diffDatabaseSchemas(
      inspectDatabaseSchema(beforePath),
      inspectDatabaseSchema(afterPath),
    );
    expect(diff['user_version'], {'before': 1, 'after': 2});
    expect(diff['missing_tables'], ['gone']);
    expect(diff['added_tables'], ['fresh']);
    expect(diff['missing_columns'], hasLength(2));
    expect(diff['added_columns'], hasLength(2));
    expect(diff['changed_columns'], [
      allOf(containsPair('table', 'profiles'), containsPair('name', 'name')),
    ]);
  });

  test('equal schemas have no differences', () {
    create(beforePath, 'CREATE TABLE t (a TEXT);');
    final schema = inspectDatabaseSchema(beforePath);
    final diff = diffDatabaseSchemas(schema, schema);
    for (final key in [
      'missing_tables',
      'added_tables',
      'missing_columns',
      'added_columns',
      'changed_columns',
    ]) {
      expect(diff[key], isEmpty);
    }
  });

  test('missing database is not created', () {
    expect(
      () => inspectDatabaseSchema(beforePath),
      throwsA(isA<SqliteException>()),
    );
    expect(File(beforePath).existsSync(), isFalse);
  });

  test('invalid database fails without overwriting it', () {
    File(beforePath).writeAsStringSync('not SQLite');
    expect(
      () => inspectDatabaseSchema(beforePath),
      throwsA(isA<SqliteException>()),
    );
    expect(File(beforePath).readAsStringSync(), 'not SQLite');
  });

  test('inspect and diff leave database bytes and directory unchanged', () {
    create(
      beforePath,
      'CREATE TABLE t (a TEXT); INSERT INTO t VALUES (\'value\');',
    );
    create(afterPath, 'CREATE TABLE t (a INTEGER);');
    final bytes = {
      for (final path in [beforePath, afterPath])
        path: File(path).readAsBytesSync(),
    };
    final names = directory.listSync().map((e) => e.path).toSet();
    diffDatabaseSchemas(
      inspectDatabaseSchema(beforePath),
      inspectDatabaseSchema(afterPath),
    );
    for (final entry in bytes.entries) {
      expect(File(entry.key).readAsBytesSync(), entry.value);
    }
    expect(directory.listSync().map((e) => e.path).toSet(), names);
  });

  test(
    'CLI inspect and diff emit JSON and failures use nonzero exit',
    () async {
      create(beforePath, 'CREATE TABLE t (a TEXT);');
      create(afterPath, 'CREATE TABLE t (a INTEGER);');
      for (final arguments in [
        ['inspect', beforePath],
        ['diff', beforePath, afterPath],
      ]) {
        final result = await Process.run('dart', [
          'run',
          'tool/database_schema.dart',
          ...arguments,
        ]);
        expect(result.exitCode, 0, reason: '${result.stderr}');
        final output = result.stdout as String;
        final json = jsonDecode(output.substring(output.indexOf('{'))) as Map;
        expect(json, contains('user_version'));
      }
      final missing = await Process.run('dart', [
        'run',
        'tool/database_schema.dart',
        'inspect',
        '${directory.path}/missing.db',
      ]);
      expect(missing.exitCode, 1);
      expect(missing.stderr, contains('Could not inspect SQLite schema'));
      expect(File('${directory.path}/missing.db').existsSync(), isFalse);
    },
  );
}
