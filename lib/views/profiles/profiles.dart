import 'dart:async';

import 'package:reclash/common/common.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/profiles/overwrite/overwrite.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:reclash/widgets/theme/profile_patina.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'add.dart';
import 'edit.dart';
import 'preview.dart';
import 'subscription_report.dart';

class ProfilesView extends ConsumerStatefulWidget {
  const ProfilesView({super.key});

  @override
  ConsumerState<ProfilesView> createState() => _ProfilesViewState();
}

class _ProfilesViewState extends ConsumerState<ProfilesView> {
  Function? applyConfigDebounce;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
  }

  void _handleShowAddExtendPage() {
    final context = globalState.navigatorKey.currentState!.context;
    showExtend(
      context,
      builder: (context) => AdaptiveSheetScaffold(
        title: context.appLocalizations.addProfile,
        body: Builder(
          builder: (chooserContext) => AddProfileView(
            onProfileAdded: (_) => closeProfileImportRoute(chooserContext),
          ),
        ),
      ),
    );
  }

  Future<void> _updateProfiles(List<Profile> profiles) async {
    if (_isUpdating == true) {
      return;
    }
    _isUpdating = true;
    final appLocalizations = context.appLocalizations;
    final profilesAction = ref.read(profilesActionProvider.notifier);
    final List<UpdatingMessage> messages = [];
    final updateProfiles = profiles.map<Future>((profile) async {
      if (profile.type == ProfileType.file) return;
      try {
        await profilesAction.updateProfile(profile, showLoading: true);
      } catch (e) {
        messages.add(
          UpdatingMessage(
            label: profile.realLabel,
            message: userFacingErrorMessage(e, appLocalizations),
          ),
        );
      }
    });
    await Future.wait(updateProfiles);
    if (messages.isNotEmpty) {
      unawaited(dialogs.showAllUpdatingMessagesDialog(messages));
    }
    _isUpdating = false;
  }

  List<IconButtonData> _buildActions(List<Profile> profiles) {
    return profiles.isNotEmpty
        ? [
            IconButtonData(
              glyph: AppGlyphs.sync,
              onPressed: () {
                _updateProfiles(profiles);
              },
              tooltip: context.appLocalizations.update,
            ),
            IconButtonData(
              glyph: AppGlyphs.sort,
              onPressed: () {
                showSheet(
                  context: context,
                  builder: (_) {
                    return ReorderableProfilesSheet(profiles: profiles);
                  },
                );
              },
              tooltip: context.appLocalizations.profilesSort,
            ),
          ]
        : [];
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (_, ref, _) {
        final appLocalizations = context.appLocalizations;
        final isLoading = ref.watch(loadingProvider(LoadingTag.profiles));
        final state = ref.watch(profilesStateProvider);
        final spacing = 14.mAp;
        return CommonScaffold(
          isLoading: isLoading,
          title: appLocalizations.profiles,
          floatBody: true,
          primaryAction: IconButtonData(
            glyph: AppGlyphs.add,
            onPressed: _handleShowAddExtendPage,
            tooltip: appLocalizations.addProfile,
          ),
          iconActions: _buildActions(state.profiles),
          foldPrimaryAction: true,
          body: NullStatusSwitcher(
            isEmpty: state.profiles.isEmpty,
            nullStatus: NullStatus(
              label: appLocalizations.nullProfileDesc,
              illustration: NullStatusIllustration.profile,
            ),
            child: _ProfilesGrid(
              profiles: state.profiles,
              currentProfileId: state.currentProfileId,
              spacing: spacing,
            ),
          ),
        );
      },
    );
  }
}

class _ProfilesGrid extends ConsumerWidget {
  const _ProfilesGrid({
    required this.profiles,
    required this.currentProfileId,
    required this.spacing,
  });

  static const _horizontalPadding = 16.0;

