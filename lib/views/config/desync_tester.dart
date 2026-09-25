part of 'desync.dart';

class DesyncLadderPreview extends StatelessWidget {
  const DesyncLadderPreview({super.key});

  @override
  Widget build(BuildContext context) => CommonScaffold(
    title: context.appLocalizations.developerFindings,
    floatBody: true,
    body: SingleChildScrollView(
      padding: EdgeInsets.only(top: context.appBarInset),
      child: _DesyncTester(
        showOverview: false,
        preview: true,
        onRunningChanged: (_) {},
      ),
    ),
  );
}

class _DesyncTester extends ConsumerStatefulWidget {
  const _DesyncTester({
    required this.showOverview,
    required this.onRunningChanged,
    this.preview = false,
  });

  final bool preview;

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
          unawaited(
            container
                .read(coreHandlerProvider)
                .signalOdometer(
                  OdometerSignal(OdometerSignalKind.ladder, value: index + 1),
                ),
          );
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
    if (failure == null &&
        !_stoppedByUser &&
        outcomes.length == desyncTestPresets.length &&
        listEquals(
          props.strategyArgs,
          desyncTestArgs(desyncTestPresets.first),
        )) {
      unawaited(
        container
            .read(coreHandlerProvider)
            .signalOdometer(
              const OdometerSignal(
                OdometerSignalKind.ladder,
                reason: 'completed',
                value: 1,
              ),
            ),
      );
    }
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
    final outcomes = widget.preview
        ? [
            for (var index = 0; index < desyncTestPresets.length; index++)
              DesyncTestOutcome(
                text: desyncTestPresets[index],
                failedSites: List.filled(
                  index < 3 ? 3 - index : 0,
                  'example.invalid',
                ),
                passedOnRetry: 0,
                total: 5,
                engineUp: true,
                elapsed: Duration(milliseconds: 120 + index * 35),
              ),
          ]
        : _outcomes;
    final selectedLists = [
      for (final list in desyncTestSiteLists)
        if (props.contains(list.id)) list,
    ];
    return Column(
      children: [
        if (widget.showOverview)
          _DesyncOverviewCard(
            icon: AppGlyphs.beaker,
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
              subtitle: Text(
                widget.preview
                    ? appLocalizations.developerFindingsDesc
                    : subtitle,
              ),
              trailing: CommonMinFilledButtonTheme(
                child: FilledButton.tonal(
                  onPressed: widget.preview
                      ? null
                      : _running
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
            if (!widget.preview)
              DecorationListItem.open(
                title: Text(appLocalizations.desyncTestDomains),
                subtitle: Text(
                  appLocalizations.desyncTestDomainsCount(sites.length),
                ),
                widget: const _DesyncTestSitesPage(),
              ),
            for (final outcome in outcomes)
              DecorationListItem(
                leading: CircleAvatar(
                  radius: 14,
                  child: Text('${outcomes.indexOf(outcome) + 1}'),
                ),
                title: Text(
                  outcome.text.replaceAll('{sni}', desyncTestFakeSni),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                ),
                subtitle: Text(
                  outcome.engineUp
                      ? '${appLocalizations.desyncLadderResult(outcome.passed, outcome.total)}'
                            '${outcome.elapsed > Duration.zero ? ' · ${outcome.elapsed.inMilliseconds} ms' : ''}'
                      : appLocalizations.desyncTestEngineCrashed,
                ),
                trailing: widget.preview || outcome.failedSites.isEmpty
                    ? null
                    : IconButton(
                        icon: const GlyphIcon(AppGlyphs.info),
                        tooltip: appLocalizations.desyncTestFailedTitle,
                        onPressed: () => _showFailed(outcome),
                      ),
                onPressed: _running || widget.preview
                    ? null
                    : () => _applyOutcome(outcome),
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
      floatBody: true,
      body: SettingsScrollView(
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: context.appBarInset)),
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
    floatBody: true,
    body: SettingsScrollView(
      slivers: [
        SliverToBoxAdapter(child: SizedBox(height: context.appBarInset)),
        SettingSection.sliver(
          title: context.appLocalizations.desyncTestDomains,
          subTitle: context.appLocalizations.desyncTestDomainsCount(
            list.domains.length,
          ),
          bottom: 24,
          items: [
            for (final domain in list.domains)
              DecorationListItem(
                leading: const GlyphIcon(AppGlyphs.language),
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
