import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/common/update.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/features/form/form.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/ui/icons/icons.dart';

class UpdatePreferences extends ConsumerStatefulWidget {
  const UpdatePreferences({
    super.key,
    required this.isAndroid,
    required this.onSaved,
    required this.onCanSaveChanged,
  });

  final bool isAndroid;
  final VoidCallback onSaved;
  final ValueChanged<bool> onCanSaveChanged;

  @override
  UpdatePreferencesState createState() => UpdatePreferencesState();
}

class UpdatePreferencesState extends ConsumerState<UpdatePreferences> {
  late bool _check;
  late bool _download;
  late bool _install;
  late UpdateChannel _channel;
  bool _consent = false;
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

  void _setAutomatic(bool enabled) {
    if (enabled) {
      setState(() => _consent = true);
      widget.onCanSaveChanged(false);
    } else {
      setState(() {
        _install = false;
        _consent = false;
      });
      widget.onCanSaveChanged(true);
    }
  }

  Future<void> save() async {
    if (_saving || _consent) return;
    setState(() {
      _saving = true;
      _failed = false;
    });
    widget.onCanSaveChanged(false);
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
      if (mounted) widget.onSaved();
    } catch (error) {
      commonPrint.log('update preferences save failed: ${compactError(error)}');
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) {
        setState(() => _saving = false);
        widget.onCanSaveChanged(!_consent);
      }
    }
  }

  Widget _toggle(String title, bool value, ValueChanged<bool>? onChanged) =>
      FormRow(
        title: title,
        onPressed: onChanged == null || _saving
            ? null
            : () => onChanged(!value),
        trailing: Switch(value: value, onChanged: _saving ? null : onChanged),
      );

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        Text(
          l.updatePreferencesIntro,
          style: AppTextStyle.title1.of(context, emphasized: true),
        ),
        Text(
          l.updatePreferencesDescription,
          style: AppTextStyle.footnote
              .of(context)
              .copyWith(color: context.colorScheme.onSurfaceVariant),
        ),
        generateSection(
          items: [
            _toggle(
              l.updateCheckAutomatically,
              _check,
              (value) => setState(() => _check = value),
            ),
          ],
          footer: l.updateCheckQuietly,
        ),
        if (widget.isAndroid) ...[
          generateSection(
            items: [
              _toggle(
                l.updatePreload,
                _download,
                (value) => setState(() => _download = value),
              ),
            ],
            footer: l.updatePreloadDescription,
          ),
          generateSection(
            items: [_toggle(l.updateAutoInstall, _install, _setAutomatic)],
            footer: l.updateAutoInstallDescription,
          ),
          if (_consent)
            CommonCard(
              key: const ValueKey('update-auto-consent'),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 12,
                children: [
                  Text(
                    l.updateAutoConsentTitle,
                    style: AppTextStyle.headline.of(context),
                  ),
                  Text(
                    l.updateAutoConsentDescription,
                    style: AppTextStyle.footnote.of(context),
                  ),
                  FilledButton(
                    key: const ValueKey('update-auto-allow'),
                    onPressed: () {
                      setState(() {
                        _install = true;
                        _consent = false;
                      });
                      widget.onCanSaveChanged(true);
                    },
                    child: Text(l.updateAllowAutomatic),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() => _consent = false);
                      widget.onCanSaveChanged(true);
                    },
                    child: Text(l.updateDoNotEnable),
                  ),
                ],
              ),
            ),
        ],
        generateSection(
          items: [
            CommonPopupBox(
              targetBuilder: (open) => FormRow(
                title: l.updateChannel,
                onPressed: _saving ? null : open,
                trailing: TextButton(
                  onPressed: _saving ? null : open,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 4,
                    children: [
                      Flexible(
                        child: PopupValueText(
                          _channel == UpdateChannel.release
                              ? l.updateChannelRelease
                              : l.updateChannelPre,
                          alignment: AlignmentDirectional.centerEnd,
                        ),
                      ),
                      const GlyphIcon(AppGlyphs.picker),
                    ],
                  ),
                ),
              ),
              popupBuilder: (_) => CommonPopupMenu(
                items: [
                  for (final channel in UpdateChannel.values)
                    CommonPopupMenuItem(
                      label: channel == UpdateChannel.release
                          ? l.updateChannelRelease
                          : l.updateChannelPre,
                      checked: channel == _channel,
                      onPressed: () {
                        if (mounted && !_saving) {
                          setState(() => _channel = channel);
                        }
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
        Text(
          widget.isAndroid
              ? l.updateAndroidAutoNote
              : l.updateDesktopDescription,
          style: AppTextStyle.footnote
              .of(context)
              .copyWith(color: context.colorScheme.onSurfaceVariant),
        ),
        if (_failed)
          Text(
            l.updatePreferencesSaveFailed,
            style: AppTextStyle.footnote
                .of(context)
                .copyWith(color: context.colorScheme.error),
          ),
      ],
    );
  }
}
