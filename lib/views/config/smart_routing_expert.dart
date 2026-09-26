part of 'smart_routing.dart';

/// The expert knobs live one level down so the main screen stays a short list
/// of the choices most users make. Everything here is still preset-seeded and
/// editable; the engine reads the same provider whether the page is open or not.
class _AdvancedRoutingPage extends ConsumerWidget {
  const _AdvancedRoutingPage();

  void _update(WidgetRef ref, SmartRoutingProps Function(SmartRoutingProps) f) {
    ref.read(smartRoutingSettingProvider.notifier).update(f);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final props = ref.watch(smartRoutingSettingProvider);
    return CommonScaffold(
      title: appLocalizations.advancedConfig,
      floatBody: true,
      body: SettingsListView(
        children: [
          SettingSection(
            top: 16,
            title: appLocalizations.smartRoutingPacing,
            subTitle: appLocalizations.smartRoutingPacingDesc,
            actions: _resetActions(context, ref, props, RoutingFacetGroup.pacing),
            items: [
              _pacingItem(
                ref,
                title: appLocalizations.smartRoutingDwell,
                desc: appLocalizations.smartRoutingDwellDesc,
                options: _dwellChoices,
                value: props.dwellSeconds,
                textBuilder: appLocalizations.smartRoutingSeconds,
                write: (state, value) => state.copyWith(dwellSeconds: value),
              ),
              _pacingItem(
                ref,
                title: appLocalizations.smartRoutingWave,
                desc: appLocalizations.smartRoutingWaveDesc,
                options: _waveChoices,
                value: props.waveWidth,
                textBuilder: appLocalizations.smartRoutingWaveNodes,
                write: (state, value) => state.copyWith(waveWidth: value),
              ),
              _pacingItem(
                ref,
                title: appLocalizations.smartRoutingCeiling,
                desc: appLocalizations.smartRoutingCeilingDesc,
                options: _ceilingChoices,
                value: props.absCeilingMs,
                textBuilder: appLocalizations.smartRoutingMillis,
                write: (state, value) => state.copyWith(absCeilingMs: value),
              ),
              _pacingItem(
                ref,
                title: appLocalizations.smartRoutingDegradeConfirm,
                desc: appLocalizations.smartRoutingDegradeConfirmDesc,
                options: _degradeChoices,
                value: props.degradeConfirmSeconds,
                textBuilder: appLocalizations.smartRoutingSeconds,
                write: (state, value) =>
                    state.copyWith(degradeConfirmSeconds: value),
              ),
              _pacingItem(
                ref,
                title: appLocalizations.smartRoutingProofTtl,
                desc: appLocalizations.smartRoutingProofTtlDesc,
                options: _proofTtlChoices,
                value: props.proofTtlMinutes,
                textBuilder: appLocalizations.smartRoutingMinutes,
                write: (state, value) => state.copyWith(proofTtlMinutes: value),
              ),
            ],
          ),
          SettingSection(
            title: appLocalizations.smartRoutingProbes,
            subTitle: appLocalizations.smartRoutingRegionNote,
            actions: _resetActions(context, ref, props, RoutingFacetGroup.probes),
            items: [
              _StringListItem(
                title: appLocalizations.smartRoutingCanariesForeign,
                desc: appLocalizations.smartRoutingCanariesForeignDesc,
                value: props.canaryForeign,
                write: (state, value) => state.copyWith(canaryForeign: value),
              ),
              _StringListItem(
                title: appLocalizations.smartRoutingCanariesDomestic,
                desc: appLocalizations.smartRoutingCanariesDomesticDesc,
                value: props.canaryDomestic,
                write: (state, value) => state.copyWith(canaryDomestic: value),
              ),
            ],
          ),
          SettingSection(
            title: appLocalizations.smartRoutingCountryPolicy,
            subTitle: appLocalizations.smartRoutingCountryPolicyDesc,
            actions: _resetActions(context, ref, props, RoutingFacetGroup.censorship),
            items: [
              _CountryListItem(
                title: appLocalizations.smartRoutingCensor,
                desc: appLocalizations.smartRoutingCensorDesc,
                kind: _CountryKind.censor,
              ),
              _CountryListItem(
                title: appLocalizations.smartRoutingAvoidCountries,
                desc: appLocalizations.smartRoutingAvoidCountriesDesc,
                kind: _CountryKind.avoid,
              ),
            ],
          ),
          SettingSection(
            title: appLocalizations.smartRoutingEgress,
            subTitle: appLocalizations.smartRoutingEgressDesc,
            actions: _resetActions(context, ref, props, RoutingFacetGroup.egress),
            items: [
              _StringListItem(
                title: appLocalizations.smartRoutingEgressEchoes,
                desc: appLocalizations.smartRoutingEgressEchoesDesc,
                value: props.egressEchoes,
                write: (state, value) => state.copyWith(egressEchoes: value),
              ),
              _StringListItem(
                title: appLocalizations.smartRoutingCountryEchoes,
                desc: appLocalizations.smartRoutingCountryEchoesDesc,
                value: props.countryEchoes,
                write: (state, value) => state.copyWith(countryEchoes: value),
              ),
            ],
          ),
          SettingSection(
            title: appLocalizations.smartRoutingHeuristics,
            subTitle: appLocalizations.smartRoutingHeuristicsDesc,
            actions: _resetActions(context, ref, props, RoutingFacetGroup.heuristics),
            items: [
              _StringListItem(
                title: appLocalizations.smartRoutingNameHints,
                desc: appLocalizations.smartRoutingNameHintsDesc,
                value: props.nameHints,
                write: (state, value) => state.copyWith(nameHints: value),
              ),
              _StringListItem(
                title: appLocalizations.smartRoutingBreakerPatterns,
                desc: appLocalizations.smartRoutingBreakerPatternsDesc,
                value: props.breakerPatterns,
                write: (state, value) => state.copyWith(breakerPatterns: value),
              ),
              _RulesItem(rules: props.nodeRules),
            ],
          ),
          SettingSection(
            title: appLocalizations.smartRoutingMarkers,
            subTitle: appLocalizations.smartRoutingMarkersDesc,
            actions: _resetActions(context, ref, props, RoutingFacetGroup.markers),
            items: [
              _MarkersItem(
                title: appLocalizations.smartRoutingMarkersOpen,
                desc: appLocalizations.smartRoutingMarkersOpenDesc,
                markers: props.openMarkers,
                kind: _MarkerKind.open,
              ),
              _MarkersItem(
                title: appLocalizations.smartRoutingMarkersDomestic,
                desc: appLocalizations.smartRoutingMarkersDomesticDesc,
                markers: props.domesticMarkers,
                kind: _MarkerKind.domestic,
              ),
              _MarkersItem(
                title: appLocalizations.smartRoutingMarkersLocal,
                desc: appLocalizations.smartRoutingMarkersLocalDesc,
                markers: props.localMarkers,
                kind: _MarkerKind.local,
              ),
            ],
          ),
          SettingSection(
            title: appLocalizations.smartRoutingRanking,
            actions: _resetActions(context, ref, props, RoutingFacetGroup.bands),
            items: [
              DecorationListItem(
                leading: const GlyphIcon(AppGlyphs.sort),
                title: Text(
                  [
                    appLocalizations.smartRoutingKeyVerdict,
                    appLocalizations.smartRoutingKeyMisfit,
                    appLocalizations.smartRoutingKeyEvidence,
                    appLocalizations.smartRoutingKeyBand,
                  ].join(' → '),
                ),
              ),
              _StringListItem(
                title: appLocalizations.smartRoutingLatencyBands,
                desc: appLocalizations.smartRoutingLatencyBandsDesc,
                itemMaxLength: 6,
                itemValidator: (value) {
                  final edge = int.tryParse(value);
                  return edge == null || edge <= 0
                      ? appLocalizations.smartRoutingBandInvalid
                      : null;
                },
                value: props.latencyBands
                    .map((edge) => edge.toString())
                    .toList(),
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
          SettingSection(
            title: appLocalizations.smartRoutingBackup,
            bottom: 24,
            items: [
              DecorationListItem(
                minVerticalPadding: 8,
                leading: const GlyphIcon(AppGlyphs.share),
                title: Text(appLocalizations.smartRoutingExport),
                subtitle: Text(appLocalizations.smartRoutingExportDesc),
                onPressed: () => _handleExport(context, props),
              ),
              DecorationListItem(
                minVerticalPadding: 8,
                leading: const GlyphIcon(AppGlyphs.document),
                title: Text(appLocalizations.smartRoutingImport),
                subtitle: Text(appLocalizations.smartRoutingImportDesc),
                onPressed: () => _handleImport(context, ref),
              ),
            ],
          ),
          const SettingBottomInset(),
        ],
      ),
    );
  }

  Widget _pacingItem(
    WidgetRef ref, {
    required String title,
    required String desc,
    required List<int> options,
    required int value,
    required String Function(int) textBuilder,
    required SmartRoutingProps Function(SmartRoutingProps, int) write,
  }) {
    return DecorationListItem.options(
      title: Text(title),
      subtitle: Text(desc),
      dialogTitle: title,
      options: options.contains(value) ? options : [value, ...options],
      value: value,
      textBuilder: (option) => textBuilder(option as int),
      onChanged: (option) {
        if (option == null) return;
        _update(ref, (state) => write(state, option as int));
      },
    );
  }

  List<Widget>? _resetActions(
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
          onPressed: () => _handleSectionReset(context, ref, group),
          child: Text(context.appLocalizations.reset),
        ),
      ),
    ];
  }

