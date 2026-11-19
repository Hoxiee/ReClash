import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';

Future<SiteLockPreset?> showSiteLockPresetSheet(BuildContext context) =>
    showSheet<SiteLockPreset>(
      context: context,
      builder: (_) => const _SiteLockPresetSheet(),
    );

class _SiteLockPresetSheet extends StatelessWidget {
  const _SiteLockPresetSheet();

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    return CommonScaffold(
      title: l.siteLockFromPreset,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(
          top: context.contentTopPadding,
          bottom: 20 + context.bottomInset,
        ),
        children: [
          generateSection(
            items: [
              for (final preset in siteLockPresets)
                ListItem(
                  leading: const GlyphIcon(AppGlyphs.sparkle),
                  title: Text(preset.name),
                  subtitle: Text(
                    preset.match.join(', '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.footnote
                        .of(context)
                        .toJetBrainsMono
                        .copyWith(color: context.colorScheme.tertiary),
                  ),
                  onTap: () => Navigator.of(context).pop(preset),
                ),
            ],
            footer: l.siteLockPresetsFooter,
          ),
        ],
      ),
    );
  }
}
