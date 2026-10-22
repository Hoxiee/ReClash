import 'dart:async';
import 'dart:convert';

import 'package:reclash/common/common.dart';
import 'package:reclash/features/form/form.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'routing.dart';
import 'routing_studio.dart';

/// Opens the import review for a routing profile [text] that arrived from
/// [origin] (a link's host, a file name or the clipboard).
Future<void> openRoutingImport(
  BuildContext context, {
  required String text,
  String? origin,
  String? groupName,
}) {
  return showInSheet<void>(
    context,
    builder: (_) =>
        RoutingImportPage(text: text, origin: origin, groupName: groupName),
  );
}

/// Asks where to import from, then opens the review.
Future<void> pickRoutingImport(
  BuildContext context, {
  String? groupName,
}) async {
  final l = context.appLocalizations;
  final source = await showInSheet<String>(
    context,
    builder: (sheetContext) => SelectionSheet<String>(
      title: l.import,
      sections: const [
        SelectionSection(items: ['clipboard', 'file']),
      ],
      labelBuilder: (item) => item == 'file' ? l.importFile : l.clipboardImport,
      selectedOf: (_) => null,
      onSelected: (item) => Navigator.of(sheetContext).pop(item),
    ),
  );
  if (source == null || !context.mounted) return;
  final String? text;
  final String origin;
  if (source == 'file') {
    final file = await globalState.safeRun(picker.pickerFile);
    final bytes = await file?.readBytes();
    text = bytes == null ? null : utf8.decode(bytes, allowMalformed: true);
    origin = file?.name ?? '';
  } else {
    text = (await Clipboard.getData(Clipboard.kTextPlain))?.text;
    origin = l.clipboardImport;
  }
  if (text == null || text.trim().isEmpty || !context.mounted) return;
  await openRoutingImport(
    context,
    text: _fromLink(text.trim()),
    origin: origin,
    groupName: groupName,
  );
}

/// A pasted share link carries the profile itself.
String _fromLink(String text) {
  final uri = Uri.tryParse(text);
  final payload = uri?.queryParameters['p'];
  if (uri?.scheme != 'reclash' || uri?.host != 'routing' || payload == null) {
    return text;
  }
  try {
    return decodeRcxPayload(payload);
  } on FormatException {
    return text;
  }
}

/// Copies or saves [text] as YAML, or as a link that carries it.
Future<void> showRoutingExport(
  BuildContext context, {
  required String text,
  required String title,
}) async {
  final l = context.appLocalizations;
  final choice = await showInSheet<String>(
    context,
    builder: (sheetContext) => SelectionSheet<String>(
      title: l.rcxExport,
      sections: const [
        SelectionSection(items: ['yaml', 'link', 'file']),
      ],
      labelBuilder: (item) => switch (item) {
        'link' => l.copyLink,
        'file' => l.exportFile,
        _ => l.clipboardExport,
      },
      selectedOf: (_) => null,
      onSelected: (item) => Navigator.of(sheetContext).pop(item),
    ),
  );
  if (choice == null || !context.mounted) return;
  if (choice == 'file') {
    await picker.saveFile(
      '${rcxFreeProfileName(const {}, title)}.rcx.yaml',
      Uint8List.fromList(utf8.encode(text)),
    );
    return;
  }
  await Clipboard.setData(
    ClipboardData(text: choice == 'link' ? encodeRcxLink(text) : text),
  );
  if (context.mounted) context.showNotifier(l.copySuccess);
}

/// What an imported profile would do before it is kept: its errors, the
/// hosts it would contact, and what it would pick in the group now.
class RoutingImportPage extends ConsumerStatefulWidget {
  const RoutingImportPage({
    super.key,
    required this.text,
    this.origin,
    this.groupName,
  });

  final String text;
  final String? origin;
  final String? groupName;

  @override
  ConsumerState<RoutingImportPage> createState() => _RoutingImportPageState();
}

// Only a scenario names groups or a tunnel mode at its top level.
final _scenarioKeys = RegExp(r'^(groups|mode):', multiLine: true);

class _RoutingImportPageState extends ConsumerState<RoutingImportPage> {
  RcxStudioResult? _lint;
  bool _loaded = false;
  late final bool _scenario = _scenarioKeys.hasMatch(widget.text);

  @override
  void initState() {
    super.initState();
    unawaited(_check());
  }

  Future<void> _check() async {
    final result = await ref.read(rcxRoutingActionProvider.notifier).studio({
      'op': 'lint',
      'text': widget.text,
      if (_scenario) 'kind': 'scenario' else 'group': ?widget.groupName,
    });
    if (mounted) {
      setState(() {
        _lint = result;
        _loaded = true;
      });
    }
  }

  Future<void> _add() async {
    final document = _scenario ? _lint?.scenario : _lint?.profile;
    final title = document?['title'] as String? ?? '';
    final name = rcxFreeProfileName(ref.read(rcxProfilesProvider), title);
    await ref
        .read(rcxRoutingActionProvider.notifier)
        .saveProfile(
          name,
          RcxUserProfile(text: widget.text, kind: _scenario ? 'scenario' : ''),
        );
    if (!mounted) return;
    context.showNotifier(context.appLocalizations.rcxImported(title));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final lint = _lint;
    final info = lint?.info;
    final locale = Localizations.localeOf(context).toString();
    final error = !_loaded
        ? null
        : lint == null
        ? l.rcxImportNeedsCore
        : lint.errors.isEmpty
        ? null
        : rcxIssueText(l, lint.errors.first);
    return FormPage(
      title: l.rcxImportTitle,
      saveLabel: l.rcxImportAdd,
      error: error,
      onSave: lint != null && lint.errors.isEmpty ? _add : null,
      children: [
        if (info != null)
          generateSection(
            items: [
              DecorationListItem(
                title: EmojiText(info.displayTitle(locale)),
                subtitle: Text(
                  [
                    if (_scenario)
                      l.rcxScenario
                    else
                      rcxLevelLabel(
                        l,
                        info.level.isEmpty ? 'simple' : info.level,
                      ),
                    if (widget.origin case final origin? when origin.isNotEmpty)
                      origin,
                  ].join(' · '),
                ),
              ),
            ],
          ),
        if (lint?.candidate != null)
          generateSection(
            title: l.rcxCheckOn(widget.groupName ?? ''),
            items: [
              DecorationListItem(title: EmojiText(rcxCheckHeadline(l, lint!))),
            ],
          ),
        if (lint != null && lint.endpoints.isNotEmpty)
          generateSection(
            title: l.rcxContacts,
            footer: l.rcxContactsHint,
            items: [
              for (final endpoint in lint.endpoints)
                DecorationListItem(
                  title: Text(endpoint.host),
                  subtitle: Text(
                    [
                      rcxEndpointUse(l, endpoint.use),
                      if (endpoint.thirdParty) l.rcxThirdParty,
                    ].join(' · '),
                  ),
                ),
            ],
          ),
        if (lint != null && lint.warnings.isNotEmpty)
          generateSection(
            title: l.rcxWarnings,
            items: [
              for (final warning in lint.warnings)
                DecorationListItem(title: Text(rcxIssueText(l, warning))),
            ],
          ),
      ],
    );
  }
}
