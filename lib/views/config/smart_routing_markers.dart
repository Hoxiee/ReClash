part of 'smart_routing.dart';

/// Local: answers *only* from home, unlike domestic (still reachable from home).
enum _MarkerKind { open, domestic, local }

/// A marker is a URL plus the statuses that count, so it cannot ride the plain
/// string-list editor: a bare URL would silently mean "any completed exchange".
class _MarkersItem extends StatelessWidget {
  const _MarkersItem({
    required this.title,
    required this.desc,
    required this.markers,
    required this.kind,
  });

  final String title;
  final String desc;
  final List<RcxMarker> markers;
  final _MarkerKind kind;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return DecorationListItem.open(
      title: Text(title),
      subtitle: Text(
        markers.isEmpty
            ? desc
            : appLocalizations.entriesCount(markers.length),
      ),
      blur: false,
      widget: _MarkersPage(title: title, kind: kind),
    );
  }
}

class _MarkersPage extends ConsumerStatefulWidget {
  const _MarkersPage({required this.title, required this.kind});

  final String title;
  final _MarkerKind kind;

  @override
  ConsumerState<_MarkersPage> createState() => _MarkersPageState();
}

class _MarkersPageState extends ConsumerState<_MarkersPage> {
  Set<String> _selection = {};

  void _deleteSelected() {
    _writeMarkers(
      ref,
      widget.kind,
      _markerRowsOf(
        ref.read(smartRoutingSettingProvider),
        widget.kind,
      ).where((marker) => !_selection.contains(marker.url)).toList(),
    );
    setState(() => _selection = {});
  }

  void _toggleSelectAll() {
    final markers = _markerRowsOf(
      ref.read(smartRoutingSettingProvider),
      widget.kind,
    );
    setState(() {
      _selection = _selection.length == markers.length
          ? {}
          : markers.map((marker) => marker.url).toSet();
    });
  }

  @override
  Widget build(BuildContext context) {
    final selection = _selection;
    final appLocalizations = context.appLocalizations;
    return CommonPopScope(
      onPop: (_) {
        if (selection.isEmpty) {
          return true;
        }
        setState(() => _selection = {});
        return false;
      },
      child: CommonScaffold(
        title: widget.title,
        actions: [
          if (selection.isNotEmpty) ...[
            CommonMinIconButtonTheme(
              child: IconButton.filledTonal(
                tooltip: appLocalizations.delete,
                onPressed: _deleteSelected,
                icon: const Icon(Icons.delete),
              ),
            ),
            const SizedBox(width: 2),
          ],
          CommonMinFilledButtonTheme(
            child: selection.isNotEmpty
                ? FilledButton(
                    onPressed: _toggleSelectAll,
                    child: Text(appLocalizations.selectAll),
                  )
                : FilledButton.tonal(
                    onPressed: () =>
                        _showMarkerDialog(context, ref, widget.kind),
                    child: Text(appLocalizations.add),
                  ),
          ),
          const SizedBox(width: 8),
        ],
        body: _MarkersBody(
          kind: widget.kind,
          selection: selection,
          onSelected: (url) => setState(() {
            _selection = {..._selection}..addOrRemove(url);
          }),
        ),
      ),
    );
  }
}

List<RcxMarker> _markerRowsOf(SmartRoutingProps props, _MarkerKind kind) =>
    switch (kind) {
      _MarkerKind.open => props.openMarkers,
      _MarkerKind.domestic => props.domesticMarkers,
      _MarkerKind.local => props.localMarkers,
    };

void _writeMarkers(WidgetRef ref, _MarkerKind kind, List<RcxMarker> next) {
  ref
      .read(smartRoutingSettingProvider.notifier)
      .update(
        (state) => switch (kind) {
          _MarkerKind.open => state.copyWith(openMarkers: next),
          _MarkerKind.domestic => state.copyWith(domesticMarkers: next),
          _MarkerKind.local => state.copyWith(localMarkers: next),
        },
      );
}

Future<void> _showMarkerDialog(
  BuildContext context,
  WidgetRef ref,
  _MarkerKind kind, [
  int? index,
]) async {
  final rows = _markerRowsOf(ref.read(smartRoutingSettingProvider), kind);
  final result = await dialogs.showCommonDialog<RcxMarker>(
    child: _MarkerDialog(marker: index == null ? null : rows[index]),
  );
  if (result == null) {
    return;
  }
  final next = [...rows];
  if (index == null) {
    next.add(result);
  } else {
    next[index] = result;
  }
  // Rows are keyed by URL, so a repeat URL must collapse onto the latest edit
  // rather than duplicate the key and crash the reorder list.
  final deduped = <String, RcxMarker>{};
  for (final marker in next) {
    deduped[marker.url] = marker;
  }
  _writeMarkers(ref, kind, deduped.values.toList());
}

