import 'dart:async';

import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/features/form/form_row.dart';
import 'package:reclash/models/profile.dart';
import 'package:reclash/subscriptions/compatibility/client_labels.dart';
import 'package:reclash/subscriptions/compatibility/clients.dart';
import 'package:reclash/subscriptions/compatibility/policy.dart';
import 'package:reclash/subscriptions/external_link.dart';
import 'package:reclash/subscriptions/imports/import.dart';
import 'package:reclash/subscriptions/metadata/metadata.dart';
import 'package:reclash/subscriptions/page_preview.dart';
import 'package:reclash/subscriptions/transport/transport.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/widgets/profile_import_parts.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';

typedef ProfileLinkPreviewer =
    Future<SubscriptionPagePreview> Function(
      ProfileLinkSource source, {
      SubscriptionCancellation? cancellation,
    });

/// With [commit], the sheet stays open while the profile is imported, so a
/// loss review opens over it and a failure is shown in it. Resolves once the
/// sheet has left the screen, so what the caller does next does not run
/// under its exit.
Future<ProfileLinkImport?> showProfileImportDialog(
  ProfileLinkSource source, {
  ProfileLinkPreviewer? preview,
  String? duplicateOf,
  ProfileLinkCommit? commit,
}) async {
  TransitionRoute<Object?>? route;
  final choice = await dialogs.showForm<ProfileLinkImport>(
    builder: (context) {
      route ??= ModalRoute.of(context);
      return _ProfileImportSheet(
        source: source,
        preview: preview,
        duplicateOf: duplicateOf,
        commit: commit,
      );
    },
  );
  await route?.completed;
  return choice;
}

/// Resolves with true when the user picks [profile] from the sheet.
Future<bool?> showProfilePreviewDialog(
  Profile profile, {
  required bool selected,
}) => dialogs.showForm<bool>(
  builder: (_) => _ProfilePreviewSheet(profile: profile, selected: selected),
);

class _ProfilePreviewSheet extends StatelessWidget {
  const _ProfilePreviewSheet({required this.profile, required this.selected});

