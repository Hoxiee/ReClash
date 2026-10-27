import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/common/update.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/features/form/form.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/ui/ui.dart';

class UpdatePreferences extends ConsumerStatefulWidget {
  const UpdatePreferences({super.key, required this.isAndroid});

  final bool isAndroid;

  @override
  ConsumerState<UpdatePreferences> createState() => _UpdatePreferencesState();
}

class _UpdatePreferencesState extends ConsumerState<UpdatePreferences> {
  late bool _check;
  late bool _download;
  late bool _install;
  late UpdateChannel _channel;
  bool _saving = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    final setting = ref.read(appSettingProvider);
    _check = setting.autoCheckUpdate;
    _download = setting.autoDownloadUpdate;
    _install = setting.autoInstallUpdate;
    _channel = effectiveUpdateChannel(
      configured: setting.updateChannel,
      isPreBuild: globalState.isPre,
    );
  }

  Future<void> _setAutomatic(bool enabled) async {
    if (!enabled) {
      setState(() => _install = false);
      return;
    }
    final l = context.appLocalizations;
    final allowed = await dialogs.showMessage(
      context: sheetNavigatorOf(context).context,
      title: l.updateAutoConsentTitle,
      message: TextSpan(text: l.updateAutoConsentDescription),
      confirmText: l.updateAllowAutomatic,
      cancelText: l.updateDoNotEnable,
    );
    if (allowed == true && mounted) setState(() => _install = true);
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _failed = false;
    });
    try {
      final saved = await ref
          .read(appUpdateActionProvider.notifier)
          .savePreferences(
            check: _check,
            preload: _download,
            install: _install,
            channel: _channel,
          );
      if (!saved) {
        if (mounted) setState(() => _failed = true);
        return;
      }
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      commonPrint.log('update preferences save failed: ${compactError(error)}');
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _toggle(String title, bool value, ValueChanged<bool> onChanged) =>
      ListItem.toggle(
        title: Text(title),
        value: value,
        onChanged: _saving ? null : onChanged,
      );

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    return FormPage(
      title: l.updatePreferencesTitle,
      onSave: () => unawaited(_save()),
      saving: _saving,
      error: _failed ? l.updatePreferencesSaveFailed : null,
      children: [
        generateSection(
          items: [
            _toggle(
              l.updateCheckAutomatically,
              _check,
              (value) => setState(() => _check = value),
            ),
            if (widget.isAndroid) ...[
              _toggle(
                l.updatePreload,
                _download,
                (value) => setState(() => _download = value),
              ),
              _toggle(
                l.updateAutoInstall,
                _install,
                (value) => unawaited(_setAutomatic(value)),
              ),
            ],
          ],
        ),
        generateSection(
          items: [
            IgnorePointer(
              ignoring: _saving,
              child: ListItem<UpdateChannel>.options(
                title: Text(l.updateChannel),
                options: UpdateChannel.values,
                value: _channel,
                textBuilder: (channel) => channel == UpdateChannel.release
                    ? l.updateChannelRelease
                    : l.updateChannelPre,
                onChanged: (channel) {
                  if (mounted && !_saving) setState(() => _channel = channel);
                },
              ),
            ),
          ],
          footer: widget.isAndroid ? null : l.updateDesktopDescription,
        ),
      ],
    );
  }
}
