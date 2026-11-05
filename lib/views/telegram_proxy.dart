import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/widgets/settings/setting_target.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

const _pollInterval = Duration(seconds: 1);
const _dataCenters = [1, 2, 3, 4, 5];

String telegramProxyLink(TelegramProxyProps props) =>
    'tg://proxy?server=127.0.0.1&port=${props.port}&secret=dd${props.secret}';

/// A data center serves regular and media connections, which the core counts
/// apart under a signed number. One that reaches Telegram at all is reachable.
TelegramProxyDc? mergeTelegramProxyDc(
  int dc,
  List<TelegramProxyDc> connections,
) {
  final parts = connections.where((item) => item.dc.abs() == dc).toList();
  if (parts.isEmpty) {
    return null;
  }
  final connected = parts.where(
    (item) => item.route == 'websocket' || item.route == 'outbound',
  );
  final used = parts.where((item) => item.route != 'idle');
  return connected.firstOrNull ?? used.firstOrNull ?? parts.first;
}

class TelegramProxyView extends ConsumerStatefulWidget {
  const TelegramProxyView({super.key});

  @override
  ConsumerState<TelegramProxyView> createState() => _TelegramProxyViewState();
}

class _TelegramProxyViewState extends ConsumerState<TelegramProxyView>
    with RouteMotionHoldMixin<TelegramProxyView> {
  Timer? _timer;
  bool _polling = false;
  bool _advancedExpanded = false;
  TelegramProxyState? _state;

  @override
  void initState() {
    super.initState();
    unawaited(_poll());
    _timer = Timer.periodic(_pollInterval, (_) => unawaited(_poll()));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _poll() async {
    if (_polling) {
      return;
    }
    _polling = true;
    TelegramProxyState? state;
    try {
      state = await ref.read(coreHandlerProvider).getTelegramProxy();
    } catch (_) {
      state = null;
    } finally {
      _polling = false;
    }
    if (!mounted || state == _state) {
      return;
    }
    updateWhenRouteSettled(() => setState(() => _state = state));
  }

  void _update(TelegramProxyProps Function(TelegramProxyProps) update) {
    ref.read(telegramProxySettingProvider.notifier).update(update);
  }

  Future<void> _open(TelegramProxyProps props) async {
    var opened = false;
    try {
      opened = await launchUrl(
        Uri.parse(telegramProxyLink(props)),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      opened = false;
    }
    if (!opened && mounted) {
      await _showQrCode(props);
    }
  }

  Future<void> _showQrCode(TelegramProxyProps props) {
    final l = context.appLocalizations;
    return dialogs.showQrCode(
      title: l.telegramProxyLink,
      data: telegramProxyLink(props),
      message: l.telegramProxyManualSteps(props.port),
    );
  }

  Future<void> _copyLink(TelegramProxyProps props) async {
    await Clipboard.setData(ClipboardData(text: telegramProxyLink(props)));
    if (mounted) {
      context.showNotifier(
        context.appLocalizations.copySuccess,
        level: MessageLevel.success,
      );
    }
  }

  String _statusText(AppLocalizations l, TelegramProxyState? state) {
    final status = state?.status;
    if (state != null && state.error.isNotEmpty) {
      return l.telegramProxyStartFailed(state.error);
    }
    if (status != null && status.clients > 0 && status.bytesDown > 0) {
      return l.telegramProxyConnected;
    }
    if (status != null && status.badSecrets > 0) {
      return l.telegramProxyBadSecret;
    }
    return l.telegramProxyWaiting;
  }

  String _routeText(AppLocalizations l, TelegramProxyDc? dc) {
    final latency = dc == null || dc.connectMs <= 0
        ? null
        : l.telegramProxyLatency(dc.connectMs);
    final route = switch (dc?.route) {
      'websocket' => l.telegramProxyRouteDirect,
      'outbound' => l.telegramProxyRouteOutbound(_state?.outboundName ?? ''),
      'unavailable' => l.telegramProxyRouteUnavailable,
      _ => l.telegramProxyRouteIdle,
    };
    final connected = dc?.route == 'websocket' || dc?.route == 'outbound';
    return connected && latency != null ? '$route · $latency' : route;
  }

  Widget _buildMain(AppLocalizations l) {
    return generateSection(
      items: [
        ConfigToggleItem(
          selector: telegramProxySettingProvider.select(
            (props) => props.enabled,
          ),
          title: (l) => l.telegramProxyEnable,
          onChanged: (_, value) =>
              _update((props) => props.copyWith(enabled: value)),
        ),
        if (system.isAndroid)
          ConfigToggleItem(
            selector: telegramProxySettingProvider.select(
              (props) => props.autostart,
            ),
            title: (l) => l.telegramProxyAutostart,
            onChanged: (_, value) =>
                _update((props) => props.copyWith(autostart: value)),
          ),
      ],
      footer: l.telegramProxyFooter,
    );
  }

  Widget _buildStatus(AppLocalizations l) {
    final colorScheme = context.colorScheme;
    final state = _state;
    final connections = state?.status?.dcs ?? const <TelegramProxyDc>[];
    return generateSection(
      title: l.telegramProxyStatus,
      items: [
        ListItem(
          title: Text(
            _statusText(l, state),
            style: state != null && state.error.isNotEmpty
                ? TextStyle(color: colorScheme.error)
                : null,
          ),
        ),
        for (final dc in _dataCenters)
          ListItem(
            title: Text(l.telegramProxyDc(dc)),
            trailing: Text(
              _routeText(l, mergeTelegramProxyDc(dc, connections)),
              style: AppTextStyle.footnote
                  .of(context)
                  .copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ),
      ],
      footer: l.telegramProxyStatusFooter,
    );
  }

  Widget _buildOutbound(AppLocalizations l, String selected) {
    final names = ref.watch(
      groupsProvider.select(
        (groups) => groups.map((group) => group.name).toList(),
      ),
    );
    return generateSection(
      items: [
        ConfigOptionsItem<String>(
          selector: telegramProxySettingProvider.select(
            (props) => props.outbound,
          ),
          title: (l) => l.telegramProxyOutbound,
          options: [
            '',
            telegramProxyOutboundRules,
            ...names,
            if (!{'', telegramProxyOutboundRules, ...names}.contains(selected))
              selected,
          ],
          textBuilder: (name) => switch (name) {
            '' => l.telegramProxyOutboundOff,
            telegramProxyOutboundRules => l.telegramProxyByRules,
            _ => name,
          },
          onChanged: (_, value) =>
              _update((props) => props.copyWith(outbound: value)),
        ),
      ],
      footer: l.telegramProxyOutboundFooter,
    );
  }

  Widget _buildAdvanced(AppLocalizations l) {
    return generateSection(
      items: [
        ListItem(
          title: Text(l.telegramProxyAdvanced),
          trailing: GlyphIcon(
            _advancedExpanded ? AppGlyphs.chevronUp : AppGlyphs.chevronDown,
          ),
          onTap: () => setState(() => _advancedExpanded = !_advancedExpanded),
        ),
        if (_advancedExpanded) ...[
          ConfigTextItem(
            selector: telegramProxySettingProvider.select(
              (props) => props.port.toString(),
            ),
            title: (l) => l.telegramProxyPort,
            keyboardType: TextInputType.number,
            validator: (value, l) {
              final port = int.tryParse(value ?? '');
              return port != null && port >= 1024 && port <= 65535
                  ? null
                  : l.telegramProxyInvalidPort;
            },
            onChanged: (_, value) =>
                _update((props) => props.copyWith(port: int.parse(value))),
          ),
          ConfigListEditItem(
            selector: telegramProxySettingProvider.select(
              (props) => props.endpoints,
            ),
            title: (l) => l.telegramProxyEndpoints,
            itemValidator: validateHost,
            onChanged: (_, value) =>
                _update((props) => props.copyWith(endpoints: value)),
          ),
        ],
      ],
      footer: _advancedExpanded ? l.telegramProxyAdvancedFooter : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final props = ref.watch(telegramProxySettingProvider);
    final running = props.enabled && (_state?.running ?? false);
    return CommonScaffold(
      title: l.telegramProxyTitle,
      primaryAction: IconButtonData(
        glyph: AppGlyphs.send,
        tooltip: l.telegramProxyOpen,
        onPressed: running ? () => unawaited(_open(props)) : null,
      ),
      iconActions: [
        IconButtonData(
          glyph: AppGlyphs.qrCode,
          tooltip: l.telegramProxyLink,
          onPressed: running ? () => unawaited(_showQrCode(props)) : null,
        ),
        IconButtonData(
          glyph: AppGlyphs.copy,
          tooltip: l.telegramProxyCopyLink,
          onPressed: running ? () => unawaited(_copyLink(props)) : null,
        ),
      ],
      body: SettingsPageScroll(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ).copyWith(top: context.sectionsTopPadding, bottom: 16),
          child: Column(
            children: [
              _buildMain(l),
              if (props.enabled) _buildStatus(l),
              _buildOutbound(l, props.outbound),
              _buildAdvanced(l),
            ],
          ),
        ),
      ),
    );
  }
}
