import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
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
class DesyncView extends StatelessWidget {
  const DesyncView({super.key});

  @override
  Widget build(BuildContext context) => CommonScaffold(
    title: context.appLocalizations.desync,
    body: const SingleChildScrollView(
      child: Column(children: [DesyncControls(), SettingBottomInset()]),
    ),
  );
}

class DesyncStrategyView extends StatelessWidget {
  const DesyncStrategyView({super.key});

  @override
  Widget build(BuildContext context) => CommonScaffold(
    title: context.appLocalizations.desyncStrategySection,
    body: const SingleChildScrollView(
      child: Column(
        children: [
          _DesyncStrategyOverview(),
          DesyncControls._focused(_DesyncSection.strategy),
          SettingBottomInset(),
        ],
      ),
    ),
  );
}

class DesyncTestView extends StatelessWidget {
  const DesyncTestView({super.key});

  @override
  Widget build(BuildContext context) => CommonScaffold(
    title: context.appLocalizations.desyncTestSection,
    body: const SingleChildScrollView(
      child: Column(
        children: [
          DesyncControls._focused(_DesyncSection.test),
          SettingBottomInset(),
        ],
      ),
    ),
  );
}

class DesyncEngineView extends StatelessWidget {
  const DesyncEngineView({super.key});

  @override
  Widget build(BuildContext context) => CommonScaffold(
    title: context.appLocalizations.desyncEngine,
    body: const SingleChildScrollView(
      child: Column(
        children: [
          _DesyncEngineOverview(),
          DesyncControls._focused(_DesyncSection.engine),
          SettingBottomInset(),
        ],
      ),
    ),
  );
}

enum _DesyncSection { strategy, test, engine }

String _desyncStrategyName(
  AppLocalizations appLocalizations,
  DesyncProps props,
) {
  if (listEquals(props.strategyArgs, desyncDefaultStrategy)) {
    return appLocalizations.desyncDefaultName;
  }
  for (final strategy in props.savedStrategies) {
    if (listEquals(strategy.args, props.strategyArgs)) return strategy.name;
  }
  return appLocalizations.custom;
}

String _desyncCategoryLabel(DesyncCategory category) => switch (category) {
  DesyncCategory.youtube => 'YouTube',
  DesyncCategory.discord => 'Discord',
  DesyncCategory.twitter => 'Twitter / X',
  DesyncCategory.meta => 'Meta',
  DesyncCategory.signal => 'Signal',
};

