import 'dart:async';
import 'package:reclash/icons/icons.dart';

import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/action.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/views/misc/finding_preview.dart';
import 'package:reclash/state.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeveloperView extends ConsumerWidget {
  const DeveloperView({super.key});

  String _subscriptionDescription(
    AppLocalizations appLocalizations,
    DeveloperSubscriptionId id,
  ) => switch (id) {
    DeveloperSubscriptionId.prism =>
      appLocalizations.developerSubscriptionPrismDesc,
    DeveloperSubscriptionId.orbit =>
      appLocalizations.developerSubscriptionOrbitDesc,
    DeveloperSubscriptionId.atlas =>
      appLocalizations.developerSubscriptionAtlasDesc,
    DeveloperSubscriptionId.ember =>
      appLocalizations.developerSubscriptionEmberDesc,
  };

  Widget _getSubscriptionsList(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    return SettingSection(
      title: appLocalizations.developerSubscriptions,
      items: [
        for (final fixture in developerSubscriptions)
          DecorationListItem(
            leading: SizedBox.square(
              dimension: 32,
              child: ImageCacheWidget(
                src: fixture.logo,
                fit: BoxFit.contain,
                defaultWidget: const GlyphIcon(AppGlyphs.cloud),
              ),
            ),
            title: Text(fixture.name),
            subtitle: Text(
              _subscriptionDescription(appLocalizations, fixture.id),
            ),
            onPressed: () async {
              final installed = await ref
                  .read(profilesActionProvider.notifier)
                  .installDeveloperSubscription(fixture);
              if (installed && context.mounted) {
                context.showNotifier(
                  appLocalizations.developerSubscriptionInstalled(fixture.name),
                  level: MessageLevel.success,
                );
              }
            },
          ),
      ],
    );
  }

  Widget _getDeveloperList(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    return SettingSection(
      title: appLocalizations.options,
      items: [
        DecorationListItem(
          title: Text(appLocalizations.messageTest),
          onPressed: () {
            for (final level in MessageLevel.values) {
              context.showNotifier(
                '${level.name}: ${appLocalizations.messageTestTip}',
                level: level,
              );
            }
          },
        ),
        DecorationListItem(
          title: Text(appLocalizations.logsTest),
          onPressed: () {
            for (int i = 0; i < 1000; i++) {
              ref
                  .read(logsProvider.notifier)
                  .add(
                    Log.app(
                      '[$i]${generateRandomString(maxLength: 200, minLength: 20)}',
                    ),
                  );
            }
          },
        ),
        if (globalState.canCrashCore)
          ListItem(
            title: Text(appLocalizations.crashTest),
            minVerticalPadding: 12,
            onTap: () async {
              final coreAction = ref.read(coreActionProvider.notifier);
              final res = await dialogs.showMessage(
                message: TextSpan(text: appLocalizations.confirmForceCrashCore),
              );
              if (res != true) {
                return;
              }
              unawaited(coreAction.crash());
            },
          ),
        DecorationListItem(
          title: Text(appLocalizations.clearData),
          onPressed: () async {
            final storeAction = ref.read(storeActionProvider.notifier);
            final res = await dialogs.showMessage(
              message: TextSpan(text: appLocalizations.confirmClearAllData),
            );
            if (res != true) {
              return;
            }
            await storeAction.handleClear();
          },
        ),
        DecorationListItem(
          title: Text(appLocalizations.pruneCache),
          onPressed: () async {
            await ref.read(storeActionProvider.notifier).shakingStore();
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, ref) {
    final appLocalizations = context.appLocalizations;
    final enable = ref.watch(
      appSettingProvider.select((state) => state.developerMode),
    );
    return BaseScaffold(
      title: appLocalizations.developerMode,
      body: ListView(
        padding: EdgeInsets.only(top: context.appBarInset),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: CommonCard(
              type: CommonCardType.filled,
              radius: AppCorner.md,
              child: ListItem.toggle(
                padding: const EdgeInsets.only(left: 16, right: 16),
                title: Text(appLocalizations.developerMode),
                value: enable,
                onChanged: (value) {
                  ref
                      .read(appSettingProvider.notifier)
                      .update((state) => state.copyWith(developerMode: value));
                },
              ),
            ),
          ),
          _getSubscriptionsList(context, ref),
          _getDeveloperList(context, ref),
          if (enable)
            SettingSection(
              items: [
                DecorationListItem.open(
                  leading: const GlyphIcon(AppGlyphs.beaker),
                  title: Text(appLocalizations.developerFindings),
                  widget: const FindingPreviewView(),
                ),
              ],
            ),
          const SettingBottomInset(),
        ],
      ),
    );
  }
}
