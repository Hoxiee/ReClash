import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/database/database.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';

part 'task_encoding.dart';
part 'task_groups.dart';
part 'task_rcx_skeleton.dart';
part 'task_real_profile.dart';
part 'task_migration.dart';
part 'task_backup.dart';

const currentDataVersion = 2;

Future<List<T>> mapListTask<T, S>(List<S> results, T Function(S) mapper) async {
  return compute<({List<S> results, T Function(S) mapper}), List<T>>(
    _mapListTask,
    (results: results, mapper: mapper),
  );
}

Future<List<T>> _mapListTask<T, S>(
  ({List<S> results, T Function(S) mapper}) args,
) async {
  return args.results.map((item) => args.mapper(item)).toList();
}
