import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/widgets/widgets.dart';

const coreToolsPaneId = 'core';

class CoreSection extends ConsumerStatefulWidget {
  const CoreSection({super.key});

  @override
  ConsumerState<CoreSection> createState() => _CoreSectionState();
}

class _CoreSectionState extends ConsumerState<CoreSection> {
  Future<String?>? _version;
  bool _restartPending = false;

  @override
  void initState() {
    super.initState();
    ref.listenManual(coreStatusProvider, (previous, next) {
      if (next == CoreStatus.connected && previous != next) {
        final version = _readVersion();
        setState(() {
          _version = version;
        });
      }
    }, fireImmediately: true);
  }

  Future<String?> _readVersion() async {
    try {
      final version = await ref
          .read(coreHandlerProvider)
          .getVersion()
          .timeout(const Duration(seconds: 2));
      return RegExp(r'^v?(\d+\.\d+\.\d+)').firstMatch(version)?.group(1) ??
          version;
    } catch (_) {
      return null;
    }
  }

  Future<void> _restart() async {
    if (_restartPending ||
        ref.read(coreStatusProvider) == CoreStatus.connecting) {
      return;
    }
    setState(() => _restartPending = true);
    try {
      final status = ref.read(coreStatusProvider);
      final l10n = context.appLocalizations;
      final confirmed = await dialogs.showMessage(
        message: TextSpan(
          text: status == CoreStatus.connected
              ? l10n.forceRestartCoreTip
              : l10n.restartCoreTip,
        ),
      );
      if (!mounted ||
          confirmed != true ||
          ref.read(coreStatusProvider) == CoreStatus.connecting) {
        return;
      }
      await ref.read(coreActionProvider.notifier).restartCore();
    } catch (error) {
      if (mounted) {
        context.showNotifier(error.toString(), level: MessageLevel.error);
      }
    } finally {
      if (mounted) setState(() => _restartPending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(coreStatusProvider);
    final l10n = context.appLocalizations;
    final color = switch (status) {
      CoreStatus.connected => context.colorScheme.success,
      CoreStatus.connecting => context.colorScheme.primary,
      CoreStatus.disconnected => context.colorScheme.onSurfaceVariant,
    };
    return SettingSection(
      title: l10n.core,
      items: [
        DecorationListItem.open(
          paneId: coreToolsPaneId,
          leading: const GlyphIcon(AppGlyphs.memory),
          title: FutureBuilder<String?>(
            future: _version,
            builder: (_, snapshot) => Text(
              snapshot.data == null ? 'mihomo' : 'mihomo ${snapshot.data}',
            ),
          ),
          subtitle: Row(
            spacing: 6,
            children: [
              GlyphIcon(
                switch (status) {
                  CoreStatus.connected => AppGlyphs.checkCircle,
                  CoreStatus.connecting => AppGlyphs.sync,
                  CoreStatus.disconnected => AppGlyphs.stop,
                },
                size: 16,
                color: color,
              ),
              Flexible(
                child: Text(switch (status) {
                  CoreStatus.connected => l10n.coreRunning,
                  CoreStatus.connecting => l10n.coreStarting,
                  CoreStatus.disconnected => l10n.coreStopped,
                }),
              ),
            ],
          ),
          trailing: system.isDesktop
              ? IconButton.outlined(
                  tooltip: l10n.restart,
                  onPressed: _restartPending || status == CoreStatus.connecting
                      ? null
                      : _restart,
                  icon: const GlyphIcon(AppGlyphs.reset),
                )
              : null,
          widget: const CoreDetailView(),
        ),
      ],
    );
  }
}

class CoreDetailView extends ConsumerStatefulWidget {
  const CoreDetailView({super.key});

  @override
  ConsumerState<CoreDetailView> createState() => _CoreDetailViewState();
}

class _CoreDetailViewState extends ConsumerState<CoreDetailView> {
  String? _versionText;
  String? _configText;
  bool _configLoading = false;

  @override
  void initState() {
    super.initState();
    ref.listenManual(coreStatusProvider, (previous, next) {
      if (next == CoreStatus.connected && previous != next) {
        _refresh();
      }
    }, fireImmediately: true);
  }

  Future<void> _refresh() async {
    if (ref.read(coreStatusProvider) != CoreStatus.connected) {
      return;
    }
    setState(() => _configLoading = true);
    final version = await _readVersion();
    final config = await _readConfig();
    if (!mounted) return;
    setState(() {
      _versionText = version;
      _configText = config;
      _configLoading = false;
    });
  }

  Future<String?> _readVersion() async {
    try {
      return await ref
          .read(coreHandlerProvider)
          .getVersion()
          .timeout(const Duration(seconds: 2));
    } catch (_) {
      return null;
    }
  }

  Future<String?> _readConfig() async {
    try {
      final config = await ref.read(coreHandlerProvider).getAppliedConfig();
      return const JsonEncoder.withIndent('  ').convert(config);
    } catch (_) {
      return null;
    }
  }

  void _resetTraffic() {
    ref.read(coreHandlerProvider).resetTraffic();
    ref.read(totalTrafficProvider.notifier).value = const Traffic();
  }

  Future<void> _copyConfig() async {
    final text = _configText;
    if (text == null) return;
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    context.showNotifier(context.appLocalizations.copySuccess);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.appLocalizations;
    final status = ref.watch(coreStatusProvider);
    final total = ref.watch(totalTrafficProvider);
    final statusText = switch (status) {
      CoreStatus.connected => l10n.coreRunning,
      CoreStatus.connecting => l10n.coreStarting,
      CoreStatus.disconnected => l10n.coreStopped,
    };
    final appVersion = 'v${globalState.packageInfo.version}';
    return CommonScaffold(
      title: l10n.core,
      floatBody: true,
      body: ListView(
        padding: EdgeInsets.only(top: context.appBarInset),
        children: [
          SettingSection(
            top: 16,
            title: l10n.core,
            items: [
              DetailRow(
                title: 'mihomo',
                value: Text(_versionText ?? '-'),
                copyText: _versionText,
              ),
              DetailRow.text(title: 'ReClash', value: appVersion),
              DetailRow(title: l10n.status, value: Text(statusText)),
            ],
          ),
          SettingSection(
            title: l10n.traffic,
            actions: [
              IconButton(
                tooltip: l10n.reset,
                onPressed: _resetTraffic,
                icon: const GlyphIcon(AppGlyphs.reset),
              ),
            ],
            items: [
              DetailRow(
                title: l10n.upload,
                value: Text(total.up.traffic.show),
              ),
              DetailRow(
                title: l10n.download,
                value: Text(total.down.traffic.show),
              ),
            ],
          ),
          SettingSection(
            title: l10n.appliedConfig,
            actions: [
              IconButton(
                tooltip: l10n.copy,
                onPressed: _configText == null ? null : _copyConfig,
                icon: const GlyphIcon(AppGlyphs.copy),
              ),
            ],
            items: [_buildConfigCard(context)],
          ),
          const SettingBottomInset(),
        ],
      ),
    );
  }

  Widget _buildConfigCard(BuildContext context) {
    final l10n = context.appLocalizations;
    final text = _configText;
    final Widget child;
    if (_configLoading) {
      child = const Center(child: CircularProgressIndicator());
    } else if (text == null) {
      child = Text(
        l10n.coreStopped,
        style: context.textTheme.bodyMedium?.copyWith(
          color: context.colorScheme.onSurfaceVariant,
        ),
      );
    } else {
      child = ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 360),
        child: SingleChildScrollView(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SelectableText(
              text,
              style: context.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      );
    }
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: CommonCard(
        type: CommonCardType.filled,
        radius: AppCorner.xl,
        child: Padding(padding: AppInsets.lg, child: child),
      ),
    );
  }
}