  final List<Profile> profiles;
  final int? currentProfileId;
  final double spacing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final columns = getProfilesColumns(
          constraints.maxWidth - _horizontalPadding * 2,
          spacing: spacing,
          minItemWidth: profileItemMinWidth.ap,
        );
        return MasonryGridView.count(
          key: profilesStoreKey,
          padding: EdgeInsets.only(
            left: _horizontalPadding,
            right: _horizontalPadding,
            top: context.appBarInset,
            bottom: 16 + BottomInsetScope.of(context),
          ),
          crossAxisCount: columns,
          mainAxisSpacing: spacing,
          crossAxisSpacing: spacing,
          itemCount: profiles.length,
          itemBuilder: (context, index) {
            final profile = profiles[index];
            return ProfileItem(
              profile: profile,
              groupValue: currentProfileId,
              onChanged: (profileId) {
                ref.read(currentProfileIdProvider.notifier).value = profileId;
                if (profileId != null) {
                  ref
                      .read(profilesActionProvider.notifier)
                      .markProfileUsed(profileId);
                }
              },
            );
          },
        );
      },
    );
  }
}

class ProfileItem extends ConsumerWidget {
  final Profile profile;
  final int? groupValue;
  final void Function(int? value) onChanged;

  const ProfileItem({
    super.key,
    required this.profile,
    required this.groupValue,
    required this.onChanged,
  });

  Future<void> _handleDeleteProfile(BuildContext context, WidgetRef ref) async {
    final profilesAction = ref.read(profilesActionProvider.notifier);
    final appLocalizations = context.appLocalizations;
    final res = await dialogs.showMessage(
      dangerous: true,
      title: appLocalizations.tip,
      message: TextSpan(
        text: appLocalizations.deleteTip(appLocalizations.profile),
      ),
    );
    if (res != true) {
      return;
    }
    await profilesAction.deleteProfile(profile.id);
  }

  Future<void> _handlePreview(BuildContext context) async {
    unawaited(
      BaseNavigator.push<String>(context, PreviewProfileView(profile: profile)),
    );
  }

  void _handleShowSubscriptionInfo(BuildContext context) {
    showSubscriptionInfoDialog(context, profile.subscriptionInfo!);
  }

  Future updateProfile(WidgetRef ref) async {
    if (profile.type == ProfileType.file) return;
    await globalState.loadingRun(() async {
      await ref
          .read(profilesActionProvider.notifier)
          .updateProfile(profile, showLoading: true);
    }, tag: LoadingTag.profiles);
  }

  void _handleShowEditExtendPage(BuildContext context) {
    showExtend(
      context,
      builder: (context) => AdaptiveSheetScaffold(
        title: context.appLocalizations.edit,
        body: EditProfileView(profile: profile, context: context),
      ),
    );
  }

  List<Widget> _buildUrlProfileInfo(BuildContext context) {
    final subscriptionInfo = profile.subscriptionInfo;
    return [
      if (subscriptionInfo != null && subscriptionInfo.hasFacts) ...[
        SubscriptionInfoView(subscriptionInfo: subscriptionInfo),
        const SizedBox(height: 6),
      ],
      LastUpdateTimeText(
        lastUpdateDate: profile.lastUpdateDate,
        style: context.textTheme.bodySmall?.toLighter,
      ),
      const SizedBox(height: AppSpacing.xxs),
      LastUsedTimeText(
        lastUsedAt: profile.lastUsedAt,
        style: context.textTheme.bodySmall?.toLighter,
      ),
    ];
  }

  List<Widget> _buildFileProfileInfo(BuildContext context) {
    return [
      LastUpdateTimeText(
        lastUpdateDate: profile.lastUpdateDate,
        style: context.textTheme.bodySmall?.toLighter,
      ),
      const SizedBox(height: AppSpacing.xxs),
      LastUsedTimeText(
        lastUsedAt: profile.lastUsedAt,
        style: context.textTheme.bodySmall?.toLighter,
      ),
    ];
  }

