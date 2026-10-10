import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/widgets/widgets.dart';

enum _ToggleOverride { inherit, enabled, disabled }

enum _ListOverride { inherit, custom }

class ProfileTunEditor extends StatelessWidget {
  const ProfileTunEditor({
    super.key,
    required this.value,
    required this.onChanged,
    required this.isLinux,
  });

  final ProfileTun value;
  final ValueChanged<ProfileTun> onChanged;
  final bool isLinux;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final icmpMode = switch (value.disableIcmpForwarding) {
      null => _ToggleOverride.inherit,
      true => _ToggleOverride.enabled,
      false => _ToggleOverride.disabled,
    };
    String icmpLabel(Object? mode) => switch (mode) {
      _ToggleOverride.enabled => l.enabled,
      _ToggleOverride.disabled => l.disabled,
      _ => l.followProfile,
    };
    final interfaces = value.excludeInterface;
    return SettingSection(
      title: l.tun,
      items: [
        DecorationListItem.options(
          title: Text(l.disableIcmpForwarding),
          subtitle: Text(
            '${icmpLabel(icmpMode)}\n${l.disableIcmpForwardingDesc}',
          ),
          dialogTitle: l.disableIcmpForwarding,
          options: _ToggleOverride.values,
          value: icmpMode,
          textBuilder: icmpLabel,
          onChanged: (mode) {
            if (mode == null) return;
            onChanged(
              value.copyWith(
                disableIcmpForwarding: switch (mode) {
                  _ToggleOverride.enabled => true,
                  _ToggleOverride.disabled => false,
                  _ => null,
                },
              ),
            );
          },
        ),
        if (isLinux) ...[
          DecorationListItem.options(
            title: Text(l.excludeInterface),
            subtitle: Text(
              '${interfaces == null ? l.followProfile : l.custom}\n${l.excludeInterfaceDesc}',
            ),
            dialogTitle: l.excludeInterface,
            options: _ListOverride.values,
            value: interfaces == null
                ? _ListOverride.inherit
                : _ListOverride.custom,
            textBuilder: (mode) =>
                mode == _ListOverride.custom ? l.custom : l.followProfile,
            onChanged: (mode) {
              if (mode == null) return;
              onChanged(
                value.copyWith(
                  excludeInterface: mode == _ListOverride.inherit
                      ? null
                      : interfaces ?? const [],
                ),
              );
            },
          ),
          if (interfaces != null)
            DecorationListItem.open(
              title: Text(l.edit),
              subtitle: Text(
                interfaces.isEmpty ? l.noData : interfaces.join(', '),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              forceFull: false,
              preferSheet: true,
              maxWidth: 360,
              widget: ListInputPage(
                title: l.excludeInterface,
                items: interfaces,
                itemMaxLength: TextInputLimits.name,
                itemNormalizer: (item) => item.trim(),
                titleBuilder: (item) => Text(item),
              ),
              onChanged: (items) => onChanged(
                value.copyWith(
                  excludeInterface: List<String>.from(items as List),
                ),
              ),
            ),
        ],
      ],
    );
  }
}
