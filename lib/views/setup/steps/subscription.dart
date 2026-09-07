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

class SetupSubscriptionStep extends ConsumerStatefulWidget {
  const SetupSubscriptionStep({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  ConsumerState<SetupSubscriptionStep> createState() =>
      _SetupSubscriptionStepState();
}

class _SetupSubscriptionStepState extends ConsumerState<SetupSubscriptionStep> {
  bool _showImporter = false;
  int? _replaceProfileId;

  Future<void> _handleRestore() async {
    final appLocalizations = context.appLocalizations;
    final before = ref.read(appSettingProvider);
    final option = await dialogs.showCommonDialog<RestoreOption>(
      child: const RestoreOptionsDialog(),
    );
    if (option == null || !mounted) return;
    final restored = await globalState.loadingRun<bool>(
      () => ref.read(backupActionProvider.notifier).restorePickedFile(option),
      tag: LoadingTag.backup_restore,
      title: appLocalizations.restore,
    );
    if (restored != true) return;
    ref
        .read(appSettingProvider.notifier)
        .update(
          (state) => state.copyWith(
            disclaimerAccepted: before.disclaimerAccepted,
            crashlyticsTip: before.crashlyticsTip,
            crashlytics: before.crashlytics,
            setupCompleted: before.setupCompleted,
            setupStep: before.setupStep,
          ),
        );
    if (mounted) {
      setState(() => _showImporter = false);
      context.showNotifier(appLocalizations.restoreSuccess);
    }
  }

  Future<void> _delete(Profile profile) async {
    final appLocalizations = context.appLocalizations;
    final confirmed = await dialogs.showMessage(
      title: appLocalizations.setupDeleteProfile,
      message: TextSpan(text: appLocalizations.deleteTip(profile.label)),
      confirmText: appLocalizations.delete,
    );
    if (confirmed != true) return;
    await ref.read(profilesActionProvider.notifier).deleteProfile(profile.id);
  }

  Future<void> _handleAdded(Profile profile) async {
    final replaceProfileId = _replaceProfileId;
    if (replaceProfileId != null && replaceProfileId != profile.id) {
      await ref
          .read(profilesActionProvider.notifier)
          .deleteProfile(replaceProfileId);
    } else if (ref.read(profilesProvider).length == 1 &&
        profile.panelMeta?.settings == null) {
      ref
          .read(appSettingProvider.notifier)
          .update((state) => state.copyWith(autoRun: true));
    }
    if (!mounted) return;
    setState(() {
      _showImporter = false;
      _replaceProfileId = null;
    });
  }

  void _showAdd({Profile? replacing}) {
    setState(() {
      _showImporter = true;
      _replaceProfileId = replacing?.id;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final profiles = ref.watch(profilesProvider);
    final currentProfile = ref.watch(currentProfileProvider);
    final selected = currentProfile ?? profiles.firstOrNull;
    final importing = profiles.isEmpty || _showImporter;
    return SetupStepScaffold(
      title: appLocalizations.setupSubscriptionTitle,
      subtitle: appLocalizations.setupSubscriptionDesc,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            appLocalizations.setupProfileSourceNotice,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          if (importing) ...[
            SetupCard(
              child: AddProfileView(
                context: context,
                keepCurrentPage: true,
                shrinkWrap: true,
                onProfileAdded: _handleAdded,
              ),
            ),
            const SizedBox(height: 12),
            SetupCard(
              child: ListItem(
                leading: const Icon(Icons.settings_backup_restore_sharp),
                title: Text(appLocalizations.setupRestore),
                subtitle: Text(appLocalizations.setupRestoreDesc),
                onTap: _handleRestore,
              ),
            ),
          ] else if (selected != null) ...[
            _AddedProfile(profile: selected, count: profiles.length),
            const SizedBox(height: 12),
            SetupCard(
              child: Column(
                children: [
                  ListItem(
                    leading: const Icon(Icons.add_rounded),
                    title: Text(appLocalizations.setupAddAnotherProfile),
                    onTap: _showAdd,
                  ),
                  ListItem(
                    leading: const Icon(Icons.swap_horiz_rounded),
                    title: Text(appLocalizations.setupReplaceProfile),
                    subtitle: Text(appLocalizations.setupReplaceProfileHint),
                    onTap: () => _showAdd(replacing: selected),
                  ),
                  ListItem(
                    leading: const Icon(Icons.delete_outline_rounded),
                    title: Text(appLocalizations.setupDeleteProfile),
                    onTap: () => _delete(selected),
                  ),
                ],
              ),
            ),
          ],
          if (profiles.isEmpty) ...[
            const SizedBox(height: 12),
            SetupCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      appLocalizations.setupContinueWithoutProfile,
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(appLocalizations.setupContinueWithoutProfileDesc),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
      actions: [
        SetupPrimaryButton(
          label: profiles.isEmpty
              ? appLocalizations.setupContinueWithoutProfile
              : appLocalizations.setupNext,
          onPressed: widget.onNext,
        ),
        OutlinedButton(
          onPressed: widget.onBack,
          child: Text(appLocalizations.setupBack),
        ),
      ],
    );
  }
}

class _AddedProfile extends StatelessWidget {
  const _AddedProfile({required this.profile, required this.count});

  final Profile profile;
  final int count;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final appLocalizations = context.appLocalizations;
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
                      appLocalizations.setupSubscriptionReady,
                    ]),
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              appLocalizations.setupProfilesReady(count),
              style: context.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            SubscriptionInfoView(subscriptionInfo: profile.subscriptionInfo),
          ],
        ),
      ),
    );
  }
}
