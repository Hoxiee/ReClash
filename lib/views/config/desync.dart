import 'package:reclash/common/common.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _ttlChoices = [3600, 43200, 100800, 604800];

/// The strategy is a raw ciadpi argument line, ByeByeDPI-style: the app manages
/// the listener, the per-network cache and the loop break, everything else is
/// the user's to write.
class DesyncView extends ConsumerWidget {
  const DesyncView({super.key});

  void _update(WidgetRef ref, DesyncProps Function(DesyncProps) f) {
    ref.read(desyncSettingProvider.notifier).update(f);
  }

  Future<void> _handleSave(BuildContext context, WidgetRef ref) async {
    final appLocalizations = context.appLocalizations;
    final name = await dialogs.showCommonDialog<String>(
      child: InputDialog(
        title: appLocalizations.desyncSaveCurrent,
        value: '',
        hintText: appLocalizations.desyncStrategyNameHint,
        maxLength: TextInputLimits.name,
        validator: (value) =>
            (value == null || value.trim().isEmpty)
            ? appLocalizations.emptyTip(appLocalizations.desyncSaveCurrent)
            : null,
      ),
    );
    if (name == null || name.trim().isEmpty) {
      return;
    }
    _update(
      ref,
      (state) => state.copyWith(
        savedStrategies: [
          ...state.savedStrategies,
          DesyncStrategy(name: name.trim(), args: state.strategyArgs),
        ],
      ),
    );
  }

  Future<void> _handleDelete(
    BuildContext context,
    WidgetRef ref,
    DesyncStrategy strategy,
  ) async {
    final appLocalizations = context.appLocalizations;
    final confirmed = await dialogs.showMessage(
      title: appLocalizations.delete,
      message: TextSpan(text: appLocalizations.deleteTip(strategy.name)),
    );
    if (confirmed != true) {
      return;
    }
    _update(
      ref,
      (state) => state.copyWith(
        savedStrategies: state.savedStrategies
            .where((item) => item != strategy)
            .toList(),
      ),
    );
  }

