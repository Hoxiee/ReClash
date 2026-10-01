part of 'smart_routing.dart';

/// Cadence: how fast the engine looks and how far it lets latency slide before
/// it acts. Strategy-seeded and editable, these fill the studio's Pace page, one
/// stage of the decision pipeline between the switch triggers and the signals
/// the engine reads.
List<Widget> _pacingSlivers(
  BuildContext context,
  WidgetRef ref,
  SmartRoutingProps props,
) {
  final appLocalizations = context.appLocalizations;
  return [
    SettingSection.sliver(
      search: const SettingSearch(),
      title: appLocalizations.smartRoutingPacing,
      subTitle: appLocalizations.smartRoutingPacingDesc,
      actions: routingFacetResetActions(
        context,
        ref,
        props,
        RoutingFacetGroup.pacing,
      ),
      items: [
        _pacingItem(
          ref,
          glyph: AppGlyphs.clock,
          search: const SettingSearch(),
          title: appLocalizations.smartRoutingDwell,
          desc: appLocalizations.smartRoutingDwellDesc,
          options: _dwellChoices,
          value: props.dwellSeconds,
          textBuilder: appLocalizations.smartRoutingSeconds,
          write: (state, value) => state.copyWith(dwellSeconds: value),
        ),
        _pacingItem(
          ref,
          glyph: AppGlyphs.radar,
          search: const SettingSearch(),
          title: appLocalizations.smartRoutingWave,
          desc: appLocalizations.smartRoutingWaveDesc,
          options: _waveChoices,
          value: props.waveWidth,
          textBuilder: appLocalizations.smartRoutingWaveNodes,
          write: (state, value) => state.copyWith(waveWidth: value),
        ),
        _pacingItem(
          ref,
          glyph: AppGlyphs.speed,
          search: const SettingSearch(),
          title: appLocalizations.smartRoutingCeiling,
          desc: appLocalizations.smartRoutingCeilingDesc,
          options: _ceilingChoices,
          value: props.absCeilingMs,
          textBuilder: appLocalizations.smartRoutingMillis,
          write: (state, value) => state.copyWith(absCeilingMs: value),
        ),
        _pacingItem(
          ref,
          glyph: AppGlyphs.hourglass,
          search: const SettingSearch(),
          title: appLocalizations.smartRoutingDegradeConfirm,
          desc: appLocalizations.smartRoutingDegradeConfirmDesc,
          options: _degradeChoices,
          value: props.degradeConfirmSeconds,
          textBuilder: appLocalizations.smartRoutingSeconds,
          write: (state, value) => state.copyWith(degradeConfirmSeconds: value),
        ),
        _pacingItem(
          ref,
          glyph: AppGlyphs.history,
          search: const SettingSearch(),
          title: appLocalizations.smartRoutingProofTtl,
          desc: appLocalizations.smartRoutingProofTtlDesc,
          options: _proofTtlChoices,
          value: props.proofTtlMinutes,
          textBuilder: appLocalizations.smartRoutingMinutes,
          write: (state, value) => state.copyWith(proofTtlMinutes: value),
        ),
      ],
    ),
    SettingSection.sliver(
      search: const SettingSearch(),
      title: appLocalizations.smartRoutingRanking,
      actions: routingFacetResetActions(
        context,
        ref,
        props,
        RoutingFacetGroup.bands,
      ),
      items: [
        _StringListItem(
          glyph: AppGlyphs.chart,
          search: const SettingSearch(),
          title: appLocalizations.smartRoutingLatencyBands,
          desc: appLocalizations.smartRoutingLatencyBandsDesc,
          itemMaxLength: 6,
          itemValidator: (value) {
            final edge = int.tryParse(value);
            return edge == null || edge <= 0
                ? appLocalizations.smartRoutingBandInvalid
                : null;
          },
          value: props.latencyBands.map((edge) => edge.toString()).toList(),
          write: (state, value) => state.copyWith(
            latencyBands: value
                .map(int.tryParse)
                .whereType<int>()
                .where((edge) => edge > 0)
                .toList(),
          ),
        ),
      ],
    ),
  ];
}

