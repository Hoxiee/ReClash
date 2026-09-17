import 'dart:async';
import 'dart:io';

import 'package:reclash/common/finding_events.dart';
import 'package:reclash/common/boot_guard.dart';
import 'package:reclash/common/boot_record.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/common/wallpaper_store.dart';
import 'package:reclash/common/subscription_reminder.dart';
import 'package:reclash/common/subscription_retry.dart';
import 'package:reclash/common/system_dns.dart';
import 'package:reclash/core/core.dart';
import 'package:reclash/core/desktop/helper_client.dart';
import 'package:reclash/database/database.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/plugins/app.dart';
import 'package:reclash/plugins/service.dart';
import 'package:reclash/providers/actions/system_exit.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/widgets/dialog.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart' show CancelToken, DioException, DioExceptionType;
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' show basename, join;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:url_launcher/url_launcher.dart';

part 'actions/common.dart';
part 'actions/setup.dart';
part 'actions/backup.dart';
part 'actions/core.dart';
part 'actions/system.dart';
part 'actions/store.dart';
part 'actions/theme.dart';
part 'actions/proxies.dart';
part 'actions/profiles.dart';
part 'actions/geo_resource.dart';
part 'actions/updating.dart';
part 'actions/app_update.dart';
part 'generated/action.g.dart';

enum RunRequestPhase { idle, starting, stopping }

@immutable
class RunRequestState {
  const RunRequestState({this.phase = RunRequestPhase.idle, this.revision = 0});

  final RunRequestPhase phase;
  final int revision;

  bool get isStarting => phase == RunRequestPhase.starting;
}

class RunRequestStateNotifier extends Notifier<RunRequestState> {
  int _revision = 0;

  @override
  RunRequestState build() => const RunRequestState();

  int begin(bool running) {
    final revision = ++_revision;
    state = RunRequestState(
      phase: running ? RunRequestPhase.starting : RunRequestPhase.stopping,
      revision: revision,
    );
    return revision;
  }

  void finish(int revision) {
    if (state.revision != revision) return;
    state = RunRequestState(revision: revision);
  }
}

final runRequestStateProvider =
    NotifierProvider<RunRequestStateNotifier, RunRequestState>(
      RunRequestStateNotifier.new,
    );
