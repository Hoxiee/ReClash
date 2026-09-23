part of 'input.dart';

class ListInputPage extends ConsumerStatefulWidget {
  final String title;
  final List<String> items;
  final Widget Function(String item) titleBuilder;
  final Widget Function(String item)? subtitleBuilder;
  final Widget Function(String item)? leadingBuilder;
  final String? valueLabel;
  final int? itemMaxLength;
  final String Function(String item)? itemNormalizer;
  final String? Function(String item)? itemValidator;

  const ListInputPage({
    super.key,
    required this.title,
    required this.items,
    required this.titleBuilder,
    this.leadingBuilder,
    this.valueLabel,
    this.subtitleBuilder,
    this.itemMaxLength,
    this.itemNormalizer,
    this.itemValidator,
  });

  @override
  ConsumerState createState() => _ListInputPageState();
}

class _ListInputPageState extends ConsumerState<ListInputPage> {
  late final ListEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ListEditingController(
      items: widget.items,
      valueLabel: widget.valueLabel,
      itemMaxLength: widget.itemMaxLength,
      itemNormalizer: widget.itemNormalizer,
      itemValidator: widget.itemValidator,
    );
    _controller.addListener(_handleControllerChange);
  }

  void _handleControllerChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerChange);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CommonPopScope(
      onPop: (_) {
        if (_controller.selection.isNotEmpty) {
          _controller.clearSelection();
          return false;
        }
        Navigator.of(context).pop(_controller.items);
        return false;
      },
      child: CommonScaffold(
        title: widget.title,
        actions: _controller.actions(context),
        body: ListInputBody(
          controller: _controller,
          titleBuilder: widget.titleBuilder,
          subtitleBuilder: widget.subtitleBuilder,
          leadingBuilder: widget.leadingBuilder,
        ),
      ),
    );
  }
}

/// The editable string list as a bare body: the wrapper — a page's
/// CommonScaffold or a sheet's AdaptiveSheetScaffold — is the only title bar,
/// so the actions ride along through [ListEditingController.actions].
class ListInputBody extends StatelessWidget {
  // The controller notifies on every edit; a ListenableBuilder at the top
  // re-renders the list, so the stateless body itself needs no state.
  final ListEditingController controller;
  final Widget Function(String item) titleBuilder;
  final Widget Function(String item)? subtitleBuilder;
  final Widget Function(String item)? leadingBuilder;

  const ListInputBody({
    super.key,
    required this.controller,
    required this.titleBuilder,
    this.leadingBuilder,
    this.subtitleBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final selectedItems = controller.selection;
        final items = controller.items;
        return items.isEmpty
            ? NullStatus(label: appLocalizations.noData)
            : ReorderableListView.builder(
                padding: const EdgeInsets.only(
                  bottom: 16 + 64,
                  top: 16,
                  left: 16,
                  right: 16,
                ),
                buildDefaultDragHandles: false,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final value = items[index];
                  return controller.buildItem(
                    context: context,
                    value: value,
                    index: index,
                    length: items.length,
                    isSelected: selectedItems.contains(value),
                    isEditing: selectedItems.isNotEmpty,
                    titleBuilder: titleBuilder,
                    subtitleBuilder: subtitleBuilder,
                    leadingBuilder: leadingBuilder,
                  );
                },
                proxyDecorator: (child, index, animation) {
                  final value = items[index];
                  return commonProxyDecorator(
                    controller.buildItem(
                      context: context,
                      value: value,
                      index: index,
                      length: items.length,
                      isSelected: selectedItems.contains(value),
                      isEditing: selectedItems.isNotEmpty,
                      titleBuilder: titleBuilder,
                      subtitleBuilder: subtitleBuilder,
                      leadingBuilder: leadingBuilder,
                    ),
                    index,
                    animation,
                  );
                },
                onReorderItem: controller.reorder,
              );
      },
    );
  }
}

/// Editing state of a string list: the items, the selection set, and the
/// toolbar actions that act on them. A ChangeNotifier because the body and
/// the actions live in different subtrees (body vs. the wrapper's app bar).
class ListEditingController extends ChangeNotifier {
  ListEditingController({
    required List<String> items,
    this.onChanged,
    this.valueLabel,
    this.itemMaxLength,
    this.itemNormalizer,
    this.itemValidator,
  }) {
    _items = items;
    _originItems = List<String>.from(items);
  }

  final ValueChanged<List<String>>? onChanged;
  final String? valueLabel;
  final int? itemMaxLength;
  final String Function(String item)? itemNormalizer;
  final String? Function(String item)? itemValidator;

