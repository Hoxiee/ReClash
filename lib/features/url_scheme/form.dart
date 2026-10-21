import 'dart:async';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/features/form/form.dart';
import 'package:reclash/subscriptions/external_link.dart';
import 'package:reclash/subscriptions/imports/import.dart';
import 'package:reclash/widgets/url_scheme_labels.dart';
import 'package:reclash/widgets/url_scheme_preview.dart';
import 'package:reclash/widgets/widgets.dart';

class UrlSchemeForm extends StatefulWidget {
  const UrlSchemeForm({super.key, this.command = ReClashCommand.add});

  final ReClashCommand command;

  @override
  State<UrlSchemeForm> createState() => _UrlSchemeFormState();
}

class _UrlSchemeFormState extends State<UrlSchemeForm> {
  final _payloadController = TextEditingController();
  final _nameController = TextEditingController();
  late ReClashCommand _command;
  Timer? _previewTimer;
  int _revision = 0;
  String? _link;
  UrlSchemeIssue? _issue;
  String? _error;
  bool _building = false;
  bool _copying = false;
  bool _attempted = false;

  @override
  void initState() {
    super.initState();
    _command = widget.command;
    if (!_command.isProfile) _link = 'reclash://${_command.host}';
  }

  @override
  void dispose() {
    _revision++;
    _previewTimer?.cancel();
    _payloadController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _schedulePreview() {
    _previewTimer?.cancel();
    final revision = ++_revision;
    if (!_command.isProfile) {
      _link = 'reclash://${_command.host}';
      return;
    }
    if (_payloadController.text.trim().isEmpty) {
      _issue = UrlSchemeIssue.missingPayload;
      _error = context.appLocalizations.urlSchemeMissingPayload;
      return;
    }
    _previewTimer = Timer(const Duration(milliseconds: 180), () {
      unawaited(_buildPreview(revision));
    });
  }

  void _changed(String _) {
    setState(() {
      _link = null;
      _issue = null;
      _error = null;
      _building = false;
      _schedulePreview();
    });
  }

  Future<void> _buildPreview(int revision) async {
    if (!mounted || revision != _revision) return;
    final l = context.appLocalizations;
    final command = _command;
    final payload = command.isProfile ? _payloadController.text : '';
    final name = command.isProfile ? _nameController.text : '';
    setState(() => _building = true);
    try {
      final link = await buildUrlSchemeLink(
        command,
        payload: payload,
        name: name,
      );
      if (command == ReClashCommand.importProfile) {
        final parsed = await prepareSubscriptionImport(
          (await resolveProfileLink(link)).bytes!,
        );
        if (parsed.summary.rejectCoreFallback ||
            parsed.format == SubscriptionFormat.unknown) {
          throw MessageException(l.importConfigInvalid);
        }
      }
      if (mounted && revision == _revision) setState(() => _link = link);
    } catch (error) {
      if (mounted && revision == _revision) {
        setState(() {
          _link = null;
          _issue = error is UrlSchemeException ? error.issue : null;
          _error = userFacingErrorMessage(error, context.appLocalizations);
        });
      }
    } finally {
      if (mounted && revision == _revision) setState(() => _building = false);
    }
  }

  Future<void> _copy({bool close = false}) async {
    if (_copying || _building) return;
    final revision = _revision;
    _previewTimer?.cancel();
    setState(() {
      _attempted = true;
      _copying = true;
    });
    try {
      if (_link == null) await _buildPreview(revision);
      if (!mounted || revision != _revision) return;
      final link = _link;
      if (link == null) return;
      await Clipboard.setData(ClipboardData(text: link));
      if (mounted && revision == _revision) {
        context.showNotifier(
          context.appLocalizations.copySuccess,
          level: MessageLevel.success,
        );
        if (close) Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted && revision == _revision) {
        setState(() => _error = context.appLocalizations.urlSchemeCopyFailed);
      }
    } finally {
      if (mounted) setState(() => _copying = false);
    }
  }

  void _example() {
    _payloadController.text = _command == ReClashCommand.importProfile
        ? 'proxies: []\nproxy-groups: []\nrules:\n  - MATCH,DIRECT\n'
        : 'https://example.com/subscription?token=example';
    _nameController.text = context.appLocalizations.urlSchemeExampleProfile;
    _changed('');
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final error =
        _attempted ||
            _payloadController.text.isNotEmpty ||
            _nameController.text.isNotEmpty
        ? _error
        : null;
    return FormPage(
      title: l.urlSchemeBuild,
      saveLabel: l.urlSchemeCopyLink,
      onSave: () => unawaited(_copy(close: true)),
      saving: _building || _copying,
      error: error,
      actions: [
        if (_command.isProfile)
          IconButtonData(
            glyph: AppGlyphs.code,
            tooltip: l.urlSchemeUseExample,
            onPressed: _copying ? null : _example,
          ),
      ],
      children: [
        generateSection(
          footer: urlSchemeCommandDescription(_command, l),
          items: [
            IgnorePointer(
              ignoring: _copying,
              child: ListItem<ReClashCommand>.options(
                title: Text(l.urlSchemeAction),
                leading: GlyphIcon(urlSchemeCommandGlyph(_command)),
                options: ReClashCommand.values,
                value: _command,
                textBuilder: (value) => urlSchemeCommandLabel(value, l),
                onChanged: (value) {
                  if (_copying) return;
                  setState(() {
                    if ((_command == ReClashCommand.importProfile) !=
                        (value == ReClashCommand.importProfile)) {
                      _payloadController.clear();
                    }
                    _command = value;
                    _attempted = false;
                  });
                  _changed('');
                },
              ),
            ),
          ],
        ),
        if (_command.isProfile)
          generateSection(
            title: l.urlSchemeParameters,
            items: [
              FormRow(
                title: l.name,
                invalid: error != null && _issue == UrlSchemeIssue.invalidName,
                trailing: FormRowTextField(
                  controller: _nameController,
                  hintText: l.optional,
                  inputFormatters: TextInputLimits.limit(TextInputLimits.name),
                  onChanged: _changed,
                ),
              ),
              if (_command != ReClashCommand.importProfile)
                FormRow(
                  title: l.url,
                  invalid:
                      error != null && _issue != UrlSchemeIssue.invalidName,
                  trailing: FormRowTextField(
                    controller: _payloadController,
                    hintText: 'https://',
                    autocorrect: false,
                    keyboardType: TextInputType.url,
                    inputFormatters: TextInputLimits.limit(TextInputLimits.url),
                    onChanged: _changed,
                  ),
                ),
              if (_command == ReClashCommand.importProfile)
                DecorationListItem(
                  invalid:
                      error != null && _issue != UrlSchemeIssue.invalidName,
                  title: InputDecorationTheme(
                    data: InputDecorationTheme.of(context).copyWith(
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                    ),
                    child: TextField(
                      controller: _payloadController,
                      minLines: 4,
                      maxLines: null,
                      autocorrect: false,
                      keyboardType: TextInputType.multiline,
                      style: AppTextStyle.footnote.of(context).toJetBrainsMono,
                      inputFormatters: TextInputLimits.limit(
                        urlSchemeMaxContentBytes,
                      ),
                      onChanged: _changed,
                      decoration: InputDecoration.collapsed(
                        border: const NoInputBorder(),
                        hintText: l.urlSchemeConfigHint,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        UrlSchemePreview(
          link: _link,
          onCopy: _building || _copying ? null : () => unawaited(_copy()),
        ),
      ],
    );
  }
}
