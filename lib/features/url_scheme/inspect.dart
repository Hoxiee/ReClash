import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/features/form/form.dart';
import 'package:reclash/subscriptions/compatibility/client_labels.dart';
import 'package:reclash/subscriptions/compatibility/clients.dart';
import 'package:reclash/subscriptions/external_link.dart';
import 'package:reclash/subscriptions/imports/import.dart';
import 'package:reclash/widgets/url_scheme_labels.dart';
import 'package:reclash/widgets/widgets.dart';

typedef _Inspection = ({
  ReClashCommand? command,
  ProfileLinkSource? source,
  SubscriptionImportResult? config,
});

class UrlSchemeInspector extends StatefulWidget {
  const UrlSchemeInspector({super.key});

  @override
  State<UrlSchemeInspector> createState() => _UrlSchemeInspectorState();
}

class _UrlSchemeInspectorState extends State<UrlSchemeInspector> {
  final _controller = TextEditingController();
  int _revision = 0;
  bool _checking = false;
  bool _pasting = false;
  String? _error;
  _Inspection? _result;

  @override
  void dispose() {
    _revision++;
    _controller.dispose();
    super.dispose();
  }

  void _changed(String _) {
    _revision++;
    setState(() {
      _checking = false;
      _result = null;
      _error = null;
    });
  }

  Future<void> _paste() async {
    if (_pasting) return;
    final revision = _revision;
    setState(() => _pasting = true);
    try {
      final clipboard = await Clipboard.getData(Clipboard.kTextPlain);
      if (!mounted || revision != _revision) return;
      final text = clipboard?.text;
      if (text == null || text.isEmpty) return;
      if (text.length > urlSchemeMaxLength) {
        throw const UrlSchemeException(UrlSchemeIssue.tooLarge);
      }
      _controller.text = text;
      _changed(text);
    } catch (error) {
      if (mounted && revision == _revision) {
        setState(() {
          _error = error is UrlSchemeException
              ? userFacingErrorMessage(error, context.appLocalizations)
              : context.appLocalizations.urlSchemePasteFailed;
        });
      }
    } finally {
      if (mounted) setState(() => _pasting = false);
    }
  }

  Future<void> _inspect() async {
    if (_checking) return;
    final l = context.appLocalizations;
    final input = _controller.text;
    final revision = ++_revision;
    setState(() {
      _checking = true;
      _result = null;
      _error = null;
    });
    try {
      final link = await readUrlSchemeLink(input);
      final ProfileLinkSource? source;
      SubscriptionImportResult? config;
      if (link != null && !link.command.isProfile) {
        source = null;
      } else {
        source = await resolveProfileLink(input);
        final bytes =
            source.bytes ??
            (source.shareLink == null
                ? null
                : Uint8List.fromList(utf8.encode(source.shareLink!)));
        if (bytes != null) {
          config = await prepareSubscriptionImport(bytes);
          if (config.summary.rejectCoreFallback ||
              source.bytes != null &&
                  config.format == SubscriptionFormat.unknown ||
              source.shareLink != null &&
                  config.format == SubscriptionFormat.shareLinks &&
                  config.summary.nodes == 0) {
            throw MessageException(l.importConfigInvalid);
          }
          if (config.format == SubscriptionFormat.unknown) config = null;
        }
      }
      if (mounted && revision == _revision) {
        setState(
          () => _result = (
            command: link?.command,
            source: source,
            config: config,
          ),
        );
      }
    } catch (error) {
      if (mounted && revision == _revision) {
        setState(() => _error = userFacingErrorMessage(error, l));
      }
    } finally {
      if (mounted && revision == _revision) {
        setState(() => _checking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final result = _result;
    return FormPage(
      title: l.urlSchemeInspect,
      saveLabel: l.urlSchemeInspect,
      onSave: () => unawaited(_inspect()),
      saving: _checking,
      error: _error,
      actions: [
        IconButtonData(
          glyph: AppGlyphs.paste,
          tooltip: l.paste,
          isLoading: _pasting,
          onPressed: _pasting ? null : () => unawaited(_paste()),
        ),
      ],
      children: [
        generateSection(
          title: l.link,
          footer: l.urlSchemeInspectTip,
          items: [
            DecorationListItem(
              invalid: _error != null,
              title: InputDecorationTheme(
                data: InputDecorationTheme.of(
                  context,
                ).copyWith(floatingLabelBehavior: FloatingLabelBehavior.never),
                child: TextField(
                  controller: _controller,
                  minLines: 3,
                  maxLines: null,
                  autocorrect: false,
                  keyboardType: TextInputType.multiline,
                  style: AppTextStyle.footnote.of(context).toJetBrainsMono,
                  inputFormatters: TextInputLimits.limit(urlSchemeMaxLength),
                  onChanged: _changed,
                  decoration: InputDecoration.collapsed(
                    border: const NoInputBorder(),
                    hintText: l.urlSchemeInspectHint,
                  ),
                ),
              ),
            ),
          ],
        ),
        if (result != null) _details(context, result),
      ],
    );
  }

  Widget _details(BuildContext context, _Inspection result) {
    final l = context.appLocalizations;
    final source = result.source;
    final config = result.config;
    final command = result.command;
    Widget detail(String title, String value) =>
        DecorationListItem(title: Text(title), subtitle: Text(value));
    return generateSection(
      title: l.urlSchemeInspectionResult,
      footer: source == null
          ? l.urlSchemeConfirmationTip
          : l.urlSchemeInspectionLimit,
      items: [
        DecorationListItem(
          leading: const GlyphIcon(AppGlyphs.checkCircle),
          title: Text(l.urlSchemeRecognized),
          subtitle: Text(l.urlSchemeNoExecution),
        ),
        detail(
          l.urlSchemeAction,
          command == null
              ? l.urlSchemeImport
              : urlSchemeCommandLabel(command, l),
        ),
        if (command != null && source == null)
          DecorationListItem(
            title: Text(urlSchemeCommandDescription(command, l)),
          ),
        if (source != null) ...[
          detail(l.name, source.name ?? l.unnamed),
          detail(
            l.source,
            source.displaySource.isNotEmpty
                ? source.displaySource
                : l.urlSchemeEmbeddedConfig,
          ),
          if (source.url != null)
            detail(
              l.subscriptionClientRequestAs,
              (source.preset ?? SubscriptionClientPreset.auto).label,
            ),
          if (source.shareLink != null && config == null)
            detail(
              l.urlSchemeContentFormat,
              SubscriptionFormat.shareLinks.label,
            ),
          if (config != null) ...[
            detail(l.urlSchemeContentFormat, config.format.label),
            detail(
              l.urlSchemeConfigSummary,
              l.urlSchemeConfigCounts(
                config.summary.nodes,
                config.summary.groups,
                config.summary.remoteProviders,
              ),
            ),
            if (config.summary.hasLosses)
              DecorationListItem(
                leading: const GlyphIcon(AppGlyphs.warning),
                title: Text(l.urlSchemeConversionWarning),
              ),
          ],
        ],
      ],
    );
  }
}
