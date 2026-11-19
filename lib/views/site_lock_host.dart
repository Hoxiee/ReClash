import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/core/desktop/helper_client.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/widgets/widgets.dart';

/// What the Helper's firewall holds right now; nothing while it is unreachable.
class SiteLockHostGroup extends ConsumerWidget {
  const SiteLockHostGroup({super.key});

  String? _problem(AppLocalizations l, String? problem) => switch (problem) {
    null => null,
    'nftMissing' => l.siteLockHostNftMissing,
    'queueStopped' => l.siteLockHostQueueStopped,
    _ => l.siteLockHostRefused,
  };

  Widget _value(BuildContext context, String text) => Text(
    text,
    style: AppTextStyle.body
        .of(context)
        .copyWith(color: context.colorScheme.onSurfaceVariant),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = ref.watch(siteLockHostInfoProvider).value;
    if (info == null) return const SizedBox.shrink();
    final l = context.appLocalizations;
    final problem = _problem(l, info.problem);
    final wfp = info.layer == 'wfp';
    return generateSection(
      title: l.siteLockHostTitle,
      actions: [
        IconButtonData(
          glyph: AppGlyphs.refresh,
          tooltip: l.retry,
          onPressed: () => ref.invalidate(siteLockHostInfoProvider),
        ),
      ],
      items: [
        ListItem(
          title: Text(l.siteLockHostMechanism),
          trailing: _value(
            context,
            wfp ? 'Windows Filtering Platform' : 'nftables',
          ),
        ),
        ListItem(
          title: Text(l.siteLockHostStatus),
          subtitle: problem == null
              ? null
              : Text(
                  problem,
                  style: TextStyle(color: context.colorScheme.error),
                ),
          trailing: problem == null
              ? _value(
                  context,
                  info.active ? l.siteLockHostActive : l.siteLockHostIdle,
                )
              : null,
        ),
        ListItem(
          title: Text(l.siteLockHostAddresses),
          trailing: _value(context, '${info.addresses}'),
        ),
        ListItem(
          title: Text(l.siteLockHostNames),
          subtitle: Text(
            info.dnsFilter ? l.siteLockHostFilterOn : l.siteLockHostFilterOff,
          ),
          trailing: _value(context, '${info.names}'),
        ),
        ListItem(
          title: Text(l.siteLockHostFake),
          trailing: _value(context, '${info.fake}'),
        ),
        if (info.ruleset != null)
          ListItem.open(
            title: Text(l.siteLockHostShowRules),
            widget: _RulesSheet(info: info),
            preferSheet: true,
          ),
      ],
      footer: l.siteLockHostFooter,
    );
  }
}

class _RulesSheet extends StatelessWidget {
  const _RulesSheet({required this.info});

  final HelperSiteLock info;

  Future<void> _copy(BuildContext context, String text) async {
    final copied = context.appLocalizations.copySuccess;
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) context.showNotifier(copied);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final ruleset = (info.ruleset ?? '').trim();
    final table = info.table;
    final mono = AppTextStyle.footnote.of(context).toJetBrainsMono;
    return CommonScaffold(
      title: l.siteLockHostRulesTitle,
      actions: [
        AppBarActionButton(
          data: IconButtonData(
            glyph: AppGlyphs.copy,
            tooltip: l.copy,
            onPressed: ruleset.isEmpty ? null : () => _copy(context, ruleset),
          ),
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(
          top: context.contentTopPadding,
          bottom: 20 + context.bottomInset,
        ),
        children: [
          if (table != null && !(info.layer == 'wfp')) ...[
            Text(
              l.siteLockHostInspect,
              style: AppTextStyle.body
                  .of(context)
                  .copyWith(color: context.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            SelectableText('sudo nft list table $table', style: mono),
            const SizedBox(height: 16),
          ],
          SelectableText(
            ruleset.isEmpty ? l.siteLockHostRulesEmpty : ruleset,
            style: ruleset.isEmpty ? null : mono,
          ),
        ],
      ),
    );
  }
}
