import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/common/tools_search.dart';
import 'package:reclash/views/tools/navigation.dart';
import 'package:reclash/views/url_scheme.dart';
import 'package:reclash/models/tools.dart';
import 'package:reclash/views/application_setting.dart';
import 'package:reclash/views/config/general.dart';
import 'package:reclash/views/config/web_dashboard.dart';
import 'package:reclash/views/tools/catalog.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

ToolEnvironment _environment({
  bool android = false,
  bool developer = false,
  bool authentication = false,
  bool controller = false,
  Set<String> dnsKeys = const {},
}) => ToolEnvironment(
  desktop: !android,
  android: android,
  windows: false,
  linux: !android,
  developer: developer,
  authentication: authentication,
  controller: controller,
  coreReady: false,
  logs: false,
  dnsKeys: dnsKeys,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('catalogue groups follow the Alpha section order', () async {
    expect(ToolCategory.values, [
      ToolCategory.observation,
      ToolCategory.configuration,
      ToolCategory.application,
      ToolCategory.information,
    ]);
    final l = await AppLocalizations.load(const Locale('en'));
    final catalog = buildToolCatalog(l, _environment());
    expect(
      catalog
          .where(
            (entry) =>
                entry.category == ToolCategory.configuration &&
                entry.showInCatalog,
          )
          .map((entry) => entry.id),
      [
        'page.general',
        'page.advanced',
        'page.resources',
        'page.backup',
        'page.customResources',
      ],
    );
  });

  test('web dashboard stays nested beside the external controller', () async {
    final l = await AppLocalizations.load(const Locale('en'));
    final catalog = buildToolCatalog(l, _environment());
    final dashboard = catalog.singleWhere(
      (entry) => entry.id == 'page.webDashboard',
    );
    expect(dashboard.route, const ToolRoute(ToolPage.webDashboard));
    expect(dashboard.path, contains(l.general));
    expect(dashboard.showInCatalog, isFalse);
    expect(ToolPage.webDashboard.ancestors, [ToolPage.general]);
    expect(webDashboardSetting.page, ToolPage.general);
    final ids = GeneralSettings.all.map((spec) => spec.id).toList();
    expect(
      ids.indexOf('general.webDashboard'),
      ids.indexOf('general.externalControllerSecret') + 1,
    );
  });

  test('catalogue has unique IDs and setting destinations exist', () async {
    final l = await AppLocalizations.load(const Locale('en'));
    final catalog = buildToolCatalog(l, _environment(developer: true));
    expect(catalog.map((e) => e.id).toSet().length, catalog.length);
    final pages = {
      for (final e in catalog)
        if (e.route?.settingId == null && e.route != null) e.route!.page,
    };
    for (final entry in catalog) {
      if (entry.route case final route?) {
        expect(pages, contains(route.page), reason: entry.id);
      }
    }
    final specs = toolSettingSpecs;
    expect(specs.map((s) => s.id).toSet().length, specs.length);
    expect(specs.map((spec) => spec.id), contains('developer.setup'));
    expect(specs.length, greaterThan(80));
  });

  test(
    'platform gates and dependency reasons do not fabricate settings',
    () async {
      final l = await AppLocalizations.load(const Locale('en'));
      final desktop = buildToolCatalog(l, _environment());
      expect(desktop.any((e) => e.id == 'application.hidden'), isFalse);
      expect(desktop.any((e) => e.id == 'page.access'), isFalse);
      expect(desktop.any((e) => e.id == 'page.developer'), isFalse);
      expect(
        desktop
            .singleWhere((e) => e.id == 'general.password')
            .unavailableReason,
        isNotNull,
      );
      expect(
        desktop
            .singleWhere((e) => e.id == 'general.externalControllerSecret')
            .unavailableReason,
        isNotNull,
      );
      final android = buildToolCatalog(
        l,
        _environment(android: true, authentication: true),
      );
      expect(android.any((e) => e.id == 'page.hotkey'), isFalse);
      expect(
        android
            .singleWhere((e) => e.id == 'general.password')
            .unavailableReason,
        isNull,
      );
      expect(android.any((e) => e.id == 'network.disableKeepAlive'), isFalse);
      final dns = desktop.where((e) => e.id.startsWith('dns.'));
      expect(dns, isNotEmpty);
      expect(
        dns.every(
          (e) =>
              e.unavailableReason != null &&
              e.fallback == const ToolRoute(ToolPage.dns),
        ),
        isTrue,
      );
    },
  );

  test(
    'nested sections and settings include their actual parent path',
    () async {
      final l = await AppLocalizations.load(const Locale('en'));
      final catalog = buildToolCatalog(l, _environment());
      final region = catalog.singleWhere((e) => e.id == 'page.appRegion');
      expect(region.route, const ToolRoute(ToolPage.appRegion));
      expect(region.path, contains(l.applicationSettings));
      expect(region.showInCatalog, isFalse);
      expect(ToolPage.appRegion.ancestors, [ToolPage.application]);
      expect(
        catalog.singleWhere((e) => e.id == 'page.network').path,
        contains(l.advancedConfig),
      );
      expect(
        catalog.singleWhere((e) => e.id == 'userAgents.default').path,
        contains(l.general),
      );
    },
  );

  test('stable IDs survive locale changes and never contain values', () async {
    final en = await AppLocalizations.load(const Locale('en'));
    final first = buildToolCatalog(en, _environment());
    final ru = await AppLocalizations.load(const Locale('ru'));
    final second = buildToolCatalog(ru, _environment());
    expect(second.map((e) => e.id), first.map((e) => e.id));
    expect(
      second.singleWhere((e) => e.id == 'page.application').title,
      'Настройки приложения',
    );
    final secret = second.singleWhere(
      (e) => e.id == 'general.externalControllerSecret',
    );
    expect(secret.document.keywords, ['externalControllerSecret']);
  });

  test(
    'URL scheme follows shortcuts in the application category on desktop',
    () async {
      final l = await AppLocalizations.load(const Locale('en'));
      final catalog = buildToolCatalog(l, _environment());
      final pages = catalog
          .where(
            (entry) =>
                entry.category == ToolCategory.application &&
                entry.showInCatalog,
          )
          .map((entry) => entry.id)
          .toList();
      expect(pages.indexOf('page.urlScheme'), pages.indexOf('page.hotkey') + 1);
      final entry = catalog.singleWhere(
        (entry) => entry.id == 'page.urlScheme',
      );
      expect(entry.route, const ToolRoute(ToolPage.urlScheme));
      expect(entry.path, l.applicationSettings);
      expect(toolPageOf(const UrlSchemeView()), ToolPage.urlScheme);
    },
  );

  test(
    'URL scheme is available on mobile and through localized search',
    () async {
      for (final locale in ['en', 'ru']) {
        final l = await AppLocalizations.load(Locale(locale));
        final catalog = buildToolCatalog(l, _environment(android: true));
        expect(
          catalog
              .singleWhere((entry) => entry.id == 'page.urlScheme')
              .showInCatalog,
          isTrue,
        );
        final search = ToolsSearch(catalog.map((entry) => entry.document));
        for (final query in [
          'url',
          'deep link',
          'automation',
          'ссылки',
          'автоматизация',
        ]) {
          expect(
            search.search(query).map((match) => match.document.id),
            contains('page.urlScheme'),
            reason: '$locale: $query',
          );
        }
      }
    },
  );

  test('application and core settings have disjoint owners', () {
    final app = ApplicationSettings.all;
    final general = GeneralSettings.all;
    expect(app.every((s) => s.page == ToolPage.application), isTrue);
    expect(general.every((s) => s.page == ToolPage.general), isTrue);
    expect(
      app.map((s) => s.id),
      containsAll([
        'application.autoRun',
        'application.openLogs',
        'application.checkCertificate',
      ]),
    );
    expect(
      general.map((s) => s.id),
      containsAll([
        'general.port',
        'general.logLevel',
        'general.testUrl',
        'general.userAgent',
      ]),
    );
    expect(
      app
          .map((s) => s.id)
          .toSet()
          .intersection(general.map((s) => s.id).toSet()),
      isEmpty,
    );
  });
}