  List<String> _items = [];
  late List<String> _originItems;
  final Set<String> _selection = {};

  List<String> get items => _items;
  Set<String> get selection => _selection;

  static final _separator = RegExp(r'[,，]');

  @override
  void dispose() {
    onChanged?.call(_items);
    super.dispose();
  }

  void _update(List<String> next) {
    _items = next;
    notifyListeners();
  }

  void reorder(int oldIndex, int newIndex) {
    _update(_items.copyAndReorder(oldIndex, newIndex));
  }

  void toggleSelected(String value) {
    _selection.addOrRemove(value);
    notifyListeners();
  }

  void clearSelection() {
    _selection.clear();
    notifyListeners();
  }

  void selectAll() {
    if (_selection.containsAll(_items.toSet())) {
      _selection.clear();
    } else {
      _selection
        ..clear()
        ..addAll(_items);
    }
    notifyListeners();
  }

  List<String> splitValues(String? value) {
    return (value ?? '')
        .split(_separator)
        .map((entry) => entry.trim())
        .map((entry) => itemNormalizer?.call(entry) ?? entry)
        .where((entry) => entry.isNotEmpty)
        .toSet()
        .toList();
  }

  Future<void> addOrEdit(
    BuildContext context, {
    String? item,
    int? itemMaxLength,
  }) async {
    final maxLength = itemMaxLength ?? this.itemMaxLength;
    final appLocalizations = context.appLocalizations;
    final label = valueLabel ?? appLocalizations.value;
    final isEdit = item != null;

    String? editValidator(String? value) {
      final normalized = itemNormalizer?.call(value ?? '') ?? (value ?? '');
      final itemError = itemValidator?.call(normalized);
      if (itemError != null) {
        return itemError;
      }
      final exists = _items.contains(normalized) && normalized != item;
      return exists ? appLocalizations.existsTip(label) : null;
    }

    String? addValidator(String? value) {
      final values = splitValues(value);
      if (values.isEmpty) {
        return appLocalizations.emptyTip(label);
      }
      if (maxLength != null && values.any((v) => v.length > maxLength)) {
        return appLocalizations.maxLengthTip(label, maxLength);
      }
      if (itemValidator != null) {
        for (final value in values) {
          final itemError = itemValidator!(value);
          if (itemError != null) {
            return itemError;
          }
        }
      }
      if (values.any(_items.contains)) {
        return appLocalizations.existsTip(label);
      }
      return null;
    }

    final value = await dialogs.showCommonDialog<String>(
      child: AddDialog(
        valueField: Field(
          label: label,
          value: item ?? '',
          validator: isEdit ? editValidator : addValidator,
        ),
        valueMaxLength: isEdit ? maxLength : null,
        valueHelperText: isEdit ? null : appLocalizations.multipleValuesTip,
        title: isEdit ? appLocalizations.edit : appLocalizations.add,
      ),
    );

    final nextItems = List<String>.from(_items);
    if (value == null) {
      return;
    }
    if (isEdit) {
      nextItems[_items.indexOf(item)] = itemNormalizer?.call(value) ?? value;
    } else {
      nextItems.addAll(splitValues(value));
    }
    _update(nextItems);
  }

  void delete() {
    _update(_items.where((item) => !_selection.contains(item)).toList());
    _selection.clear();
    notifyListeners();
  }

  Future<void> reset(BuildContext context) async {
    final res = await dialogs.showMessage(
      message: TextSpan(text: context.appLocalizations.resetPageChangesTip),
    );
    if (res != true) {
      return;
    }
    _update(_originItems);
  }

  Widget buildItem({
    required BuildContext context,
    required String value,
    required int index,
    required int length,
    required bool isSelected,
    required bool isEditing,
    required Widget Function(String item) titleBuilder,
    Widget Function(String item)? subtitleBuilder,
    Widget Function(String item)? leadingBuilder,
  }) {
    final position = ItemPosition.get(index, length);
    return ReorderableDelayedDragStartListener(
      key: ValueKey(value),
      index: index,
      child: ItemPositionProvider(
        position: position,
        child: SelectedDecorationListItem(
          title: titleBuilder(value),
          isSelected: isSelected,
          isEditing: isEditing,
          onSelected: () {
            toggleSelected(value);
          },
          onPressed: () {
            addOrEdit(context, item: value);
          },
          leading: leadingBuilder != null ? leadingBuilder(value) : null,
          subtitle: subtitleBuilder != null ? subtitleBuilder(value) : null,
          trailing: ReorderMenuHandle(
            index: index,
            count: length,
            delayedDrag: true,
            onReorder: reorder,
          ),
        ),
      ),
    );
  }

