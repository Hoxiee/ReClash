import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/features/lovense/controller.dart';
import 'package:reclash/features/lovense/engine.dart';
import 'package:reclash/features/lovense/models.dart';
import 'package:reclash/features/lovense/providers.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/widgets/settings/setting_target.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

const _documentation =
    'https://developer.lovense.com/docs/standard-solutions/standard-api.html';
const _durations = [2, 5, 10, 20, 30, 60];
const _minStrokeWidth = 20.0;

class LovenseView extends ConsumerStatefulWidget {
  const LovenseView({super.key});

  @override
  ConsumerState<LovenseView> createState() => _LovenseViewState();
}

class _LovenseViewState extends ConsumerState<LovenseView>
    with WidgetsBindingObserver {
  late final LovenseController _controller;
  late final LovenseReactions _reactions;
  String _address = lovenseDefaultAddress;
  bool _addressEdited = false;
  LovenseNotice? _shownNotice;

  @override
  void initState() {
    super.initState();
    _controller = ref.read(lovenseControllerProvider);
    _reactions = ref.read(lovenseReactionsProvider);
    _shownNotice = _controller.notice;
    _controller.addListener(_announce);
    WidgetsBinding.instance.addObserver(this);
    unawaited(_restoreAddress());
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    if (lifecycle != null && lifecycle != AppLifecycleState.resumed) {
      unawaited(_controller.pause());
    } else {
      _controller.resume();
    }
  }

  Future<void> _restoreAddress() async {
    final address = await _controller.restoreAddress();
    if (mounted && !_addressEdited) setState(() => _address = address);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _controller.resume();
    } else {
      unawaited(_controller.pause());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.removeListener(_announce);
    if (_reactions.active) {
      unawaited(_controller.stopManual());
    } else {
      unawaited(_controller.disconnect());
    }
    super.dispose();
  }

  void _announce() {
    final notice = _controller.notice;
    if (notice == _shownNotice) return;
    _shownNotice = notice;
    if (notice == null || !mounted) return;
    final l = context.appLocalizations;
    context.showNotifier(switch (notice) {
      LovenseNotice.commandSent => l.lovenseCommandSent(
        _controller.lastDuration,
      ),
      LovenseNotice.stopSent => l.lovenseStopSent,
    }, level: MessageLevel.success);
  }

  void _connect() => unawaited(_controller.connect(_address));

  String? _errorText(AppLocalizations l) {
    final error = _controller.error;
    if (error == null) return null;
    return switch (error.kind) {
      LovenseErrorKind.invalidAddress => l.lovenseInvalidAddress,
      LovenseErrorKind.invalidCommand => l.lovenseInvalidCommand,
      LovenseErrorKind.unavailable => l.lovenseUnavailable,
      LovenseErrorKind.timeout => l.lovenseTimeout,
      LovenseErrorKind.tls => l.lovenseTlsError,
      LovenseErrorKind.invalidResponse => l.lovenseInvalidResponse,
      LovenseErrorKind.remote =>
        error.code == null ? l.lovenseError : l.lovenseRemoteError(error.code!),
      LovenseErrorKind.cancelled => null,
    };
  }

  Widget _buildConnection(AppLocalizations l) {
    final controller = _controller;
    final error = _errorText(l);
    final warnings = [
      if (controller.stopFailed) l.lovenseStopFailed,
      if (controller.saveFailed) l.lovenseSaveFailed,
      if (controller.paused) l.lovensePaused,
    ];
    final secondary = AppTextStyle.footnote
        .of(context)
        .copyWith(color: context.colorScheme.onSurfaceVariant);
    return generateSection(
      items: [
        if (controller.connected || controller.busy)
          ListItem(
            title: Text(l.lovenseAddress),
            subtitle: Text(controller.endpoint?.displayAddress ?? _address),
          )
        else
          ListItem.input(
            key: const ValueKey('lovense-address'),
            title: Text(l.lovenseAddress),
            subtitle: Text(_address),
            dialogTitle: l.lovenseAddress,
            value: _address,
            keyboardType: TextInputType.url,
            resetValue: lovenseDefaultAddress,
            validator: (value) {
              try {
                LovenseEndpoint.parse(value ?? '');
                return null;
              } on LovenseError {
                return l.lovenseInvalidAddress;
              }
            },
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _addressEdited = true;
                _address = LovenseEndpoint.parse(value).displayAddress;
              });
            },
          ),
        ListItem(
          title: Text(
            controller.connected ? l.lovenseConnected : l.lovenseDisconnected,
          ),
          subtitle: error == null
              ? null
              : Text(
                  error,
                  key: const ValueKey('lovense-error'),
                  style: TextStyle(color: context.colorScheme.error),
                ),
        ),
        for (final warning in warnings)
          ListItem(title: Text(warning, style: secondary)),
      ],
      footer: l.lovenseFooter,
    );
  }

  Widget _buildToys(AppLocalizations l) {
    final controller = _controller;
    if (!controller.connected) return const SizedBox.shrink();
    if (controller.toys.isEmpty) {
      return generateSection(items: [ListItem(title: Text(l.lovenseNoToys))]);
    }
    return Column(
      children: [
        for (final toy in controller.toys)
          _ToySection(key: ValueKey(toy.id), toy: toy, controller: controller),
      ],
    );
  }

  Widget _buildReactions(AppLocalizations l) {
    if (!_controller.connected) return const SizedBox.shrink();
    final reactions = _reactions;
    return generateSection(
      title: l.lovenseReactions,
      items: [
        ListItem.toggle(
          key: const ValueKey('lovense-react-connection'),
          title: Text(l.lovenseReactConnection),
          value: reactions.connection,
          onChanged: reactions.setConnection,
        ),
        ListItem.toggle(
          key: const ValueKey('lovense-react-traffic'),
          title: Text(l.lovenseReactTraffic),
          value: reactions.traffic,
          onChanged: reactions.setTraffic,
        ),
      ],
      footer: l.lovenseReactionsFooter,
    );
  }

  Widget _buildAbout(AppLocalizations l) {
    return generateSection(
      items: [
        ListItem(
          title: Text(l.lovenseDocumentation),
          trailing: const GlyphIcon(AppGlyphs.openExternal),
          onTap: () => unawaited(
            launchUrl(
              Uri.parse(_documentation),
              mode: LaunchMode.externalApplication,
            ),
          ),
        ),
      ],
      footer: l.lovenseSafety,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    return ListenableBuilder(
      listenable: Listenable.merge([_controller, _reactions]),
      builder: (context, _) {
        final controller = _controller;
        final idle = !controller.busy && !controller.stopping;
        return CommonScaffold(
          title: l.lovense,
          isLoading: !idle,
          primaryAction: controller.connected
              ? IconButtonData(
                  glyph: AppGlyphs.refresh,
                  tooltip: l.lovenseRefresh,
                  onPressed: idle
                      ? () => unawaited(controller.refresh())
                      : null,
                )
              : IconButtonData(
                  glyph: AppGlyphs.link,
                  tooltip: l.lovenseConnect,
                  onPressed: controller.busy ? null : _connect,
                ),
          iconActions: [
            if (controller.connected)
              IconButtonData(
                glyph: AppGlyphs.close,
                tooltip: l.lovenseDisconnect,
                onPressed: controller.stopping
                    ? null
                    : () => unawaited(controller.disconnect()),
              ),
          ],
          body: Column(
            children: [
              Expanded(
                child: SettingsPageScroll(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ).copyWith(top: context.sectionsTopPadding, bottom: 16),
                    child: Column(
                      children: [
                        _buildConnection(l),
                        _buildToys(l),
                        _buildReactions(l),
                        _buildAbout(l),
                      ],
                    ),
                  ),
                ),
              ),
              if (controller.connected)
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        key: const ValueKey('lovense-stop-all'),
                        style: FilledButton.styleFrom(
                          backgroundColor: context.colorScheme.error,
                          foregroundColor: context.colorScheme.onError,
                        ),
                        onPressed: controller.stopping
                            ? null
                            : () {
                                _reactions.disableAll();
                                unawaited(controller.stopAll());
                              },
                        icon: const GlyphIcon(AppGlyphs.block, fill: 1),
                        label: Text(l.lovenseStopAll),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ToySection extends StatefulWidget {
  const _ToySection({super.key, required this.toy, required this.controller});

  final LovenseToy toy;
  final LovenseController controller;

  @override
  State<_ToySection> createState() => _ToySectionState();
}

class _ToySectionState extends State<_ToySection> {
  LovenseFunction? _function;
  int _strength = 1;
  int _duration = 10;
  RangeValues _stroke = const RangeValues(0, 100);

  @override
  void initState() {
    super.initState();
    _syncFunction();
  }

  @override
  void didUpdateWidget(covariant _ToySection oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncFunction();
  }

  void _syncFunction() {
    final functions = widget.toy.functions;
    if (!functions.contains(_function)) {
      _function = functions.firstOrNull;
    }
    final max = _function?.maxStrength ?? 0;
    if (_strength > max) _strength = max;
  }

  bool get _usesStroke =>
      widget.toy.supportsStroke && _function == LovenseFunction.thrusting;

  void _start(LovenseFunction function) {
    unawaited(
      widget.controller.run(
        toyId: widget.toy.id,
        function: function,
        strength: _strength,
        duration: _duration,
        stroke: _usesStroke
            ? LovenseStroke(_stroke.start.round(), _stroke.end.round())
            : null,
      ),
    );
  }

  String _status(AppLocalizations l) {
    final toy = widget.toy;
    final state = toy.connected
        ? l.lovenseToyConnected
        : l.lovenseToyDisconnected;
    final battery = toy.battery;
    return battery == null ? state : '$state · ${l.lovenseBattery(battery)}';
  }

  String? _footer(AppLocalizations l) {
    if (!widget.toy.hasFunctionInfo) return l.lovenseUnknownFunctions;
    if (_function == null) return l.lovenseNoFunctions;
    if (_usesStroke) return l.lovenseStrokeHelp;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final toy = widget.toy;
    final controller = widget.controller;
    final function = _function;
    final canStart = controller.canStart && toy.connected && function != null;
    return generateSection(
      title: toy.displayName,
      items: [
        ListItem(
          title: Text(_status(l)),
          subtitle: Text('${toy.name} · ${toy.id}'),
        ),
        if (function != null) ...[
          ListItem<LovenseFunction>.options(
            key: ValueKey('lovense-function-${toy.id}'),
            title: Text(l.lovenseFunction),
            options: toy.functions,
            value: function,
            textBuilder: (value) => value.apiName,
            onChanged: (value) => setState(() {
              _function = value;
              _strength = 1.clamp(0, value.maxStrength);
            }),
          ),
          _SliderItem(
            key: ValueKey('lovense-strength-${toy.id}'),
            title: l.lovenseStrength,
            value: '$_strength / ${function.maxStrength}',
            enabled: canStart,
            child: Slider(
              padding: EdgeInsets.zero,
              max: function.maxStrength.toDouble(),
              divisions: function.maxStrength,
              value: _strength.toDouble(),
              label: '$_strength',
              onChanged: canStart
                  ? (value) => setState(() => _strength = value.round())
                  : null,
            ),
          ),
          ListItem<int>.options(
            key: ValueKey('lovense-duration-${toy.id}'),
            title: Text(l.lovenseDuration),
            options: _durations,
            value: _duration,
            textBuilder: l.lovenseSeconds,
            onChanged: (value) => setState(() => _duration = value),
          ),
          if (_usesStroke)
            _SliderItem(
              key: ValueKey('lovense-stroke-${toy.id}'),
              title: l.lovenseStroke,
              value: '${_stroke.start.round()}–${_stroke.end.round()}',
              enabled: canStart,
              child: RangeSlider(
                // ignore: deprecated_member_use
                year2023: false,
                padding: EdgeInsets.zero,
                values: _stroke,
                max: 100,
                divisions: 100,
                onChanged: canStart
                    ? (value) {
                        if (value.end - value.start >= _minStrokeWidth) {
                          setState(() => _stroke = value);
                        }
                      }
                    : null,
              ),
            ),
        ],
        _ItemCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            spacing: 8,
            children: [
              Expanded(
                child: FilledButton(
                  key: ValueKey('lovense-start-${toy.id}'),
                  onPressed: canStart ? () => _start(function) : null,
                  child: Text(l.lovenseStart),
                ),
              ),
              Expanded(
                child: FilledButton.tonal(
                  key: ValueKey('lovense-stop-${toy.id}'),
                  onPressed: controller.connected && !controller.stopping
                      ? () => unawaited(controller.stopToy(toy.id))
                      : null,
                  child: Text(l.lovenseStop),
                ),
              ),
            ],
          ),
        ),
      ],
      footer: _footer(l),
    );
  }
}

class _SliderItem extends StatelessWidget {
  const _SliderItem({
    super.key,
    required this.title,
    required this.value,
    required this.enabled,
    required this.child,
  });

  final String title;
  final String value;
  final bool enabled;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _ItemCard(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Opacity(
        opacity: enabled ? 1 : 0.5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              spacing: 12,
              children: [
                Expanded(child: Text(title, style: context.listTitleStyle)),
                Text(value, style: context.listSubtitleStyle.toTabular),
              ],
            ),
            SliderTheme(data: SliderDefaultsM3(context), child: child),
          ],
        ),
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({required this.padding, required this.child});

  final EdgeInsets padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final position = ItemPositionProvider.of(context)?.position;
    return CommonCard(
      shape: AppShape.of(
        AppRadius.vertical(
          top: switch (position) {
            ItemPosition.start || ItemPosition.startAndEnd => AppCorner.xl,
            _ => AppCorner.none,
          },
          bottom: switch (position) {
            ItemPosition.end || ItemPosition.startAndEnd => AppCorner.xl,
            _ => AppCorner.none,
          },
        ),
      ),
      padding: padding,
      child: child,
    );
  }
}
