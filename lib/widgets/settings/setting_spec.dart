import 'package:material_ui/material_ui.dart' show ThemeMode;
import 'package:reclash/enum/enum.dart' show NavigationLayout;
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/tool_route.dart';

enum SettingCondition {
  always,
  android,
  desktop,
  windows,
  linuxOrWindows,
  authentication,
  controller,
  developer,
  dnsOverride,
  macos,
  linux,
  customInterface,
  mipsStack,
  sidebarBlur,
  navigationBar,
  navigationSidebar,
  darkTheme,
  contextual,
  remoteBackup,
  locationPermission,
}

class SettingSpec {
  const SettingSpec({
    required this.id,
    required this.page,
    required this.title,
    this.keywords = const [],
    this.condition = SettingCondition.always,
  });

  final String id;
  final ToolPage page;
  final String Function(AppLocalizations l) title;
  final List<String> keywords;
  final SettingCondition condition;

  ToolRoute get route => ToolRoute(page, settingId: id);
}

bool isAppearanceSettingVisible(
  SettingCondition condition, {
  required NavigationLayout layout,
  required ThemeMode themeMode,
}) => switch (condition) {
  SettingCondition.navigationBar => layout != NavigationLayout.sidebar,
  SettingCondition.navigationSidebar ||
  SettingCondition.sidebarBlur => layout != NavigationLayout.bar,
  SettingCondition.darkTheme => themeMode != ThemeMode.light,
  _ => true,
};
