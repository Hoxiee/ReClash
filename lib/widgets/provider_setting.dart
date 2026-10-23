import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/subscriptions/provider_settings.dart';
import 'package:reclash/ui/ui.dart';

import 'settings/setting_spec.dart';

enum ProviderSettingStatus { none, managed, released }

final providerSettingStatusProvider = Provider.autoDispose
    .family<ProviderSettingStatus, String>((ref, id) {
      final input = ref.watch(providerSettingsInputProvider);
      final config = ref.watch(configProvider);
      if (input == null) return ProviderSettingStatus.none;
      if (isProviderManaged(config, id)) return ProviderSettingStatus.managed;
      if (isProviderReleased(config, input, id)) {
        return ProviderSettingStatus.released;
      }
      return ProviderSettingStatus.none;
    });

final providerReleasedSettingsProvider = Provider.autoDispose<List<String>>((
  ref,
) {
  final input = ref.watch(providerSettingsInputProvider);
  final config = ref.watch(configProvider);
  if (input == null) return const [];
  return [
    for (final setting in providerSettingsCatalog)
      if (isProviderReleased(config, input, setting.id)) setting.id,
  ];
});

/// The provider settings each searchable settings row edits.
const providerSettingsBySpec = {
  'application.autoLaunch': ['settings.autorun'],
  'application.silentLaunch': ['settings.shadowstart'],
  'application.autoRun': ['settings.autostart'],
  'application.minimizeOnExit': ['settings.minimize'],
  'application.closeConnections': ['settings.closeconnections'],
  'application.autoCheckUpdate': ['settings.autoupdate'],
  'application.openLogs': ['settings.openlogs'],
  'theme.themeColor': ['app.color', 'app.style'],
  'theme.pureBlackMode': ['app.black'],
  'theme.navigationBarStyle': ['app.navbar'],
  'theme.tabAnimation': ['app.tabs'],
  'theme.liquidGlass': ['app.glass'],
  'theme.wallpaper.enabled': ['background'],
};

Widget? providerSpecTag(WidgetRef ref, SettingSpec spec) =>
    switch (providerSettingsBySpec[spec.id]) {
      final ids? => providerSettingTag(ref, ids),
      null => null,
    };

/// Null when the subscription sets none of [ids], so the row keeps its own
/// height.
Widget? providerSettingTag(WidgetRef ref, Iterable<String> ids) {
  final statuses = {
    for (final id in ids) id: ref.watch(providerSettingStatusProvider(id)),
  };
  if (statuses.containsValue(ProviderSettingStatus.managed)) {
    return const ProviderTag();
  }
  final released = [
    for (final MapEntry(:key, :value) in statuses.entries)
      if (value == ProviderSettingStatus.released) key,
  ];
  if (released.isEmpty) return null;
  return ProviderReturnTag(
    onPressed: () =>
        ref.read(providerSettingsActionProvider).returnToProvider(released),
  );
}

class ProviderTag extends StatelessWidget {
  const ProviderTag({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: TonalChip(
        label: context.appLocalizations.providerSettingManaged,
        color: SurfaceLevel.inset.colorOf(colorScheme),
        foregroundColor: colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class ProviderReturnTag extends StatelessWidget {
  const ProviderReturnTag({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: TonalChip(
        label: context.appLocalizations.providerSettingReturn,
        color: SurfaceLevel.inset.colorOf(colorScheme),
        foregroundColor: colorScheme.primary,
        onPressed: onPressed,
      ),
    );
  }
}
