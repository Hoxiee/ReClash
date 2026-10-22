import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationServerGroupProvider = Provider<String?>((ref) {
  final settings = ref.watch(
    appSettingProvider.select((s) => s.notificationSettings),
  );
  if (!settings.detailed) return null;
  final component = settings.components
      .where((c) => c.type == NotificationComponentType.currentServer)
      .firstOrNull;
  if (component == null) return null;
  final groups = ref.watch(currentGroupsStateProvider).value;
  if (component.group case final group?) {
    return groups.any((g) => g.name == group) ? group : null;
  }
  final mode = ref.watch(patchClashConfigProvider.select((s) => s.mode));
  if (mode == Mode.direct) return null;
  if (mode == Mode.global) {
    return groups.any((g) => g.name == 'GLOBAL') ? 'GLOBAL' : null;
  }
  final selected = ref.watch(
    currentProfileProvider.select((s) => s?.currentGroupName),
  );
  return groups.where((g) => g.name == selected).firstOrNull?.name ??
      groups.firstOrNull?.name;
});