  List<Widget> actions(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return [
      if (_selection.isNotEmpty) ...[
        CommonMinIconButtonTheme(
          child: IconButton.filledTonal(
            tooltip: context.appLocalizations.delete,
            onPressed: delete,
            icon: const Icon(Icons.delete),
          ),
        ),
        const SizedBox(width: 2),
      ] else if (!stringListEquality.equals(_items, _originItems)) ...[
        CommonMinIconButtonTheme(
          child: IconButton.filledTonal(
            tooltip: context.appLocalizations.reset,
            onPressed: () => reset(context),
            icon: const Icon(Icons.replay),
          ),
        ),
        const SizedBox(width: 2),
      ],
      CommonMinFilledButtonTheme(
        child: _selection.isNotEmpty
            ? FilledButton(
                onPressed: selectAll,
                child: Text(appLocalizations.selectAll),
              )
            : FilledButton.tonal(
                onPressed: () => addOrEdit(context),
                child: Text(appLocalizations.add),
              ),
      ),
      const SizedBox(width: 8),
    ];
  }

  List<IconButtonData> iconActions(BuildContext context) {
    return [
      if (_selection.isNotEmpty)
        IconButtonData(
          icon: Icons.delete,
          onPressed: delete,
          tooltip: context.appLocalizations.delete,
        )
      else if (!stringListEquality.equals(_items, _originItems))
        IconButtonData(
          icon: Icons.replay,
          onPressed: () => reset(context),
          tooltip: context.appLocalizations.reset,
        ),
      IconButtonData(
        icon: Icons.add,
        onPressed: () => addOrEdit(context),
        tooltip: context.appLocalizations.add,
      ),
    ];
  }
}

class MapInputPage extends ConsumerStatefulWidget {
  final String title;
  final Map<String, String> map;
  final Widget Function(MapEntry<String, String> item) titleBuilder;
  final Widget Function(MapEntry<String, String> item)? subtitleBuilder;
  final Widget Function(MapEntry<String, String> item)? leadingBuilder;
  final String? keyLabel;
  final String? valueLabel;
  final int? keyMaxLength;
  final int? valueMaxLength;

  const MapInputPage({
    super.key,
    required this.title,
    required this.map,
    required this.titleBuilder,
    this.leadingBuilder,
    this.keyLabel,
    this.valueLabel,
    this.subtitleBuilder,
    this.keyMaxLength,
    this.valueMaxLength,
  });

  @override
  ConsumerState<MapInputPage> createState() => _MapInputPageState();
}

class _MapInputPageState extends ConsumerState<MapInputPage> {
  List<MapEntry<String, String>> _items = [];
  late final List<MapEntry<String, String>> _originItems;
  final _key = uniqueId;

  @override
  void initState() {
    super.initState();
    _items = List<MapEntry<String, String>>.from(widget.map.entries);
    _originItems = List<MapEntry<String, String>>.from(_items);
  }

  void _handleReorder(int oldIndex, newIndex) {
    _items = _items.copyAndReorder(oldIndex, newIndex);
    setState(() {});
  }

  void _handleSelected(MapEntry<String, String> value) {
    ref.read(itemsProvider(_key).notifier).update((state) {
      final newState = Set<String>.from(state)..addOrRemove(value.key);
      return newState;
    });
  }

  void _handleSelectAll() {
    final ids = _items.map((item) => item.key).toSet();
    ref.read(itemsProvider(_key).notifier).update((selected) {
      return selected.containsAll(ids) ? {} : ids;
    });
  }

  Future<void> _handleAddOrEdit([MapEntry<String, String>? item]) async {
    final appLocalizations = context.appLocalizations;
    String? uniqueValidator(String? value) {
      final index = _items.indexWhere((entry) {
        return entry.key == value;
      });
      final current = item?.key == value;
      if (index != -1 && !current) {
        return appLocalizations.existsTip(appLocalizations.key);
      }
      return null;
    }

    final keyField = Field(
      label: widget.keyLabel ?? appLocalizations.key,
      value: item == null ? '' : item.key,
      validator: uniqueValidator,
    );

    final valueField = Field(
      label: widget.valueLabel ?? appLocalizations.value,
      value: item == null ? '' : item.value,
    );

    final value = await dialogs.showCommonDialog<MapEntry<String, String>>(
      child: AddDialog(
        keyField: keyField,
        valueField: valueField,
        keyMaxLength: widget.keyMaxLength,
        valueMaxLength: widget.valueMaxLength,
        title: item != null ? appLocalizations.edit : appLocalizations.add,
      ),
    );
    if (!mounted) return;
    if (value == null) return;
    final index = _items.indexWhere((entry) {
      return entry.key == item?.key;
    });

    final nextItems = List<MapEntry<String, String>>.from(_items);
    if (item != null) {
      nextItems[index] = value;
    } else {
      nextItems.add(value);
    }
    _items = nextItems;
    setState(() {});
  }

