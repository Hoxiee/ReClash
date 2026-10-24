import 'dart:convert';
import 'dart:io';

import 'package:sqlite3/sqlite3.dart';

Map<String, Object?> inspectDatabaseSchema(String path) {
  final database = sqlite3.open(path, mode: OpenMode.readOnly);
  try {
    database.execute('BEGIN');
    final version = database
        .select('PRAGMA user_version')
        .single['user_version'];
    final tables = <String, Object?>{};
    for (final row in database.select(
      "SELECT name FROM sqlite_schema WHERE type = 'table' "
      "AND name NOT LIKE 'sqlite\\_%' ESCAPE '\\' ORDER BY name",
    )) {
      final name = row['name'] as String;
      final quotedName = name.replaceAll('"', '""');
      tables[name] = [
        for (final column in database.select(
          'PRAGMA table_xinfo("$quotedName")',
        ))
          {
            'name': column['name'],
            'type': column['type'],
            'not_null': column['notnull'] == 1,
            'default': column['dflt_value'],
            'primary_key': column['pk'],
            'hidden': column['hidden'],
          },
      ];
    }
    return {'user_version': version, 'tables': tables};
  } finally {
    database.close();
  }
}

Map<String, Object?> diffDatabaseSchemas(
  Map<String, Object?> before,
  Map<String, Object?> after,
) {
  final beforeTables = before['tables'] as Map<String, Object?>;
  final afterTables = after['tables'] as Map<String, Object?>;
  final missingTables =
      beforeTables.keys.toSet().difference(afterTables.keys.toSet()).toList()
        ..sort();
  final addedTables =
      afterTables.keys.toSet().difference(beforeTables.keys.toSet()).toList()
        ..sort();
  final missingColumns = <Object?>[];
  final addedColumns = <Object?>[];
  final changedColumns = <Object?>[];
  final names = {...beforeTables.keys, ...afterTables.keys}.toList()..sort();
  for (final table in names) {
    Map<String, Map<String, Object?>> columns(Object? value) => {
      for (final column in (value as List? ?? const []))
        (column as Map<String, Object?>)['name'] as String: column,
    };
    final oldColumns = columns(beforeTables[table]);
    final newColumns = columns(afterTables[table]);
    for (final entry in oldColumns.entries) {
      final replacement = newColumns[entry.key];
      if (replacement == null) {
        missingColumns.add({'table': table, 'column': entry.value});
      } else if (jsonEncode(entry.value) != jsonEncode(replacement)) {
        changedColumns.add({
          'table': table,
          'name': entry.key,
          'before': entry.value,
          'after': replacement,
        });
      }
    }
    for (final entry in newColumns.entries) {
      if (!oldColumns.containsKey(entry.key)) {
        addedColumns.add({'table': table, 'column': entry.value});
      }
    }
  }
  return {
    'user_version': {
      'before': before['user_version'],
      'after': after['user_version'],
    },
    'missing_tables': missingTables,
    'added_tables': addedTables,
    'missing_columns': missingColumns,
    'added_columns': addedColumns,
    'changed_columns': changedColumns,
  };
}

void main(List<String> args) {
  if (!((args.length == 2 && args.first == 'inspect') ||
      (args.length == 3 && args.first == 'diff'))) {
    stderr.writeln(
      'Usage: dart run tool/database_schema.dart inspect <db>\n'
      '       dart run tool/database_schema.dart diff <before> <after>',
    );
    exitCode = 64;
    return;
  }
  try {
    final before = inspectDatabaseSchema(args[1]);
    final result = args.first == 'inspect'
        ? before
        : diffDatabaseSchemas(before, inspectDatabaseSchema(args[2]));
    stdout.writeln(const JsonEncoder.withIndent('  ').convert(result));
  } on SqliteException catch (error) {
    stderr.writeln('Could not inspect SQLite schema: $error');
    exitCode = 1;
  } on FileSystemException catch (error) {
    stderr.writeln('Could not read database: $error');
    exitCode = 1;
  }
}
