import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/dashboard/widgets/subscription_overview.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _expiringSoonDays = 3;

class MetaInfo extends StatelessWidget {
  const MetaInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return SizedBox(
      height: getWidgetHeight(2),
      child: RepaintBoundary(
        child: Consumer(
          builder: (_, ref, _) {
            final profile = ref.watch(currentProfileProvider);
            final subscriptionInfo = profile?.subscriptionInfo;
            return CommonCard(
              radius: AppCorner.lg,
              info: Info(
                label: appLocalizations.metaInfo,
                iconData: Icons.event_available,
              ),
              infoActions: profile != null && profile.type == ProfileType.url
                  ? [_UpdateAction(profile: profile)]
                  : null,
              onPressed: () => showExtend(
                context,
                builder: (_) => const SubscriptionOverviewView(),
              ),
              child: _MetaInfoBody(
                profileLabel: profile?.realLabel ?? '',
                subscriptionInfo: subscriptionInfo,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MetaInfoBody extends StatelessWidget {
  const _MetaInfoBody({
    required this.profileLabel,
    required this.subscriptionInfo,
  });

  final String profileLabel;
  final SubscriptionInfo? subscriptionInfo;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final expire = subscriptionInfo?.expire ?? 0;
    final expireDate = expire == 0
        ? null
        : DateTime.fromMillisecondsSinceEpoch(expire * 1000);
    final isPerpetual =
        expire == 0 || (expireDate?.year ?? 0) >= perpetualExpireYear;
    var daysLeft = expireDate?.difference(DateTime.now()).inDays;
    if (daysLeft != null && daysLeft < 0) {
      daysLeft = 0;
    }
    final expireStyle =
        isPerpetual || daysLeft == null || daysLeft > _expiringSoonDays
        ? context.textTheme.titleMedium?.toLight.adjustSize(4)
        : context.textTheme.titleMedium?.toLight
              .adjustSize(4)
              .copyWith(color: context.colorScheme.error);
    return Padding(
      padding: baseInfoEdgeInsets.copyWith(top: 0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Text(
              profileLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodySmall?.toLighter,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isPerpetual
                ? appLocalizations.perpetualSubscription
                : daysLeft == null
                ? appLocalizations.infiniteTime
                : appLocalizations.daysLeft(daysLeft),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: expireStyle,
          ),
          if (subscriptionInfo != null && subscriptionInfo!.total > 0) ...[
            const SizedBox(height: 6),
            SubscriptionInfoView(subscriptionInfo: subscriptionInfo!),
          ],
        ],
      ),
    );
  }
}

class _UpdateAction extends ConsumerWidget {
  const _UpdateAction({required this.profile});

  final Profile profile;

  Future<void> _handleUpdate(WidgetRef ref) async {
    try {
      await ref
          .read(profilesActionProvider.notifier)
          .updateProfile(profile, showLoading: true);
    } catch (e) {
      dialogs.showNotifier(
        userFacingErrorMessage(e, currentAppLocalizations),
        level: MessageLevel.error,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUpdating = ref.watch(isUpdatingProvider(profile.updatingKey));
    return FadeThroughBox(
      child: isUpdating
          ? const Padding(
              key: ValueKey('loading'),
              padding: EdgeInsets.all(8),
              child: CommonCircleLoading(),
            )
          : IconButton(
              key: const ValueKey('update'),
              style: IconButton.styleFrom(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              tooltip: context.appLocalizations.update,
              onPressed: () => _handleUpdate(ref),
              icon: const Icon(Icons.sync),
            ),
    );
  }
}
