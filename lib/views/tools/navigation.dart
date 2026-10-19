import 'package:reclash/views/config/override.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/models/tools.dart';
import 'package:reclash/views/about.dart';
import 'package:reclash/views/access.dart';
import 'package:reclash/views/application_setting.dart';
import 'package:reclash/views/backup_and_restore.dart';
import 'package:reclash/views/config/advanced.dart';
import 'package:reclash/views/config/custom_resources.dart';
import 'package:reclash/views/config/dns.dart';
import 'package:reclash/views/config/general.dart';
import 'package:reclash/views/config/web_dashboard.dart';
import 'package:reclash/views/config/network.dart';
import 'package:reclash/views/config/on_demand.dart';
import 'package:reclash/views/config/rules.dart';
import 'package:reclash/views/config/scripts.dart';
import 'package:reclash/views/config/user_agents.dart';
import 'package:reclash/views/connection/connections.dart';
import 'package:reclash/views/connection/requests.dart';
import 'package:reclash/views/developer.dart';
import 'package:reclash/views/disclaimer.dart';
import 'package:reclash/views/dns_queries.dart';
import 'package:reclash/views/hotkey.dart';
import 'package:reclash/views/hotkey_desktop.dart';
import 'package:reclash/views/language.dart';
import 'package:reclash/views/logs.dart';
import 'package:reclash/views/region.dart';
import 'package:reclash/views/resources.dart';
import 'package:reclash/views/theme.dart';
import 'package:reclash/views/tools/core.dart';
import 'package:reclash/views/url_scheme.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';

ToolPage? toolPageOf(Widget widget) => switch (widget) {
  ApplicationSettingView() => ToolPage.application,
  GeneralView() => ToolPage.general,
  WebDashboardView() => ToolPage.webDashboard,
  AdvancedConfigView() => ToolPage.advanced,
  BaseScaffold(body: NetworkListView()) ||
  NetworkListView() => ToolPage.network,
  DnsView(spec: final spec) when spec.target is PatchOverrideTarget =>
    ToolPage.dns,
  OnDemandView() => ToolPage.onDemand,
  RegionView() => ToolPage.appRegion,
  UserAgentsView() => ToolPage.userAgents,
  ThemeView() => ToolPage.theme,
  LanguageView() => ToolPage.locale,
  HotKeyView() => ToolPage.hotkey,
  HotkeyDesktopView() => ToolPage.hotkeyDesktop,
  UrlSchemeView() => ToolPage.urlScheme,
  AccessView() => ToolPage.access,
  ResourcesView() => ToolPage.resources,
  CustomResourcesView() => ToolPage.customResources,
  BackupAndRestore() => ToolPage.backup,
  AboutView() => ToolPage.about,
  DisclaimerView() => ToolPage.disclaimer,
  DeveloperView() => ToolPage.developer,
  RequestsView() => ToolPage.requests,
  ConnectionsView() => ToolPage.connections,
  DnsQueriesView() => ToolPage.dnsQueries,
  LogsView() => ToolPage.logs,
  AddedRulesView() => ToolPage.rules,
  ScriptsView() => ToolPage.scripts,
  CoreDetailView() => ToolPage.coreDetails,
  CoreRuntimeConfigView() => ToolPage.coreRuntimeConfig,
  _ => null,
};

Widget buildToolPage(ToolPage page, BuildContext context) => switch (page) {
  ToolPage.application => const ApplicationSettingView(),
  ToolPage.general => const GeneralView(),
  ToolPage.webDashboard => const WebDashboardView(),
  ToolPage.advanced => const AdvancedConfigView(),
  ToolPage.network => BaseScaffold(
    title: context.appLocalizations.network,
    body: const NetworkListView(),
  ),
  ToolPage.dns => const DnsView(),
  ToolPage.onDemand => const OnDemandView(),
  ToolPage.appRegion => const RegionView(),
  ToolPage.userAgents => const UserAgentsView(),
  ToolPage.theme => const ThemeView(),
  ToolPage.locale => const LanguageView(),
  ToolPage.hotkey => const HotKeyView(),
  ToolPage.hotkeyDesktop => const HotkeyDesktopView(),
  ToolPage.urlScheme => const UrlSchemeView(),
  ToolPage.access => const AccessView(),
  ToolPage.resources => const ResourcesView(),
  ToolPage.customResources => const CustomResourcesView(),
  ToolPage.backup => const BackupAndRestore(),
  ToolPage.about => const AboutView(),
  ToolPage.disclaimer => const DisclaimerView(),
  ToolPage.developer => const DeveloperView(),
  ToolPage.requests => const RequestsView(),
  ToolPage.connections => const ConnectionsView(),
  ToolPage.dnsQueries => const DnsQueriesView(),
  ToolPage.logs => const LogsView(),
  ToolPage.rules => const AddedRulesView(),
  ToolPage.scripts => const ScriptsView(),
  ToolPage.coreDetails => const CoreDetailView(),
  ToolPage.coreRuntimeConfig => const CoreRuntimeConfigView(),
};
