import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/core/desktop/model.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/pages/editor.dart';
import 'package:reclash/widgets/widgets.dart';

class CoreSection extends ConsumerStatefulWidget {
  const CoreSection({super.key, required this.onOpen});

  final VoidCallback onOpen;

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
        setState(() {
          _version = _readVersion();
        });
      }
    }, fireImmediately: true);
  }

  Future<String?> _readVersion() async {
    try {
      final info = await ref
          .read(coreHandlerProvider)
          .getCoreInfo()
          .timeout(const Duration(seconds: 2));
      return RegExp(
            r'^v?(\d+\.\d+\.\d+)',
          ).firstMatch(info?.version ?? '')?.group(1) ??
          info?.version;
    } catch (_) {
      return null;
    }
  }

  Future<void> _restart() async {
    final status = ref.read(coreStatusProvider);
    if (_restartPending || status == CoreStatus.connecting) return;
    setState(() => _restartPending = true);
    try {
      final l10n = context.appLocalizations;
      final confirmed = await dialogs.showMessage(
        context: context,
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
      await ref
          .read(coreActionProvider.notifier)
          .restartCore(allowPrompt: true);
    } catch (error) {
      if (mounted) {
        context.showNotifier(
          userFacingErrorMessage(error, context.appLocalizations),
          level: MessageLevel.error,
        );
      }
    } finally {
      if (mounted) setState(() => _restartPending = false);
    }
  }

  String _statusText(CoreStatus status) => switch (status) {
    CoreStatus.connected => context.appLocalizations.coreRunning,
    CoreStatus.connecting => context.appLocalizations.coreStarting,
    CoreStatus.disconnected => context.appLocalizations.coreStopped,
  };

  Color _statusColor(CoreStatus status) => switch (status) {
    CoreStatus.connected => context.colorScheme.success,
    CoreStatus.connecting => context.colorScheme.primary,
    CoreStatus.disconnected => context.colorScheme.onSurfaceVariant,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.appLocalizations;
    final status = ref.watch(coreStatusProvider);
    final color = _statusColor(status);
    return DecorationListItem(
      leading: const GlyphIcon(AppGlyphs.memory),
      title: FutureBuilder<String?>(
        future: _version,
        builder: (_, snapshot) =>
            Text(snapshot.data == null ? 'mihomo' : 'mihomo ${snapshot.data}'),
      ),
      subtitle: Row(
        spacing: 6,
        children: [
          GlyphIcon(
            switch (status) {
              CoreStatus.connected => AppGlyphs.checkCircle,
              CoreStatus.connecting => AppGlyphs.sync,
              CoreStatus.disconnected => AppGlyphs.close,
            },
            size: 16,
            color: color,
          ),
          Flexible(child: Text(_statusText(status))),
        ],
      ),
      trailing: system.isDesktop
          ? IconButton.outlined(
              tooltip: l10n.restart,
              onPressed: _restartPending || status == CoreStatus.connecting
                  ? null
                  : _restart,
              icon: const GlyphIcon(AppGlyphs.reset),
            ).withAppTooltip()
          : null,
      onPressed: widget.onOpen,
    );
  }
}

class CoreDetailView extends ConsumerStatefulWidget {
  const CoreDetailView({super.key});

  @override
  ConsumerState<CoreDetailView> createState() => _CoreDetailViewState();
}

