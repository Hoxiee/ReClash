import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/ui/code_label.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/widgets/widgets.dart';

class UrlSchemeSupportedLinksRow extends StatelessWidget {
  const UrlSchemeSupportedLinksRow({
    super.key,
    required this.glyph,
    required this.title,
    required this.formats,
  });

  final Glyph glyph;
  final String title;
  final List<String> formats;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    PopupOpen? openFormats;
    return DecorationListItem(
      leading: GlyphIcon(glyph),
      title: Text(title),
      onPressed: () => openFormats?.call(),
      trailing: CommonPopupBox(
        targetBuilder: (open) {
          openFormats = open;
          return TextButton(
            onPressed: open,
            style: TextButton.styleFrom(
              foregroundColor: context.colorScheme.onSurfaceVariant,
              textStyle: AppTextStyle.subheadline.of(context),
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 4,
              children: [
                Text(l.urlSchemeFormats),
                const GlyphIcon(AppGlyphs.picker),
              ],
            ),
          );
        },
        popupBuilder: (context) => Material(
          color: context.surfaceLevel.colorOf(context.colorScheme),
          shape: AppShape.md,
          elevation: 6,
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360, maxHeight: 400),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 8,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      title,
                      style: AppTextStyle.headline.of(context),
                    ),
                  ),
                  for (final format in formats) CodeLabel(format),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      l.urlSchemeFormatsTip,
                      style: AppTextStyle.footnote
                          .of(context)
                          .copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
