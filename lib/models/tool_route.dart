import 'package:flutter/foundation.dart';

enum ToolPage {
  application,
  general,
  advanced,
  network,
  dns,
  onDemand,
  appRegion,
  userAgents,
  webDashboard,
  theme,
  locale,
  hotkey,
  hotkeyDesktop,
  access,
  resources,
  customResources,
  backup,
  about,
  disclaimer,
  developer,
  requests,
  connections,
  dnsQueries,
  logs,
  rules,
  scripts,
  coreDetails,
  coreRuntimeConfig,
}

extension ToolPageHierarchy on ToolPage {
  ToolPage? get parent => switch (this) {
    ToolPage.network ||
    ToolPage.dns ||
    ToolPage.rules ||
    ToolPage.scripts => ToolPage.advanced,
    ToolPage.userAgents || ToolPage.webDashboard => ToolPage.general,
    ToolPage.onDemand || ToolPage.appRegion => ToolPage.application,
    ToolPage.coreRuntimeConfig => ToolPage.coreDetails,
    ToolPage.hotkeyDesktop => ToolPage.hotkey,
    _ => null,
  };

  List<ToolPage> get ancestors => [
    if (parent case final parent?) ...parent.ancestors,
    ?parent,
  ];
}

@immutable
class ToolRoute {
  const ToolRoute(this.page, {this.settingId});

  final ToolPage page;
  final String? settingId;

  String get id => settingId ?? 'page.${page.name}';

  @override
  bool operator ==(Object other) =>
      other is ToolRoute && other.page == page && other.settingId == settingId;

  @override
  int get hashCode => Object.hash(page, settingId);
}
