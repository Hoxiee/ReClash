import 'package:flutter/foundation.dart';

enum ToolPage {
  application,
  general,
  advanced,
  network,
  dns,
  onDemand,
  appRegion,
  notifications,
  userAgents,
  webDashboard,
  theme,
  locale,
  hotkey,
  hotkeyDesktop,
  urlScheme,
  access,
  resources,
  customResources,
  customProxies,
  ruleProviders,
  filters,
  iconSets,
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
  routing,
  coreDetails,
  coreRuntimeConfig,
}

extension ToolPageHierarchy on ToolPage {
  ToolPage? get parent => switch (this) {
    ToolPage.network ||
    ToolPage.dns ||
    ToolPage.rules ||
    ToolPage.scripts ||
    ToolPage.routing => ToolPage.advanced,
    ToolPage.userAgents || ToolPage.webDashboard => ToolPage.general,
    ToolPage.onDemand ||
    ToolPage.appRegion ||
    ToolPage.notifications => ToolPage.application,
    ToolPage.customProxies ||
    ToolPage.ruleProviders ||
    ToolPage.filters ||
    ToolPage.iconSets => ToolPage.customResources,
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
