import 'package:reclash/common/common.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/dashboard/widgets/dashboard_centered_scroll_view.dart';
import 'package:reclash/views/dashboard/widgets/hero/hero_surface.dart';
import 'package:reclash/views/dashboard/widgets/subscription_overview.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProviderSummaryPage extends ConsumerWidget {
  const ProviderSummaryPage({super.key, required this.scrollController});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider);
    return DashboardCenteredScrollView(
      controller: scrollController,
      alignment: Alignment.topCenter,
      child: profile == null
          ? const _ProviderEmptyState()
          : _ProviderSummary(profile: profile),
    );
  }
}

/// The pager's second page and the split board's right column show the same
/// stack; only the spacing follows the board the cards land on.
List<Widget> providerSummaryCards(
  BuildContext context,
  Profile profile, {
  double gap = 12,
}) {
  final cards = subscriptionDetailCards(context, profile, wrap: _heroCard);
  return [
    for (final (index, card) in cards.indexed) ...[
      if (index > 0) SizedBox(height: gap),
      card,
    ],
  ];
}

/// The dashboard board's own surface: translucent card over the wallpaper,
/// with a soft tint when a notice carries a tone.
Widget _heroCard(Widget child, {Color? tone}) {
  return HeroSurface(
    padding: const EdgeInsets.all(20),
    child: tone == null
        ? child
        : IconTheme.merge(
            data: IconThemeData(color: tone),
            child: child,
          ),
  );
}

class _ProviderSummary extends StatelessWidget {
  const _ProviderSummary({required this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
      child: Column(
        key: const ValueKey('provider-plan-card'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: providerSummaryCards(context, profile),
      ),
    );
  }
}

class _ProviderEmptyState extends ConsumerWidget {
  const _ProviderEmptyState();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: HeroSurface(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.folder_off_rounded,
              size: 44,
              color: context.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 14),
            Semantics(
              header: true,
              child: Text(
                context.appLocalizations.dashboardNoActiveProfileTitle,
                textAlign: TextAlign.center,
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              context.appLocalizations.dashboardNoActiveProfileDesc,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () =>
                  ref.read(currentPageLabelProvider.notifier).toProfiles(),
              icon: const Icon(Icons.folder_open_rounded),
              label: Text(context.appLocalizations.dashboardSelectProfile),
            ),
          ],
        ),
      ),
    );
  }
}
