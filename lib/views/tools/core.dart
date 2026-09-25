import 'package:dynamic_color/dynamic_color.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      CoreStatus.connected => Colors.green.harmonizeWith(
        context.colorScheme.primary,
      ),
      CoreStatus.connecting => context.colorScheme.primary,
      CoreStatus.disconnected => context.colorScheme.onSurfaceVariant,
    };
    return SettingSection(
      title: l10n.core,
      items: [
        DecorationListItem(
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
        ),
      ],
    );
  }
}