/// Signals: everything the engine measures a node against, each measured input
/// on its own focused page so no single screen stacks every list. Together they
/// are the pipeline stage for what the engine senses before it ranks.
List<Widget> _signalsSlivers(
  BuildContext context,
  WidgetRef ref,
  SmartRoutingProps props,
) {
  final appLocalizations = context.appLocalizations;
  return [
    SettingSection.sliver(
      search: const SettingSearch(),
      title: appLocalizations.smartRoutingSignals,
      subTitle: appLocalizations.smartRoutingSignalsDesc,
      items: [
        _routingStageRow(
          context,
          glyph: AppGlyphs.radar,
          title: appLocalizations.smartRoutingProbes,
          subtitle: appLocalizations.smartRoutingRegionNote,
          builder: _probesSlivers,
        ),
        _routingStageRow(
          context,
          glyph: AppGlyphs.networkCheck,
          title: appLocalizations.smartRoutingMarkers,
          subtitle: appLocalizations.smartRoutingMarkersDesc,
          builder: _markersSlivers,
        ),
        _routingStageRow(
          context,
          glyph: AppGlyphs.globeSearch,
          title: appLocalizations.smartRoutingCountryPolicy,
          subtitle: appLocalizations.smartRoutingCountryPolicyDesc,
          builder: _countryPolicySlivers,
        ),
        _routingStageRow(
          context,
          glyph: AppGlyphs.locate,
          title: appLocalizations.smartRoutingEgress,
          subtitle: appLocalizations.smartRoutingEgressDesc,
          builder: _egressSlivers,
        ),
        _routingStageRow(
          context,
          glyph: AppGlyphs.rules,
          title: appLocalizations.smartRoutingHeuristics,
          subtitle: appLocalizations.smartRoutingHeuristicsDesc,
          builder: _heuristicsSlivers,
        ),
      ],
    ),
  ];
}

List<Widget> _probesSlivers(
  BuildContext context,
  WidgetRef ref,
  SmartRoutingProps props,
) {
  final appLocalizations = context.appLocalizations;
  return [
    SettingSection.sliver(
      search: const SettingSearch(),
      title: appLocalizations.smartRoutingProbes,
      subTitle: appLocalizations.smartRoutingRegionNote,
      actions: routingFacetResetActions(
        context,
        ref,
        props,
        RoutingFacetGroup.probes,
      ),
      items: [
        _StringListItem(
          glyph: AppGlyphs.globeSearch,
          search: const SettingSearch(),
          title: appLocalizations.smartRoutingCanariesForeign,
          desc: appLocalizations.smartRoutingCanariesForeignDesc,
          value: props.canaryForeign,
          write: (state, value) => state.copyWith(canaryForeign: value),
        ),
        _StringListItem(
          glyph: AppGlyphs.router,
          search: const SettingSearch(),
          title: appLocalizations.smartRoutingCanariesDomestic,
          desc: appLocalizations.smartRoutingCanariesDomesticDesc,
          value: props.canaryDomestic,
          write: (state, value) => state.copyWith(canaryDomestic: value),
        ),
        _StringListItem(
          glyph: AppGlyphs.shield,
          search: const SettingSearch(),
          title: appLocalizations.smartRoutingCensorSni,
          desc: appLocalizations.smartRoutingCensorSniDesc,
          value: props.censorSNI,
          write: (state, value) => state.copyWith(censorSNI: value),
        ),
      ],
    ),
  ];
}

List<Widget> _markersSlivers(
  BuildContext context,
  WidgetRef ref,
  SmartRoutingProps props,
) {
  final appLocalizations = context.appLocalizations;
  return [
    SettingSection.sliver(
      search: const SettingSearch(),
      title: appLocalizations.smartRoutingMarkers,
      subTitle: appLocalizations.smartRoutingMarkersDesc,
      actions: routingFacetResetActions(
        context,
        ref,
        props,
        RoutingFacetGroup.markers,
      ),
      items: [
        _MarkersItem(
          glyph: AppGlyphs.globeSearch,
          search: const SettingSearch(),
          title: appLocalizations.smartRoutingMarkersOpen,
          desc: appLocalizations.smartRoutingMarkersOpenDesc,
          markers: props.openMarkers,
          kind: _MarkerKind.open,
        ),
        _MarkersItem(
          glyph: AppGlyphs.router,
          search: const SettingSearch(),
          title: appLocalizations.smartRoutingMarkersDomestic,
          desc: appLocalizations.smartRoutingMarkersDomesticDesc,
          markers: props.domesticMarkers,
          kind: _MarkerKind.domestic,
        ),
        _MarkersItem(
          glyph: AppGlyphs.pin,
          search: const SettingSearch(),
          title: appLocalizations.smartRoutingMarkersLocal,
          desc: appLocalizations.smartRoutingMarkersLocalDesc,
          markers: props.localMarkers,
          kind: _MarkerKind.local,
        ),
      ],
    ),
  ];
}

