part of '../application_notification.dart';

/// Marks the rows whose tap opens a picker; the plain, option-less rows stay
/// bare so the two read differently at a glance.
const _optionCaret = GlyphIcon(AppGlyphs.caretDown, size: 20);

/// The components that build the notification, in the order they are printed.
/// Mirrors the DNS/NTP override editor: each active component is an inline row
/// carrying its own option and a remove button, new ones come from the add
/// menu, and a long press reorders the print order.
class NotificationComponentsEditor extends ConsumerWidget {
  const NotificationComponentsEditor({super.key});

  Future<void> _handleAdd(BuildContext context, WidgetRef ref) async {
    final l = context.appLocalizations;
    final present = ref
        .read(_componentsSelector)
        .map((item) => item.type)
        .toSet();
    final remaining = [
      for (final type in NotificationComponentType.values)
        if (!present.contains(type)) type,
    ];
    final type = await showSheet<NotificationComponentType>(
      context: context,
      props: const SheetProps(isScrollControlled: true),
      builder: (context) => OverwriteSelectionSheet<NotificationComponentType>(
        title: l.notificationAddComponent,
        sections: [
          OverwriteSelectionSection(
            items: remaining,
            subtitleBuilder: (context, type) =>
                _componentDescription(context.appLocalizations, type),
          ),
        ],
        labelBuilder: (type) => _componentLabel(l, type),
        selectedOf: (_) => null,
        onSelected: (type) => Navigator.of(context).pop(type),
      ),
    );
    if (type == null || !context.mounted) {
      return;
    }
    _writeComponents(ref, [
      ...ref.read(_componentsSelector),
      _defaultComponent(type),
    ]);
  }

  Future<void> _handleReset(BuildContext context, WidgetRef ref) async {
    final l = context.appLocalizations;
    final res = await dialogs.showMessage(
      dangerous: true,
      title: l.reset,
      message: TextSpan(text: l.resetTip),
    );
    if (res != true) {
      return;
    }
    _writeComponents(ref, defaultNotificationComponents);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.appLocalizations;
    final canAdd = ref.watch(
      _componentsSelector.select(
        (components) =>
            components.length < NotificationComponentType.values.length,
      ),
    );
    return CommonScaffold(
      title: l.notificationComponents,
      floatBody: true,
      menuItems: [
        CommonPopupMenuItem(
          glyph: AppGlyphs.add,
          label: l.add,
          onPressed: canAdd ? () => _handleAdd(context, ref) : null,
        ),
        CommonPopupMenuItem(
          glyph: AppGlyphs.replay,
          label: l.reset,
          danger: true,
          onPressed: () => _handleReset(context, ref),
        ),
      ],
      body: const _ComponentList(),
    );
  }
}

class _ComponentList extends ConsumerWidget {
  const _ComponentList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.appLocalizations;
    final components = ref.watch(_componentsSelector);
    final environment = _watchEnvironment(ref);
    Widget itemAt(int index) => _ComponentItem(
      key: ValueKey(components[index].type),
      components: components,
      index: index,
      environment: environment,
    );
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(
            top: context.contentTopPadding,
            bottom: components.isEmpty ? 0 : 16,
          ),
          sliver: SliverReorderableList(
            itemCount: components.length,
            itemBuilder: (_, index) => itemAt(index),
            proxyDecorator: (child, index, animation) =>
                commonProxyDecorator(itemAt(index), index, animation),
            onReorderItem: (oldIndex, newIndex) => _writeComponents(
              ref,
              components.copyAndReorder(oldIndex, newIndex),
            ),
          ),
        ),
        if (components.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: NullStatus(
              label: l.notificationComponentsEmptyDesc,
              illustration: NullStatusIllustration.notifications,
            ),
          ),
      ],
    );
  }
}

/// One active component. The remove button rides in the leading slot like the
/// DNS/NTP override rows; the component's single option, when it has one, is
/// the row's own control.
class _ComponentItem extends ConsumerWidget {
  const _ComponentItem({
    super.key,
    required this.components,
    required this.index,
    required this.environment,
  });

  final List<NotificationComponent> components;
  final int index;
  final _ComponentEnvironment environment;

  void _move(WidgetRef ref, int to) {
    if (to < 0 || to >= components.length) {
      return;
    }
    _writeComponents(ref, components.copyAndReorder(index, to));
  }

  void _update(
    WidgetRef ref,
    NotificationComponent Function(NotificationComponent) update,
  ) {
    final type = components[index].type;
    _writeComponents(ref, [
      for (final component in components)
        if (component.type == type) update(component) else component,
    ]);
  }