class _CoreDetailViewState extends ConsumerState<CoreDetailView> {
  CoreInfo? _info;
  bool _loading = false;
  bool _failed = false;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    ref.listenManual(coreStatusProvider, (previous, next) {
      if (previous != next) unawaited(_refresh());
    }, fireImmediately: true);
  }

  Future<void> _refresh() async {
    final generation = ++_generation;
    final connected = ref.read(coreStatusProvider) == CoreStatus.connected;
    setState(() {
      _info = null;
      _loading = connected;
      _failed = false;
    });
    if (!connected) return;
    try {
      final info = await ref
          .read(coreHandlerProvider)
          .getCoreInfo()
          .timeout(const Duration(seconds: 3));
      if (!mounted || generation != _generation) return;
      setState(() {
        _info = info;
        _failed = info == null || info.workingDirectory.isEmpty;
      });
    } catch (_) {
      if (!mounted || generation != _generation) return;
      setState(() => _failed = true);
    } finally {
      if (mounted && generation == _generation) {
        setState(() => _loading = false);
      }
    }
  }

  String _statusText(CoreStatus status) => switch (status) {
    CoreStatus.connected => context.appLocalizations.coreRunning,
    CoreStatus.connecting => context.appLocalizations.coreStarting,
    CoreStatus.disconnected => context.appLocalizations.coreStopped,
  };

  String _valueOrUnknown(String value) =>
      value.isEmpty ? context.appLocalizations.unknown : value;

  Widget _field(String title, String value) => DetailRow(
    title: title,
    value: Text(
      _valueOrUnknown(value),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    ),
    copyText: value.isEmpty ? null : value,
  );

  List<Widget> _identityRows(CoreInfo info) {
    final locale = Localizations.localeOf(context).toString();
    final formatter = DateFormat.localeExists(locale)
        ? DateFormat.yMd(locale).add_Hms()
        : DateFormat('yyyy-MM-dd HH:mm:ss', 'en');
    final buildTime = info.buildTime?.toUtc();
    return [
      DetailRow.text(title: 'mihomo', value: _valueOrUnknown(info.version)),
      DetailRow(
        title: context.appLocalizations.coreBuildTime,
        value: Text(
          buildTime == null
              ? context.appLocalizations.unknown
              : '${formatter.format(buildTime)} UTC',
        ),
        copyText: buildTime?.toIso8601String(),
      ),
    ];
  }

  String _launchMode(CoreInfo info) {
    final l10n = context.appLocalizations;
    if (info.platform == 'android') return l10n.coreModeLibrary;
    return switch (ref.read(coreHandlerProvider).processOwner) {
      CoreProcessOwner.direct => l10n.coreModeProcess,
      CoreProcessOwner.helper => l10n.coreModeHelper,
      CoreProcessOwner.windowsElevated => l10n.coreModeElevated,
      CoreProcessOwner.macosHelper => l10n.coreModePrivilegedHelper,
      null => l10n.unknown,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.appLocalizations;
    final status = ref.watch(coreStatusProvider);
    final info = _info;
    return CommonScaffold(
      title: l10n.core,
      body: Builder(
        builder: (context) => ListView(
          padding: EdgeInsets.only(
            left: 16,
            top: context.appBarInset,
            right: 16,
            bottom: BottomInsetScope.of(context),
          ),
          children: [
            generateSection(
              items: [
                DetailRow(title: l10n.status, value: Text(_statusText(status))),
                if (_loading)
                  DecorationListItem(
                    leading: const CommonCircleLoading(),
                    title: Text(l10n.loading),
                  ),
                if (_failed)
                  DecorationListItem(
                    title: Text(l10n.coreInfoUnavailable),
                    trailing: IconButton(
                      tooltip: l10n.retry,
                      onPressed: _refresh,
                      icon: const GlyphIcon(AppGlyphs.refresh),
                    ).withAppTooltip(),
                  ),
                if (info != null) ..._identityRows(info),
              ],
            ),
            if (info != null)
              generateSection(
                title: l10n.coreEnvironment,
                items: [
                  _field('Go', info.goVersion),
                  _field(l10n.corePlatform, info.platform),
                  _field(l10n.coreArchitecture, info.architecture),
                  _field(
                    l10n.coreBuildTags,
                    info.tags.isEmpty ? l10n.none : info.tags.join(', '),
                  ),
                  _field(l10n.coreLaunchMode, _launchMode(info)),
                ],
              ),
            if (info != null)
              generateSection(
                title: l10n.coreLocation,
                items: [
                  _field(l10n.coreWorkingDirectory, info.workingDirectory),
                  if (info.platform != 'android')
                    _field(l10n.coreExecutable, info.executablePath),
                ],
              ),
            const SizedBox(height: 16),
            generateSection(
              items: [
                DecorationListItem(
                  leading: const GlyphIcon(AppGlyphs.code),
                  title: Text(l10n.coreOpenRuntimeConfig),
                  subtitle: Text(l10n.coreRuntimeConfigDescription),
                  trailing: const GlyphIcon(AppGlyphs.chevronForward),
                  onPressed: () => PageNavigationScope.of(
                    context,
                  )?.open(const CoreRuntimeConfigView()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CoreRuntimeConfigView extends ConsumerStatefulWidget {
  const CoreRuntimeConfigView({super.key});

  @override
  ConsumerState<CoreRuntimeConfigView> createState() =>
      _CoreRuntimeConfigViewState();
}

class _CoreRuntimeConfigViewState extends ConsumerState<CoreRuntimeConfigView> {
  String? _content;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    if (_failed) setState(() => _failed = false);
    try {
      final content = await ref
          .read(coreHandlerProvider)
          .getAppliedConfigContent();
      if (!mounted) return;
      setState(() => _content = content);
    } catch (_) {
      if (!mounted) return;
      setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.appLocalizations;
    if (_failed) {
      return CommonScaffold(
        title: l10n.coreRuntimeConfig,
        body: Center(
          child: NullStatus(
            label: l10n.coreRuntimeConfigReadFailed,
            illustration: NullStatusIllustration.error,
            action: FilledButton.icon(
              onPressed: _load,
              icon: const GlyphIcon(AppGlyphs.refresh),
              label: Text(l10n.retry),
            ),
          ),
        ),
      );
    }
    return EditorPage(
      title: l10n.coreRuntimeConfig,
      content: _content,
      readOnly: true,
    );
  }
}
