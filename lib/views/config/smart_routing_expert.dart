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
      body: SettingsListView(
        children: [
          SettingSection(
            top: 16,
            title: appLocalizations.smartRoutingPacing,
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
            title: appLocalizations.smartRoutingDetection,
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
              _StringListItem(
                title: appLocalizations.smartRoutingBreakerPatterns,
                desc: appLocalizations.smartRoutingBreakerPatternsDesc,
                value: props.breakerPatterns,
                write: (state, value) => state.copyWith(breakerPatterns: value),
              ),
              _StringListItem(
                title: appLocalizations.smartRoutingCountryEchoes,
                desc: appLocalizations.smartRoutingCountryEchoesDesc,
                value: props.countryEchoes,
                write: (state, value) => state.copyWith(countryEchoes: value),
              ),
              _StringListItem(
                title: appLocalizations.smartRoutingEgressEchoes,
                desc: appLocalizations.smartRoutingEgressEchoesDesc,
                value: props.egressEchoes,
                write: (state, value) => state.copyWith(egressEchoes: value),
              ),
              _StringListItem(
                title: appLocalizations.smartRoutingNameHints,
                desc: appLocalizations.smartRoutingNameHintsDesc,
                value: props.nameHints,
                write: (state, value) => state.copyWith(nameHints: value),
              ),
              _RulesItem(rules: props.nodeRules),
            ],
          ),
          SettingSection(
            title: appLocalizations.smartRoutingMarkers,
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
            items: [
              DecorationListItem(
                minVerticalPadding: 8,
                title: Text(appLocalizations.smartRoutingRankOrder),
                subtitle: Text(
                  [
                    appLocalizations.smartRoutingKeyVerdict,
                    appLocalizations.smartRoutingKeyMisfit,
                    appLocalizations.smartRoutingKeyEvidence,
                    appLocalizations.smartRoutingKeyBand,
                  ].join(' → '),
                ),
              ),
              DecorationListItem(
                minVerticalPadding: 8,
                title: Text(appLocalizations.smartRoutingKeyBand),
                subtitle: Text(appLocalizations.smartRoutingRankingDesc),
              ),
              _StringListItem(
                title: appLocalizations.smartRoutingLatencyBands,
                desc: appLocalizations.smartRoutingLatencyBandsDesc,
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

/// Countries ride a picker rather than the plain string editor so a code is a
/// recognised place with a flag, not a raw two-letter token the user must know.
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
      widget: _CountryPickerPage(
        title: title,
        codes: value,
        onCommit: (next) => ref
            .read(smartRoutingSettingProvider.notifier)
            .update((state) => write(state, next)),
      ),
    );
  }
}

String _countryLabel(String code) {
  final flag = countryCodeToEmoji(code);
  return flag == null ? code : '$flag $code';
}

class _CountryPickerPage extends StatefulWidget {
  const _CountryPickerPage({
    required this.title,
    required this.codes,
    required this.onCommit,
  });

  final String title;
  final List<String> codes;
  final ValueChanged<List<String>> onCommit;

  @override
  State<_CountryPickerPage> createState() => _CountryPickerPageState();
}

class _CountryPickerPageState extends State<_CountryPickerPage> {
  late List<String> _codes = [...widget.codes];
  final _controller = TextEditingController();
  String _draft = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _normalized =>
      _draft.toUpperCase().replaceAll(RegExp('[^A-Z]'), '');

  bool get _canAdd {
    final code = _normalized;
    return countryCodeToEmoji(code) != null && !_codes.contains(code);
  }

  void _add() {
    if (!_canAdd) {
      return;
    }
    setState(() {
      _codes = [..._codes, _normalized];
      _controller.clear();
      _draft = '';
    });
    widget.onCommit(_codes);
  }

  void _remove(String code) {
    setState(() => _codes = _codes.where((item) => item != code).toList());
    widget.onCommit(_codes);
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final preview = countryCodeToEmoji(_normalized);
    return CommonScaffold(
      title: widget.title,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              spacing: 12,
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textCapitalization: TextCapitalization.characters,
                    maxLength: 2,
                    decoration: InputDecoration(
                      prefixText: preview == null ? null : '$preview  ',
                      hintText: appLocalizations.smartRoutingCountrySearch,
                      counterText: '',
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) => setState(() => _draft = value),
                    onSubmitted: (_) => _add(),
                  ),
                ),
                CommonMinFilledButtonTheme(
                  child: FilledButton(
                    onPressed: _canAdd ? _add : null,
                    child: Text(appLocalizations.smartRoutingCountryAdd),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _codes.isEmpty
                ? NullStatus(label: appLocalizations.smartRoutingCountryEmpty)
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final code in _codes)
                          Chip(
                            label: Text(_countryLabel(code)),
                            onDeleted: () => _remove(code),
                          ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
