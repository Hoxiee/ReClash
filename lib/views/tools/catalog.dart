import 'package:reclash/views/resources.dart';
import 'package:reclash/common/tools_search.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/tools.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/views/application_setting.dart';
import 'package:reclash/views/config/advanced.dart';
import 'package:reclash/views/config/custom_resources.dart';
import 'package:reclash/views/config/dns.dart';
import 'package:reclash/views/config/general.dart';
import 'package:reclash/views/config/network.dart';
import 'package:reclash/views/config/on_demand.dart';
import 'package:reclash/views/config/user_agents.dart';
import 'package:reclash/views/theme.dart';
import 'package:reclash/views/hotkey.dart';
import 'package:reclash/views/access.dart';
import 'package:reclash/views/backup_and_restore.dart';
import 'package:reclash/views/developer.dart';
import 'package:reclash/widgets/settings/setting_spec.dart';

enum ToolCategory { observation, configuration, application, information }

class ToolEntry {
  const ToolEntry({
    required this.id,
    required this.title,
    required this.category,
    required this.glyph,
    this.route,
    this.command,
    this.keywords = const [],
    this.path = '',
    this.unavailableReason,
    this.fallback,
    this.showInCatalog = true,
  });

  final String id;
  final String title;
  final ToolCategory category;
  final Glyph glyph;
  final ToolRoute? route;
  final ToolCommand? command;
  final List<String> keywords;
  final String path;
  final String? unavailableReason;
  final ToolRoute? fallback;
  final bool showInCatalog;

  ToolSearchDocument get document =>
      ToolSearchDocument(id: id, title: title, path: path, keywords: keywords);
}

class ToolEnvironment {
  const ToolEnvironment({
    required this.desktop,
    required this.android,
    required this.windows,
    required this.linux,
    required this.developer,
    required this.authentication,
    required this.controller,
    required this.coreReady,
    required this.logs,
    this.morePages = const {},
    this.macos = false,
    this.customInterface = false,
    this.mipsStack = false,
    this.sidebarBlur = false,
    this.dnsKeys = const {},
    this.webdav = false,
  });

  final bool desktop;
  final bool android;
  final bool windows;
  final bool linux;
  final bool developer;
  final bool authentication;
  final bool controller;
  final bool coreReady;
  final bool logs;
  final Set<ToolPage> morePages;
  final bool macos;
  final bool customInterface;
  final bool mipsStack;
  final bool sidebarBlur;
  final Set<String> dnsKeys;
  final bool webdav;
}

String toolCategoryLabel(ToolCategory category, AppLocalizations l) =>
    switch (category) {
      ToolCategory.observation => l.toolsObservation,
      ToolCategory.configuration => l.toolsConfiguration,
      ToolCategory.application => l.applicationSettings,
      ToolCategory.information => l.toolsInformation,
    };

List<SettingSpec> get toolSettingSpecs => [
  ...ApplicationSettings.all,
  ...GeneralSettings.all,
  ...advancedToolSettings,
  ...networkToolSettings,
  ...dnsToolSettings,
  ...onDemandToolSettings,
  ...userAgentToolSettings,
  ...customResourceToolSettings,
  ...themeToolSettings,
  ...hotkeyToolSettings,
  ...accessToolSettings,
  ...backupToolSettings,
  ...developerToolSettings,
  ...resourceToolSettings,
];

