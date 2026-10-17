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
