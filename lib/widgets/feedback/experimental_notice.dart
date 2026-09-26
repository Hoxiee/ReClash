import 'package:reclash/common/common.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/widgets/feedback/dialog.dart';
import 'package:material_ui/material_ui.dart';

class ExperimentalNoticeDialog extends StatelessWidget {
  const ExperimentalNoticeDialog({
    super.key,
    required this.message,
    this.title,
    this.confirmText,
    this.cancelText,
  });

  final String message;
  final String? title;
  final String? confirmText;
  final String? cancelText;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    return CommonDialog(
      title: title ?? appLocalizations.experimentalNoticeTitle,
      actions: [
        TextButton(
          autofocus: true,
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelText ?? appLocalizations.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmText ?? appLocalizations.confirm),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 14,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: ShapeDecoration(
              color: colorScheme.tertiaryContainer,
              shape: const RoundedRectangleBorder(borderRadius: AppRadius.md),
            ),
            child: Row(
              spacing: 10,
              children: [
                GlyphIcon(
                  AppGlyphs.beaker,
                  color: colorScheme.onTertiaryContainer,
                ),
                Expanded(
                  child: Text(
                    appLocalizations.experimentalLabel,
                    style: context.textTheme.labelLarge?.copyWith(
                      color: colorScheme.onTertiaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Text(message, style: context.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
