import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/providers/app.dart';
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
      icon: const GlyphIcon(AppGlyphs.copy, size: 20),
    ).withAppTooltip();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = context.appLocalizations;
    final platform = ref.watch(hotKeyPlatformProvider);
    final id = platform.applicationId;
    final directory = platform.exportDirectory;
    return BaseScaffold(
      title: localizations.hotkeyDesktopCommands,
      body: SettingsListView(
        children: [
          Padding(
            padding: AppInsets.lg,
            child: Text(localizations.hotkeyDesktopCommandsDesc),
          ),
          if (id != null)
            SettingSection(
              items: [
                for (final action in HotAction.values)
                  DecorationListItem(
                    title: Text(action.label),
                    subtitle: Text(
                      action.desktopCommand(id),
                      style: context.textTheme.bodySmall?.toJetBrainsMono,
                    ),
                    trailing: _copyButton(context, action.desktopCommand(id)),
                  ),
              ],
            ),
          Padding(
            padding: AppInsets.lg,
            child: Text(
              directory == null
                  ? localizations.hotkeyExportUnavailable
                  : localizations.hotkeyCompositorConfigDesc,
            ),
          ),
          if (directory != null)
            SettingSection(
              title: localizations.hotkeyCompositorConfig,
              items: [
                for (final format in HotkeyExportFormat.values)
                  DecorationListItem(
                    title: Text(format.label),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: AppSpacing.xs,
                      children: [
                        Text(
                          format.includeDirective(directory) ??
                              '$directory/${format.fileName}',
                          style: context.textTheme.bodySmall?.toJetBrainsMono,
                        ),
                        if (platform.exports[format]?.unsupported.isNotEmpty ==
                            true)
                          Text(
                            localizations.hotkeyExportSkipped(
                              platform.exports[format]!.unsupported
                                  .map((action) => action.label)
                                  .join(', '),
                            ),
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colorScheme.error,
                            ),
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
          const SettingBottomInset(),
        ],
      ),
    );
  }
}
