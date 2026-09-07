import 'dart:io';

import 'package:reclash/common/common.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/about.dart';
import 'package:reclash/views/access.dart';
import 'package:reclash/views/application_setting.dart';
import 'package:reclash/views/backup_and_restore.dart';
import 'package:reclash/views/config/config.dart';
import 'package:reclash/views/hotkey.dart';
import 'package:reclash/views/locale.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' show dirname, join;

import 'appearance/appearance.dart';
import 'config/advanced.dart';
import 'developer.dart';
import 'url_scheme.dart';

class ToolsView extends ConsumerStatefulWidget {
  const ToolsView({super.key});

  @override
  ConsumerState<ToolsView> createState() => _ToolViewState();
}

class _ToolViewState extends ConsumerState<ToolsView> {
  Widget _buildNavigationMenu(List<NavigationItem> navigationItems) {
    return SettingSection(
      top: 16,
      items: [
        for (final navigationItem in navigationItems)
          DecorationListItem.open(
            leading: navigationItem.icon,
            title: Text(navigationItem.label.label),
            subtitle: switch (navigationItem.label.description) {
              null => null,
              final description => Text(description),
            },
            widget: navigationItem.builder(context),
            maxWidth: 400,
            forceFull: false,
          ),
      ],
    );
  }

  List<Widget> _getOtherList(bool enableDeveloperMode) {
    return [
      SettingSection(
        title: context.appLocalizations.other,
        items: [
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
      ..._getOtherList(appSetting.developerMode),
      const SettingBottomInset(),
    ];
    return CommonScaffold(
      title: context.appLocalizations.tools,
      body: ListView.builder(
        key: toolsStoreKey,
        itemCount: items.length,
        itemBuilder: (_, index) => items[index],
      ),
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
      leading: const Icon(Icons.language_outlined),
      title: Text(appLocalizations.language),
      subtitle: Text(
        currentLocale?.nativeLabel ?? appLocalizations.defaultText,
      ),
      widget: const LocaleView(),
    );
  }
}

class _ThemeItem extends StatelessWidget {
  const _ThemeItem();

  @override
  Widget build(BuildContext context) {
    return DecorationListItem.open(
      leading: const Icon(Icons.style),
      title: Text(context.appLocalizations.appearance),
      subtitle: Text(context.appLocalizations.appearanceDesc),
      widget: const AppearanceView(),
    );
  }
}

class _BackupItem extends StatelessWidget {
  const _BackupItem();

  @override
  Widget build(BuildContext context) {
    return DecorationListItem.open(
      leading: const Icon(Icons.cloud_sync),
      title: Text(context.appLocalizations.backupAndRestore),
      subtitle: Text(context.appLocalizations.backupAndRestoreDesc),
      widget: const BackupAndRestore(),
    );
  }
}

class _HotkeyItem extends StatelessWidget {
  const _HotkeyItem();

  @override
  Widget build(BuildContext context) {
    return DecorationListItem.open(
      leading: const Icon(Icons.keyboard),
      title: Text(context.appLocalizations.hotkeyManagement),
      subtitle: Text(context.appLocalizations.hotkeyManagementDesc),
      widget: const HotKeyView(),
    );
  }
}

class _LoopbackItem extends StatelessWidget {
  const _LoopbackItem();

  @override
  Widget build(BuildContext context) {
    return DecorationListItem(
      leading: const Icon(Icons.lock),
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
      leading: const Icon(Icons.view_list),
      title: Text(context.appLocalizations.accessControl),
      subtitle: Text(context.appLocalizations.accessControlDesc),
      widget: const AccessView(),
    );
  }
}

class _ConfigItem extends StatelessWidget {
  const _ConfigItem();

  @override
  Widget build(BuildContext context) {
    return DecorationListItem.open(
      leading: const Icon(Icons.edit),
      title: Text(context.appLocalizations.basicConfig),
      subtitle: Text(context.appLocalizations.basicConfigDesc),
      widget: const ConfigView(),
    );
  }
}

class _AdvancedConfigItem extends StatelessWidget {
  const _AdvancedConfigItem();

  @override
  Widget build(BuildContext context) {
    return DecorationListItem.open(
      leading: const Icon(Icons.build),
      title: Text(context.appLocalizations.advancedConfig),
      subtitle: Text(context.appLocalizations.advancedConfigDesc),
      widget: const AdvancedConfigView(),
    );
  }
}

class _SettingItem extends StatelessWidget {
  const _SettingItem();

  @override
  Widget build(BuildContext context) {
    return DecorationListItem.open(
      leading: const Icon(Icons.settings),
      title: Text(context.appLocalizations.application),
      subtitle: Text(context.appLocalizations.applicationDesc),
      widget: const ApplicationSettingView(),
    );
  }
}

class _DisclaimerItem extends ConsumerWidget {
  const _DisclaimerItem();

  @override
  Widget build(BuildContext context, ref) {
    return DecorationListItem(
      leading: const Icon(Icons.gavel),
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
      leading: const Icon(Icons.link),
      title: Text(context.appLocalizations.urlScheme),
      widget: const UrlSchemeView(),
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem();

  @override
  Widget build(BuildContext context) {
    return DecorationListItem.open(
      leading: const Icon(Icons.info),
      title: Text(context.appLocalizations.about),
      widget: const AboutView(),
    );
  }
}

class _DeveloperItem extends StatelessWidget {
  const _DeveloperItem();

  @override
  Widget build(BuildContext context) {
    return DecorationListItem.open(
      leading: const Icon(Icons.developer_board),
      title: Text(context.appLocalizations.developerMode),
      widget: const DeveloperView(),
    );
  }
}