  final Profile profile;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.appLocalizations;
    final isUrl = profile.type == ProfileType.url;
    final metadata = isUrl ? profile.subscriptionSnapshot?.metadata : null;
    final info = isUrl ? profile.subscriptionInfo : null;
    final host = isUrl ? Uri.tryParse(profile.url)?.host : null;
    final announce = metadata?.announce?.trim();
    final support = safeSubscriptionSupportLink(
      metadata?.text('provider.supportUrl') ?? '',
    );
    return CommonScaffold(
      title: l10n.profile,
      primaryAction: support == null
          ? null
          : IconButtonData(
              glyph: AppGlyphs.openExternal,
              tooltip: l10n.subscriptionProviderSupport,
              onPressed: () => dialogs.openUrl(support.toString()),
            ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ).copyWith(top: context.contentTopPadding, bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ImportHero(
                    monogram: metadata?.name ?? profile.realLabel,
                    logoBytes: null,
                    logoIsSvg: false,
                    account: metadata?.accountTitle,
                    kind: metadata?.kind,
                    glyph: isUrl ? AppGlyphs.cloudDownload : AppGlyphs.code,
                    loading: false,
                    title: profile.realLabel,
                    caption: metadata?.hideUrl == true ? '' : host ?? '',
                  ),
                  if (announce != null && announce.isNotEmpty)
                    ImportAnnounce(text: announce),
                  if (info != null)
                    ImportStats(
                      nodes: null,
                      usage: (
                        used: info.upload + info.download,
                        total: info.total,
                        expire: info.expire,
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: AlertActions(
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.close),
                ),
                if (!selected)
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(l10n.select),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Preview {
  const _Preview({this.value, this.failure});

  final SubscriptionPagePreview? value;
  final Object? failure;

  bool get loading => value == null && failure == null;
}

class _ProfileImportSheet extends StatefulWidget {
  const _ProfileImportSheet({
    required this.source,
    required this.preview,
    required this.duplicateOf,
    required this.commit,
  });

  final ProfileLinkSource source;
  final ProfileLinkPreviewer? preview;
  final String? duplicateOf;
  final ProfileLinkCommit? commit;

  @override
  State<_ProfileImportSheet> createState() => _ProfileImportSheetState();
}

class _ProfileImportSheetState extends State<_ProfileImportSheet> {
  late SubscriptionClientPreset _preset =
      widget.source.preset ?? SubscriptionClientPreset.auto;
  late final _nameController = TextEditingController(
    text: widget.source.name ?? '',
  );
  _Preview? _preview;
  final _cancellations = <SubscriptionCancellation>{};
  SubscriptionImportResult? _embedded;
  bool _nameEdited = false;
  bool _committing = false;
  Object? _commitFailure;
  bool _declined = false;

  SubscriptionPagePreview? get _current => _preview?.value;

  @override
  void initState() {
    super.initState();
    _load();
    if (widget.source.bytes case final bytes?) {
      unawaited(
        prepareSubscriptionImport(bytes).then((result) {
          if (mounted) setState(() => _embedded = result);
        }, onError: (_) {}),
      );
    }
  }

  @override
  void dispose() {
    _cancelAll();
    _nameController.dispose();
    super.dispose();
  }

  void _cancelAll() {
    for (final cancellation in _cancellations) {
      cancellation.cancel();
    }
  }

  SubscriptionClientSettings _settings(SubscriptionClientPreset preset) =>
      const SubscriptionClientSettings.forNewProfile().copyWith(preset: preset);

  void _load() {
    final preview = widget.preview;
    if (preview == null ||
        widget.source.url == null ||
        widget.duplicateOf != null ||
        _preview != null) {
      return;
    }
    final cancellation = SubscriptionCancellation();
    _cancellations.add(cancellation);
    _preview = const _Preview();
    unawaited(
      preview(widget.source, cancellation: cancellation)
          .then<void>(
            (value) {
              if (!mounted || cancellation.cancelled) return;
              setState(() {
                _preview = _Preview(value: value);
                final name = value.metadata.name ?? value.label;
                if (!_nameEdited && name != null) {
                  _nameController.text = name;
                }
              });
            },
            onError: (Object error) {
              if (!mounted || cancellation.cancelled) return;
              setState(() => _preview = _Preview(failure: error));
            },
          )
          .whenComplete(() => _cancellations.remove(cancellation)),
    );
  }

  void _retry() {
    setState(() => _preview = null);
    _load();
  }

  void _select(SubscriptionClientPreset preset) {
    if (preset == _preset) return;
    setState(() => _preset = preset);
  }

  Future<void> _submit() async {
    if (_committing) return;
    final label = _nameController.text.trim();
    final choice = ProfileLinkImport(
      clientSettings: _settings(_preset),
      label: label.isEmpty ? null : label,
    );
    final commit = widget.commit;
    if (commit == null) {
      Navigator.of(context).pop(choice);
      return;
    }
    final cancellation = SubscriptionCancellation();
    _cancellations.add(cancellation);
    FocusScope.of(context).unfocus();
    setState(() {
      _committing = true;
      _commitFailure = null;
      _declined = false;
    });
    try {
      await commit(choice, reviewContext: context, cancellation: cancellation);
      if (mounted && !cancellation.cancelled) {
        Navigator.of(context).pop(choice);
      }
    } catch (error) {
      if (!mounted || cancellation.cancelled) return;
      setState(() {
        if (_isCancellation(error)) {
          _declined = widget.source.preset != null;
        } else {
          _commitFailure = error;
        }
      });
    } finally {
      _cancellations.remove(cancellation);
      if (mounted) setState(() => _committing = false);
    }
  }

  static bool _isCancellation(Object error) => switch (error) {
    SubscriptionUpdateCancelled() || SubscriptionUpdateSuperseded() => true,
    SubscriptionException(:final failure) =>
      failure == SubscriptionFailure.cancelled ||
          failure == SubscriptionFailure.superseded,
    SubscriptionUpdateRejected(:final reason) =>
      reason == SubscriptionRetryReason.cancelled,
    _ => false,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.appLocalizations;
    final source = widget.source;
    final current = _current;
    final metadata = current?.metadata;
    final summary = _embedded?.summary;
    final format = _embedded?.format;
    final host = source.url == null ? null : Uri.tryParse(source.url!)?.host;
    final title =
        metadata?.name ??
        current?.label ??
        source.name ??
        (source.url != null ? host : null) ??
        l10n.addProfile;
    final caption = [
      if (source.url != null && metadata?.hideUrl != true && host != title)
        ?host,
      if (source.bytes != null) l10n.urlSchemeEmbeddedConfig,
      if (source.shareLink case final link?) ...[
        Uri.tryParse(link)?.scheme.toUpperCase() ?? '',
        l10n.profileImportSingleServer,
      ],
      if (format != null) format.label,
    ].where((part) => part.isNotEmpty).join('  ·  ');
    final support = safeSubscriptionSupportLink(
      metadata?.text('provider.supportUrl') ?? '',
    );
    final duplicateOf = widget.duplicateOf;
    final state = _preview;
    final failure = _commitFailure;
    final supportUri = failure is SubscriptionException
        ? failure.supportUri
        : null;
    final scaffold = CommonScaffold(
      title: source.url != null ? l10n.profileImportTitle : l10n.addProfile,
      primaryAction: support == null
          ? null
          : IconButtonData(
              glyph: AppGlyphs.openExternal,
              tooltip: l10n.subscriptionProviderSupport,
              onPressed: () => dialogs.openUrl(support.toString()),
            ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ).copyWith(top: context.contentTopPadding, bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ImportHero(
                    monogram: metadata?.name,
                    logoBytes: current?.logoBytes,
                    logoIsSvg: current?.logoIsSvg ?? false,
                    account: metadata?.accountTitle,
                    kind: metadata?.kind,
                    glyph: source.bytes != null
                        ? AppGlyphs.code
                        : source.shareLink != null
                        ? AppGlyphs.link
                        : AppGlyphs.cloudDownload,
                    loading: (state?.loading ?? false) || _committing,
                    title: title,
                    caption: caption,
                  ),
                  AnimatedEntries(
                    children: [
                      if (metadata?.announce case final announce?
                          when announce.trim().isNotEmpty)
                        ImportAnnounce(
                          key: const ValueKey('announce'),
                          text: announce.trim(),
                        ),
                      if ((summary != null || current?.info != null) &&
                          source.shareLink == null)
                        ImportStats(
                          key: const ValueKey('stats'),
                          nodes: summary?.nodes,
                          usage: switch (current?.info) {
                            final info? => (
                              used: info.upload + info.download,
                              total: info.total,
                              expire: info.expire,
                            ),
                            null => null,
                          },
                        ),
                      if (duplicateOf != null)
                        _Notice(
                          key: const ValueKey('duplicate'),
                          glyph: AppGlyphs.info,
                          text: l10n.profileImportAlreadyAdded(duplicateOf),
                        )
                      else if (_committing)
                        _Notice(
                          key: const ValueKey('committing'),
                          glyph: AppGlyphs.cloudDownload,
                          text: l10n.profileImportDownloading,
                        )
                      else if (failure != null)
                        _Notice(
                          key: const ValueKey('commitFailure'),
                          glyph: AppGlyphs.error,
                          text: userFacingErrorMessage(failure, l10n),
                          tone: _NoticeTone.error,
                          action: supportUri == null
                              ? (l10n.retry, () => unawaited(_submit()))
                              : (
                                  l10n.subscriptionProviderSupport,
                                  () => dialogs.openUrl(supportUri.toString()),
                                ),
                        )
                      else if (_declined)
                        _Notice(
                          key: const ValueKey('declined'),
                          glyph: AppGlyphs.swap,
                          text: l10n.profileImportTryOtherFormat,
                        )
                      else if (state?.loading == true)
                        _Notice(
                          key: const ValueKey('checking'),
                          glyph: AppGlyphs.cloudSync,
                          text: l10n.profileImportChecking,
                        )
                      else if (state?.failure case final failure?)
                        _Notice(
                          key: ValueKey(failure.runtimeType),
                          glyph: failure is AgeSecretKeyRequiredException
                              ? AppGlyphs.key
                              : AppGlyphs.wifiOff,
                          text: failure is AgeSecretKeyRequiredException
                              ? l10n.profileImportEncrypted
                              : l10n.profileImportPreviewFailed,
                          action: failure is AgeSecretKeyRequiredException
                              ? null
                              : (l10n.retry, _retry),
                        ),
                      if (summary?.hasLosses == true)
                        _Notice(
                          key: const ValueKey('losses'),
                          glyph: AppGlyphs.warning,
                          text: l10n.profileImportLosses,
                          tone: _NoticeTone.warning,
                        ),
                    ],
                  ),
                  if (duplicateOf == null) ...[
                    const SizedBox(height: 12),
                    _Locked(
                      locked: _committing,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          generateGroup([
                            FormRow(
                              title: l10n.name,
                              trailing: FormRowTextField(
                                controller: _nameController,
                                hintText: host ?? l10n.unnamed,
                                inputFormatters: TextInputLimits.limit(
                                  TextInputLimits.name,
                                ),
                                onChanged: (_) => _nameEdited = true,
                              ),
                            ),
                          ]),
                          if (source.preset case final native?)
                            generateSection(
                              title: l10n.profileImportFormat,
                              items: [
                                for (final preset in [
                                  native,
                                  SubscriptionClientPreset.auto,
                                ])
                                  _FormatOption(
                                    title:
                                        preset == SubscriptionClientPreset.auto
                                        ? l10n.subscriptionClientReclash
                                        : preset.label,
                                    description:
                                        preset == SubscriptionClientPreset.auto
                                        ? l10n.profileImportFormatReclash
                                        : l10n.profileImportFormatClient(
                                            preset.label,
                                          ),
                                    selected: preset == _preset,
                                    onPressed: () => _select(preset),
                                  ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: AlertActions(
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(duplicateOf == null ? l10n.cancel : l10n.close),
                ),
                if (duplicateOf == null)
                  TextButton(
                    onPressed: _committing ? null : () => unawaited(_submit()),
                    child: Text(l10n.add),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
    return PopScope<Object?>(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && result is! ProfileLinkImport) _cancelAll();
      },
      child: scaffold,
    );
  }
}

class _Locked extends StatelessWidget {
  const _Locked({required this.locked, required this.child});

  final bool locked;
  final Widget child;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    ignoring: locked,
    child: AnimatedOpacity(
      opacity: locked ? 0.5 : 1,
      duration: context.motionDuration(commonDuration),
      child: child,
    ),
  );
}

enum _NoticeTone { plain, warning, error }

class _Notice extends StatelessWidget {
  const _Notice({
    super.key,
    required this.glyph,
    required this.text,
    this.action,
    this.tone = _NoticeTone.plain,
  });

  final Glyph glyph;
  final String text;
  final (String, VoidCallback)? action;
  final _NoticeTone tone;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final color = switch (tone) {
      _NoticeTone.plain => colorScheme.onSurfaceVariant,
      _NoticeTone.warning => colorScheme.warning,
      _NoticeTone.error => colorScheme.error,
    };
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        spacing: 10,
        children: [
          GlyphIcon(glyph, size: 18, color: color),
          Expanded(
            child: Text(
              text,
              style: AppTextStyle.footnote.of(context).copyWith(color: color),
            ),
          ),
          if (action case (final label, final onPressed))
            TextButton(onPressed: onPressed, child: Text(label)),
        ],
      ),
    );
  }
}

class _FormatOption extends StatelessWidget {
  const _FormatOption({
    required this.title,
    required this.description,
    required this.selected,
    required this.onPressed,
  });

  final String title;
  final String description;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final muted = AppTextStyle.footnote
        .of(context)
        .copyWith(color: context.colorScheme.onSurfaceVariant);
    return DecorationListItem(
      isSelected: selected,
      onPressed: onPressed,
      title: Text(title),
      subtitle: Text(description, style: muted),
      trailing: selected ? const SelectionCheck() : null,
    );
  }
}
