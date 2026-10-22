import 'package:reclash/common/url_scheme.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/ui/icons/icons.dart';

String urlSchemeCommandLabel(ReClashCommand command, AppLocalizations l) =>
    switch (command) {
      ReClashCommand.connect => l.urlSchemeConnect,
      ReClashCommand.disconnect => l.urlSchemeDisconnect,
      ReClashCommand.toggle => l.urlSchemeToggle,
      ReClashCommand.open => l.urlSchemeOpen,
      ReClashCommand.close => l.urlSchemeClose,
      ReClashCommand.add => l.urlSchemeAdd,
      ReClashCommand.importProfile => l.urlSchemeImport,
      ReClashCommand.installConfig => l.urlSchemeInstallConfig,
      ReClashCommand.routing => l.rcxImportTitle,
    };

String urlSchemeCommandDescription(
  ReClashCommand command,
  AppLocalizations l,
) => switch (command) {
  ReClashCommand.connect => l.urlSchemeConnectDesc,
  ReClashCommand.disconnect => l.urlSchemeDisconnectDesc,
  ReClashCommand.toggle => l.urlSchemeToggleDesc,
  ReClashCommand.open => l.urlSchemeOpenDesc,
  ReClashCommand.close => l.urlSchemeCloseDesc,
  ReClashCommand.add => l.urlSchemeAddDesc,
  ReClashCommand.importProfile => l.urlSchemeImportDesc,
  ReClashCommand.installConfig => l.urlSchemeInstallConfigDesc,
  ReClashCommand.routing => l.rcxImportTitle,
};

Glyph urlSchemeCommandGlyph(ReClashCommand command) => switch (command) {
  ReClashCommand.connect => AppGlyphs.vpn,
  ReClashCommand.disconnect => AppGlyphs.close,
  ReClashCommand.toggle => AppGlyphs.toggle,
  ReClashCommand.open => AppGlyphs.eye,
  ReClashCommand.close => AppGlyphs.eyeOff,
  ReClashCommand.add => AppGlyphs.cloudDownload,
  ReClashCommand.importProfile => AppGlyphs.importFile,
  ReClashCommand.installConfig => AppGlyphs.link,
  ReClashCommand.routing => AppGlyphs.shuffle,
};
