import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

const _manualHoldChoices = [0, 15, 30, 60, 240];

class SmartRoutingView extends ConsumerWidget {
  const SmartRoutingView({super.key});

  void _update(WidgetRef ref, SmartRoutingProps Function(SmartRoutingProps) f) {
    ref.read(smartRoutingSettingProvider.notifier).update(f);
  }

  void _handleEnabled(BuildContext context, WidgetRef ref, bool value) {
    _update(ref, (state) {
      var preset = state.preset;
      if (value && preset == SmartRoutingPreset.off) {
        final locale = Intl.defaultLocale ?? '';
        if (locale.startsWith('ru')) {
          preset = SmartRoutingPreset.ruMobile;
        }
      }
      return state.copyWith(enabled: value, preset: preset);
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final props = ref.watch(smartRoutingSettingProvider);
    final items = [
      DecorationListItem(
        minVerticalPadding: 8,
        contentPadding: const EdgeInsets.only(left: 16, right: 8),
        title: Text(appLocalizations.smartRouting),
        subtitle: Text(appLocalizations.smartRoutingDesc),
        onPressed: () => _handleEnabled(context, ref, !props.enabled),
        trailing: Switch(
          value: props.enabled,
          onChanged: (value) => _handleEnabled(context, ref, value),
        ),
      ),
      if (props.enabled) ...[
        ListItem<SmartRoutingPreset>.options(
          title: Text(appLocalizations.smartRoutingPreset),
          subtitle: Text(props.preset.label),
          dialogTitle: appLocalizations.smartRoutingPreset,
          options: SmartRoutingPreset.values,
          value: props.preset,
          textBuilder: (value) => value.label,
          onChanged: (value) {
            if (value != null) {
              _update(ref, (state) => state.copyWith(preset: value));
            }
          },
        ),
        DecorationListItem(
          minVerticalPadding: 8,
          contentPadding: const EdgeInsets.only(left: 16, right: 8),
          title: Text(appLocalizations.smartRoutingDomestic),
          subtitle: Text(appLocalizations.smartRoutingDomesticDesc),
          onPressed: () {
            _update(
              ref,
              (state) => state.copyWith(
                allowDomesticLastResort: !state.allowDomesticLastResort,
              ),
            );
          },
          trailing: Switch(
            value: props.allowDomesticLastResort,
            onChanged: (value) {
              _update(
                ref,
                (state) => state.copyWith(allowDomesticLastResort: value),
              );
            },
          ),
        ),
        DecorationListItem(
          minVerticalPadding: 8,
          contentPadding: const EdgeInsets.only(left: 16, right: 8),
          title: Text(appLocalizations.smartRoutingSaveData),
          subtitle: Text(appLocalizations.smartRoutingSaveDataDesc),
          onPressed: () {
            _update(
              ref,
              (state) => state.copyWith(saveMobileData: !state.saveMobileData),
            );
          },
          trailing: Switch(
            value: props.saveMobileData,
            onChanged: (value) {
              _update(
                ref,
                (state) => state.copyWith(saveMobileData: value),
              );
            },
          ),
        ),
        ListItem<int>.options(
          title: Text(appLocalizations.smartRoutingManualHold),
          subtitle: Text(
            props.manualHoldMinutes == 0
                ? appLocalizations.smartRoutingManualHoldOff
                : appLocalizations.smartRoutingManualHoldMinutes(
                    props.manualHoldMinutes,
                  ),
          ),
          dialogTitle: appLocalizations.smartRoutingManualHold,
          options: _manualHoldChoices,
          value: props.manualHoldMinutes,
          textBuilder: (value) => value == 0
              ? appLocalizations.smartRoutingManualHoldOff
              : appLocalizations.smartRoutingManualHoldMinutes(value),
          onChanged: (value) {
            if (value != null) {
              _update(ref, (state) => state.copyWith(manualHoldMinutes: value));
            }
          },
        ),
      ],
    ];
    return CommonScaffold(
      title: appLocalizations.smartRouting,
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: generateSectionV3(items: items),
            ),
          ),
        ],
      ),
    );
  }
}
