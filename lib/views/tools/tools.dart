import 'dart:io';

import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/settings/about.dart';
import 'package:reclash/views/settings/access.dart';
import 'package:reclash/views/settings/application_setting.dart';
import 'package:reclash/views/settings/backup_and_restore.dart';
import 'package:reclash/views/config/config.dart';
import 'package:reclash/views/settings/hotkey.dart';
import 'package:reclash/views/settings/locale.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' show dirname, join;

import '../appearance/appearance.dart';
import '../config/advanced.dart';
import '../settings/developer.dart';
import 'connection_doctor.dart';
import 'core.dart';
import 'findings.dart';
import '../settings/url_scheme.dart';

const toolsDoctorPaneId = 'doctor';

const _toolsListPaneWidth = 360.0;

class ToolsView extends ConsumerStatefulWidget {
  const ToolsView({super.key});

  @override
  ConsumerState<ToolsView> createState() => _ToolViewState();
}

class _ToolViewState extends ConsumerState<ToolsView> {
  String? _selectedPaneId;
  Widget? _selectedDetail;

  void _selectPane(SettingsPaneSelection selection) {
    if (selection.id == _selectedPaneId) {
      return;
    }
    setState(() {
      _selectedPaneId = selection.id;
      _selectedDetail = selection.detail;
    });
  }

  Widget _buildNavigationMenu(List<NavigationItem> navigationItems) {
    return SettingSection(
      top: 16,
      items: [
        const _ConnectionDoctorItem(),
        for (final navigationItem in navigationItems)
          DecorationListItem.open(
            leading: GlyphIcon(navigationItem.glyph),
            title: Text(navigationItem.label.label),
            subtitle: switch (navigationItem.label.description) {
              null => null,
              final description => Text(description),
            },
            widget: navigationItem.builder(context),
            maxWidth: 400,
            forceFull: false,
            paneId: 'nav_${navigationItem.label.name}',
          ),
      ],
    );
  }

  List<Widget> _getOtherList(bool enableDeveloperMode, bool hasFindings) {
    return [
      SettingSection(
        title: context.appLocalizations.other,
        items: [
          if (hasFindings) const _FindingsItem(),
          const _DisclaimerItem(),
          const _UrlSchemeItem(),
          if (enableDeveloperMode) const _DeveloperItem(),
          const _InfoItem(),
        ],
        enterDelay: const Duration(milliseconds: 100),
      ),
    ];
  }

  List<Widget> _getSettingList({required bool first}) {
    return [
      SettingSection(
        top: first ? 16 : 0,
        title: first ? null : context.appLocalizations.settings,
        items: [
          if (first) const _ConnectionDoctorItem(),
          const _LocaleItem(),
          const _ThemeItem(),
          const _BackupItem(),
          if (system.isDesktop) const _HotkeyItem(),
          if (system.isWindows) const _LoopbackItem(),
          if (system.isAndroid) const _AccessItem(),
          const _ConfigItem(),
          const _AdvancedConfigItem(),
          const _SettingItem(),
        ],
        enterDelay: const Duration(milliseconds: 50),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final appSetting = ref.watch(
      appSettingProvider.select(
        (state) => (locale: state.locale, developerMode: state.developerMode),
      ),
    );
    final hasFindings = ref.watch(
      visibleMilestonesProvider.select((state) => state.revealedAt.isNotEmpty),
    );
    final items = [
      Consumer(
        builder: (_, ref, _) {
          final state = ref.watch(moreToolsSelectorStateProvider);
          if (state.navigationItems.isEmpty) {
            return Container();
          }
          return _buildNavigationMenu(state.navigationItems);
        },
      ),
      ..._getSettingList(
        first: ref
            .watch(moreToolsSelectorStateProvider)
            .navigationItems
            .isEmpty,
      ),
      ..._getOtherList(appSetting.developerMode, hasFindings),
      const CoreSection(),
      const SettingBottomInset(),
    ];
    final viewMode = ref.watch(viewModeProvider);
    final list = ListView.builder(
      key: toolsStoreKey,
      padding: viewMode == ViewMode.desktop
          ? null
          : EdgeInsets.only(top: context.appBarInset),
      itemCount: items.length,
      itemBuilder: (_, index) => items[index],
    );
    if (viewMode != ViewMode.desktop) {
      return CommonScaffold(
        title: context.appLocalizations.tools,
        floatBody: true,
        body: SettingsPaneScope(
          active: false,
          selectedId: null,
          onSelect: _selectPane,
          child: list,
        ),
      );
    }
    return CommonScaffold(
      title: context.appLocalizations.tools,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: _toolsListPaneWidth,
            child: SettingsPaneScope(
              active: true,
              selectedId: _selectedPaneId,
              onSelect: _selectPane,
              child: list,
            ),
          ),
          VerticalDivider(
            width: 1,
            thickness: 1,
            color: context.colorScheme.outlineVariant.withValues(alpha: 0.6),
          ),
          Expanded(child: _buildDetailPane()),
        ],
      ),
    );
  }

  Widget _buildDetailPane() {
    final detail = _selectedDetail;
    if (detail == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            context.appLocalizations.toolsSelectPanePlaceholder,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyLarge?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }
    return SettingsPaneScope(
      active: false,
      selectedId: null,
      onSelect: _selectPane,
      child: SheetProvider(
        type: SheetType.page,
        child: Navigator(
          key: ValueKey(_selectedPaneId),
          onDidRemovePage: (_) {},
          pages: [MaterialPage<void>(child: detail)],
        ),
      ),
    );
  }
}

