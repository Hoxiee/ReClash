import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/providers/app.dart';
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
                      DetailRow(
                        title: action.label,
                        value: Text(
                          action.desktopCommand(id),
                          style: codeStyle,
                        ),
                        copyText: action.desktopCommand(id),
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
                        onPressed: format.includeDirective(directory) == null
                            ? null
                            : () => unawaited(
                                _copy(
                                  context,
                                  format.includeDirective(directory)!,
                                ),
                              ),
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
