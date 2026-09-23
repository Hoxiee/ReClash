part of '../application_notification.dart';

/// Two runs over the same list: the components that build the notification, in
/// the order they are printed, and the ones still available to add.
class NotificationComponentsEditor extends ConsumerWidget {
  const NotificationComponentsEditor({super.key});

  void _move(
    WidgetRef ref,
    List<NotificationComponent> components,
    int from,
    int to,
  ) {
    if (to < 0 || to >= components.length) return;
    _writeComponents(ref, components.copyAndReorder(from, to));
  }

  void _open(BuildContext context, NotificationComponentType type) {
    unawaited(
      showSheet(
        context: context,
        props: const SheetProps(isScrollControlled: true),
        builder: (_) => NotificationComponentSettings(type: type),
      ),
    );
  }

  Widget _activeItem(
    BuildContext context,
    WidgetRef ref,
    List<NotificationComponent> components,
    int index,
    _ComponentEnvironment environment,
  ) {
    final l = context.appLocalizations;
    final component = components[index];
    final notice = _componentNotice(l, component.type, environment);
    return Semantics(
      key: ValueKey(component.type),
      customSemanticsActions: {
        if (index > 0)
          CustomSemanticsAction(label: l.notificationMoveUp): () =>
              _move(ref, components, index, index - 1),
        if (index < components.length - 1)
          CustomSemanticsAction(label: l.notificationMoveDown): () =>
              _move(ref, components, index, index + 1),
      },
      child: ReorderableDelayedDragStartListener(
        index: index,
        child: ItemPositionProvider(
          position: ItemPosition.get(index, components.length),
          child: DecorationListItem(
            leading: _componentGlyph(context, component.type),
            title: Text(_componentLabel(l, component.type)),
            subtitle: notice == null
                ? Text(_componentStatus(l, component))
                : _NoticeText(notice: notice),
            invalid: notice?.severe ?? false,
            trailing: ReorderMenuHandle(
              index: index,
              count: components.length,
              onReorder: (oldIndex, newIndex) =>
                  _move(ref, components, oldIndex, newIndex),
            ),
            onPressed: () => _open(context, component.type),
          ),
        ),
      ),
    );
  }

  Widget _availableItem(
    BuildContext context,
    WidgetRef ref,
    List<NotificationComponent> components,
    NotificationComponentType type,
  ) {
    final l = context.appLocalizations;
    return DecorationListItem(
      leading: _componentGlyph(context, type, muted: true),
      title: Text(_componentLabel(l, type)),
      subtitle: Text(_componentDescription(l, type)),
      trailing: Icon(
        Icons.add_rounded,
        color: context.colorScheme.onSurfaceVariant,
      ),
      onPressed: () =>
          _writeComponents(ref, [...components, _defaultComponent(type)]),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.appLocalizations;
    final components = ref.watch(
      appSettingProvider.select(
        (state) => state.notificationSettings.components,
      ),
    );
    final environment = _watchEnvironment(ref);
    final available = [
      for (final type in NotificationComponentType.values)
        if (components.every((item) => item.type != type)) type,
    ];
    Widget activeAt(int index) =>
        _activeItem(context, ref, components, index, environment);
    return AdaptiveSheetScaffold(
      title: l.notificationComponents,
      body: CustomScrollView(
        primary: false,
        slivers: [
          SliverPadding(
            padding: EdgeInsets.only(top: context.sheetTopPadding),
            sliver: SliverToBoxAdapter(
              child: ListHeader(
                title: l.notificationComponentsActive,
                subTitle: l.notificationComponentsOrderHint,
              ),
            ),
          ),
          if (components.isEmpty)
            const SliverToBoxAdapter(child: _NoActiveComponents())
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverReorderableList(
                itemCount: components.length,
                itemBuilder: (_, index) => activeAt(index),
                proxyDecorator: (child, index, animation) =>
                    commonProxyDecorator(activeAt(index), index, animation),
                onReorderItem: (oldIndex, newIndex) => _writeComponents(
                  ref,
                  components.copyAndReorder(oldIndex, newIndex),
                ),
              ),
            ),
          if (available.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: ListHeader(title: l.notificationAddComponent),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList.builder(
                itemCount: available.length,
                itemBuilder: (_, index) => ItemPositionProvider(
                  position: ItemPosition.get(index, available.length),
                  child: _availableItem(
                    context,
                    ref,
                    components,
                    available[index],
                  ),
                ),
              ),
            ),
          ],
          const SettingBottomInset.sliver(),
        ],
      ),
    );
  }
}

