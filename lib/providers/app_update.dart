import 'package:reclash/common/app_update_runtime.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated/app_update.g.dart';

@Riverpod(keepAlive: true)
AppUpdateRuntime appUpdateRuntime(Ref ref) => AppUpdateRuntime();