class _ConnectionDoctorItem extends ConsumerWidget {
  const _ConnectionDoctorItem();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final snapshot = ref.watch(connectionDoctorProvider);
    return DecorationListItem.open(
      leading: const GlyphIcon(AppGlyphs.healthMonitor),
      title: Text(appLocalizations.connectionDoctor),
      subtitle: Text(connectionDoctorTitle(appLocalizations, snapshot)),
      widget: const ConnectionDoctorView(),
      paneId: toolsDoctorPaneId,
    );
  }
}

class _FindingsItem extends StatelessWidget {
  const _FindingsItem();

  @override
  Widget build(BuildContext context) {
    return DecorationListItem.open(
      leading: const GlyphIcon(AppGlyphs.sparkle),
      title: Text(context.appLocalizations.findings),
      widget: const FindingsView(),
      paneId: 'findings',
    );
  }
}

class _LocaleItem extends ConsumerWidget {
  const _LocaleItem();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final currentLocale = getLocaleForString(
      ref.watch(appSettingProvider.select((state) => state.locale)),
    );
    return DecorationListItem.open(
      leading: const GlyphIcon(AppGlyphs.language),
      title: Text(appLocalizations.language),
      subtitle: Text(
        currentLocale?.nativeLabel ?? appLocalizations.defaultText,
      ),
      widget: const LocaleView(),
      paneId: 'locale',
    );
  }
}

class _ThemeItem extends StatelessWidget {
  const _ThemeItem();

  @override
  Widget build(BuildContext context) {
    return DecorationListItem.open(
      leading: const GlyphIcon(AppGlyphs.palette),
      title: Text(context.appLocalizations.appearance),
      subtitle: Text(context.appLocalizations.appearanceDesc),
      widget: const AppearanceView(),
      paneId: 'appearance',
    );
  }
}

class _BackupItem extends StatelessWidget {
  const _BackupItem();

  @override
  Widget build(BuildContext context) {
    return DecorationListItem.open(
      leading: const GlyphIcon(AppGlyphs.cloudSync),
      title: Text(context.appLocalizations.backupAndRestore),
      subtitle: Text(context.appLocalizations.backupAndRestoreDesc),
      widget: const BackupAndRestore(),
      paneId: 'backup',
    );
  }
}

class _HotkeyItem extends StatelessWidget {
  const _HotkeyItem();