List<Widget> _countryPolicySlivers(
  BuildContext context,
  WidgetRef ref,
  SmartRoutingProps props,
) {
  final appLocalizations = context.appLocalizations;
  return [
    SettingSection.sliver(
      search: const SettingSearch(),
      title: appLocalizations.smartRoutingCountryPolicy,
      subTitle: appLocalizations.smartRoutingCountryPolicyDesc,
      actions: routingFacetResetActions(
        context,
        ref,
        props,
        RoutingFacetGroup.censorship,
      ),
      items: [
        _CountryListItem(
          glyph: AppGlyphs.shield,
          search: const SettingSearch(),
          title: appLocalizations.smartRoutingCensor,
          desc: appLocalizations.smartRoutingCensorDesc,
          kind: _CountryKind.censor,
        ),
        _CountryListItem(
          glyph: AppGlyphs.block,
          search: const SettingSearch(),
          title: appLocalizations.smartRoutingAvoidCountries,
          desc: appLocalizations.smartRoutingAvoidCountriesDesc,
          kind: _CountryKind.avoid,
        ),
      ],
    ),
  ];
}

List<Widget> _egressSlivers(
  BuildContext context,
  WidgetRef ref,
  SmartRoutingProps props,
) {
  final appLocalizations = context.appLocalizations;
  return [
    SettingSection.sliver(
      search: const SettingSearch(),
      title: appLocalizations.smartRoutingEgress,
      subTitle: appLocalizations.smartRoutingEgressDesc,
      actions: routingFacetResetActions(
        context,
        ref,
        props,
        RoutingFacetGroup.egress,
      ),
      items: [
        _StringListItem(
          glyph: AppGlyphs.locate,
          search: const SettingSearch(),
          title: appLocalizations.smartRoutingEgressEchoes,
          desc: appLocalizations.smartRoutingEgressEchoesDesc,
          value: props.egressEchoes,
          write: (state, value) => state.copyWith(egressEchoes: value),
        ),
        _StringListItem(
          glyph: AppGlyphs.flag,
          search: const SettingSearch(),
          title: appLocalizations.smartRoutingCountryEchoes,
          desc: appLocalizations.smartRoutingCountryEchoesDesc,
          value: props.countryEchoes,
          write: (state, value) => state.copyWith(countryEchoes: value),
        ),
      ],
    ),
  ];
}

List<Widget> _heuristicsSlivers(
  BuildContext context,
  WidgetRef ref,
  SmartRoutingProps props,
) {
  final appLocalizations = context.appLocalizations;
  return [
    SettingSection.sliver(
      search: const SettingSearch(),
      title: appLocalizations.smartRoutingHeuristics,
      subTitle: appLocalizations.smartRoutingHeuristicsDesc,
      actions: routingFacetResetActions(
        context,
        ref,
        props,
        RoutingFacetGroup.heuristics,
      ),
      items: [
        _StringListItem(
          glyph: AppGlyphs.textShort,
          search: const SettingSearch(),
          title: appLocalizations.smartRoutingNameHints,
          desc: appLocalizations.smartRoutingNameHintsDesc,
          value: props.nameHints,
          write: (state, value) => state.copyWith(nameHints: value),
        ),
        _StringListItem(
          glyph: AppGlyphs.key,
          search: const SettingSearch(),
          title: appLocalizations.smartRoutingBreakerPatterns,
          desc: appLocalizations.smartRoutingBreakerPatternsDesc,
          value: props.breakerPatterns,
          write: (state, value) => state.copyWith(breakerPatterns: value),
        ),
        _RulesItem(rules: props.nodeRules),
      ],
    ),
  ];
}