  Future<void> _handleCopyLink(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: profile.url));
    if (context.mounted) {
      context.showNotifier(
        context.appLocalizations.copySuccess,
        level: MessageLevel.success,
      );
    }
  }

  Future<void> _handleExportFile(BuildContext context) async {
    final appLocalizations = context.appLocalizations;
    final res = await globalState.safeRun<bool>(() async {
      final mFile = await profile.file;
      final value = await picker.saveFile(
        profile.realLabel,
        await mFile.readAsBytes(),
      );
      if (value == null) return false;
      return true;
    }, title: appLocalizations.tip);
    if (res == true && context.mounted) {
      context.showNotifier(
        appLocalizations.exportSuccess,
        level: MessageLevel.success,
      );
    }
  }

  void _handlePushGenProfilePage(BuildContext context, int id) {
    BaseNavigator.push(context, OverwriteView(profileId: id));
  }

  Future<void> _handleShowSubscriptionReport(BuildContext context) async {
    final appLocalizations = context.appLocalizations;
    final confirmed = await dialogs.showMessage(
      context: context,
      title: appLocalizations.subscriptionReport,
      confirmText: appLocalizations.subscriptionReport,
      message: TextSpan(text: appLocalizations.subscriptionReportConfirm),
    );
    if (confirmed != true || !context.mounted) return;
    await showSubscriptionReportSheet(context);
  }

  List<CommonPopupMenuItem> _menuItems(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final isUrl = profile.type == ProfileType.url;
    final subscriptionInfo = profile.subscriptionInfo;
    final hasSubscriptionInfo =
        isUrl && subscriptionInfo != null && subscriptionInfo.hasFacts;
    final supportUrl = profile.panelMeta?.supportUrl;
    return [
      CommonPopupMenuItem(
        glyph: AppGlyphs.edit,
        label: appLocalizations.edit,
        onPressed: () {
          _handleShowEditExtendPage(context);
        },
      ),
      if (supportUrl != null)
        CommonPopupMenuItem(
          glyph: AppGlyphs.support,
          label: appLocalizations.support,
          onPressed: () {
            dialogs.openUrl(supportUrl);
          },
        ),
      CommonPopupMenuItem(
        glyph: AppGlyphs.eye,
        label: appLocalizations.preview,
        onPressed: () {
          _handlePreview(context);
        },
      ),
      if (isUrl)
        CommonPopupMenuItem(
          glyph: AppGlyphs.swap,
          label: appLocalizations.sync,
          onPressed: () {
            updateProfile(ref);
          },
        ),
      CommonPopupMenuItem(
        glyph: AppGlyphs.emergency,
        label: appLocalizations.more,
        subItems: [
          CommonPopupMenuItem(
            glyph: AppGlyphs.puzzle,
            label: appLocalizations.override,
            onPressed: () {
              _handlePushGenProfilePage(context, profile.id);
            },
          ),
          if (hasSubscriptionInfo)
            CommonPopupMenuItem(
              glyph: AppGlyphs.dataUsage,
              label: appLocalizations.subscriptionInfo,
              onPressed: () {
                _handleShowSubscriptionInfo(context);
              },
            ),
          if (isUrl)
            CommonPopupMenuItem(
              glyph: AppGlyphs.copy,
              label: appLocalizations.copyLink,
              onPressed: () {
                _handleCopyLink(context);
              },
            ),
          CommonPopupMenuItem(
            glyph: AppGlyphs.copy,
            label: appLocalizations.exportFile,
            onPressed: () {
              _handleExportFile(context);
            },
          ),
          if (isUrl)
            CommonPopupMenuItem(
              glyph: AppGlyphs.document,
              label: appLocalizations.subscriptionReport,
              onPressed: () {
                unawaited(_handleShowSubscriptionReport(context));
              },
            ),
        ],
      ),
      CommonPopupMenuItem(
        danger: true,
        glyph: AppGlyphs.delete,
        label: appLocalizations.delete,
        onPressed: () {
          _handleDeleteProfile(context, ref);
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profiles = ref.watch(profilesProvider);
    final seasonalEnabled = ref.watch(
      milestoneSettingProvider.select((state) => state.seasonalEnabled),
    );
    final dustyCount = profiles.where((item) => item.patinaLevel > 0).length;
    final soften = profiles.isNotEmpty && dustyCount * 3 > profiles.length * 2;
    final previewDays = ref.watch(
      findingPreviewProvider.select((state) => state.patinaDays),
    );
    final previewAmount = previewDays == null
        ? null
        : patinaAmountForDays(previewDays.toDouble());
    final updating = ref.watch(isUpdatingProvider(profile.updatingKey));
    final patina = !seasonalEnabled || profile.id == groupValue || updating
        ? 0.0
        : previewAmount ??
              (soften
                  ? profile.patinaAmount.clamp(0.0, 1.0)
                  : profile.patinaAmount);
    final reduceMotion =
        context.disableAnimations || ref.watch(appSettingProvider).reduceMotion;
    return CommonCard(
      enterActionsOnRight: true,
      radius: AppCorner.xl,
      isSelected: profile.id == groupValue,
      onPressed: () {
        onChanged(profile.id);
      },
      child: ProfilePatina(
        level: patina,
        seed: profile.id,
        reduceMotion: reduceMotion,
        child: ListItem(
          key: Key(profile.id.toString()),
          horizontalTitleGap: 8,
          minVerticalPadding: 12,
          padding: const EdgeInsets.only(left: 16, right: 6),
          trailing: SizedBox(
            height: 40,
            width: 40,
            child: Consumer(
              builder: (context, ref, _) {
                final isUpdating = ref.watch(
                  isUpdatingProvider(profile.updatingKey),
                );
                return FadeThroughBox(
                  alignment: Alignment.center,
                  child: isUpdating
                      ? const Padding(
                          key: ValueKey('loading'),
                          padding: AppInsets.sm,
                          child: CommonCircleLoading(),
                        )
                      : CommonPopupBox(
                          key: const ValueKey('menu'),
                          popupBuilder: (_) =>
                              CommonPopupMenu(items: _menuItems(context, ref)),
                          targetBuilder: (open) {
                            return IconButton(
                              style: IconButton.styleFrom(
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.standard,
                              ),
                              tooltip: context.appLocalizations.more,
                              onPressed: () {
                                open();
                              },
                              icon: const GlyphIcon(AppGlyphs.more),
                            );
                          },
                        ),
                );
              },
            ),
          ),
          title: _ProfileCardTitle(
            profile: profile,
            desaturation: (patina * 0.16).clamp(0.0, 0.48),
            reduceMotion: reduceMotion,
            info: switch (profile.type) {
              ProfileType.file => _buildFileProfileInfo(context),
              ProfileType.url => _buildUrlProfileInfo(context),
            },
          ),
          tileTitleAlignment: ListTileTitleAlignment.top,
        ),
      ),
    );
  }
}

class _ProfileCardTitle extends StatelessWidget {
  const _ProfileCardTitle({
    required this.profile,
    required this.info,
    required this.desaturation,
    required this.reduceMotion,
  });

  final double desaturation;
  final bool reduceMotion;

  final Profile profile;
  final List<Widget> info;

  @override
  Widget build(BuildContext context) {
    final client = profile.type == ProfileType.url
        ? profile.effectiveClient
        : null;
    final native = client == null || isNativeSubscriptionClient(client);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          spacing: 6,
          children: [
            if (profile.panelMeta?.serviceLogo case final logo?
                when logo.isNotEmpty)
              TweenAnimationBuilder<double>(
                tween: Tween(end: desaturation),
                duration: reduceMotion
                    ? Duration.zero
                    : const Duration(milliseconds: 600),
                builder: (_, amount, child) {
                  final r = 0.2126 * amount;
                  final g = 0.7152 * amount;
                  final b = 0.0722 * amount;
                  final keep = 1 - amount;
                  return ColorFiltered(
                    colorFilter: ColorFilter.matrix([
                      keep + r,
                      g,
                      b,
                      0,
                      0,
                      r,
                      keep + g,
                      b,
                      0,
                      0,
                      r,
                      g,
                      keep + b,
                      0,
                      0,
                      0,
                      0,
                      0,
                      1,
                      0,
                    ]),
                    child: child,
                  );
                },
                child: SizedBox.square(
                  dimension: 24,
                  child: ImageCacheWidget(
                    src: logo,
                    defaultWidget: const GlyphIcon(AppGlyphs.cloud, size: 20),
                  ),
                ),
              ),
            Flexible(
              child: Text(
                profile.realLabel,
                style: context.textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (client != null)
              CommonChip(
                label:
                    '${subscriptionClientLabel(client, context.appLocalizations)}'
                    '${native ? '' : ' · Experimental'}',
                icon: native ? null : AppGlyphs.beaker,
              ),
            if (isDeveloperSubscriptionProfile(profile))
              const CommonChip(label: 'Dev'),
          ],
        ),
        const SizedBox(height: 6),
        ...info,
      ],
    );
  }
}

class LastUsedTimeText extends ConsumerWidget {
  const LastUsedTimeText({
    super.key,
    required this.lastUsedAt,
    this.style,
    this.now,
  });

  final DateTime? lastUsedAt;
  final TextStyle? style;
  final DateTime? now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final previewDays = ref.watch(
      findingPreviewProvider.select((state) => state.patinaDays),
    );
    final value = previewDays == null
        ? lastUsedAt
        : (now ?? DateTime.now()).subtract(Duration(days: previewDays));
    if (value == null) {
      return Text(context.appLocalizations.neverUsed, style: style);
    }
    final age = (now ?? DateTime.now()).difference(value);
    final showInactiveAge = ref.watch(
      milestoneSettingProvider.select((state) => state.seasonalEnabled),
    );
    if (showInactiveAge && age.inDays >= 120) {
      return Text(
        context.appLocalizations.profileUnusedForMonths(age.inDays ~/ 30),
        style: style,
      );
    }
    return Text(
      '${context.appLocalizations.lastUsed}: '
      '${value.getLastUpdateTimeDesc(context)}',
      style: style,
    );
  }
}

