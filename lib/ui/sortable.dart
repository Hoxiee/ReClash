import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/l10n.dart';
import 'package:reclash/ui/models.dart';
import 'package:flutter/widgets.dart';

export 'package:prism_ui/sortable.dart';

IconButtonData sortModeAction(
  BuildContext context, {
  required bool sorting,
  required VoidCallback? onPressed,
}) {
  final localizations = UiLocalizations.of(context);
  return IconButtonData(
    glyph: AppGlyphs.sort,
    onPressed: onPressed,
    tooltip: localizations.sort,
    isSelected: sorting,
  );
}