/// A tonal Reset shown only when [group] has diverged from its seed, wired to
/// the shared confirm dialog. Reused across the studio's facets — the inline
/// ladder and each settings page — so every one resets the same way.
List<Widget>? routingFacetResetActions(
  BuildContext context,
  WidgetRef ref,
  SmartRoutingProps props,
  RoutingFacetGroup group,
) {
  if (props.matchesSeedGroup(group)) {
    return null;
  }
  return [
    CommonMinFilledButtonTheme(
      child: FilledButton.tonal(
        onPressed: () => routingHandleFacetReset(context, ref, group),
        child: Text(context.appLocalizations.reset),
      ),
    ),
  ];
}

Future<void> routingHandleFacetReset(
  BuildContext context,
  WidgetRef ref,
  RoutingFacetGroup group,
) async {
  final appLocalizations = context.appLocalizations;
  final confirmed = await dialogs.showMessage(
    dangerous: true,
    title: appLocalizations.reset,
    message: TextSpan(text: appLocalizations.resetTip),
  );
  if (confirmed != true) {
    return;
  }
  ref
      .read(smartRoutingSettingProvider.notifier)
      .update((state) => state.resetSeedGroup(group));
}

/// Hysteresis for switching: how much a challenger must beat the incumbent
/// before the engine moves, and the equality band the latency rung ignores.
/// Every value at zero hands the choice back to the strategy pacing. Fills the
/// studio's Switch-triggers page, since triggers gate the comparison the ladder
/// ran.
List<Widget> _triggersSlivers(
  BuildContext context,
  WidgetRef ref,
  SmartRoutingProps props,
) {
  final appLocalizations = context.appLocalizations;
  return [
    SettingSection.sliver(
      search: const SettingSearch(),
      title: appLocalizations.smartRoutingTriggers,
      subTitle: appLocalizations.smartRoutingTriggersDesc,
      actions: routingFacetResetActions(
        context,
        ref,
        props,
        RoutingFacetGroup.triggers,
      ),
      items: [
        _pacingItem(
          ref,
          glyph: AppGlyphs.trendDown,
          search: const SettingSearch(),
          title: appLocalizations.smartRoutingSwitchImproveMs,
          desc: appLocalizations.smartRoutingSwitchImproveMsDesc,
          options: _switchImproveMsChoices,
          value: props.switchImproveMs,
          textBuilder: (value) => value == 0
              ? appLocalizations.smartRoutingTriggerAuto
              : appLocalizations.smartRoutingMillis(value),
          write: (state, value) => state.copyWith(switchImproveMs: value),
        ),
        _pacingItem(
          ref,
          glyph: AppGlyphs.balance,
          search: const SettingSearch(),
          title: appLocalizations.smartRoutingSwitchImprovePct,
          desc: appLocalizations.smartRoutingSwitchImprovePctDesc,
          options: _switchImprovePctChoices,
          value: props.switchImprovePct,
          textBuilder: (value) => value == 0
              ? appLocalizations.smartRoutingTriggerAuto
              : appLocalizations.smartRoutingPercent(value),
          write: (state, value) => state.copyWith(switchImprovePct: value),
        ),
        _pacingItem(
          ref,
          glyph: AppGlyphs.filter,
          search: const SettingSearch(),
          title: appLocalizations.smartRoutingLatencyStep,
          desc: appLocalizations.smartRoutingLatencyStepDesc,
          options: _latencyStepChoices,
          value: props.latencyStepMs,
          textBuilder: (value) => value == 0
              ? appLocalizations.smartRoutingTriggerAuto
              : appLocalizations.smartRoutingMillis(value),
          write: (state, value) => state.copyWith(latencyStepMs: value),
        ),
      ],
    ),
  ];
}

Widget _pacingItem(
  WidgetRef ref, {
  required Glyph glyph,
  required String title,
  required String desc,
  required List<int> options,
  required int value,
  required String Function(int) textBuilder,
  required SmartRoutingProps Function(SmartRoutingProps, int) write,
  SettingSearch? search,
}) {
  return DecorationListItem.options(
    leading: GlyphIcon(glyph),
    title: Text(title),
    subtitle: Text(desc),
    dialogTitle: title,
    options: options.contains(value) ? options : [value, ...options],
    value: value,
    textBuilder: (option) => textBuilder(option as int),
    onChanged: (option) {
      if (option == null) return;
      ref
          .read(smartRoutingSettingProvider.notifier)
          .update((state) => write(state, option as int));
    },
  );
}

