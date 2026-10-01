import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/action.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/misc/finding_preview.dart';
import 'package:reclash/widgets/widgets.dart';

class DeveloperView extends ConsumerWidget {
  const DeveloperView({super.key});

  Widget _getDeveloperList(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    return SettingSection(
      search: const SettingSearch(),
      title: appLocalizations.options,
      items: [
        DecorationListItem(
          search: const SettingSearch(),
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
          search: const SettingSearch(),
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
            search: const SettingSearch(),
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
          search: const SettingSearch(),
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
          search: const SettingSearch(),
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
    return BaseScaffold(
      title: appLocalizations.developerMode,
      body: ListView(
        padding: EdgeInsets.only(top: context.appBarInset),
        children: [
          _getDeveloperList(context, ref),
          SettingSection(
            items: [
              DecorationListItem.open(
                leading: const GlyphIcon(AppGlyphs.beaker),
                search: const SettingSearch(),
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