class _NoActiveComponents extends StatelessWidget {
  const _NoActiveComponents();

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final colorScheme = context.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: CommonCard(
        type: CommonCardType.filled,
        radius: AppCorner.xl,
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 20,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.notificationComponentsEmpty,
                    style: context.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l.notificationComponentsEmptyDesc,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

IconData _noticeIcon(_ComponentNotice notice) =>
    notice.severe ? Icons.error_outline_rounded : Icons.visibility_off_outlined;

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
        Icon(_noticeIcon(notice), size: 15, color: color),
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

/// One component: the line it prints, when it prints it, the options it owns
/// and the way back out of the notification.
class NotificationComponentSettings extends ConsumerWidget {
  const NotificationComponentSettings({super.key, required this.type});

  final NotificationComponentType type;

  void _update(
    WidgetRef ref,
    NotificationComponent Function(NotificationComponent) update,
  ) {
    ref
        .read(appSettingProvider.notifier)
        .update(
          (state) => state.copyWith(
            notificationSettings: state.notificationSettings.copyWith(
              components: List.unmodifiable([
                for (final component in state.notificationSettings.components)
                  if (component.type == type) update(component) else component,
              ]),
            ),
          ),
        );
  }

  void _remove(BuildContext context, WidgetRef ref) {
    final components = ref
        .read(appSettingProvider)
        .notificationSettings
        .components
        .where((item) => item.type != type)
        .toList();
    _writeComponents(ref, components);
    context.safeNestedPop();
  }

  List<DecorationListItem> _options(
    BuildContext context,
    WidgetRef ref,
    NotificationComponent component,
    _ComponentEnvironment environment,
  ) {
    final l = context.appLocalizations;
    switch (type) {
      case NotificationComponentType.connectionDoctor:
        final priority =
            component.doctorPriority ?? DoctorNotificationPriority.problems;
        return [
          DecorationListItem.options(
            leading: const Icon(Icons.priority_high_rounded),
            title: Text(l.notificationDoctorPriority),
            subtitle: Text(_doctorPriorityLabel(l, priority)),
            dialogTitle: l.notificationDoctorPriority,
            options: const [
              DoctorNotificationPriority.problems,
              DoctorNotificationPriority.always,
            ],
            value: priority,
            textBuilder: (value) =>
                _doctorPriorityLabel(l, value! as DoctorNotificationPriority),
            onChanged: (value) {
              if (value == null) return;
              _update(
                ref,
                (item) => item.copyWith(
                  doctorPriority: value as DoctorNotificationPriority,
                ),
              );
            },
          ),
        ];
      case NotificationComponentType.speed:
        return [
          DecorationListItem.toggle(
            leading: const Icon(Icons.bedtime_outlined),
            title: Text(l.notificationHideIdleSpeed),
            subtitle: Text(l.notificationHideIdleSpeedDesc),
            value: component.hideWhenIdle ?? true,
            onChanged: (value) =>
                _update(ref, (item) => item.copyWith(hideWhenIdle: value)),
          ),
        ];
      case NotificationComponentType.currentServer:
        final missing = environment.serverGroupMissing;
        return [
          DecorationListItem.options(
            leading: const Icon(Icons.dns_outlined),
            title: Text(l.notificationSelectServerGroup),
            subtitle: Text(
              missing
                  ? l.notificationServerGroupMissing
                  : component.group ?? l.notificationAutomaticGroup,
            ),
            dialogTitle: l.notificationSelectServerGroup,
            options: <String>[
              '',
              for (final group in environment.serverGroups) group.name,
            ],
            value: missing ? '' : component.group ?? '',
            textBuilder: (value) =>
                value == '' ? l.notificationAutomaticGroup : value! as String,
            invalid: missing,
            onChanged: (value) {
              if (value == null) return;
              final group = value as String;
              _update(
                ref,
                (item) => item.copyWith(group: group.isEmpty ? null : group),
              );
            },
          ),
        ];
      case NotificationComponentType.networkState:
      case NotificationComponentType.smartRouting:
      case NotificationComponentType.sessionTraffic:
        return const [];
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.appLocalizations;
    final components = ref.watch(
      appSettingProvider.select(
        (state) => state.notificationSettings.components,
      ),
    );
    final index = components.indexWhere((item) => item.type == type);
    if (index == -1) {
      return AdaptiveSheetScaffold(
        title: _componentLabel(l, type),
        body: NullStatus(label: l.notificationComponentsEmpty),
      );
    }
    final component = components[index];
    final environment = _watchEnvironment(ref);
    final options = _options(context, ref, component, environment);
    return AdaptiveSheetScaffold(
      title: _componentLabel(l, type),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, context.sheetTopPadding, 16, 0),
        children: [
          _ComponentLineCard(
            component: component,
            notice: _componentNotice(l, type, environment),
            isFirst: index == 0,
          ),
          if (options.isNotEmpty) ...[
            const SizedBox(height: 8),
            generateSectionV3(
              title: l.notificationComponentBehaviour,
              items: options,
            ),
          ],
          const SizedBox(height: 24),
          generateSectionV3(
            items: [
              DecorationListItem(
                leading: const Icon(Icons.remove_circle_outline_rounded),
                title: Text(l.notificationRemoveComponent),
                onPressed: () => _remove(context, ref),
              ),
            ],
          ),
          const SettingBottomInset(),
        ],
      ),
    );
  }
}

class _ComponentLineCard extends StatelessWidget {
  const _ComponentLineCard({
    required this.component,
    required this.notice,
    required this.isFirst,
  });

  final NotificationComponent component;
  final _ComponentNotice? notice;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final warning = notice;
    return CommonCard(
      type: CommonCardType.filled,
      radius: AppCorner.xl,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 14,
        children: [
          Row(
            children: [
              _componentGlyph(context, component.type),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  _componentSampleLine(l, component.type),
                  style: context.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              if (warning != null)
                _previewLineRow(context, (
                  icon: _noticeIcon(warning),
                  text: warning.text,
                  alert: warning.severe,
                )),
              _previewLineRow(context, (
                icon: Icons.schedule_rounded,
                text: _componentVisibility(l, component),
                alert: false,
              )),
              if (isFirst)
                _previewLineRow(context, (
                  icon: Icons.unfold_less_rounded,
                  text: l.notificationCollapsedLine,
                  alert: false,
                )),
            ],
          ),
        ],
      ),
    );
  }
}