  void _remove(WidgetRef ref) {
    final type = components[index].type;
    _writeComponents(
      ref,
      components.where((item) => item.type != type).toList(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.appLocalizations;
    final component = components[index];
    final notice = _componentNotice(l, component.type, environment);
    final subtitle = notice == null
        ? Text(_componentStatus(l, component))
        : _NoticeText(notice: notice);
    return Semantics(
      customSemanticsActions: {
        if (index > 0)
          CustomSemanticsAction(label: l.notificationMoveUp): () =>
              _move(ref, index - 1),
        if (index < components.length - 1)
          CustomSemanticsAction(label: l.notificationMoveDown): () =>
              _move(ref, index + 1),
      },
      child: ReorderableDelayedDragStartListener(
        index: index,
        child: ItemPositionProvider(
          position: ItemPosition.get(index, components.length),
          child: _control(
            context,
            ref,
            component,
            _RemoveButton(onPressed: () => _remove(ref)),
            Text(_componentLabel(l, component.type)),
            subtitle,
            notice?.severe ?? false,
          ),
        ),
      ),
    );
  }

  Widget _control(
    BuildContext context,
    WidgetRef ref,
    NotificationComponent component,
    Widget leading,
    Widget title,
    Widget subtitle,
    bool invalid,
  ) {
    final l = context.appLocalizations;
    switch (component.type) {
      case NotificationComponentType.connectionDoctor:
        final priority =
            component.doctorPriority ?? DoctorNotificationPriority.problems;
        return DecorationListItem.options(
          leading: leading,
          title: title,
          subtitle: subtitle,
          trailing: _optionCaret,
          invalid: invalid,
          dialogTitle: l.notificationDoctorPriority,
          options: const [
            DoctorNotificationPriority.problems,
            DoctorNotificationPriority.always,
          ],
          value: priority,
          textBuilder: (value) =>
              _doctorPriorityLabel(l, value! as DoctorNotificationPriority),
          onChanged: (value) {
            if (value == null) {
              return;
            }
            _update(
              ref,
              (item) => item.copyWith(
                doctorPriority: value as DoctorNotificationPriority,
              ),
            );
          },
        );
      case NotificationComponentType.speed:
        return DecorationListItem.toggle(
          leading: leading,
          title: title,
          subtitle: subtitle,
          invalid: invalid,
          value: component.hideWhenIdle ?? true,
          onChanged: (value) =>
              _update(ref, (item) => item.copyWith(hideWhenIdle: value)),
        );
      case NotificationComponentType.currentServer:
        final missing = environment.serverGroupMissing;
        return DecorationListItem.options(
          leading: leading,
          title: title,
          subtitle: subtitle,
          trailing: _optionCaret,
          invalid: invalid,
          dialogTitle: l.notificationSelectServerGroup,
          options: <String>[
            '',
            for (final group in environment.serverGroups) group.name,
          ],
          value: missing ? '' : component.group ?? '',
          textBuilder: (value) =>
              value == '' ? l.notificationAutomaticGroup : value! as String,
          onChanged: (value) {
            if (value == null) {
              return;
            }
            final group = value as String;
            _update(
              ref,
              (item) => item.copyWith(group: group.isEmpty ? null : group),
            );
          },
        );
      case NotificationComponentType.networkState:
      case NotificationComponentType.smartRouting:
      case NotificationComponentType.sessionTraffic:
        return DecorationListItem(
          leading: leading,
          title: title,
          subtitle: subtitle,
          invalid: invalid,
        );
    }
  }
}

class _RemoveButton extends StatelessWidget {
  const _RemoveButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return CommonMinIconButtonTheme(
      child: ElasticButton(
        child: IconButton.filledTonal(
          tooltip: context.appLocalizations.remove,
          onPressed: onPressed,
          icon: const GlyphIcon(AppGlyphs.remove, size: 18, fill: 1),
          padding: EdgeInsets.zero,
        ).withAppTooltip(),
      ),
    );
  }
}

Glyph _noticeIcon(_ComponentNotice notice) =>
    notice.severe ? AppGlyphs.error : AppGlyphs.eyeOff;

class _NoticeText extends StatelessWidget {
  const _NoticeText({required this.notice});

  final _ComponentNotice notice;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final color = notice.severe
        ? colorScheme.error
        : colorScheme.onSurfaceVariant;
    return Row(
      children: [
        GlyphIcon(_noticeIcon(notice), size: 15, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            notice.text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodySmall?.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}