class _DesyncOverviewCard extends StatelessWidget {
  const _DesyncOverviewCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.detail,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? detail;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
    child: CommonCard(
      type: CommonCardType.filled,
      radius: AppCorner.lg,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: ShapeDecoration(
                color: context.colorScheme.primaryContainer,
                shape: AppShape.all(AppCorner.md),
              ),
              child: Icon(icon, color: context.colorScheme.onPrimaryContainer),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (detail case final detail?) ...[
                    const SizedBox(height: 8),
                    Text(
                      detail,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.outline,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _DesyncStrategyOverview extends ConsumerWidget {
  const _DesyncStrategyOverview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final props = ref.watch(desyncSettingProvider);
    return _DesyncOverviewCard(
      icon: Icons.tune_rounded,
      title: appLocalizations.desyncActiveStrategy,
      subtitle: _desyncStrategyName(appLocalizations, props),
      detail: appLocalizations.desyncArgsCount(props.strategyArgs.length),
    );
  }
}

class _DesyncEngineOverview extends ConsumerWidget {
  const _DesyncEngineOverview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final props = ref.watch(desyncSettingProvider);
    return _DesyncOverviewCard(
      icon: Icons.hub_rounded,
      title: '127.0.0.1:${props.port}',
      subtitle: appLocalizations.desyncEngineSummary(props.categories.length),
      detail: props.cacheEnabled ? null : appLocalizations.desyncCacheDisabled,
    );
  }
}

class DesyncControls extends ConsumerStatefulWidget {
  const DesyncControls({super.key}) : _section = null;

  const DesyncControls._focused(this._section) : super();

  final _DesyncSection? _section;

  @override
  ConsumerState<DesyncControls> createState() => _DesyncControlsState();
}

class _DesyncControlsState extends ConsumerState<DesyncControls> {
  var _testing = false;

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
        validator: (value) => (value == null || value.trim().isEmpty)
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
  Widget build(BuildContext context) {
    final ref = this.ref;
    final appLocalizations = context.appLocalizations;
    final props = ref.watch(desyncSettingProvider);
    final defaultActive = listEquals(props.strategyArgs, desyncDefaultStrategy);
    return Column(
      children: [
        if (widget._section == null ||
            widget._section == _DesyncSection.strategy)
          SettingSection(
            top: 16,
            actions: [
              const SizedBox(width: 8),
              CommonMinFilledButtonTheme(
                child: FilledButton.tonal(
                  onPressed: () => _handleSave(context, ref),
                  child: Text(appLocalizations.desyncSaveCurrent),
                ),
              ),
            ],
            items: _locked([
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
                leading: defaultActive ? const Icon(Icons.check_rounded) : null,
                title: Text(appLocalizations.desyncDefaultName),
                subtitle: const Text('split · disorder · fake · oob · tlsrec'),
                onPressed: () => _update(
                  ref,
                  (state) =>
                      state.copyWith(strategyArgs: desyncDefaultStrategy),
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
            ]),
          ),
        if (widget._section == null || widget._section == _DesyncSection.test)
          _DesyncTester(
            showOverview: widget._section == _DesyncSection.test,
            onRunningChanged: (value) => setState(() => _testing = value),
          ),
        if (widget._section == null || widget._section == _DesyncSection.engine)
          SettingSection(
            title: appLocalizations.desyncEngine,
            items: _locked([
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
                onChanged: (value) => _update(
                  ref,
                  (state) => state.copyWith(cacheEnabled: value),
                ),
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
            ]),
          ),
        if (widget._section == null || widget._section == _DesyncSection.engine)
          SettingSection(
            title: appLocalizations.desyncRouting,
            bottom: 24,
            items: _locked([
              for (final category in DesyncCategory.values)
                DecorationListItem.toggle(
                  title: Text(_desyncCategoryLabel(category)),
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
            ]),
          ),
        if (widget._section == _DesyncSection.engine)
          _DesyncRoutingRules(props: props),
      ],
    );
  }

  // The tester drives the strategy field through the provider; the rest of
  // the page must not fight it from under the battery.
  List<Widget> _locked(List<Widget> items) => _testing
      ? items.map((item) => IgnorePointer(child: item)).toList()
      : items;
}

class _DesyncRoutingRules extends StatelessWidget {
  const _DesyncRoutingRules({required this.props});

  final DesyncProps props;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final rules = desyncRules(
      categories: props.categories,
      forceTcp: props.forceTcp,
    );
    return SettingSection(
      title: appLocalizations.desyncRoutingRules,
      subTitle: appLocalizations.desyncRoutingGeositeNote,
      bottom: 24,
      items: [
        if (rules.isEmpty)
          DecorationListItem(
            leading: const Icon(Icons.route_rounded),
            title: Text(appLocalizations.desyncRoutingNoCategories),
            subtitle: Text(appLocalizations.desyncRoutingNoCategoriesDesc),
          )
        else
          for (final rule in rules)
            DecorationListItem(
              leading: Icon(
                rule.endsWith('REJECT')
                    ? Icons.block_rounded
                    : Icons.alt_route_rounded,
              ),
              title: Text(
                rule,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
        DecorationListItem(
          leading: const Icon(Icons.public_rounded),
          title: Text(
            desyncOnlyFallback().single,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
          subtitle: Text(appLocalizations.desyncRoutingFallbackDesc),
        ),
      ],
    );
  }
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
        final issues = desyncValidateArgs(args);
        if (issues.isNotEmpty) {
          await dialogs.showMessage(
            title: appLocalizations.desyncArgs,
            message: TextSpan(
              text: issues
                  .map(
                    (issue) => switch (issue.kind) {
                      DesyncArgsIssueKind.unknownFlag =>
                        appLocalizations.desyncArgsUnknownFlag(issue.token),
                      DesyncArgsIssueKind.appOwnedFlag =>
                        appLocalizations.desyncArgsAppOwnedFlag(issue.token),
                      DesyncArgsIssueKind.missingValue =>
                        appLocalizations.desyncArgsMissingValue(issue.token),
                      DesyncArgsIssueKind.positional =>
                        appLocalizations.desyncArgsPositional(issue.token),
                    },
                  )
                  .join('\n'),
            ),
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

/// Runs the preset battery against the live engine and lets the user apply a
/// winner; the strategy in force when the test started is restored at the end.
class _DesyncTester extends ConsumerStatefulWidget {
  const _DesyncTester({
    required this.showOverview,
    required this.onRunningChanged,
  });

  final bool showOverview;
  final ValueChanged<bool> onRunningChanged;

  @override
  ConsumerState<_DesyncTester> createState() => _DesyncTesterState();
}

class _DesyncTesterState extends ConsumerState<_DesyncTester> {
  final _outcomes = <DesyncTestOutcome>[];
  DesyncStrategyTester? _tester;
  int _index = 0;
  bool _running = false;
  bool _stoppedByUser = false;
  bool _aborted = false;
  bool _engineDown = false;

  @override
  void dispose() {
    _tester?.stop();
    super.dispose();
  }

  Future<void> _handleStart() async {
    final container = ProviderScope.containerOf(context, listen: false);
    final props = container.read(desyncSettingProvider);
    final sites = desyncTestSitesFor(props.testSiteLists);
    if (sites.isEmpty || !await desyncEngineAlive(props.port)) {
      if (mounted) setState(() => _engineDown = true);
      return;
    }
    final retention = container.listen<DesyncProps>(
      desyncSettingProvider,
      (_, _) {},
    );
    final notifier = container.read(desyncSettingProvider.notifier);
    final tester = DesyncStrategyTester(
      port: props.port,
      applyArgs: (args) async =>
          notifier.update((state) => state.copyWith(strategyArgs: args)),
    );
    setState(() {
      _tester = tester;
      _running = true;
      _stoppedByUser = false;
      _aborted = false;
      _engineDown = false;
      _index = 0;
      _outcomes.clear();
    });
    widget.onRunningChanged(true);
    notifier.update(
      (state) => state.copyWith(
        testRunning: true,
        testRestoreArgs: props.strategyArgs,
      ),
    );
    final store = container.read(storeActionProvider.notifier);
    if (!await store.savePreferences()) {
      notifier.update(
        (state) => state.copyWith(testRunning: false, testRestoreArgs: null),
      );
      debouncer.cancel(FunctionTag.savePreferences);
      retention.close();
      if (!mounted) return;
      setState(() {
        _tester = null;
        _running = false;
        _aborted = true;
      });
      widget.onRunningChanged(false);
      dialogs.showNotifier(
        context.appLocalizations.databaseWriteFailedTip,
        level: MessageLevel.error,
      );
      return;
    }

    var outcomes = const <DesyncTestOutcome>[];
    Object? failure;
    StackTrace? failureStack;
    var recoverySaved = true;
    try {
      outcomes = await tester.run(
        originalArgs: props.strategyArgs,
        sites: sites,
        onProgress: (index, outcome) {
          if (!mounted) return;
          setState(() {
            _index = index + 1;
            _outcomes.add(outcome);
          });
        },
      );
    } catch (error, stackTrace) {
      failure = error;
      failureStack = stackTrace;
    } finally {
      notifier.update(
        (state) => state.copyWith(testRunning: false, testRestoreArgs: null),
      );
      recoverySaved = await store.savePreferences();
      retention.close();
    }
    if (!mounted) return;
    setState(() {
      _tester = null;
      _running = false;
      _aborted =
          failure != null ||
          outcomes.length < desyncTestPresets.length && !_stoppedByUser;
    });
    widget.onRunningChanged(false);
    if (failure case final failure?) {
      commonPrint.log(
        'DPI strategy test failed: ${compactError(failure)}, $failureStack',
        logLevel: LogLevel.warning,
      );
      dialogs.showNotifier(compactError(failure), level: MessageLevel.error);
    } else if (!recoverySaved) {
      dialogs.showNotifier(
        context.appLocalizations.databaseWriteFailedTip,
        level: MessageLevel.error,
      );
    }
  }

  void _handleStop() {
    _stoppedByUser = true;
    _tester?.stop();
  }

  void _applyOutcome(DesyncTestOutcome outcome) {
    ref
        .read(desyncSettingProvider.notifier)
        .update(
          (state) => state.copyWith(strategyArgs: desyncTestArgs(outcome.text)),
        );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final props = ref.watch(
      desyncSettingProvider.select((state) => state.testSiteLists),
    );
    final sites = desyncTestSitesFor(props);
    final subtitle = _running
        ? appLocalizations.desyncTestProgress(_index, desyncTestPresets.length)
        : _engineDown
        ? appLocalizations.desyncTestEngineDown
        : _aborted
        ? appLocalizations.desyncTestAborted
        : _outcomes.isNotEmpty
        ? appLocalizations.desyncTestDone(_outcomes.length)
        : sites.isEmpty
        ? appLocalizations.desyncTestNoLists
        : appLocalizations.desyncTestHint(sites.length);
    final outcomes =
        _running || _outcomes.length < 2 ? _outcomes : [..._outcomes]
          ..sort((a, b) => b.score.compareTo(a.score));
    final selectedLists = [
      for (final list in desyncTestSiteLists)
        if (props.contains(list.id)) list,
    ];
    return Column(
      children: [
        if (widget.showOverview)
          _DesyncOverviewCard(
            icon: Icons.science_rounded,
            title: appLocalizations.desyncTestBattery,
            subtitle: appLocalizations.desyncTestBatterySummary(
              desyncTestPresets.length,
              selectedLists.length,
              sites.length,
            ),
            detail: selectedLists.map((list) => list.name).join(' · '),
          ),
        SettingSection(
          title: appLocalizations.desyncTestSection,
          items: [
            DecorationListItem(
              title: Text(appLocalizations.desyncTestTitle),
              subtitle: Text(subtitle),
              trailing: CommonMinFilledButtonTheme(
                child: FilledButton.tonal(
                  onPressed: _running
                      ? _handleStop
                      : sites.isEmpty
                      ? null
                      : _handleStart,
                  child: Text(
                    _running
                        ? appLocalizations.stop
                        : appLocalizations.desyncTestStart,
                  ),
                ),
              ),
            ),
            DecorationListItem.open(
              title: Text(appLocalizations.desyncTestDomains),
              subtitle: Text(
                appLocalizations.desyncTestDomainsCount(sites.length),
              ),
              widget: const _DesyncTestSitesPage(),
            ),
            for (final outcome in outcomes)
              DecorationListItem(
                leading: outcome.engineUp && outcome.passed == outcome.total
                    ? const Icon(Icons.check_rounded)
                    : null,
                title: Text(
                  outcome.text.replaceAll('{sni}', desyncTestFakeSni),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                ),
                subtitle: Text(
                  outcome.engineUp
                      ? appLocalizations.desyncTestScore(
                          outcome.passed,
                          outcome.total,
                        )
                      : appLocalizations.desyncTestEngineCrashed,
                ),
                trailing: outcome.failedSites.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.info_outline_rounded),
                        tooltip: appLocalizations.desyncTestFailedTitle,
                        onPressed: () => _showFailed(outcome),
                      ),
                onPressed: _running ? null : () => _applyOutcome(outcome),
              ),
          ],
        ),
      ],
    );
  }

  Future<void> _showFailed(DesyncTestOutcome outcome) async {
    final appLocalizations = context.appLocalizations;
    await dialogs.showMessage(
      title: appLocalizations.desyncTestFailedTitle,
      message: TextSpan(text: outcome.failedSites.join('\n')),
    );
  }
}

class _DesyncTestSitesPage extends ConsumerWidget {
  const _DesyncTestSitesPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final selected = ref.watch(
      desyncSettingProvider.select((state) => state.testSiteLists),
    );
    return CommonScaffold(
      title: appLocalizations.desyncTestDomains,
      body: CustomScrollView(
        slivers: [
          SettingSection.sliver(
            bottom: 24,
            items: [
              for (final list in desyncTestSiteLists)
                DecorationListItem.open(
                  title: Text(list.name),
                  subtitle: Text(
                    '${appLocalizations.desyncTestDomainsCount(list.domains.length)}'
                    ' · ${list.domains.take(2).join(' · ')}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Switch(
                    value: selected.contains(list.id),
                    onChanged: (value) => ref
                        .read(desyncSettingProvider.notifier)
                        .update((state) {
                          final next = {...state.testSiteLists};
                          value ? next.add(list.id) : next.remove(list.id);
                          return state.copyWith(testSiteLists: next.toList());
                        }),
                  ),
                  widget: _DesyncTestDomainListView(list: list),
                ),
            ],
          ),
          const SettingBottomInset.sliver(),
        ],
      ),
    );
  }
}

class _DesyncTestDomainListView extends StatelessWidget {
  const _DesyncTestDomainListView({required this.list});

  final DesyncTestSiteList list;

  @override
  Widget build(BuildContext context) => CommonScaffold(
    title: list.name,
    body: CustomScrollView(
      slivers: [
        SettingSection.sliver(
          title: context.appLocalizations.desyncTestDomains,
          subTitle: context.appLocalizations.desyncTestDomainsCount(
            list.domains.length,
          ),
          bottom: 24,
          items: [
            for (final domain in list.domains)
              DecorationListItem(
                leading: const Icon(Icons.language_rounded),
                title: SelectableText(
                  domain,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                ),
              ),
          ],
        ),
        const SettingBottomInset.sliver(),
      ],
    ),
  );
}