Future<void> _handleExport(
  BuildContext context,
  SmartRoutingProps props,
) async {
  final appLocalizations = context.appLocalizations;
  final json = const JsonEncoder.withIndent('  ').convert(props.toJson());
  final uri = await picker.saveFile(
    'smart_routing.json',
    Uint8List.fromList(utf8.encode(json)),
  );
  if (uri != null) {
    dialogs.showNotifier(appLocalizations.smartRoutingExported);
  }
}

Future<void> _handleImport(BuildContext context, WidgetRef ref) async {
  final appLocalizations = context.appLocalizations;
  final file = await picker.pickerFile();
  if (file == null) {
    return;
  }
  SmartRoutingProps imported;
  try {
    final decoded = jsonDecode(utf8.decode(await file.readBytes()));
    // safeFromJson, not fromJson: a file exported before the unlocked/enabled
    // split has no `unlocked` key, and a raw parse would leave an Auto config
    // enabled yet locked, which the view gates on.
    imported = SmartRoutingProps.safeFromJson(decoded as Map<String, Object?>);
  } catch (_) {
    dialogs.showNotifier(
      appLocalizations.smartRoutingImportFailed,
      level: MessageLevel.error,
    );
    return;
  }
  final confirmed = await dialogs.showMessage(
    dangerous: true,
    title: appLocalizations.smartRoutingImport,
    message: TextSpan(text: appLocalizations.smartRoutingImportDesc),
  );
  if (confirmed != true) {
    return;
  }
  ref.read(smartRoutingSettingProvider.notifier).value = imported;
  dialogs.showNotifier(appLocalizations.smartRoutingImported);
}

/// Countries are chosen, not typed: Add opens a searchable dialog over every
/// ISO code, so an invalid code cannot be entered, and a pick lands in a
/// reorderable list. Stored as the bare two-letter tokens the engine expects,
/// in the order the user arranges.
enum _CountryKind { censor, avoid }

List<String> _countriesOf(SmartRoutingProps props, _CountryKind kind) =>
    switch (kind) {
      _CountryKind.censor => props.censorCountries,
      _CountryKind.avoid => props.avoidCountries,
    };

void _writeCountries(WidgetRef ref, _CountryKind kind, List<String> next) {
  ref
      .read(smartRoutingSettingProvider.notifier)
      .update(
        (state) => switch (kind) {
          _CountryKind.censor => state.copyWith(censorCountries: next),
          _CountryKind.avoid => state.copyWith(avoidCountries: next),
        },
      );
}

class _CountryListItem extends ConsumerWidget {
  const _CountryListItem({
    required this.glyph,
    required this.title,
    required this.desc,
    required this.kind,
    this.search,
  });

  final Glyph glyph;
  final String title;
  final String desc;
  final _CountryKind kind;
  final SettingSearch? search;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = _countriesOf(ref.watch(smartRoutingSettingProvider), kind);
    return DecorationListItem.open(
      leading: GlyphIcon(glyph),
      title: Text(title),
      subtitle: Text(
        value.isEmpty ? desc : value.map(_countryLabel).join(', '),
      ),
      blur: false,
      forceFull: false,
      preferSheet: true,
      maxWidth: 400,
      widget: _CountryListPage(title: title, desc: desc, kind: kind),
    );
  }
}

class _CountryListPage extends ConsumerStatefulWidget {
  const _CountryListPage({
    required this.title,
    required this.desc,
    required this.kind,
  });

  final String title;
  final String desc;
  final _CountryKind kind;

  @override
  ConsumerState<_CountryListPage> createState() => _CountryListPageState();
}

class _CountryListPageState extends ConsumerState<_CountryListPage> {
  Set<String> _selection = {};

  void _deleteSelected() {
    _writeCountries(
      ref,
      widget.kind,
      _countriesOf(
        ref.read(smartRoutingSettingProvider),
        widget.kind,
      ).where((code) => !_selection.contains(code)).toList(),
    );
    setState(() => _selection = {});
  }

  void _toggleSelectAll() {
    final codes = _countriesOf(
      ref.read(smartRoutingSettingProvider),
      widget.kind,
    );
    setState(() {
      _selection = _selection.length == codes.length ? {} : codes.toSet();
    });
  }