  Future<void> _handleSectionReset(
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
    _update(ref, (state) => state.resetSeedGroup(group));
  }
}

Future<void> _handleExport(BuildContext context, SmartRoutingProps props) async {
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
    imported = SmartRoutingProps.fromJson(decoded as Map<String, Object?>);
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
    required this.title,
    required this.desc,
    required this.kind,
  });

  final String title;
  final String desc;
  final _CountryKind kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = _countriesOf(ref.watch(smartRoutingSettingProvider), kind);
    return DecorationListItem.open(
      title: Text(title),
      subtitle: Text(
        value.isEmpty ? desc : value.map(_countryLabel).join(', '),
      ),
      blur: false,
      forceFull: false,
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
      _countriesOf(ref.read(smartRoutingSettingProvider), widget.kind)
          .where((code) => !_selection.contains(code))
          .toList(),
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
  'AD', 'AE', 'AF', 'AG', 'AI', 'AL', 'AM', 'AO', 'AQ', 'AR', 'AS', 'AT', 'AU',
  'AW', 'AX', 'AZ', 'BA', 'BB', 'BD', 'BE', 'BF', 'BG', 'BH', 'BI', 'BJ', 'BL',
  'BM', 'BN', 'BO', 'BQ', 'BR', 'BS', 'BT', 'BV', 'BW', 'BY', 'BZ', 'CA', 'CC',
  'CD', 'CF', 'CG', 'CH', 'CI', 'CK', 'CL', 'CM', 'CN', 'CO', 'CR', 'CU', 'CV',
  'CW', 'CX', 'CY', 'CZ', 'DE', 'DJ', 'DK', 'DM', 'DO', 'DZ', 'EC', 'EE', 'EG',
  'EH', 'ER', 'ES', 'ET', 'FI', 'FJ', 'FK', 'FM', 'FO', 'FR', 'GA', 'GB', 'GD',
  'GE', 'GF', 'GG', 'GH', 'GI', 'GL', 'GM', 'GN', 'GP', 'GQ', 'GR', 'GS', 'GT',
  'GU', 'GW', 'GY', 'HK', 'HM', 'HN', 'HR', 'HT', 'HU', 'ID', 'IE', 'IL', 'IM',
  'IN', 'IO', 'IQ', 'IR', 'IS', 'IT', 'JE', 'JM', 'JO', 'JP', 'KE', 'KG', 'KH',
  'KI', 'KM', 'KN', 'KP', 'KR', 'KW', 'KY', 'KZ', 'LA', 'LB', 'LC', 'LI', 'LK',
  'LR', 'LS', 'LT', 'LU', 'LV', 'LY', 'MA', 'MC', 'MD', 'ME', 'MF', 'MG', 'MH',
  'MK', 'ML', 'MM', 'MN', 'MO', 'MP', 'MQ', 'MR', 'MS', 'MT', 'MU', 'MV', 'MW',
  'MX', 'MY', 'MZ', 'NA', 'NC', 'NE', 'NF', 'NG', 'NI', 'NL', 'NO', 'NP', 'NR',
  'NU', 'NZ', 'OM', 'PA', 'PE', 'PF', 'PG', 'PH', 'PK', 'PL', 'PM', 'PN', 'PR',
  'PS', 'PT', 'PW', 'PY', 'QA', 'RE', 'RO', 'RS', 'RU', 'RW', 'SA', 'SB', 'SC',
  'SD', 'SE', 'SG', 'SH', 'SI', 'SJ', 'SK', 'SL', 'SM', 'SN', 'SO', 'SR', 'SS',
  'ST', 'SV', 'SX', 'SY', 'SZ', 'TC', 'TD', 'TF', 'TG', 'TH', 'TJ', 'TK', 'TL',
  'TM', 'TN', 'TO', 'TR', 'TT', 'TV', 'TW', 'TZ', 'UA', 'UG', 'UM', 'US', 'UY',
  'UZ', 'VA', 'VC', 'VE', 'VG', 'VI', 'VN', 'VU', 'WF', 'WS', 'XK', 'YE', 'YT',
  'ZA', 'ZM', 'ZW',
};
