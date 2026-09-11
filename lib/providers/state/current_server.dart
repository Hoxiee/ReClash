part of '../state.dart';

List<Group> displayServerGroups(Mode mode, List<Group> groups) =>
    switch (mode) {
      Mode.direct => const [],
      Mode.global => groups,
      Mode.rule =>
        groups
            .where((group) => group.hidden == false)
            .where((group) => group.name != GroupName.GLOBAL.name)
            .toList(),
    };

String? selectCurrentServerGroupHint({
  required Mode mode,
  required List<Group> groups,
  String? componentGroup,
  String? profileGroup,
}) {
  final displayGroups = displayServerGroups(mode, groups);
  final explicitGroup = componentGroup?.trim();
  if (explicitGroup != null &&
      explicitGroup.isNotEmpty &&
      displayGroups.getGroup(explicitGroup) != null) {
    return explicitGroup;
  }

  final preferredGroup = profileGroup?.trim();
  if (preferredGroup != null &&
      preferredGroup.isNotEmpty &&
      displayGroups.getGroup(preferredGroup) != null) {
    return preferredGroup;
  }

  for (final group in displayGroups) {
    final selected = group.realNow;
    if (selected.isNotEmpty && selected != 'DIRECT' && selected != 'REJECT') {
      return group.name;
    }
  }
  return null;
}

@riverpod
String? activeServerGroup(Ref ref) {
  final mode = ref.watch(
    patchClashConfigProvider.select((state) => state.mode),
  );
  final groups = ref.watch(groupsProvider);
  final profileGroup = ref.watch(
    currentProfileProvider.select((state) => state?.panelMeta?.serverInfoGroup),
  );
  final componentGroup = ref.watch(
    appSettingProvider.select(
      (state) => state.notificationSettings.components
          .where(
            (component) =>
                component.type == NotificationComponentType.currentServer,
          )
          .firstOrNull
          ?.group,
    ),
  );
  return selectCurrentServerGroupHint(
    mode: mode,
    groups: groups,
    componentGroup: componentGroup,
    profileGroup: profileGroup,
  );
}