  Future<void> _add() async {
    final current = _countriesOf(
      ref.read(smartRoutingSettingProvider),
      widget.kind,
    );
    final picked = await dialogs.showCommonDialog<String>(
      child: _CountryPickDialog(title: widget.title, exclude: current),
    );
    if (picked == null || current.contains(picked)) {
      return;
    }
    _writeCountries(ref, widget.kind, [...current, picked]);
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
        floatBody: true,
        actions: [
          if (selection.isNotEmpty)
            IconButton.filledTonal(
              tooltip: appLocalizations.delete,
              onPressed: _deleteSelected,
              icon: const GlyphIcon(AppGlyphs.delete),
            ),
          selection.isNotEmpty
              ? FilledButton(
                  onPressed: _toggleSelectAll,
                  child: Text(appLocalizations.selectAll),
                )
              : FilledButton.tonal(
                  onPressed: _add,
                  child: Text(appLocalizations.add),
                ),
        ],
        body: _CountryListBody(
          kind: widget.kind,
          desc: widget.desc,
          selection: selection,
          onSelected: (code) => setState(() {
            _selection = {..._selection}..addOrRemove(code);
          }),
        ),
      ),
    );
  }
}

class _CountryListBody extends ConsumerWidget {
  const _CountryListBody({
    required this.kind,
    required this.desc,
    required this.selection,
    required this.onSelected,
  });

  final _CountryKind kind;
  final String desc;
  final Set<String> selection;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final codes = _countriesOf(ref.watch(smartRoutingSettingProvider), kind);
    if (codes.isEmpty) {
      return NullStatus(
        label: desc,
        illustration: NullStatusIllustration.routing,
      );
    }
    Widget itemAt(int index) => _countryRow(context, codes, index);
    return ReorderableListView.builder(
      padding: EdgeInsets.only(
        bottom: 16 + 64,
        top: context.appBarInset,
        left: 16,
        right: 16,
      ),
      buildDefaultDragHandles: false,
      itemCount: codes.length,
      itemBuilder: (_, index) => itemAt(index),
      proxyDecorator: (child, index, animation) =>
          commonProxyDecorator(itemAt(index), index, animation),
      onReorderItem: (oldIndex, newIndex) =>
          _writeCountries(ref, kind, codes.copyAndReorder(oldIndex, newIndex)),
    );
  }

  Widget _countryRow(BuildContext context, List<String> codes, int index) {
    final code = codes[index];
    final flag = countryCodeToEmoji(code);
    return ReorderableDelayedDragStartListener(
      key: ValueKey(code),
      index: index,
      child: ItemPositionProvider(
        position: ItemPosition.get(index, codes.length),
        child: SelectedDecorationListItem(
          leading: flag == null
              ? const GlyphIcon(AppGlyphs.language)
              : Text(flag, style: const TextStyle(fontSize: 24)),
          title: Text(code),
          isSelected: selection.contains(code),
          isEditing: selection.isNotEmpty,
          onSelected: () => onSelected(code),
          onPressed: () => onSelected(code),
        ),
      ),
    );
  }
}

/// The Add dialog: the code alone is the title with the flag as the leading
/// glyph, so a row never shows the flag twice; already-picked codes drop out so
/// the list only offers what can still be added.
class _CountryPickDialog extends StatefulWidget {
  const _CountryPickDialog({required this.title, required this.exclude});

  final String title;
  final List<String> exclude;

  @override
  State<_CountryPickDialog> createState() => _CountryPickDialogState();
}

class _CountryPickDialogState extends State<_CountryPickDialog> {
  static final _sortedCodes = _isoAlpha2.toList()..sort();