  String _ttlLabel(AppLocalizations appLocalizations, int seconds) =>
      switch (seconds) {
        3600 => appLocalizations.desyncTtlHour,
        43200 => appLocalizations.desyncTtl12Hours,
        604800 => appLocalizations.desyncTtlWeek,
        _ => appLocalizations.desyncTtl28Hours,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final props = ref.watch(desyncSettingProvider);
    final defaultActive = listEquals(props.strategyArgs, desyncDefaultStrategy);
    final slivers = [
      SettingSection.sliver(
        title: appLocalizations.desyncStrategySection,
        actions: [
          const SizedBox(width: 8),
          CommonMinFilledButtonTheme(
            child: FilledButton.tonal(
              onPressed: () => _handleSave(context, ref),
              child: Text(appLocalizations.desyncSaveCurrent),
            ),
          ),
        ],
        items: [
          DecorationListItem.open(
            title: Text(appLocalizations.desyncArgs),
            subtitle: Text(
              appLocalizations.desyncArgsCount(props.strategyArgs.length),
            ),
            widget: _DesyncArgsEditor(
              initialText: desyncArgsToText(props.strategyArgs),
            ),
            onChanged: (args) {
              if (args is List<String>) {
                _update(ref, (state) => state.copyWith(strategyArgs: args));
              }
            },
          ),
          DecorationListItem(
            leading: defaultActive
                ? const Icon(Icons.check_rounded)
                : null,
            title: Text(appLocalizations.desyncDefaultName),
            subtitle: const Text(
              'split · disorder · fake · oob · tlsrec',
            ),
            onPressed: () => _update(
              ref,
              (state) => state.copyWith(strategyArgs: desyncDefaultStrategy),
            ),
          ),
          for (final strategy in props.savedStrategies)
            DecorationListItem(
              leading: listEquals(props.strategyArgs, strategy.args)
                  ? const Icon(Icons.check_rounded)
                  : null,
              title: Text(strategy.name),
              subtitle: Text(
                appLocalizations.desyncArgsCount(strategy.args.length),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_rounded),
                tooltip: appLocalizations.delete,
                onPressed: () => _handleDelete(context, ref, strategy),
              ),
              onPressed: () => _update(
                ref,
                (state) => state.copyWith(strategyArgs: strategy.args),
              ),
            ),
        ],
      ),
      SettingSection.sliver(
        title: appLocalizations.desyncEngine,
        items: [
          DecorationListItem.input(
            title: Text(appLocalizations.port),
            subtitle: Text(props.port.toString()),
            dialogTitle: appLocalizations.port,
            value: props.port.toString(),
            keyboardType: TextInputType.number,
            maxLength: TextInputLimits.port,
            resetValue: defaultDesyncPort.toString(),
            validator: (value) {
              final label = appLocalizations.port;
              if (value == null || value.isEmpty) {
                return appLocalizations.emptyTip(label);
              }
              final port = int.tryParse(value);
              if (port == null) {
                return appLocalizations.numberTip(label);
              }
              return port >= 1 && port <= 65535
                  ? null
                  : appLocalizations.portTip(label);
            },
            onChanged: (value) {
              final port = int.tryParse(value ?? '');
              if (port != null && port >= 1 && port <= 65535) {
                _update(ref, (state) => state.copyWith(port: port));
              }
            },
          ),
          DecorationListItem.toggle(
            title: Text(appLocalizations.desyncCache),
            subtitle: Text(appLocalizations.desyncCacheDesc),
            value: props.cacheEnabled,
            onChanged: (value) =>
                _update(ref, (state) => state.copyWith(cacheEnabled: value)),
          ),
          if (props.cacheEnabled)
            DecorationListItem.options(
              title: Text(appLocalizations.desyncCacheTtl),
              subtitle: Text(_ttlLabel(appLocalizations, props.cacheTtl)),
              dialogTitle: appLocalizations.desyncCacheTtl,
              options: _ttlChoices,
              value: _ttlChoices.contains(props.cacheTtl)
                  ? props.cacheTtl
                  : defaultDesyncCacheTtl,
              textBuilder: (value) =>
                  _ttlLabel(appLocalizations, value as int),
              onChanged: (value) => _update(
                ref,
                (state) => state.copyWith(cacheTtl: value as int),
              ),
            ),
        ],
      ),
      SettingSection.sliver(
        title: appLocalizations.desyncRouting,
        bottom: 24,
        items: [
          for (final category in DesyncCategory.values)
            DecorationListItem.toggle(
              title: Text(_categoryLabel(category)),
              subtitle: Text('GEOSITE,${category.geosite}'),
              value: props.categories.contains(category),
              onChanged: (value) => _update(ref, (state) {
                final next = {...state.categories};
                value ? next.add(category) : next.remove(category);
                return state.copyWith(categories: next.toList());
              }),
            ),
          DecorationListItem.toggle(
            title: Text(appLocalizations.desyncForceTcp),
            subtitle: Text(appLocalizations.desyncForceTcpDesc),
            value: props.forceTcp,
            onChanged: (value) =>
                _update(ref, (state) => state.copyWith(forceTcp: value)),
          ),
        ],
      ),
    ];
    return CommonScaffold(
      title: appLocalizations.desync,
      body: CustomScrollView(
        slivers: [...slivers, const SettingBottomInset.sliver()],
      ),
    );
  }

  String _categoryLabel(DesyncCategory category) => switch (category) {
    DesyncCategory.youtube => 'YouTube',
    DesyncCategory.discord => 'Discord',
    DesyncCategory.twitter => 'Twitter / X',
    DesyncCategory.meta => 'Meta',
    DesyncCategory.signal => 'Signal',
  };
}

class _DesyncArgsEditor extends StatefulWidget {
  const _DesyncArgsEditor({required this.initialText});

  final String initialText;

  @override
  State<_DesyncArgsEditor> createState() => _DesyncArgsEditorState();
}

class _DesyncArgsEditorState extends State<_DesyncArgsEditor> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleReset() {
    _controller.text = desyncArgsToText(desyncDefaultStrategy);
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return CommonPopScope(
      onPop: (_) async {
        final List<String> args;
        try {
          args = desyncArgsFromText(_controller.text);
        } on FormatException {
          await dialogs.showMessage(
            title: appLocalizations.desyncArgs,
            message: TextSpan(text: appLocalizations.desyncArgsQuoteError),
          );
          return false;
        }
        if (context.mounted) {
          Navigator.of(context).pop(args);
        }
        return false;
      },
      child: CommonScaffold(
        title: appLocalizations.desyncArgs,
        actions: [
          IconButton(
            icon: const Icon(Icons.replay),
            tooltip: appLocalizations.reset,
            onPressed: _handleReset,
          ),
        ],
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _controller,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            style: const TextStyle(fontFamily: 'monospace'),
            decoration: InputDecoration(
              hintText: appLocalizations.desyncArgsHint,
            ),
          ),
        ),
      ),
    );
  }
}
