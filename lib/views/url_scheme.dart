import 'package:reclash/common/common.dart';
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

const List<_SchemeCommand> _commands = [
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
  _SchemeCommand(
    link: 'reclash://toggle',
    title: _toggle,
    desc: _toggleDesc,
  ),
  _SchemeCommand(
    link: 'reclash://open',
    title: _open,
    desc: _openDesc,
  ),
  _SchemeCommand(
    link: 'reclash://close',
    title: _close,
    desc: _closeDesc,
  ),
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
        children: [
          SettingSection(
            title: appLocalizations.urlSchemeCommands,
            subTitle: appLocalizations.urlSchemeCommandsDesc,
            items: [
              for (final command in _commands)
                _CommandItem(
                  command: command,
                  onCopy: (value) => _copy(context, value),
                ),
            ],
          ),
          SettingSection(
            title: appLocalizations.urlSchemeInstallConfig,
            items: [
              _CommandItem(
                command: _SchemeCommand(
                  link: 'reclash://install-config?url=<encoded url>&name=<encoded name>',
                  title: (l) => l.urlScheme,
                  desc: (l) => l.urlSchemeInstallConfigDesc,
                ),
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
      title: Text(
        command.link,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: context.textTheme.bodyMedium?.toJetBrainsMono,
      ),
      subtitle: Text(command.desc(appLocalizations)),
      trailing: IconButton(
        tooltip: appLocalizations.copy,
        icon: const Icon(Icons.copy_rounded, size: 20),
        onPressed: () => onCopy(command.link),
      ),
    );
  }
}