  final _search = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _search.addListener(
      () => setState(() => _query = _search.text.trim().toUpperCase()),
    );
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final matches = _sortedCodes
        .where((code) => !widget.exclude.contains(code))
        .where((code) => _query.isEmpty || code.contains(_query))
        .toList();
    return CommonDialog(
      title: widget.title,
      overrideScroll: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _search,
            decoration: InputDecoration(
              prefixIcon: const GlyphIcon(AppGlyphs.search),
              labelText: appLocalizations.smartRoutingCountrySearch,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Flexible(
            child: matches.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xxl,
                    ),
                    child: Text(appLocalizations.smartRoutingCountryNoMatch),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: matches.length,
                    itemBuilder: (context, index) {
                      final code = matches[index];
                      final flag = countryCodeToEmoji(code);
                      return DecorationListItem(
                        leading: flag == null
                            ? const GlyphIcon(AppGlyphs.language)
                            : Text(flag, style: const TextStyle(fontSize: 24)),
                        title: Text(code),
                        onPressed: () => Navigator.of(context).pop(code),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

String _countryLabel(String code) {
  final flag = countryCodeToEmoji(code);
  return flag == null ? code : '$flag $code';
}

/// ISO 3166-1 alpha-2 codes plus XK (Kosovo, user-assigned but what mmdb emits):
/// countryCodeToEmoji builds a flag for any two letters, so the field validates
/// against real codes instead.
const _isoAlpha2 = {
  'AD',
  'AE',
  'AF',
  'AG',
  'AI',
  'AL',
  'AM',
  'AO',
  'AQ',
  'AR',
  'AS',
  'AT',
  'AU',
  'AW',
  'AX',
  'AZ',
  'BA',
  'BB',
  'BD',
  'BE',
  'BF',
  'BG',
  'BH',
  'BI',
  'BJ',
  'BL',
  'BM',
  'BN',
  'BO',
  'BQ',
  'BR',
  'BS',
  'BT',
  'BV',
  'BW',
  'BY',
  'BZ',
  'CA',
  'CC',
  'CD',
  'CF',
  'CG',
  'CH',
  'CI',
  'CK',
  'CL',
  'CM',
  'CN',
  'CO',
  'CR',
  'CU',
  'CV',
  'CW',
  'CX',
  'CY',
  'CZ',
  'DE',
  'DJ',
  'DK',
  'DM',
  'DO',
  'DZ',
  'EC',
  'EE',
  'EG',
  'EH',
  'ER',
  'ES',
  'ET',
  'FI',
  'FJ',
  'FK',
  'FM',
  'FO',
  'FR',
  'GA',
  'GB',
  'GD',
  'GE',
  'GF',
  'GG',
  'GH',
  'GI',
  'GL',
  'GM',
  'GN',
  'GP',
  'GQ',
  'GR',
  'GS',
  'GT',
  'GU',
  'GW',
  'GY',
  'HK',
  'HM',
  'HN',
  'HR',
  'HT',
  'HU',
  'ID',
  'IE',
  'IL',
  'IM',
  'IN',
  'IO',
  'IQ',
  'IR',
  'IS',
  'IT',
  'JE',
  'JM',
  'JO',
  'JP',
  'KE',
  'KG',
  'KH',
  'KI',
  'KM',
  'KN',
  'KP',
  'KR',
  'KW',
  'KY',
  'KZ',
  'LA',
  'LB',
  'LC',
  'LI',
  'LK',
  'LR',
  'LS',
  'LT',
  'LU',
  'LV',
  'LY',
  'MA',
  'MC',
  'MD',
  'ME',
  'MF',
  'MG',
  'MH',
  'MK',
  'ML',
  'MM',
  'MN',
  'MO',
  'MP',
  'MQ',
  'MR',
  'MS',
  'MT',
  'MU',
  'MV',
  'MW',
  'MX',
  'MY',
  'MZ',
  'NA',
  'NC',
  'NE',
  'NF',
  'NG',
  'NI',
  'NL',
  'NO',
  'NP',
  'NR',
  'NU',
  'NZ',
  'OM',
  'PA',
  'PE',
  'PF',
  'PG',
  'PH',
  'PK',
  'PL',
  'PM',
  'PN',
  'PR',
  'PS',
  'PT',
  'PW',
  'PY',
  'QA',
  'RE',
  'RO',
  'RS',
  'RU',
  'RW',
  'SA',
  'SB',
  'SC',
  'SD',
  'SE',
  'SG',
  'SH',
  'SI',
  'SJ',
  'SK',
  'SL',
  'SM',
  'SN',
  'SO',
  'SR',
  'SS',
  'ST',
  'SV',
  'SX',
  'SY',
  'SZ',
  'TC',
  'TD',
  'TF',
  'TG',
  'TH',
  'TJ',
  'TK',
  'TL',
  'TM',
  'TN',
  'TO',
  'TR',
  'TT',
  'TV',
  'TW',
  'TZ',
  'UA',
  'UG',
  'UM',
  'US',
  'UY',
  'UZ',
  'VA',
  'VC',
  'VE',
  'VG',
  'VI',
  'VN',
  'VU',
  'WF',
  'WS',
  'XK',
  'YE',
  'YT',
  'ZA',
  'ZM',
  'ZW',
};
