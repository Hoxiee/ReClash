import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/features/form/form_row.dart';
import 'package:reclash/models/common.dart' show TrafficShowExt;
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
import 'package:reclash/ui/ui.dart';
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
                  _Hero(
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
                        _Announce(
                          key: const ValueKey('announce'),
                          text: announce.trim(),
                        ),
                      if ((summary != null || current?.info != null) &&
                          source.shareLink == null)
                        _Stats(
                          key: const ValueKey('stats'),
                          summary: summary,
                          info: current?.info,
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
                          generateSection(
                            items: [
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
                            ],
                          ),
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

class _Hero extends StatelessWidget {
  const _Hero({
    required this.monogram,
    required this.logoBytes,
    required this.logoIsSvg,
    required this.account,
    required this.kind,
    required this.glyph,
    required this.loading,
    required this.title,
    required this.caption,
  });

  static const _side = 104.0;
  static const _well = 76.0;

  final String? monogram;
  final Uint8List? logoBytes;
  final bool logoIsSvg;
  final String? account;
  final SubscriptionKind? kind;
  final Glyph glyph;
  final bool loading;
  final String title;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final initial = monogram?.trim().characters.firstOrNull?.toUpperCase();
    final fallback = Container(
      width: _well,
      height: _well,
      alignment: Alignment.center,
      color: initial == null
          ? context.raisedSurfaceLevel.colorOf(colorScheme)
          : colorScheme.primaryContainer,
      child: initial == null
          ? GlyphIcon(glyph, size: 34, color: colorScheme.onSurfaceVariant)
          : Text(
              initial,
              style: AppTextStyle.title1
                  .of(context, emphasized: true)
                  .copyWith(color: colorScheme.onPrimaryContainer),
            ),
    );
    final duration = context.motionDuration(commonDuration);
    final logo = logoBytes;
    final well = logo == null
        ? KeyedSubtree(key: ValueKey(initial ?? glyph), child: fallback)
        : KeyedSubtree(
            key: ObjectKey(logo),
            child: logoIsSvg
                ? SvgPicture.memory(
                    logo,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => fallback,
                  )
                : Image.memory(
                    logo,
                    fit: BoxFit.contain,
                    cacheWidth: (_well * MediaQuery.devicePixelRatioOf(context))
                        .round(),
                    errorBuilder: (_, _, _) => fallback,
                  ),
          );
    final muted = AppTextStyle.subheadline
        .of(context)
        .copyWith(color: colorScheme.onSurfaceVariant);
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: Column(
        children: [
          SizedBox.square(
            dimension: _side,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedSwitcher(
                  duration: duration,
                  child: loading
                      ? CommonCircleLoading(
                          size: _side,
                          color: colorScheme.primary,
                        )
                      : const SizedBox.square(dimension: _side),
                ),
                ClipPath(
                  clipper: const ShapeBorderClipper(shape: AppShape.lg),
                  child: SizedBox.square(
                    dimension: _well,
                    child: AnimatedSwitcher(
                      duration: duration,
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: Tween(begin: 0.8, end: 1.0).animate(animation),
                          child: child,
                        ),
                      ),
                      child: well,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          AnimatedSize(
            duration: duration,
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: AnimatedSwitcher(
              duration: duration,
              layoutBuilder: (current, previous) => Stack(
                alignment: Alignment.topCenter,
                children: [...previous, ?current],
              ),
              child: Column(
                key: ValueKey((title, account, kind, caption)),
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.title2.of(context, emphasized: true),
                  ),
                  if (kind case final kind?) ...[
                    const SizedBox(height: 6),
                    SubscriptionKindChip(kind: kind),
                  ],
                  if (account case final account?) ...[
                    const SizedBox(height: 4),
                    Text(
                      account,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.subheadline.of(context),
                    ),
                  ],
                  if (caption.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      caption,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: muted,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Announce extends StatelessWidget {
  const _Announce({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: context.raisedSurfaceLevel.colorOf(colorScheme),
          shape: AppShape.lg,
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              GlyphIcon(
                AppGlyphs.sparkle,
                size: 20,
                color: colorScheme.primary,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(
                      context.appLocalizations.profileImportFromProvider,
                      style: AppTextStyle.footnote
                          .of(context)
                          .copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                    Text(text, style: AppTextStyle.subheadline.of(context)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats({super.key, required this.summary, required this.info});

  final SubscriptionImportSummary? summary;
  final SubscriptionInfo? info;

  @override
  Widget build(BuildContext context) {
    final l10n = context.appLocalizations;
    final info = this.info;
    final used = info == null ? 0 : info.upload + info.download;
    final expire = info == null || info.expire == 0
        ? null
        : DateTime.fromMillisecondsSinceEpoch(info.expire * 1000);
    final expired = expire?.isBeforeNow ?? false;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            if (summary case final summary?)
              _StatTile(
                flex: 2,
                label: l10n.profileImportServers,
                value: '${summary.nodes}',
              ),
            if (info != null) ...[
              _StatTile(
                flex: 3,
                label: l10n.traffic,
                value: info.total == 0
                    ? l10n.profileImportUnlimited
                    : '${used.traffic.show} / ${info.total.traffic.show}',
                progress: info.total == 0
                    ? null
                    : (used / info.total).clamp(0.0, 1.0).toDouble(),
              ),
              _StatTile(
                flex: 3,
                label: l10n.profileImportValidUntil,
                value: expire == null
                    ? l10n.infiniteTime
                    : expired
                    ? l10n.profileImportExpired
                    : expire.show,
                warning: expired,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.flex,
    this.progress,
    this.warning = false,
  });

  final String label;
  final String value;
  final int flex;
  final double? progress;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final progress = this.progress;
    return Expanded(
      flex: flex,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: context.raisedSurfaceLevel.colorOf(colorScheme),
          shape: AppShape.lg,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.caption1
                    .of(context)
                    .copyWith(color: colorScheme.onSurfaceVariant),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  value,
                  maxLines: 1,
                  style: AppTextStyle.headline
                      .of(context, emphasized: true)
                      .copyWith(
                        color: warning ? colorScheme.error : null,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                ),
              ),
              if (progress != null) ...[
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  minHeight: 4,
                  value: progress,
                  color: progress >= 0.9 ? colorScheme.error : null,
                  backgroundColor: colorScheme.primary.opacity15,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
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
