import 'dart:async';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/features/url_scheme/form.dart';
import 'package:reclash/features/url_scheme/inspect.dart';
import 'package:reclash/widgets/url_scheme_labels.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:reclash/widgets/settings/setting_target.dart';

class UrlSchemeView extends StatelessWidget {
  const UrlSchemeView({super.key});

  Future<void> _copy(BuildContext context, String value) async {
    try {
      await Clipboard.setData(ClipboardData(text: value));
      if (context.mounted) {
        context.showNotifier(
          context.appLocalizations.copySuccess,
          level: MessageLevel.success,
        );
      }
    } catch (_) {
      if (context.mounted) {
        context.showNotifier(
          context.appLocalizations.urlSchemeCopyFailed,
          level: MessageLevel.error,
        );
      }
    }
  }

  void _buildLink(BuildContext context, [ReClashCommand? command]) {
    unawaited(
      showFormSheet<void>(
        context: context,
        builder: (_) => UrlSchemeForm(command: command ?? ReClashCommand.add),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    Widget section(
      String title,
      Iterable<ReClashCommand> commands, {
      String? footer,
    }) => generateSection(
      title: title,
      footer: footer,
      items: [for (final command in commands) _commandRow(context, command)],
    );
    return CommonScaffold(
      title: l.urlScheme,
      iconActions: [
        IconButtonData(
          glyph: AppGlyphs.addCircle,
          tooltip: l.urlSchemeBuild,
          onPressed: () => _buildLink(context),
        ),
        IconButtonData(
          glyph: AppGlyphs.search,
          tooltip: l.urlSchemeInspect,
          onPressed: () => unawaited(
            showFormSheet<void>(
              context: context,
              builder: (_) => const UrlSchemeInspector(),
            ),
          ),
        ),
      ],
      body: SettingsPageScroll(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ).copyWith(top: context.contentTopPadding, bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l.urlSchemeIntro, style: AppTextStyle.body.of(context)),
              section(l.urlSchemeConnection, const [
                ReClashCommand.connect,
                ReClashCommand.disconnect,
                ReClashCommand.toggle,
              ], footer: l.urlSchemeConfirmationTip),
              section(l.app, const [ReClashCommand.open, ReClashCommand.close]),
              section(l.urlSchemeProfiles, const [
                ReClashCommand.add,
                ReClashCommand.importProfile,
                ReClashCommand.installConfig,
              ], footer: l.urlSchemeProfileCommandsTip),
              generateSection(
                title: l.urlSchemeSupportedLinks,
                footer: l.urlSchemeSupportedLinksTip,
                items: [
                  const DecorationListItem(
                    leading: GlyphIcon(AppGlyphs.link),
                    title: Text('Clash, ClashMeta, ReClash'),
                    subtitle: Text('install-config'),
                  ),
                  DecorationListItem(
                    leading: const GlyphIcon(AppGlyphs.lock),
                    title: const Text('INCY, Happ'),
                    subtitle: Text(l.urlSchemeWrappedLinks),
                  ),
                  DecorationListItem(
                    leading: const GlyphIcon(AppGlyphs.vpn),
                    title: Text(l.urlSchemeProxyLinks),
                    subtitle: Text(shareProtocolSchemes.join(', ')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _commandRow(BuildContext context, ReClashCommand command) {
    final l = context.appLocalizations;
    return DecorationListItem(
      leading: GlyphIcon(urlSchemeCommandGlyph(command)),
      title: Text(urlSchemeCommandLabel(command, l)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          Text(urlSchemeCommandDescription(command, l)),
          if (!command.isProfile)
            Text(
              'reclash://${command.host}',
              style: AppTextStyle.footnote.of(context).toJetBrainsMono,
            ),
        ],
      ),
      onPressed: command.isProfile ? () => _buildLink(context, command) : null,
      trailing: command.isProfile
          ? const GlyphIcon(AppGlyphs.chevronForward, size: 16)
          : TonalButtonTheme(
              size: TonalButtonSize.section,
              child: ElasticPress(
                child: IconButton(
                  tooltip: l.copy,
                  onPressed: () => _copy(context, 'reclash://${command.host}'),
                  icon: const GlyphIcon(AppGlyphs.copy),
                ).withAppTooltip(),
              ),
            ),
    );
  }
}
