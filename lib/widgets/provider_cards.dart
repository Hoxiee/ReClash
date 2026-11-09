import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/features/speed_test/sheet.dart';
import 'package:reclash/plugins/app.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/subscriptions/metadata/metadata.dart';
import 'package:reclash/subscriptions/metadata/provider_cards.dart';
import 'package:reclash/views/dashboard/widgets/profile_detail.dart';
import 'package:reclash/views/doctor/doctor.dart';
import 'package:reclash/widgets/icon.dart';
import 'package:reclash/widgets/provider_cards_view.dart';

final _currentMetadataProvider = Provider<SubscriptionMetadata?>(
  (ref) => ref.watch(
    currentProfileProvider.select(
      (profile) => profile?.subscriptionSnapshot?.metadata,
    ),
  ),
);

/// Runs one of the fixed actions. None of them changes a setting, imports a
/// subscription or starts or stops the connection.
Future<void> runProviderAction(
  BuildContext context,
  WidgetRef ref,
  ProviderAction action,
) async {
  switch (action.kind) {
    case ProviderActionKind.url:
      await dialogs.openUrl(action.url.toString());
    case ProviderActionKind.copy:
      await _copy(context, action.text!);
    case ProviderActionKind.share:
      final shared = await app?.shareText(action.text!) ?? false;
      if (!shared && context.mounted) await _copy(context, action.text!);
    case ProviderActionKind.app:
      switch (action.app!) {
        case ProviderAppAction.support:
        case ProviderAppAction.website:
        case ProviderAppAction.renew:
        case ProviderAppAction.topUp:
          final link = providerAppLink(
            ref.read(_currentMetadataProvider),
            action.app!,
          );
          if (link != null) await dialogs.openUrl(link.toString());
        case ProviderAppAction.updateProfile:
          final profile = ref.read(currentProfileProvider);
          if (profile != null) await syncProfile(context, ref, profile);
        case ProviderAppAction.speedTest:
          await showSpeedTestSheet(context);
        case ProviderAppAction.doctor:
          await showDoctorSheet(context);
        case ProviderAppAction.updateApp:
          await ref
              .read(commonActionProvider.notifier)
              .checkForUpdates(context);
      }
  }
}

Future<void> _copy(BuildContext context, String text) async {
  await Clipboard.setData(ClipboardData(text: text));
  if (context.mounted) {
    context.showNotifier(
      context.appLocalizations.copySuccess,
      level: MessageLevel.success,
    );
  }
}

/// The current profile's cards above the user's widgets, in file order.
class ProviderCards extends ConsumerWidget {
  const ProviderCards({super.key, this.gap = 12});

  final double gap;

  @override
  Widget build(BuildContext context, WidgetRef ref) => ProviderCardsView(
    cards: ref.watch(providerCardsProvider),
    metadata: ref.watch(_currentMetadataProvider),
    images: const AppProviderImages(),
    gap: gap,
    onAction: (action) => unawaited(runProviderAction(context, ref, action)),
    onDismiss: (card) => ref
        .read(dismissedNoticesProvider.notifier)
        .dismiss(providerCardDismissId(card)),
  );
}
