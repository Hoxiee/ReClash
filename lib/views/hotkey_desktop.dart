import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/widgets/settings/setting_target.dart';
import 'package:reclash/widgets/widgets.dart';

class HotkeyDesktopView extends ConsumerWidget {
  const HotkeyDesktopView({super.key});

  Future<void> _copy(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      context.showNotifier(
        context.appLocalizations.copySuccess,
        level: MessageLevel.success,
      );
    }
  }

  Widget _copyButton(BuildContext context, String? text) {
    return IconButton.filledTonal(
      tooltip: context.appLocalizations.copy,
      onPressed: text == null ? null : () => _copy(context, text),
      icon: const GlyphIcon(AppGlyphs.copy, fill: 1, size: 20),
    ).withAppTooltip();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = context.appLocalizations;
    final platform = ref.watch(hotKeyPlatformProvider);
    final id = platform.applicationId;
    final directory = platform.exportDirectory;
    final codeStyle = AppTextStyle.caption1.of(context).toJetBrainsMono;
    return BaseScaffold(
      title: localizations.hotkeyDesktopCommands,
      body: SettingsPageScroll(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ).copyWith(top: context.contentTopPadding, bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(localizations.hotkeyDesktopCommandsDesc),
              if (id != null)
                generateSection(
                  title: localizations.hotkeyDesktopCommands,
                  items: [
                    for (final action in HotAction.values)
                      DecorationListItem(
                        title: Text(action.label),
                        subtitle: Text(
                          action.desktopCommand(id),
                          style: codeStyle,
                        ),
                        trailing: _copyButton(
                          context,
                          action.desktopCommand(id),
                        ),
                      ),
                  ],
                ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  directory == null
                      ? localizations.hotkeyExportUnavailable
                      : localizations.hotkeyCompositorConfigDesc,
                ),
              ),
              if (directory != null)
                generateSection(
                  title: localizations.hotkeyCompositorConfig,
                  items: [
                    for (final format in HotkeyExportFormat.values)
                      DecorationListItem(
                        title: Text(format.label),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 4,
                          children: [
                            Text(
                              format.includeDirective(directory) ??
                                  '$directory/${format.fileName}',
                              style: codeStyle,
                            ),
                            if (platform
                                    .exports[format]
                                    ?.unsupported
                                    .isNotEmpty ==
                                true)
                              Text(
                                localizations.hotkeyExportSkipped(
                                  platform.exports[format]!.unsupported
                                      .map((action) => action.label)
                                      .join(', '),
                                ),
                                style: AppTextStyle.footnote
                                    .of(context)
                                    .copyWith(color: context.colorScheme.error),
                              ),
                          ],
                        ),
                        trailing: _copyButton(
                          context,
                          format.includeDirective(directory),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