class _MarkersBody extends ConsumerWidget {
  const _MarkersBody({
    required this.kind,
    required this.selection,
    required this.onSelected,
  });

  final _MarkerKind kind;
  final Set<String> selection;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rows = _markerRowsOf(
      ref.watch(smartRoutingSettingProvider),
      kind,
    );
    if (rows.isEmpty) {
      return NullStatus(
        label: context.appLocalizations.smartRoutingMarkersEmpty,
      );
    }
    Widget itemAt(int index) => _markerRow(context, ref, rows, index);
    return ReorderableListView.builder(
      padding: const EdgeInsets.only(
        bottom: 16 + 64,
        top: 16,
        left: 16,
        right: 16,
      ),
      buildDefaultDragHandles: false,
      itemCount: rows.length,
      itemBuilder: (_, index) => itemAt(index),
      proxyDecorator: (child, index, animation) =>
          commonProxyDecorator(itemAt(index), index, animation),
      onReorderItem: (oldIndex, newIndex) =>
          _writeMarkers(ref, kind, rows.copyAndReorder(oldIndex, newIndex)),
    );
  }

  Widget _markerRow(
    BuildContext context,
    WidgetRef ref,
    List<RcxMarker> rows,
    int index,
  ) {
    final marker = rows[index];
    return ReorderableDelayedDragStartListener(
      key: ValueKey(marker.url),
      index: index,
      child: ItemPositionProvider(
        position: ItemPosition.get(index, rows.length),
        child: SelectedDecorationListItem(
          title: TooltipText(
            text: Text(
              marker.url,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          subtitle: Text(marker.statuses.join(', ')),
          isSelected: selection.contains(marker.url),
          isEditing: selection.isNotEmpty,
          onSelected: () => onSelected(marker.url),
          onPressed: () => selection.isEmpty
              ? _showMarkerDialog(context, ref, kind, index)
              : onSelected(marker.url),
        ),
      ),
    );
  }
}

class _MarkerDialog extends StatefulWidget {
  const _MarkerDialog({this.marker});

  final RcxMarker? marker;

  @override
  State<_MarkerDialog> createState() => _MarkerDialogState();
}

class _MarkerDialogState extends State<_MarkerDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _url;
  late final TextEditingController _statuses;

  @override
  void initState() {
    super.initState();
    _url = TextEditingController(text: widget.marker?.url ?? '');
    _statuses = TextEditingController(
      text: (widget.marker?.statuses ?? const [204]).join(', '),
    );
  }

  @override
  void dispose() {
    _url.dispose();
    _statuses.dispose();
    super.dispose();
  }

  List<int>? _parseStatuses(String? raw) {
    final parts = (raw ?? '')
        .split(',')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty);
    final parsed = <int>[];
    for (final part in parts) {
      final value = int.tryParse(part);
      if (value == null || value < 100 || value > 599) {
        return null;
      }
      parsed.add(value);
    }
    return parsed.isEmpty ? null : parsed;
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    Navigator.of(context).pop(
      RcxMarker(
        url: _url.text.trim(),
        statuses: _parseStatuses(_statuses.text) ?? const [204],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return CommonDialog(
      title: appLocalizations.smartRoutingMarkers,
      actions: [
        TextButton(onPressed: _submit, child: Text(appLocalizations.confirm)),
      ],
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: [
            TextFormField(
              controller: _url,
              minLines: 1,
              maxLines: 2,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: appLocalizations.smartRoutingMarkerUrl,
              ),
              validator: (value) {
                final raw = value?.trim() ?? '';
                if (raw.isEmpty) {
                  return appLocalizations.emptyTip(
                    appLocalizations.smartRoutingMarkerUrl,
                  );
                }
                return raw.isUrl
                    ? null
                    : appLocalizations.urlTip(
                        appLocalizations.smartRoutingMarkerUrl,
                      );
              },
            ),
            TextFormField(
              controller: _statuses,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: appLocalizations.smartRoutingMarkerStatuses,
                hintText: appLocalizations.smartRoutingMarkerStatusesHint,
              ),
              validator: (value) => _parseStatuses(value) == null
                  ? appLocalizations.smartRoutingMarkerStatusesTip
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

String _ruleActionLabel(AppLocalizations l10n, String action) =>
    switch (action) {
      'ignore' => l10n.smartRoutingRuleIgnore,
      'last-resort' => l10n.smartRoutingRuleLastResort,
      'prefer' => l10n.smartRoutingRulePrefer,
      _ => action,
    };

String _ruleMatch(AppLocalizations l10n, RcxNodeRule rule) {
  final parts = [
    if (rule.provider?.isNotEmpty ?? false) rule.provider!,
    if (rule.nameContains?.isNotEmpty ?? false) '"${rule.nameContains!}"',
    if (rule.group?.isNotEmpty ?? false) rule.group!,
    if (rule.country?.isNotEmpty ?? false) rule.country!,
  ];
  return parts.isEmpty ? l10n.smartRoutingRuleMatchAny : parts.join(' · ');
}

class _RulesItem extends StatelessWidget {
  const _RulesItem({required this.rules});

  final List<RcxNodeRule> rules;

  @override
  Widget build(BuildContext context) {
    final l10n = context.appLocalizations;
    return DecorationListItem.open(
      title: Text(l10n.smartRoutingRules),
      subtitle: Text(
        rules.isEmpty
            ? l10n.smartRoutingRulesDesc
            : l10n.rulesCount(rules.length),
      ),
      blur: false,
      widget: const _RulesPage(),
    );
  }
}

class _RulesPage extends ConsumerWidget {
  const _RulesPage();

  void _remove(WidgetRef ref, int index) {
    ref.read(smartRoutingSettingProvider.notifier).update((state) {
      final next = [...state.nodeRules]..removeAt(index);
      return state.copyWith(nodeRules: next);
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.appLocalizations;
    final rules = ref.watch(
      smartRoutingSettingProvider.select((props) => props.nodeRules),
    );
    return CommonScaffold(
      title: l10n.smartRoutingRules,
      actions: [
        CommonMinFilledButtonTheme(
          child: FilledButton.tonal(
            onPressed: () => showRuleDialog(context, ref),
            child: Text(l10n.add),
          ),
        ),
        const SizedBox(width: 8),
      ],
      body: rules.isEmpty
          ? NullStatus(label: l10n.smartRoutingRulesDesc)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: rules.length,
              itemBuilder: (context, index) {
                final rule = rules[index];
                return DecorationListItem(
                  title: Text(_ruleActionLabel(l10n, rule.action)),
                  subtitle: Text(_ruleMatch(l10n, rule)),
                  trailing: IconButton(
                    tooltip: l10n.delete,
                    onPressed: () => _remove(ref, index),
                    icon: const Icon(Icons.delete_outline),
                  ),
                );
              },
            ),
    );
  }
}

Future<void> showRuleDialog(BuildContext context, WidgetRef ref) async {
  final result = await dialogs.showCommonDialog<RcxNodeRule>(
    child: const _RuleDialog(),
  );
  if (result == null) {
    return;
  }
  ref
      .read(smartRoutingSettingProvider.notifier)
      .update(
        (state) => state.copyWith(nodeRules: [...state.nodeRules, result]),
      );
}

class _RuleDialog extends StatefulWidget {
  const _RuleDialog();

  @override
  State<_RuleDialog> createState() => _RuleDialogState();
}

class _RuleDialogState extends State<_RuleDialog> {
  final _provider = TextEditingController();
  final _name = TextEditingController();
  final _group = TextEditingController();
  final _country = TextEditingController();
  String _action = 'ignore';

  @override
  void dispose() {
    _provider.dispose();
    _name.dispose();
    _group.dispose();
    _country.dispose();
    super.dispose();
  }

  String? _clean(TextEditingController controller) {
    final text = controller.text.trim();
    return text.isEmpty ? null : text;
  }

  void _submit() {
    Navigator.of(context).pop(
      RcxNodeRule(
        action: _action,
        provider: _clean(_provider),
        nameContains: _clean(_name),
        group: _clean(_group),
        country: _clean(_country),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.appLocalizations;
    return CommonDialog(
      title: l10n.smartRoutingRuleAdd,
      actions: [TextButton(onPressed: _submit, child: Text(l10n.confirm))],
      child: Column(
        spacing: 16,
        children: [
          DropdownButtonFormField<String>(
            initialValue: _action,
            items: [
              DropdownMenuItem(
                value: 'ignore',
                child: Text(l10n.smartRoutingRuleIgnore),
              ),
              DropdownMenuItem(
                value: 'last-resort',
                child: Text(l10n.smartRoutingRuleLastResort),
              ),
              DropdownMenuItem(
                value: 'prefer',
                child: Text(l10n.smartRoutingRulePrefer),
              ),
            ],
            onChanged: (value) => setState(() => _action = value ?? 'ignore'),
          ),
          TextFormField(
            controller: _provider,
            decoration: InputDecoration(
              labelText: l10n.smartRoutingRuleProvider,
            ),
          ),
          TextFormField(
            controller: _name,
            decoration: InputDecoration(labelText: l10n.smartRoutingRuleName),
          ),
          TextFormField(
            controller: _group,
            decoration: InputDecoration(labelText: l10n.smartRoutingRuleGroup),
          ),
          TextFormField(
            controller: _country,
            decoration: InputDecoration(
              labelText: l10n.smartRoutingRuleCountry,
            ),
          ),
        ],
      ),
    );
  }
}
