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
    final pacing = props.strategy.pacing;
    return CommonScaffold(
      title: appLocalizations.advancedConfig,
      floatBody: true,
      body: SettingsListView(
        children: [
          SizedBox(height: context.appBarInset),
          SettingSection(
            top: 16,
            title: appLocalizations.smartRoutingPacing,
            subTitle: appLocalizations.smartRoutingPacingDesc,
            items: [
              _pacingItem(
                ref,
                title: appLocalizations.smartRoutingDwell,
                desc: appLocalizations.smartRoutingDwellDesc,
                options: _dwellChoices,
                value: props.dwellSeconds,
                seed: pacing.dwellSeconds,
                textBuilder: appLocalizations.smartRoutingSeconds,
                write: (state, value) => state.copyWith(dwellSeconds: value),
              ),
              _pacingItem(
                ref,
                title: appLocalizations.smartRoutingWave,
                desc: appLocalizations.smartRoutingWaveDesc,
                options: _waveChoices,
                value: props.waveWidth,
                seed: pacing.waveWidth,
                textBuilder: appLocalizations.smartRoutingWaveNodes,
                write: (state, value) => state.copyWith(waveWidth: value),
              ),
              _pacingItem(
                ref,
                title: appLocalizations.smartRoutingCeiling,
                desc: appLocalizations.smartRoutingCeilingDesc,
                options: _ceilingChoices,
                value: props.absCeilingMs,
                seed: pacing.absCeilingMs,
                textBuilder: appLocalizations.smartRoutingMillis,
                write: (state, value) => state.copyWith(absCeilingMs: value),
              ),
              _pacingItem(
                ref,
                title: appLocalizations.smartRoutingDegradeConfirm,
                desc: appLocalizations.smartRoutingDegradeConfirmDesc,
                options: _degradeChoices,
                value: props.degradeConfirmSeconds,
                seed: pacing.degradeConfirmSeconds,
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
                seed: pacing.proofTtlMinutes,
                textBuilder: appLocalizations.smartRoutingMinutes,
                write: (state, value) => state.copyWith(proofTtlMinutes: value),
              ),
            ],
          ),
          SettingSection(
            title: appLocalizations.smartRoutingProbes,
            subTitle: appLocalizations.smartRoutingRegionNote,
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
            items: [
              _CountryListItem(
                title: appLocalizations.smartRoutingCensor,
                desc: appLocalizations.smartRoutingCensorDesc,
                value: props.censorCountries,
                write: (state, value) => state.copyWith(censorCountries: value),
              ),
              _CountryListItem(
                title: appLocalizations.smartRoutingAvoidCountries,
                desc: appLocalizations.smartRoutingAvoidCountriesDesc,
                value: props.avoidCountries,
                write: (state, value) => state.copyWith(avoidCountries: value),
              ),
            ],
          ),
          SettingSection(
            title: appLocalizations.smartRoutingEgress,
            subTitle: appLocalizations.smartRoutingEgressDesc,
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
            subTitle: [
              appLocalizations.smartRoutingKeyVerdict,
              appLocalizations.smartRoutingKeyMisfit,
              appLocalizations.smartRoutingKeyEvidence,
              appLocalizations.smartRoutingKeyBand,
            ].join(' → '),
            items: [
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
                leading: const Icon(Icons.ios_share_rounded),
                title: Text(appLocalizations.smartRoutingExport),
                subtitle: Text(appLocalizations.smartRoutingExportDesc),
                onPressed: () => _handleExport(context, props),
              ),
              DecorationListItem(
                minVerticalPadding: 8,
                leading: const Icon(Icons.file_open_rounded),
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
    required int seed,
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
      trailing: value == seed
          ? null
          : Builder(
              builder: (context) => CommonMinIconButtonTheme(
                child: IconButton(
                  tooltip: context.appLocalizations.smartRoutingFieldReset,
                  onPressed: () => _update(ref, (state) => write(state, seed)),
                  icon: const Icon(Icons.restart_alt_rounded),
                ),
              ),
            ),
      onChanged: (option) {
        if (option == null) return;
        _update(ref, (state) => write(state, option as int));
      },
    );
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


/// Countries are chosen, not typed: a searchable list of every ISO code shown
/// with its flag means an invalid code cannot be entered and the flag is a
/// preview, not a second copy of the label. Stored as the bare two-letter token
/// the engine expects.
class _CountryListItem extends ConsumerWidget {
  const _CountryListItem({
    required this.title,
    required this.desc,
    required this.value,
    required this.write,
  });

  final String title;
  final String desc;
  final List<String> value;
  final SmartRoutingProps Function(SmartRoutingProps, List<String>) write;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DecorationListItem.open(
      title: Text(title),
      subtitle: Text(value.isEmpty ? desc : value.map(_countryLabel).join(', ')),
      blur: false,
      widget: _CountryPickerPage(title: title, selected: value),
      onChanged: (items) => ref
          .read(smartRoutingSettingProvider.notifier)
          .update((state) => write(state, List<String>.from(items as List))),
    );
  }
}

/// The flag is drawn once as the leading glyph; the code alone is the title, so
/// a row never shows the flag twice.
class _CountryPickerPage extends StatefulWidget {
  const _CountryPickerPage({required this.title, required this.selected});

  final String title;
  final List<String> selected;

  @override
  State<_CountryPickerPage> createState() => _CountryPickerPageState();
}

class _CountryPickerPageState extends State<_CountryPickerPage> {
  static final _sortedCodes = _isoAlpha2.toList()..sort();

  late List<String> _selected;
  final _search = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _selected = [...widget.selected];
    _search.addListener(
      () => setState(() => _query = _search.text.trim().toUpperCase()),
    );
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _toggle(String code) {
    setState(() {
      if (!_selected.remove(code)) {
        _selected.add(code);
      }
    });
  }

  List<String> get _ordered {
    final matches = _sortedCodes
        .where((code) => _query.isEmpty || code.contains(_query))
        .toList();
    final chosen = _selected.where(matches.contains).toList();
    final rest = matches.where((code) => !_selected.contains(code)).toList();
    return [...chosen, ...rest];
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final ordered = _ordered;
    return CommonPopScope(
      onPop: (_) {
        Navigator.of(context).pop(_selected);
        return false;
      },
      child: CommonScaffold(
        title: widget.title,
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _search,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search_rounded),
                  labelText: appLocalizations.smartRoutingCountrySearch,
                ),
              ),
            ),
            Expanded(
              child: ordered.isEmpty
                  ? NullStatus(
                      label: appLocalizations.smartRoutingCountryNoMatch,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16 + 64),
                      itemCount: ordered.length,
                      itemBuilder: (context, index) {
                        final code = ordered[index];
                        final selected = _selected.contains(code);
                        final flag = countryCodeToEmoji(code);
                        return DecorationListItem(
                          isSelected: selected,
                          leading: flag == null
                              ? const Icon(Icons.public_rounded)
                              : Text(
                                  flag,
                                  style: const TextStyle(fontSize: 24),
                                ),
                          title: Text(code),
                          trailing: selected
                              ? Icon(
                                  Icons.check_circle_rounded,
                                  color: context.colorScheme.primary,
                                )
                              : const Icon(Icons.circle_outlined),
                          onPressed: () => _toggle(code),
                        );
                      },
                    ),
            ),
          ],
        ),
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
