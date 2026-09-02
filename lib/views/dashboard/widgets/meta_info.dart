import 'package:reclash/common/common.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _perpetualExpireYear = 2099;
const _expiringSoonDays = 3;

class MetaInfo extends StatelessWidget {
  const MetaInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return SizedBox(
      height: getWidgetHeight(2),
      child: RepaintBoundary(
        child: CommonCard(
          radius: AppCorner.lg,
          info: Info(
            label: appLocalizations.metaInfo,
            iconData: Icons.event_available,
          ),
          onPressed: () {},
          child: Consumer(
            builder: (_, ref, _) {
              final profile = ref.watch(currentProfileProvider);
              final subscriptionInfo = profile?.subscriptionInfo;
              return _MetaInfoBody(
                profileLabel: profile?.realLabel ?? '',
                subscriptionInfo: subscriptionInfo,
              );
            },
          ),
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
        expire == 0 || (expireDate?.year ?? 0) >= _perpetualExpireYear;
    final now = DateTime.now();
    final daysLeft = expireDate?.difference(now).inDays;
    final remaining = subscriptionInfo == null || subscriptionInfo!.total == 0
        ? null
        : subscriptionInfo!.total -
              subscriptionInfo!.upload -
              subscriptionInfo!.download;
    final expireStyle = isPerpetual || daysLeft == null || daysLeft > _expiringSoonDays
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
          const SizedBox(height: 4),
          Text(
            remaining == null
                ? appLocalizations.infiniteTime
                : '${appLocalizations.remainingTraffic}: '
                      '${remaining.traffic.show}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodySmall?.toLighter,
          ),
        ],
      ),
    );
  }
}
