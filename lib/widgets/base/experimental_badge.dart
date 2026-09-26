import 'package:reclash/common/common.dart';
import 'package:reclash/widgets/base/tag.dart';
import 'package:material_ui/material_ui.dart';

class ExperimentalBadge extends StatelessWidget {
  const ExperimentalBadge({super.key, this.label});

  final String? label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return AppTag(
      label ?? context.appLocalizations.experimentalLabel,
      foreground: colorScheme.onTertiaryContainer,
      background: colorScheme.tertiaryContainer,
    );
  }
}
