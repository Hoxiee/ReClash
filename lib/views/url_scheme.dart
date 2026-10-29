import 'dart:async';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/features/url_scheme/form.dart';
import 'package:reclash/features/url_scheme/inspect.dart';
import 'package:reclash/widgets/url_scheme_supported_links.dart';
import 'package:reclash/ui/code_label.dart';
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
              section(l.urlSchemeConnection, const [
                ReClashCommand.connect,
                ReClashCommand.disconnect,
                ReClashCommand.toggle,
              ]),
              section(l.app, const [
                ReClashCommand.open,
                ReClashCommand.close,
                ReClashCommand.doctor,
              ], footer: l.urlSchemeConfirmationTip),
              section(l.urlSchemeProfiles, const [
                ReClashCommand.add,
                ReClashCommand.importProfile,
                ReClashCommand.installConfig,
              ]),
              generateSection(
                title: l.urlSchemeSupportedLinks,
                items: [
                  UrlSchemeSupportedLinksRow(
                    glyph: AppGlyphs.link,
                    title: 'Clash, ClashMeta, ReClash',
                    formats: [
                      for (final scheme in configProtocolSchemes)
                        '$scheme://install-config?url={url}',
                    ],
                  ),
                  const UrlSchemeSupportedLinksRow(
                    glyph: AppGlyphs.lock,
                    title: 'INCY',
                    formats: [
                      'incy://add/{url-or-base64}',
                      'incy://import/{url-or-base64}',
                      'incy://crypt1/{encrypted}',
                    ],
                  ),
                  const UrlSchemeSupportedLinksRow(
                    glyph: AppGlyphs.link,
                    title: 'Happ',
                    formats: ['happ://add/{url-or-base64}'],
                  ),
                  UrlSchemeSupportedLinksRow(
                    glyph: AppGlyphs.shuffle,
                    title: l.rcxTitle,
                    formats: const [
                      'reclash://routing?p={data}',
                      'reclash://routing?url={url}',
                    ],
                  ),
                  UrlSchemeSupportedLinksRow(
                    glyph: AppGlyphs.vpn,
                    title: l.urlSchemeProxyLinks,
                    formats: [
                      for (final scheme in shareProtocolSchemes)
                        '$scheme://{data}',
                    ],
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
    final row = DecorationListItem(
      leading: GlyphIcon(urlSchemeCommandGlyph(command)),
      title: LayoutBuilder(
        builder: (context, constraints) {
          final title = Text(urlSchemeCommandLabel(command, l));
          final scale = MediaQuery.textScalerOf(context).scale(1);
          final wide = constraints.maxWidth >= 420 * scale;
          final link = CodeLabel(
            'reclash://${command.host}',
            maxLines: wide ? 1 : null,
          );
          return wide
              ? Row(
                  spacing: 16,
                  children: [
                    Expanded(child: title),
                    link,
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 6,
                  children: [title, link],
                );
        },
      ),
      onPressed: command.isProfile
          ? () => _buildLink(context, command)
          : () => unawaited(_copy(context, 'reclash://${command.host}')),
      trailing: command.isProfile
          ? const DisclosureIndicator()
          : const GlyphIcon(AppGlyphs.copy),
    );
    return command.isProfile ? row : Tooltip(message: l.copy, child: row);
  }
}
