import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/backup_and_restore.dart';
import 'package:reclash/views/profiles/add.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets.dart';

class SetupSubscriptionStep extends ConsumerWidget {
  const SetupSubscriptionStep({super.key, required this.onNext});

  final VoidCallback onNext;

  Future<void> _handleRestore(BuildContext context, WidgetRef ref) async {
    final appLocalizations = context.appLocalizations;
    final option = await dialogs.showCommonDialog<RestoreOption>(
      child: const RestoreOptionsDialog(),
    );
    if (option == null || !context.mounted) return;
    final restored = await globalState.loadingRun<bool>(
      () => ref.read(backupActionProvider.notifier).restorePickedFile(option),
      tag: LoadingTag.backup_restore,
      title: appLocalizations.restore,
    );
    if (restored != true) return;
    // A restored config replaces app settings wholesale; the consent the
    // legal step recorded must survive it or the disclaimer shows again.
    ref.read(appSettingProvider.notifier).update(
      (state) => state.copyWith(disclaimerAccepted: true, crashlyticsTip: true),
    );
    if (context.mounted) {
      context.showNotifier(appLocalizations.restoreSuccess);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final profiles = ref.watch(profilesProvider);
    final added = profiles.isNotEmpty;
    return SetupStepScaffold(
      title: appLocalizations.setupSubscriptionTitle,
      subtitle: appLocalizations.setupSubscriptionDesc,
      // The pickers are a `ListView`, so they need a bounded height and scroll
      // themselves; the added card is small enough for the page to scroll it.
      scrollable: added,
      body: added
          ? _AddedProfile(profile: profiles.first)
          : Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: SetupCard(
                      child: AddProfileView(
                        context: context,
                        keepCurrentPage: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SetupCard(
                    child: ListItem(
                      leading: const Icon(Icons.settings_backup_restore_sharp),
                      title: Text(appLocalizations.setupRestore),
                      subtitle: Text(appLocalizations.setupRestoreDesc),
                      onTap: () => _handleRestore(context, ref),
                    ),
                  ),
                ],
              ),
            ),
      actions: [
        SetupPrimaryButton(
          label: added ? appLocalizations.setupNext : appLocalizations.setupSkip,
          onPressed: onNext,
        ),
      ],
    );
  }
}

class _AddedProfile extends StatelessWidget {
  const _AddedProfile({required this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return SetupCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              spacing: 8,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: 20,
                  color: colorScheme.primary,
                ),
                Expanded(
                  child: Text(
                    profile.label.takeFirstValid([
                      context.appLocalizations.setupSubscriptionReady,
                    ]),
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SubscriptionInfoView(
              subscriptionInfo: profile.subscriptionInfo,
            ),
          ],
        ),
      ),
    );
  }
}
