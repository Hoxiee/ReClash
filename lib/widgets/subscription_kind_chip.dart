import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/subscriptions/metadata/metadata.dart';
import 'package:reclash/ui/ui.dart';

extension SubscriptionKindTone on SubscriptionKind {
  Color foregroundOf(ColorScheme colorScheme) => switch (this) {
    SubscriptionKind.test => colorScheme.tertiary,
    SubscriptionKind.promo => colorScheme.primary,
    SubscriptionKind.dev => colorScheme.secondary,
  };
}

class SubscriptionKindChip extends StatelessWidget {
  const SubscriptionKindChip({super.key, required this.kind});

  final SubscriptionKind kind;

  @override
  Widget build(BuildContext context) {
    final foreground = kind.foregroundOf(context.colorScheme);
    return TonalChip(
      label: kind.label,
      color: foreground.opacity15,
      foregroundColor: foreground,
    );
  }
}
