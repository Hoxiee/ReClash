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

/// Exports a saved profile or scenario [id] together with the profiles it
/// relies on; [text] is what goes out when the core cannot bundle it.
Future<void> exportRoutingDocument(
  BuildContext context,
  WidgetRef ref, {
  required String? id,
  required String kind,
  required String text,
  required String title,
}) async {
  final bundled = id == null
      ? null
      : await ref.read(rcxRoutingActionProvider.notifier).studio({
          'op': 'export',
          'id': id,
          'kind': kind,
        });
  if (!context.mounted) return;
  final exported = bundled?.text ?? '';
  await showRoutingExport(
    context,
    text: exported.isEmpty ? text : exported,
    title: title,
  );
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

// Only a scenario names groups, routes or a tunnel mode at its top level.
final _scenarioKeys = RegExp(r'^(groups|routes|mode):', multiLine: true);

class _RoutingImportPageState extends ConsumerState<RoutingImportPage> {
  RcxStudioResult? _lint;
  List<RcxBundleItem> _items = const [];
  List<RcxStudioResult> _itemLints = const [];
  bool _loaded = false;
  bool _saving = false;
  late final bool _scenario = _scenarioKeys.hasMatch(widget.text);

  RcxRoutingAction get _action => ref.read(rcxRoutingActionProvider.notifier);

  @override
  void initState() {
    super.initState();
    unawaited(_check());
  }

  Future<void> _check() async {
    final unpacked = await _action.studio({
      'op': 'unpack',
      'text': widget.text,
      'taken': ref.read(rcxProfilesProvider).keys.toList(),
    });
    final items = unpacked?.items ?? const <RcxBundleItem>[];
    if (items.length > 1) {
      // A scenario names profiles that are not saved yet, so the bundle is
      // linted as a whole, each item against the others.
      final lint = await _action.studio({'op': 'lint', 'text': widget.text});
      if (!mounted) return;
      setState(() {
        _items = items;
        _itemLints = [?lint];
        _lint = lint;
        _loaded = true;
      });
      return;
    }
    final result = await _action.studio({
      'op': 'lint',
      'text': widget.text,
      if (_scenario) 'kind': 'scenario' else 'group': ?widget.groupName,
    });
    if (mounted) {
      setState(() {
        _lint = result;
        _itemLints = [?result];
        _loaded = true;
      });
    }
  }

  Future<void> _add() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final String title;
      if (_items.isNotEmpty) {
        for (final item in _items) {
          await _action.saveProfile(
            item.name,
            RcxUserProfile(text: item.text, kind: item.kind),
          );
        }
        final head = _items.firstWhere(
          (item) => item.kind == 'scenario',
          orElse: () => _items.first,
        );
        title = head.title.isEmpty ? head.name : head.title;
      } else {
        final document = _scenario ? _lint?.scenario : _lint?.profile;
        title = document?['title'] as String? ?? '';
        final name = rcxFreeProfileName(ref.read(rcxProfilesProvider), title);
        await _action.saveProfile(
          name,
          RcxUserProfile(text: widget.text, kind: _scenario ? 'scenario' : ''),
        );
      }
      if (!mounted) return;
      context.showNotifier(context.appLocalizations.rcxImported(title));
      Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final lint = _lint;
    final info = lint?.info;
    final locale = Localizations.localeOf(context).toString();
    final errors = [for (final result in _itemLints) ...result.errors];
    final warnings = [for (final result in _itemLints) ...result.warnings];
    final endpoints = {
      for (final result in _itemLints)
        for (final endpoint in result.endpoints) endpoint.host: endpoint,
    }.values;
    final error = !_loaded
        ? null
        : lint == null
        ? l.rcxImportNeedsCore
        : errors.isEmpty
        ? null
        : rcxIssueText(l, errors.first);
    return FormPage(
      title: l.rcxImportTitle,
      saveLabel: l.rcxImportAdd,
      error: error,
      saving: _saving,
      onSave: lint != null && errors.isEmpty ? _add : null,
      children: [
        if (_items.isNotEmpty)
          generateSection(
            title: l.rcxHubBundle,
            footer: widget.origin,
            items: [
              for (final item in _items)
                DecorationListItem(
                  title: EmojiText(item.title.isEmpty ? item.name : item.title),
                  subtitle: Text(
                    item.kind == 'scenario' ? l.rcxScenario : l.rcxProfile,
                  ),
                ),
            ],
          )
        else if (info != null)
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
              if (info.localize(info.description, locale) case final description
                  when description.isNotEmpty)
                DecorationListItem(title: EmojiText(description)),
            ],
          ),
        if (_items.isEmpty && lint?.candidate != null)
          generateSection(
            title: l.rcxCheckOn(widget.groupName ?? ''),
            items: [
              DecorationListItem(title: EmojiText(rcxCheckHeadline(l, lint!))),
            ],
          ),
        if (endpoints.isNotEmpty)
          generateSection(
            title: l.rcxContacts,
            footer: l.rcxContactsHint,
            items: [
              for (final endpoint in endpoints)
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
        if (warnings.isNotEmpty)
          generateSection(
            title: l.rcxWarnings,
            items: [
              for (final warning in warnings)
                DecorationListItem(title: Text(rcxIssueText(l, warning))),
            ],
          ),
      ],
    );
  }
}
