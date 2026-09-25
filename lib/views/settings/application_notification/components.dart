part of '../application_notification.dart';

String _componentLabel(AppLocalizations l, NotificationComponentType type) =>
    switch (type) {
      NotificationComponentType.connectionDoctor =>
        l.notificationConnectionDoctor,
      NotificationComponentType.networkState => l.notificationNetworkState,
      NotificationComponentType.currentServer => l.notificationCurrentServer,
      NotificationComponentType.smartRouting => l.notificationSmartRouting,
      NotificationComponentType.speed => l.notificationNetworkSpeed,
      NotificationComponentType.sessionTraffic => l.notificationSessionTraffic,
    };

String _componentDescription(
  AppLocalizations l,
  NotificationComponentType type,
) => switch (type) {
  NotificationComponentType.connectionDoctor =>
    l.notificationConnectionDoctorDesc,
  NotificationComponentType.networkState => l.notificationNetworkStateDesc,
  NotificationComponentType.currentServer => l.notificationCurrentServerDesc,
  NotificationComponentType.smartRouting => l.notificationSmartRoutingDesc,
  NotificationComponentType.speed => l.notificationNetworkSpeedDesc,
  NotificationComponentType.sessionTraffic => l.notificationSessionTrafficDesc,
};

/// When the line reaches the notification, given the component's own options.
String _componentVisibility(
  AppLocalizations l,
  NotificationComponent component,
) => switch (component.type) {
  NotificationComponentType.connectionDoctor =>
    component.doctorPriority == DoctorNotificationPriority.always
        ? l.notificationVisibilityAlways
        : l.notificationVisibilityDoctorProblems,
  NotificationComponentType.networkState ||
  NotificationComponentType.smartRouting =>
    l.notificationVisibilitySmartRoutingOn,
  NotificationComponentType.currentServer =>
    l.notificationVisibilityCurrentServer,
  NotificationComponentType.speed =>
    component.hideWhenIdle == false
        ? l.notificationVisibilityAlways
        : l.notificationVisibilitySpeedIdle,
  NotificationComponentType.sessionTraffic =>
    l.notificationVisibilitySessionTraffic,
};

String _componentStatus(AppLocalizations l, NotificationComponent component) =>
    switch (component.type) {
      NotificationComponentType.connectionDoctor => _doctorPriorityLabel(
        l,
        component.doctorPriority ?? DoctorNotificationPriority.problems,
      ),
      NotificationComponentType.currentServer =>
        component.group ?? l.notificationAutomaticGroup,
      _ => _componentVisibility(l, component),
    };

Glyph _componentIcon(NotificationComponentType type) => switch (type) {
  NotificationComponentType.connectionDoctor => AppGlyphs.safety,
  NotificationComponentType.networkState => AppGlyphs.route,
  NotificationComponentType.currentServer => AppGlyphs.dns,
  NotificationComponentType.smartRouting => AppGlyphs.route,
  NotificationComponentType.speed => AppGlyphs.speed,
  NotificationComponentType.sessionTraffic => AppGlyphs.dataUsage,
};

/// What the notification service needs before a component can print its line.
/// The rows and the component sheet both report it, so a component that is
/// configured but silent right now says why.
typedef _ComponentEnvironment = ({
  bool smartRouting,
  String? serverGroup,
  List<Group> serverGroups,
  bool serverGroupMissing,
});

_ComponentEnvironment _watchEnvironment(WidgetRef ref) {
  final groups = displayServerGroups(
    ref.watch(patchClashConfigProvider.select((state) => state.mode)),
    ref.watch(groupsProvider),
  );
  final chosenGroup = ref.watch(
    appSettingProvider.select(
      (state) => state.notificationSettings.components
          .where((item) => item.type == NotificationComponentType.currentServer)
          .firstOrNull
          ?.group,
    ),
  );
  return (
    smartRouting: ref.watch(
      smartRoutingSettingProvider.select((state) => state.enabled),
    ),
    serverGroup: ref.watch(activeServerGroupProvider),
    serverGroups: groups,
    serverGroupMissing:
        chosenGroup != null &&
        chosenGroup.isNotEmpty &&
        groups.getGroup(chosenGroup) == null,
  );
}

/// Why the component prints nothing, or prints something other than what it
/// was configured to print. Only a broken configuration is severe; a line that
/// is merely silent right now stays quiet about it.
typedef _ComponentNotice = ({String text, bool severe});

_ComponentNotice? _componentNotice(
  AppLocalizations l,
  NotificationComponentType type,
  _ComponentEnvironment environment,
) {
  switch (type) {
    case NotificationComponentType.networkState:
    case NotificationComponentType.smartRouting:
      return environment.smartRouting
          ? null
          : (text: l.notificationBlockedSmartRoutingOff, severe: false);
    case NotificationComponentType.currentServer:
      if (environment.serverGroupMissing) {
        return (text: l.notificationServerGroupMissing, severe: true);
      }
      return environment.serverGroup == null
          ? (text: l.notificationBlockedNoServerGroup, severe: false)
          : null;
    case NotificationComponentType.connectionDoctor:
    case NotificationComponentType.speed:
    case NotificationComponentType.sessionTraffic:
      return null;
  }
}

NotificationComponent _defaultComponent(NotificationComponentType type) =>
    switch (type) {
      NotificationComponentType.connectionDoctor => const NotificationComponent(
        type: NotificationComponentType.connectionDoctor,
        doctorPriority: DoctorNotificationPriority.problems,
      ),
      NotificationComponentType.speed => const NotificationComponent(
        type: NotificationComponentType.speed,
        hideWhenIdle: true,
      ),
      _ => NotificationComponent(type: type),
    };

String _doctorPriorityLabel(
  AppLocalizations l,
  DoctorNotificationPriority priority,
) => switch (priority) {
  DoctorNotificationPriority.problems => l.notificationDoctorPriorityProblems,
  DoctorNotificationPriority.always => l.notificationDoctorPriorityAlways,
};

void _writeComponents(WidgetRef ref, List<NotificationComponent> components) {
  ref
      .read(appSettingProvider.notifier)
      .update(
        (state) => state.copyWith(
          notificationSettings: state.notificationSettings.copyWith(
            components: List.unmodifiable(components),
          ),
        ),
      );
}
