import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';

import 'list.dart';

class RecordTextStyles {
  final TextStyle? primary;
  final TextStyle? secondary;
  final TextStyle? muted;

  const RecordTextStyles._({this.primary, this.secondary, this.muted});

  factory RecordTextStyles.of(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final secondary = textTheme.bodySmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
    );
    return RecordTextStyles._(
      primary: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
      secondary: secondary,
      muted: secondary?.copyWith(color: colorScheme.outline),
    );
  }
}

class RecordListItem extends StatelessWidget {
  final Widget header;
  final Widget body;
  final bool isError;
  final VoidCallback? onTap;

  const RecordListItem({
    super.key,
    required this.header,
    required this.body,
    this.isError = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final item = ListItem(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        10,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      minVerticalPadding: 0,
      minTileHeight: 0,
      horizontalTitleGap: AppSpacing.md,
      tileTitleAlignment: ListTileTitleAlignment.top,
      color: isError ? colorScheme.errorContainer.withValues(alpha: 0.2) : null,
      onTap: onTap,
      title: header,
      subtitle: Padding(padding: const EdgeInsets.only(top: 6), child: body),
    );
    if (!isError) {
      return item;
    }
    return DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: colorScheme.error, width: 3)),
      ),
      child: item,
    );
  }
}

class RecordHeader extends StatelessWidget {
  final List<Widget> children;
  final Widget? trailing;

  const RecordHeader({super.key, required this.children, this.trailing});

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle.merge(
      style: context.textTheme.labelMedium?.copyWith(
        color: context.colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w400,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      child: SizedBox(
        width: double.infinity,
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.xs,
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: children,
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

class RecordTimestamp extends StatelessWidget {
  final String dateTime;

  const RecordTimestamp(this.dateTime, {super.key});

  @override
  Widget build(BuildContext context) {
    final split = dateTime.lastIndexOf(' ');
    return Text.rich(
      TextSpan(
        children: [
          if (split > 0)
            TextSpan(
              text: dateTime.substring(0, split + 1),
              style: TextStyle(color: context.colorScheme.outline),
            ),
          TextSpan(text: split > 0 ? dateTime.substring(split + 1) : dateTime),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class RecordArrow extends StatelessWidget {
  const RecordArrow({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      '→',
      style: RecordTextStyles.of(context).muted?.toJetBrainsMono,
    );
  }
}
