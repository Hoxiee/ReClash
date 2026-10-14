import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/widgets/widgets.dart';

/// States what the wizard worked out on its own — region and language — instead
/// of asking for it. Everything here has a settings home of its own, so the
/// strip only has to offer one way back in.
class SetupDetectedStrip extends ConsumerWidget {
  const SetupDetectedStrip({super.key});

  Future<void> _change(BuildContext context, WidgetRef ref) async {
    final l = context.appLocalizations;
    final picked = await dialogs.showCommonDialog<String>(
      child: OptionsDialog<String>(
        title: l.appRegion,
        options: [...shippedCountryCodes, otherRegionCode],
        value: ref.read(appRegionProvider),
        textBuilder: regionLabel,
      ),
    );
    if (picked == null || !context.mounted) return;
    selectAppRegion(ref.read, picked);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final locale = getLocaleForString(
      ref.watch(appSettingProvider.select((state) => state.locale)),
    );
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Material(
        color: colorScheme.surfaceContainerHigh,
        shape: AppShape.all(AppCorner.full),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.only(left: AppSpacing.md),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: AppSpacing.sm,
            children: [
              GlyphIcon(
                AppGlyphs.language,
                size: 18,
                color: colorScheme.onSurfaceVariant,
              ),
              Flexible(
                child: Text(
                  l.setupDetectedSummary(
                    regionLabel(ref.watch(appRegionProvider)),
                    locale?.nativeLabel ?? l.setupSystemLanguage,
                  ),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: () => _change(context, ref),
                child: Text(l.setupDetectedChange),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