List<ToolEntry> buildToolCatalog(AppLocalizations l, ToolEnvironment env) {
  final pages = <ToolEntry>[];
  void page(
    ToolPage page,
    String title,
    ToolCategory category,
    Glyph glyph, {
    bool available = true,
    bool root = true,
    List<String> keywords = const [],
  }) {
    if (!available) return;
    pages.add(
      ToolEntry(
        id: 'page.${page.name}',
        title: title,
        category: category,
        glyph: glyph,
        route: ToolRoute(page),
        keywords: [page.name, ...keywords],
        path: {
          toolCategoryLabel(category, l),
          for (final ancestor in page.ancestors)
            pages.firstWhere((entry) => entry.route?.page == ancestor).title,
        }.join(' › '),
        showInCatalog: root,
      ),
    );
  }

  page(
    ToolPage.application,
    l.applicationSettings,
    ToolCategory.application,
    AppGlyphs.settings,
    keywords: ['application', 'startup', 'приложение'],
  );
  page(
    ToolPage.appRegion,
    l.regionTitle,
    ToolCategory.application,
    AppGlyphs.language,
    root: false,
  );
  page(
    ToolPage.theme,
    l.theme,
    ToolCategory.application,
    AppGlyphs.paintbrush,
    keywords: ['appearance', 'оформление'],
  );
  page(
    ToolPage.locale,
    l.language,
    ToolCategory.application,
    AppGlyphs.language,
    keywords: ['locale', 'язык'],
  );
  page(
    ToolPage.hotkey,
    l.hotkeyManagement,
    ToolCategory.application,
    AppGlyphs.keyboard,
    available: env.desktop,
  );
  page(
    ToolPage.hotkeyDesktop,
    l.hotkeyDesktopCommands,
    ToolCategory.application,
    AppGlyphs.code,
    available: env.desktop,
    root: false,
  );
  page(
    ToolPage.urlScheme,
    l.urlScheme,
    ToolCategory.application,
    AppGlyphs.link,
    keywords: ['url', 'deep link', 'automation', 'ссылки', 'автоматизация'],
  );
  page(
    ToolPage.general,
    l.general,
    ToolCategory.configuration,
    AppGlyphs.settings,
    keywords: ['core', 'ядро'],
  );
  page(
    ToolPage.webDashboard,
    l.webDashboard,
    ToolCategory.configuration,
    AppGlyphs.dashboard,
    root: false,
    keywords: ['web panel', 'web dashboard', 'zashboard', 'metacubexd'],
  );
  page(
    ToolPage.advanced,
    l.advancedConfig,
    ToolCategory.configuration,
    AppGlyphs.wrench,
  );
  page(
    ToolPage.network,
    l.network,
    ToolCategory.configuration,
    AppGlyphs.key,
    root: false,
  );
  page(
    ToolPage.dns,
    'DNS',
    ToolCategory.configuration,
    AppGlyphs.dns,
    root: false,
  );
  page(
    ToolPage.onDemand,
    l.onDemand,
    ToolCategory.application,
    AppGlyphs.settings,
    root: false,
  );
  page(
    ToolPage.userAgents,
    'User-Agent',
    ToolCategory.configuration,
    AppGlyphs.code,
    root: false,
  );
  page(
    ToolPage.access,
    l.accessControl,
    ToolCategory.configuration,
    AppGlyphs.appsList,
    available: env.android,
  );
  page(
    ToolPage.resources,
    l.resources,
    ToolCategory.configuration,
    AppGlyphs.resources,
  );
  page(
    ToolPage.backup,
    l.backupAndRestore,
    ToolCategory.configuration,
    AppGlyphs.cloudSync,
  );
  page(
    ToolPage.customResources,
    l.customProfileResources,
    ToolCategory.configuration,
    AppGlyphs.customize,
  );
  page(
    ToolPage.rules,
    l.addedRules,
    ToolCategory.configuration,
    AppGlyphs.rules,
    root: false,
  );
  page(
    ToolPage.scripts,
    l.script,
    ToolCategory.configuration,
    AppGlyphs.code,
    root: false,
  );
  page(
    ToolPage.requests,
    l.requests,
    ToolCategory.observation,
    AppGlyphs.requests,
    root: env.morePages.contains(ToolPage.requests),
  );
  page(
    ToolPage.connections,
    l.connections,
    ToolCategory.observation,
    AppGlyphs.connections,
    root: env.morePages.contains(ToolPage.connections),
  );
  page(
    ToolPage.dnsQueries,
    l.dnsQueries,
    ToolCategory.observation,
    AppGlyphs.dns,
    root: env.morePages.contains(ToolPage.dnsQueries),
  );
  page(
    ToolPage.logs,
    l.logs,
    ToolCategory.observation,
    AppGlyphs.logs,
    available: env.logs,
    root: env.morePages.contains(ToolPage.logs),
  );
  page(
    ToolPage.coreDetails,
    l.core,
    ToolCategory.information,
    AppGlyphs.cpu,
    root: false,
    keywords: ['mihomo', 'proxy', 'ядро'],
  );
  page(
    ToolPage.coreRuntimeConfig,
    l.coreRuntimeConfig,
    ToolCategory.information,
    AppGlyphs.code,
    root: false,
  );
  page(
    ToolPage.disclaimer,
    l.disclaimer,
    ToolCategory.information,
    AppGlyphs.gavel,
  );
  page(ToolPage.about, l.about, ToolCategory.information, AppGlyphs.info);
  page(
    ToolPage.developer,
    l.developerMode,
    ToolCategory.information,
    AppGlyphs.cpu,
    available: env.developer,
  );
  final byPage = {for (final entry in pages) entry.route!.page: entry};
  final entries = <ToolEntry>[...pages];
  for (final spec in toolSettingSpecs) {
    final owner = byPage[spec.page];
    if (owner == null) continue;
    final supported = switch (spec.condition) {
      SettingCondition.android => env.android,
      SettingCondition.desktop => env.desktop,
      SettingCondition.windows => env.windows,
      SettingCondition.linuxOrWindows => env.linux || env.windows,
      SettingCondition.developer => env.developer,
      SettingCondition.locationPermission => env.android || env.macos,
      SettingCondition.contextual => false,
      SettingCondition.remoteBackup => true,
      SettingCondition.macos => env.macos,
      SettingCondition.linux => env.linux,
      SettingCondition.sidebarBlur => env.sidebarBlur,
      SettingCondition.customInterface => env.desktop,
      SettingCondition.mipsStack => true,
      _ => true,
    };
    if (!supported) continue;
    final reason = switch (spec.condition) {
      SettingCondition.remoteBackup when !env.webdav => l.toolsNeedsWebdav,
      SettingCondition.mipsStack when !env.mipsStack => l.toolsNeedsMipsStack,
      SettingCondition.authentication when !env.authentication =>
        l.toolsNeedsAuthentication,
      SettingCondition.controller when !env.controller =>
        l.toolsNeedsController,
      SettingCondition.dnsOverride
          when !env.dnsKeys.contains(spec.id.substring(4)) =>
        l.toolsNeedsOverride,
      SettingCondition.customInterface when !env.customInterface =>
        l.toolsNeedsCustomInterface,
      _ => null,
    };
    entries.add(
      ToolEntry(
        id: spec.id,
        title: spec.title(l),
        category: owner.category,
        glyph: owner.glyph,
        route: spec.route,
        keywords: [...spec.keywords, spec.id.split('.').last],
        path: {
          toolCategoryLabel(owner.category, l),
          for (final ancestor in spec.page.ancestors)
            pages.firstWhere((entry) => entry.route?.page == ancestor).title,
          owner.title,
        }.join(' › '),
        unavailableReason: reason,
        fallback: reason == null
            ? null
            : switch (spec.condition) {
                SettingCondition.remoteBackup => const ToolRoute(
                  ToolPage.backup,
                ),
                SettingCondition.mipsStack => const ToolRoute(
                  ToolPage.network,
                  settingId: 'network.stackMode',
                ),
                SettingCondition.dnsOverride => const ToolRoute(ToolPage.dns),
                SettingCondition.customInterface => const ToolRoute(
                  ToolPage.network,
                  settingId: 'network.interfaceNameMode',
                ),
                SettingCondition.authentication => const ToolRoute(
                  ToolPage.general,
                  settingId: 'general.authentication',
                ),
                _ => const ToolRoute(
                  ToolPage.general,
                  settingId: 'general.externalController',
                ),
              },
        showInCatalog: false,
      ),
    );
  }
  for (final command in ToolCommand.values) {
    final title = switch (command) {
      ToolCommand.checkUpdates => l.checkUpdate,
      ToolCommand.updateResources => l.toolsUpdateResources,
      ToolCommand.closeConnections => l.closeConnections,
      ToolCommand.restartCore => l.toolsRestartCore,
    };
    entries.add(
      ToolEntry(
        id: 'command.${command.name}',
        title: title,
        category: ToolCategory.observation,
        glyph: AppGlyphs.sync,
        command: command,
        path: l.toolsAction,
        keywords: [command.name],
        showInCatalog: false,
        unavailableReason: command == ToolCommand.checkUpdates || env.coreReady
            ? null
            : l.toolsNeedsCore,
      ),
    );
  }
  return List.unmodifiable(entries);
}