  @override
  Widget build(BuildContext context) {
    return DecorationListItem.open(
      leading: const GlyphIcon(AppGlyphs.keyboard),
      title: Text(context.appLocalizations.hotkeyManagement),
      subtitle: Text(context.appLocalizations.hotkeyManagementDesc),
      widget: const HotKeyView(),
      paneId: 'hotkey',
    );
  }
}

class _LoopbackItem extends StatelessWidget {
  const _LoopbackItem();

  @override
  Widget build(BuildContext context) {
    return DecorationListItem(
      leading: const GlyphIcon(AppGlyphs.lock),
      title: Text(context.appLocalizations.loopback),
      subtitle: Text(context.appLocalizations.loopbackDesc),
      onPressed: () {
        windows?.runas(
          '"${join(dirname(Platform.resolvedExecutable), "EnableLoopback.exe")}"',
          '',
        );
      },
    );
  }
}

class _AccessItem extends StatelessWidget {
  const _AccessItem();

  @override
  Widget build(BuildContext context) {
    return DecorationListItem.open(
      leading: const GlyphIcon(AppGlyphs.list),
      title: Text(context.appLocalizations.accessControl),
      subtitle: Text(context.appLocalizations.accessControlDesc),
      widget: const AccessView(),
      paneId: 'access',
    );
  }
}

class _ConfigItem extends StatelessWidget {
  const _ConfigItem();

  @override
  Widget build(BuildContext context) {
    return DecorationListItem.open(
      leading: const GlyphIcon(AppGlyphs.edit),
      title: Text(context.appLocalizations.basicConfig),
      subtitle: Text(context.appLocalizations.basicConfigDesc),
      widget: const ConfigView(),
      paneId: 'config',
    );
  }
}

class _AdvancedConfigItem extends StatelessWidget {
  const _AdvancedConfigItem();

  @override
  Widget build(BuildContext context) {
    return DecorationListItem.open(
      leading: const GlyphIcon(AppGlyphs.wrench),
      title: Text(context.appLocalizations.advancedConfig),
      subtitle: Text(context.appLocalizations.advancedConfigDesc),
      widget: const AdvancedConfigView(),
      paneId: 'advanced',
    );
  }
}

class _SettingItem extends StatelessWidget {
  const _SettingItem();

  @override
  Widget build(BuildContext context) {
    return DecorationListItem.open(
      leading: const GlyphIcon(AppGlyphs.settings),
      title: Text(context.appLocalizations.application),
      subtitle: Text(context.appLocalizations.applicationDesc),
      widget: const ApplicationSettingView(),
      paneId: 'application',
    );
  }
}

class _DisclaimerItem extends ConsumerWidget {
  const _DisclaimerItem();

  @override
  Widget build(BuildContext context, ref) {
    return DecorationListItem(
      leading: const GlyphIcon(AppGlyphs.gavel),
      title: Text(context.appLocalizations.disclaimer),
      onPressed: () async {
        final isDisclaimerAccepted = await dialogs.showDisclaimer();
        if (!isDisclaimerAccepted) {
          await ref.read(systemActionProvider.notifier).handleExit();
        }
      },
    );
  }
}

class _UrlSchemeItem extends StatelessWidget {
  const _UrlSchemeItem();

  @override
  Widget build(BuildContext context) {
    return DecorationListItem.open(
      leading: const GlyphIcon(AppGlyphs.link),
      title: Text(context.appLocalizations.urlScheme),
      widget: const UrlSchemeView(),
      paneId: 'urlScheme',
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem();

  @override
  Widget build(BuildContext context) {
    return DecorationListItem.open(
      leading: const GlyphIcon(AppGlyphs.info),
      title: Text(context.appLocalizations.about),
      widget: const AboutView(),
      paneId: 'about',
    );
  }
}

class _DeveloperItem extends StatelessWidget {
  const _DeveloperItem();

  @override
  Widget build(BuildContext context) {
    return DecorationListItem.open(
      leading: const GlyphIcon(AppGlyphs.cpu),
      title: Text(context.appLocalizations.developerMode),
      widget: const DeveloperView(),
      paneId: 'developer',
    );
  }
}
