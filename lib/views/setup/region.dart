import 'package:reclash/common/common.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'widgets.dart';

class SetupRegionSettings extends ConsumerWidget {
  const SetupRegionSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.appLocalizations;
    final region = ref.watch(appRegionProvider);
    final sendIdentity = ref.watch(
      appSettingProvider.select((state) => state.sendDeviceIdentity),
    );
    return SetupSection(
      caption: l10n.appRegion,
      child: SetupCard(
        child: Column(
          children: [
            ListItem<AppRegion>.options(
              key: const ValueKey('setup-app-region'),
              leading: const GlyphIcon(AppGlyphs.language),
              title: Text(l10n.appRegion),
              subtitle: Text(region.label(context)),
              dialogTitle: l10n.appRegion,
              options: AppRegion.values,
              value: region,
              textBuilder: (value) => value.label(context),
              onChanged: (value) {
                if (!context.mounted || value == null) return;
                selectAppRegion(ref.read, value);
              },
            ),
            ListItem.toggle(
              key: const ValueKey('setup-send-hwid'),
              leading: const GlyphIcon(AppGlyphs.deviceInfo),
              title: Text(l10n.sendDeviceIdentity),
              subtitle: Text(l10n.sendDeviceIdentityDesc),
              value: sendIdentity,
              onChanged: (value) async {
                // Regions that seed HWID on by default are the ones whose
                // providers rely on it; elsewhere the warning would cry wolf.
                if (!value &&
                    regionAllowsFacet(
                      region,
                      RegionalFacetId.deviceIdentity,
                    )) {
                  final confirmed = await dialogs.showMessage(
                    context: context,
                    title: l10n.sendDeviceIdentity,
                    message: TextSpan(
                      text: l10n.sendDeviceIdentityDisableWarning,
                    ),
                    confirmText: l10n.turnOff,
                  );
                  if (confirmed != true || !context.mounted) return;
                }
                ref
                    .read(appSettingProvider.notifier)
                    .update(
                      (state) => state.copyWith(sendDeviceIdentity: value),
                    );
              },
            ),
          ],
        ),
      ),
    );
  }
}