class LastUpdateTimeText extends StatelessWidget {
  final DateTime? lastUpdateDate;
  final TextStyle? style;

  const LastUpdateTimeText({
    super.key,
    required this.lastUpdateDate,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    if (lastUpdateDate == null) {
      return Text('', style: style);
    }
    return TickBuilder(
      duration: const Duration(minutes: 1),
      builder: (context, _) {
        return Text(
          lastUpdateDate!.getLastUpdateTimeDesc(context),
          style: style,
        );
      },
    );
  }
}

class ReorderableProfilesSheet extends ConsumerStatefulWidget {
  final List<Profile> profiles;

  const ReorderableProfilesSheet({super.key, required this.profiles});

  @override
  ConsumerState<ReorderableProfilesSheet> createState() =>
      _ReorderableProfilesSheetState();
}

class _ReorderableProfilesSheetState
    extends ConsumerState<ReorderableProfilesSheet> {
  late List<Profile> profiles;

  @override
  void initState() {
    super.initState();
    profiles = List.from(widget.profiles);
  }

  Widget _buildItem(int index) {
    final position = ItemPosition.get(index, profiles.length);
    final profile = profiles[index];
    return ItemPositionProvider(
      key: Key(profile.id.toString()),
      position: position,
      child: ReorderableDelayedDragStartListener(
        index: index,
        child: DecorationListItem(
          trailing: ReorderMenuHandle(
            index: index,
            count: profiles.length,
            delayedDrag: true,
            icon: AppGlyphs.dragHandle,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                profiles = profiles.copyAndReorder(oldIndex, newIndex);
              });
            },
          ),
          title: Text(profile.realLabel),
        ),
      ),
    );
  }

  void _handleSave() {
    Navigator.of(context).pop();
    ref.read(profilesProvider.notifier).reorder(profiles);
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return AdaptiveSheetScaffold(
      sheetTransparentToolBar: true,
      actions: [
        IconButtonData(
          glyph: AppGlyphs.check,
          onPressed: _handleSave,
          tooltip: context.appLocalizations.save,
        ),
      ],
      body: Padding(
        padding: const EdgeInsets.only(bottom: 32),
        child: ReorderableListView.builder(
          buildDefaultDragHandles: false,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ).copyWith(top: context.sheetTopPadding),
          proxyDecorator: (child, index, animation) {
            return commonProxyDecorator(_buildItem(index), index, animation);
          },
          onReorderItem: (oldIndex, newIndex) {
            setState(() {
              profiles = profiles.copyAndReorder(oldIndex, newIndex);
            });
          },
          itemBuilder: (_, index) {
            return _buildItem(index);
          },
          itemCount: profiles.length,
        ),
      ),
      title: appLocalizations.profilesSort,
    );
  }
}
