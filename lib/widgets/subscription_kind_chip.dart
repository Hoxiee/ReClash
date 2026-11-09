import 'package:material_ui/material_ui.dart';
import 'package:reclash/l10n/l10n.dart';
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
    final l = AppLocalizations.of(context);
    return TonalChip(
      label: switch (kind) {
        SubscriptionKind.test => l.subscriptionKindTest,
        SubscriptionKind.promo => l.subscriptionKindPromo,
        SubscriptionKind.dev => l.subscriptionKindDev,
      },
      color: foreground.opacity15,
      foregroundColor: foreground,
    );
  }
}
