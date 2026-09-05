import 'package:reclash/common/common.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'widgets.dart';

const _defaultDarkAt = '22:00';
const _defaultLightAt = '07:00';

class AppearanceThemeTab extends ConsumerWidget {
  const AppearanceThemeTab({super.key});

  void _update(WidgetRef ref, ThemeProps Function(ThemeProps) f) {
    ref.read(themeSettingProvider.notifier).update(f);
  }

  Future<void> _editTime(
    BuildContext context,
    WidgetRef ref, {
    required bool isDark,
  }) async {
    final current = ref.read(
      themeSettingProvider.select(
        (state) =>
            (isDark ? state.darkAt : state.lightAt) ??
            (isDark ? _defaultDarkAt : _defaultLightAt),
      ),
    );
    final picked = await showTimePicker(
      context: context,
      initialTime: _parseTime(current),
    );
    if (picked == null) {
      return;
    }
    final value = _formatTime(picked);
    _update(
      ref,
      (state) => isDark
          ? state.copyWith(darkAt: value)
          : state.copyWith(lightAt: value),
    );
  }

  List<Widget> _modeCards(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final (themeMode: themeMode, scheduledTheme: scheduled) = ref.watch(
      themeSettingProvider.select(
        (state) => (
          themeMode: state.themeMode,
          scheduledTheme: state.scheduledTheme,
        ),
      ),
    );
    final modes = [
      (ThemeMode.system, Icons.auto_mode, appLocalizations.auto),
      (ThemeMode.light, Icons.light_mode, appLocalizations.light),
      (ThemeMode.dark, Icons.dark_mode, appLocalizations.dark),
    ];
    return [
      for (final (mode, iconData, label) in modes)
        SettingInfoCard(
          Info(label: label, iconData: iconData),
          isSelected: !scheduled && mode == themeMode,
          onPressed: () => _update(
            ref,
            (state) =>
                state.copyWith(scheduledTheme: false, themeMode: mode),
          ),
        ),
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final theme = ref.watch(
      themeSettingProvider.select(
        (state) => (
          scheduledTheme: state.scheduledTheme,
          darkAt: state.darkAt ?? _defaultDarkAt,
          lightAt: state.lightAt ?? _defaultLightAt,
          pureBlack: state.pureBlack,
          contrastLevel: state.contrastLevel,
        ),
      ),
    );
    final contrast = theme.contrastLevel.clamp(-1.0, 1.0);
    return CustomScrollView(
      primary: false,
      slivers: [
        appearanceSection(
          title: appLocalizations.themeMode,
          items: [
            Wrap(spacing: 8, runSpacing: 8, children: _modeCards(context, ref)),
          ],
        ),
        appearanceSection(
          items: [
            AppearanceSwitchItem(
              leading: const Icon(Icons.schedule),
              title: appLocalizations.schedule,
              desc: appLocalizations.scheduleDesc(theme.darkAt, theme.lightAt),
              value: theme.scheduledTheme,
              onChanged: (value) => _update(
                ref,
                (state) => value
                    ? state.copyWith(
                        scheduledTheme: true,
                        darkAt: state.darkAt ?? _defaultDarkAt,
                        lightAt: state.lightAt ?? _defaultLightAt,
                      )
                    : state.copyWith(scheduledTheme: false),
              ),
            ),
            if (theme.scheduledTheme) ...[
              AppearanceValueItem(
                leading: const Icon(Icons.bedtime),
                title: appLocalizations.darkAt,
                value: theme.darkAt,
                onPressed: () => _editTime(context, ref, isDark: true),
              ),
              AppearanceValueItem(
                leading: const Icon(Icons.wb_sunny),
                title: appLocalizations.lightAt,
                value: theme.lightAt,
                onPressed: () => _editTime(context, ref, isDark: false),
              ),
            ],
          ],
        ),
        appearanceSection(
          items: [
            AppearanceSwitchItem(
              leading: const Icon(Icons.nightlight_round),
              title: appLocalizations.pureBlackMode,
              value: theme.pureBlack,
              onChanged: (value) =>
                  _update(ref, (state) => state.copyWith(pureBlack: value)),
            ),
            AppearanceSliderItem(
              leading: Tooltip(
                message: theme.pureBlack
                    ? appLocalizations.contrastAmoledHint
                    : '',
                child: const Icon(Icons.contrast),
              ),
              title: appLocalizations.contrast,
              valueLabel: _percent(contrast),
              min: -1,
              max: 1,
              value: contrast,
              onChanged: (value) =>
                  _update(ref, (state) => state.copyWith(contrastLevel: value)),
            ),
          ],
        ),
        appearanceBottomInset(context),
      ],
    );
  }
}

String _percent(double value) {
  final percent = (value * 100).round();
  return percent > 0 ? '+$percent%' : '$percent%';
}

TimeOfDay _parseTime(String value) {
  final parts = value.split(':');
  return TimeOfDay(
    hour: int.tryParse(parts.first) ?? 0,
    minute: parts.length > 1 ? int.tryParse(parts.last) ?? 0 : 0,
  );
}

String _formatTime(TimeOfDay value) {
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
