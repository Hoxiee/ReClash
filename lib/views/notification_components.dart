import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/features/form/list_editor_page.dart';
import 'package:reclash/features/form/selection_sheet.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/widgets/widgets.dart';

String notificationComponentLabel(
  AppLocalizations l,
  NotificationComponentType type,
) => switch (type) {
  NotificationComponentType.currentServer => l.notificationCurrentServer,
  NotificationComponentType.speed => l.notificationNetworkSpeed,
  NotificationComponentType.sessionTraffic => l.notificationSessionTraffic,
};

class NotificationComponentsEditor extends ConsumerWidget {
  const NotificationComponentsEditor({super.key});

  void _write(
    WidgetRef ref,
    List<NotificationComponent> Function(List<NotificationComponent>) update,
  ) {
    ref
        .read(appSettingProvider.notifier)
        .update(
          (s) => s.copyWith(
            notificationSettings: s.notificationSettings.copyWith(
              components: update(s.notificationSettings.components),
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.appLocalizations;
    final components = ref.watch(
      appSettingProvider.select((s) => s.notificationSettings.components),
    );
    void update(NotificationComponent c, NotificationComponent next) => _write(
      ref,
      (items) => [for (final item in items) item.type == c.type ? next : item],
    );
    return ListEditorPage<NotificationComponent, NotificationComponentType>(
      title: l.notificationComponents,
      itemsOf: (ref) => ref.watch(
        appSettingProvider.select((s) => s.notificationSettings.components),
      ),
      idOf: (c) => c.type,
      emptyLabel: l.notificationComponentsEmptyDesc,
      onAdd: () async {
        final remaining = NotificationComponentType.values
            .where((t) => !components.any((c) => c.type == t))
            .toList();
        if (remaining.isEmpty) {
          return;
        }
        final type = await showSheet<NotificationComponentType>(
          context: context,
          builder: (context) => SelectionSheet<NotificationComponentType>(
            title: l.notificationAddComponent,
            sections: [SelectionSection(items: remaining)],
            labelBuilder: (t) => notificationComponentLabel(l, t),
            selectedOf: (_) => null,
            onSelected: (t) => Navigator.of(context).pop(t),
          ),
        );
        if (!context.mounted || type == null) return;
        _write(
          ref,
          (items) => items.any((c) => c.type == type)
              ? items
              : [...items, NotificationComponent(type: type)],
        );
      },
      addMenuItems: [
        CommonPopupMenuItem(
          glyph: AppGlyphs.reset,
          label: l.reset,
          onPressed: () async {
            final confirmed = await dialogs.showMessage(
              message: TextSpan(text: l.resetTip),
              destructive: true,
              confirmText: l.reset,
            );
            if (confirmed == true && context.mounted) {
              _write(ref, (_) => defaultNotificationComponents);
            }
          },
        ),
      ],
      menuItemsOf: (c) => [
        CommonPopupMenuItem(
          glyph: AppGlyphs.delete,
          label: l.delete,
          danger: true,
          onPressed: () => _write(
            ref,
            (items) => items.where((item) => item.type != c.type).toList(),
          ),
        ),
      ],
      onReorder: (oldIndex, newIndex) =>
          _write(ref, (items) => items.copyAndReorder(oldIndex, newIndex)),
      itemBuilder: (context, ref, c, index, editing, selected, toggleSelected) {
        final title = Text(notificationComponentLabel(l, c.type));
        switch (c.type) {
          case NotificationComponentType.currentServer:
            final groups = ref.watch(currentGroupsStateProvider).value;
            final missing =
                c.group != null && !groups.any((g) => g.name == c.group);
            return ListItem<String>.options(
              title: title,
              subtitle: missing ? Text(l.notificationServerGroupMissing) : null,
              options: [
                '',
                for (final g in groups) g.name,
                if (missing) c.group!,
              ],
              value: c.group ?? '',
              textBuilder: (v) => v.isEmpty ? l.notificationAutomaticGroup : v,
              onChanged: (v) =>
                  update(c, c.copyWith(group: v.isEmpty ? null : v)),
            );
          case NotificationComponentType.speed:
            return ListItem.toggle(
              title: title,
              subtitle: Text(
                '${l.notificationHideIdleSpeed}: ${c.hideWhenIdle ? l.enabled : l.disabled}',
              ),
              value: c.hideWhenIdle,
              onChanged: (v) => update(c, c.copyWith(hideWhenIdle: v)),
            );
          case NotificationComponentType.sessionTraffic:
            return ListItem(title: title);
        }
      },
    );
  }
}
