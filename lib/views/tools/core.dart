import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/core/desktop/model.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/config/editor.dart';
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
    } catch (error) {
      if (!mounted || generation != _generation) return;
      commonPrint.log(
        'read core info error: $error',
        logLevel: LogLevel.warning,
      );
      setState(() => _failed = true);
    } finally {
      if (mounted && generation == _generation) {
        setState(() => _loading = false);
      }
    }
  }

  List<Widget> _infoRows(CoreInfo info) {
    final l10n = context.appLocalizations;
    final launchMode = info.platform == 'android'
        ? l10n.coreModeLibrary
        : switch (ref.read(coreHandlerProvider).processOwner) {
            CoreProcessOwner.direct => l10n.coreModeProcess,
            CoreProcessOwner.helper => l10n.coreModeHelper,
            null => l10n.unknown,
          };
    final buildTime = info.buildTime?.toUtc();
    final locale = Localizations.localeOf(context).toString();
    final dateFormat = DateFormat.localeExists(locale)
        ? DateFormat.yMd(locale).add_Hms()
        : DateFormat('yyyy-MM-dd HH:mm:ss', 'en');
    final buildTimeText = buildTime == null
        ? l10n.unknown
        : '${dateFormat.format(buildTime)} UTC';
    final fields = [
      ('Go', info.goVersion),
      (l10n.corePlatform, info.platform),
      (l10n.coreArchitecture, info.architecture),
      (
        l10n.coreBuildTags,
        info.tags.isEmpty ? l10n.none : info.tags.join(', '),
      ),
      (l10n.coreLaunchMode, launchMode),
      (l10n.coreWorkingDirectory, info.workingDirectory),
      if (info.platform != 'android')
        (l10n.coreExecutable, info.executablePath),
    ];
    return [
      DetailRow.text(title: 'mihomo', value: info.version),
      DetailRow(
        title: l10n.coreBuildTime,
        value: Text(buildTimeText),
        copyText: buildTime?.toIso8601String(),
      ),
      for (final (title, value) in fields)
        DetailRow(
          title: title,
          value: Text(
            value.isEmpty ? l10n.unknown : value,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          copyText: value.isEmpty ? null : value,
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.appLocalizations;
    final status = ref.watch(coreStatusProvider);
    final info = _info;
    final statusText = switch (status) {
      CoreStatus.connected => l10n.coreRunning,
      CoreStatus.connecting => l10n.coreStarting,
      CoreStatus.disconnected => l10n.coreStopped,
    };
    return CommonScaffold(
      title: l10n.core,
      floatBody: true,
      body: ListView(
        padding: EdgeInsets.only(top: context.appBarInset),
        children: [
          SettingSection(
            top: AppSpacing.lg,
            title: l10n.core,
            items: [
              DetailRow(title: l10n.status, value: Text(statusText)),
              if (_loading)
                DecorationListItem(
                  leading: const CommonCircleLoading(),
                  title: Text(l10n.loading),
                ),
              if (_failed)
                DecorationListItem(
                  title: Text(l10n.coreInfoUnavailable),
                  trailing: IconButton(
                    tooltip: l10n.reload,
                    onPressed: _refresh,
                    icon: const GlyphIcon(AppGlyphs.refresh),
                  ),
                ),
              if (info != null) ..._infoRows(info),
            ],
          ),
          SettingSection(
            items: [
              DecorationListItem.open(
                leading: const GlyphIcon(AppGlyphs.code),
                title: Text(l10n.coreOpenRuntimeConfig),
                subtitle: Text(l10n.coreRuntimeConfigDescription),
                widget: const _CoreRuntimeConfigView(),
              ),
            ],
          ),
          const SettingBottomInset(),
        ],
      ),
    );
  }
}

class _CoreRuntimeConfigView extends ConsumerStatefulWidget {
  const _CoreRuntimeConfigView();

  @override
  ConsumerState<_CoreRuntimeConfigView> createState() =>
      _CoreRuntimeConfigViewState();
}

class _CoreRuntimeConfigViewState
    extends ConsumerState<_CoreRuntimeConfigView> {
  String? _content;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_load());
    });
  }

  Future<void> _load() async {
    setState(() => _failed = false);
    await whenRouteSettled(context);
    if (!mounted) return;
    try {
      final content = await ref
          .read(coreHandlerProvider)
          .getAppliedConfigContent();
      if (!mounted) return;
      setState(() => _content = content);
    } catch (error) {
      if (!mounted) return;
      commonPrint.log(
        'read runtime config error: $error',
        logLevel: LogLevel.warning,
      );
      setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.appLocalizations;
    if (_failed) {
      return CommonScaffold(
        title: l10n.coreRuntimeConfig,
        body: NullStatus(
          label: l10n.coreRuntimeConfigReadFailed,
          illustration: NullStatusIllustration.error,
          action: FilledButton.icon(
            onPressed: _load,
            icon: const GlyphIcon(AppGlyphs.refresh),
            label: Text(l10n.reload),
          ),
        ),
      );
    }
    return EditorPage(title: l10n.coreRuntimeConfig, content: _content);
  }
}