  void _handleDelete() {
    final selectedItems = ref.read(itemsProvider(_key));
    final newItems = _items
        .where((item) => !selectedItems.contains(item.key))
        .toList();
    _items = newItems;
    ref.read(itemsProvider(_key).notifier).value = {};
    setState(() {});
  }

  Future<void> _handleReset() async {
    final res = await dialogs.showMessage(
      message: TextSpan(text: context.appLocalizations.resetPageChangesTip),
    );
    if (!mounted || res != true) {
      return;
    }
    _items = _originItems;
    setState(() {});
  }

  Widget _buildItem({
    required MapEntry<String, String> value,
    required int index,
    required int length,
    required bool isSelected,
    required bool isEditing,
  }) {
    final position = ItemPosition.get(index, length);
    return ReorderableDelayedDragStartListener(
      key: ValueKey(value.key),
      index: index,
      child: ItemPositionProvider(
        position: position,
        child: SelectedDecorationListItem(
          title: widget.titleBuilder(value),
          leading: widget.leadingBuilder != null
              ? widget.leadingBuilder!(value)
              : null,
          subtitle: widget.subtitleBuilder != null
              ? widget.subtitleBuilder!(value)
              : null,
          isSelected: isSelected,
          isEditing: isEditing,
          onSelected: () {
            _handleSelected(value);
          },
          onPressed: () {
            _handleAddOrEdit(value);
          },
          trailing: ReorderMenuHandle(
            index: index,
            count: length,
            delayedDrag: true,
            onReorder: _handleReorder,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final selectedItems = ref.watch(itemsProvider(_key));
    return CommonPopScope(
      onPop: (_) {
        if (selectedItems.isNotEmpty) {
          ref.read(itemsProvider(_key).notifier).value = {};
          return false;
        }
        Navigator.of(context).pop(Map<String, String>.fromEntries(_items));
        return false;
      },
      child: CommonScaffold(
        title: widget.title,
        actions: [
          if (selectedItems.isNotEmpty) ...[
            CommonMinIconButtonTheme(
              child: IconButton.filledTonal(
                tooltip: context.appLocalizations.delete,
                onPressed: _handleDelete,
                icon: const Icon(Icons.delete),
              ),
            ),
            const SizedBox(width: 2),
          ] else if (!stringAndStringMapEntryListEquality.equals(
            _items,
            _originItems,
          )) ...[
            CommonMinIconButtonTheme(
              child: IconButton.filledTonal(
                tooltip: context.appLocalizations.reset,
                onPressed: _handleReset,
                icon: const Icon(Icons.replay),
              ),
            ),
            const SizedBox(width: 2),
          ],
          CommonMinFilledButtonTheme(
            child: selectedItems.isNotEmpty
                ? FilledButton(
                    onPressed: _handleSelectAll,
                    child: Text(appLocalizations.selectAll),
                  )
                : FilledButton.tonal(
                    onPressed: () {
                      _handleAddOrEdit();
                    },
                    child: Text(appLocalizations.add),
                  ),
          ),
          const SizedBox(width: 8),
        ],
        body: NullStatusSwitcher(
          isEmpty: _items.isEmpty,
          nullStatus: NullStatus(label: appLocalizations.noData),
          child: ReorderableListView.builder(
            padding: const EdgeInsets.only(
              bottom: 16 + 64,
              top: 16,
              left: 16,
              right: 16,
            ),
            buildDefaultDragHandles: false,
            itemCount: _items.length,
            itemBuilder: (context, index) {
              final value = _items[index];
              return _buildItem(
                value: value,
                index: index,
                length: _items.length,
                isSelected: selectedItems.contains(value.key),
                isEditing: selectedItems.isNotEmpty,
              );
            },
            proxyDecorator: (child, index, animation) {
              final value = _items[index];
              return commonProxyDecorator(
                _buildItem(
                  value: value,
                  index: index,
                  length: _items.length,
                  isSelected: selectedItems.contains(value.key),
                  isEditing: selectedItems.isNotEmpty,
                ),
                index,
                animation,
              );
            },
            onReorderItem: _handleReorder,
          ),
        ),
      ),
    );
  }
}
