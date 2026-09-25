import 'package:reclash/common/common.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

class _SchemeCommand {
  const _SchemeCommand({
    required this.link,
    required this.title,
    required this.desc,
  });

  final String link;

  final String Function(AppLocalizations appLocalizations) title;

  final String Function(AppLocalizations appLocalizations) desc;
}

const List<_SchemeCommand> _tunnelCommands = [
  _SchemeCommand(
    link: 'reclash://connect',
    title: _connect,
    desc: _connectDesc,
  ),
  _SchemeCommand(
    link: 'reclash://disconnect',
    title: _disconnect,
    desc: _disconnectDesc,
  ),
  _SchemeCommand(link: 'reclash://toggle', title: _toggle, desc: _toggleDesc),
];

const List<_SchemeCommand> _windowCommands = [
  _SchemeCommand(link: 'reclash://open', title: _open, desc: _openDesc),
  _SchemeCommand(link: 'reclash://close', title: _close, desc: _closeDesc),
];

const List<_SchemeCommand> _profileCommands = [
  _SchemeCommand(
    link: 'reclash://import/<base64 config>',
    title: _import,
    desc: _importDesc,
  ),
  _SchemeCommand(
    link: 'reclash://add/<subscription url>',
    title: _add,
    desc: _addDesc,
  ),
  _SchemeCommand(
    link: 'reclash://install-config?url=<encoded url>&name=<encoded name>',
    title: _installConfig,
    desc: _installConfigDesc,
  ),
];

String _connect(AppLocalizations l) => l.urlSchemeConnect;
String _connectDesc(AppLocalizations l) => l.urlSchemeConnectDesc;
String _disconnect(AppLocalizations l) => l.urlSchemeDisconnect;
String _disconnectDesc(AppLocalizations l) => l.urlSchemeDisconnectDesc;
String _toggle(AppLocalizations l) => l.urlSchemeToggle;
String _toggleDesc(AppLocalizations l) => l.urlSchemeToggleDesc;
String _open(AppLocalizations l) => l.urlSchemeOpen;
String _openDesc(AppLocalizations l) => l.urlSchemeOpenDesc;
String _close(AppLocalizations l) => l.urlSchemeClose;
String _closeDesc(AppLocalizations l) => l.urlSchemeCloseDesc;
String _import(AppLocalizations l) => l.urlSchemeImport;
String _importDesc(AppLocalizations l) => l.urlSchemeImportDesc;
String _add(AppLocalizations l) => l.urlSchemeAdd;
String _addDesc(AppLocalizations l) => l.urlSchemeAddDesc;
String _installConfig(AppLocalizations l) => l.urlSchemeInstallConfig;
String _installConfigDesc(AppLocalizations l) => l.urlSchemeInstallConfigDesc;

class UrlSchemeView extends StatelessWidget {
  const UrlSchemeView({super.key});

  Future<void> _copy(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      context.showNotifier(
        context.appLocalizations.copySuccess,
        level: MessageLevel.success,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return BaseScaffold(
      title: appLocalizations.urlScheme,
      body: ListView(
        padding: EdgeInsets.only(top: context.appBarInset),
        children: [
          SettingSection(
            top: 16,
            items: [
              for (final command in _tunnelCommands)
                _CommandItem(
                  command: command,
                  onCopy: (value) => _copy(context, value),
                ),
            ],
          ),
          SettingSection(
            title: appLocalizations.application,
            items: [
              for (final command in _windowCommands)
                _CommandItem(
                  command: command,
                  onCopy: (value) => _copy(context, value),
                ),
            ],
          ),
          SettingSection(
            title: appLocalizations.urlSchemeProfiles,
            items: [
              for (final command in _profileCommands)
                _CommandItem(
                  command: command,
                  onCopy: (value) => _copy(context, value),
                ),
            ],
          ),
          const SettingBottomInset(),
        ],
      ),
    );
  }
}

class _CommandItem extends StatelessWidget {
  const _CommandItem({required this.command, required this.onCopy});

  final _SchemeCommand command;
  final ValueChanged<String> onCopy;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return DecorationListItem(
      minVerticalPadding: 10,
      title: Text(command.title(appLocalizations)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          Text(command.desc(appLocalizations)),
          Text(
            command.link,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodySmall?.toJetBrainsMono.copyWith(
              color: context.colorScheme.primary,
            ),
          ),
        ],
      ),
      trailing: IconButton.filledTonal(
        tooltip: appLocalizations.copy,
        icon: const GlyphIcon(AppGlyphs.copy, size: 20),
        onPressed: () => onCopy(command.link),
      ),
    );
  }
}
