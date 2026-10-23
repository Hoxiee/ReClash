import 'dart:collection';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/common/web_dashboard/access.dart';
import 'package:reclash/common/regional/device_region_signals.dart';
import 'package:reclash/common/regional/region_detection.dart';
import 'package:reclash/common/regional/regional_network.dart';
import 'package:reclash/database/database.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/subscriptions/transport/header_policy.dart';
import 'notification.dart';
import 'package:reclash/ui/ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'app.dart';
import 'config.dart';
import 'on_demand.dart';
import 'core.dart';
import 'database.dart';
import 'provider_settings.dart';
import 'routing.dart';
import 'web_dashboard.dart';

part 'generated/state.g.dart';
part 'state/proxies.dart';
part 'state/navigation.dart';
part 'state/system.dart';
part 'state/theme.dart';
part 'state/profile.dart';
part 'state/custom.dart';
part 'state/custom_import.dart';
