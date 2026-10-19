import 'package:reclash/common/common.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';

class UrlSchemePreview extends StatelessWidget {
  const UrlSchemePreview({
    super.key,
    required this.link,
    this.onCopy,
    this.footer,
  });

  final String? link;
  final VoidCallback? onCopy;
  final String? footer;

  @override
  Widget build(BuildContext context) {
    final value = link;
    return generateSection(
      title: context.appLocalizations.urlSchemePreview,
      footer: footer ?? context.appLocalizations.urlSchemePrivateLinkTip,
      actions: [
        IconButtonData(
          glyph: AppGlyphs.copy,
          tooltip: context.appLocalizations.copy,
          onPressed: value == null ? null : onCopy,
        ),
      ],
      items: [
        DecorationListItem(
          title: value == null
              ? Text(
                  context.appLocalizations.urlSchemePreviewEmpty,
                  style: AppTextStyle.footnote
                      .of(context)
                      .copyWith(color: context.colorScheme.onSurfaceVariant),
                )
              : SelectableText(
                  value.length > 4096 ? '${value.substring(0, 4096)}…' : value,
                  style: AppTextStyle.footnote.of(context).toJetBrainsMono,
                ),
        ),
      ],
    );
  }
}
