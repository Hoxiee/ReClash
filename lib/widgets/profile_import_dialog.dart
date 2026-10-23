import 'dart:async';

import 'package:reclash/common/common.dart';
import 'package:reclash/features/form/form_row.dart';
import 'package:reclash/models/common.dart' show TrafficShowExt;
import 'package:reclash/models/profile.dart';
import 'package:reclash/subscriptions/compatibility/client_labels.dart';
import 'package:reclash/subscriptions/compatibility/clients.dart';
import 'package:reclash/subscriptions/external_link.dart';
import 'package:reclash/subscriptions/imports/import.dart';
import 'package:reclash/subscriptions/metadata/metadata.dart';
import 'package:reclash/subscriptions/transport/transport.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/widgets/provider_logo.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';

typedef ProfileLinkPreviewer =
    Future<ProfileLinkPreview> Function(
      ProfileLinkSource source,
      SubscriptionClientSettings settings, {
      SubscriptionCancellation? cancellation,
    });

Future<ProfileLinkImport?> showProfileImportDialog(
  ProfileLinkSource source, {
  ProfileLinkPreviewer? preview,
  String? duplicateOf,
}) => dialogs.showForm<ProfileLinkImport>(
  builder: (_) => _ProfileImportSheet(
    source: source,
    preview: preview,
    duplicateOf: duplicateOf,
  ),
);

class _Preview {
  const _Preview({this.value, this.failure});

  final ProfileLinkPreview? value;
  final Object? failure;

  bool get loading => value == null && failure == null;
}

class _ProfileImportSheet extends StatefulWidget {
  const _ProfileImportSheet({
    required this.source,
    required this.preview,
    required this.duplicateOf,
  });

  final ProfileLinkSource source;
  final ProfileLinkPreviewer? preview;
  final String? duplicateOf;

  @override
  State<_ProfileImportSheet> createState() => _ProfileImportSheetState();
}

class _ProfileImportSheetState extends State<_ProfileImportSheet> {
  late SubscriptionClientPreset _preset =
      widget.source.preset ?? SubscriptionClientPreset.auto;
  late final _nameController = TextEditingController(
    text: widget.source.name ?? '',
  );
  final _previews = <SubscriptionClientPreset, _Preview>{};
  final _cancellations = <SubscriptionCancellation>{};
  SubscriptionImportResult? _embedded;
  bool _nameEdited = false;

  ProfileLinkPreview? get _current => _previews[_preset]?.value;

  @override
  void initState() {
    super.initState();
    _load(_preset);
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
    for (final cancellation in _cancellations) {
      cancellation.cancel();
    }
    _nameController.dispose();
    super.dispose();
  }

  SubscriptionClientSettings _settings(SubscriptionClientPreset preset) =>
      const SubscriptionClientSettings.forNewProfile().copyWith(preset: preset);

  void _load(SubscriptionClientPreset preset) {
    final preview = widget.preview;
    if (preview == null ||
        widget.source.url == null ||
        widget.duplicateOf != null ||
        _previews.containsKey(preset)) {
      return;
    }
    final cancellation = SubscriptionCancellation();
    _cancellations.add(cancellation);
    _previews[preset] = const _Preview();
    unawaited(
      preview(widget.source, _settings(preset), cancellation: cancellation)
          .then<void>(
            (value) {
              if (!mounted || cancellation.cancelled) return;
              setState(() {
                _previews[preset] = _Preview(value: value);
                if (!_nameEdited && preset == _preset) {
                  _nameController.text = value.prepared.label;
                }
              });
            },
            onError: (Object error) {
              if (!mounted || cancellation.cancelled) return;
              setState(() => _previews[preset] = _Preview(failure: error));
            },
          )
          .whenComplete(() => _cancellations.remove(cancellation)),
    );
  }

  void _retry() {
    setState(() => _previews.remove(_preset));
    _load(_preset);
  }

  void _select(SubscriptionClientPreset preset) {
    if (preset == _preset) return;
    setState(() {
      _preset = preset;
      final current = _current;
      if (!_nameEdited && current != null) {
        _nameController.text = current.prepared.label;
      }
    });
    _load(preset);
  }

  void _submit() {
    final label = _nameController.text.trim();
    Navigator.of(context).pop(
      ProfileLinkImport(
        clientSettings: _settings(_preset),
        label: label.isEmpty ? null : label,
        preview: _current,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.appLocalizations;
    final source = widget.source;
    final current = _current;
    final metadata = current?.prepared.snapshot.metadata;
    final summary = current?.prepared.summary ?? _embedded?.summary;
    final format = current?.prepared.payload.format ?? _embedded?.format;
    final host = source.url == null ? null : Uri.tryParse(source.url!)?.host;
    final title =
        metadata?.name ??
        current?.prepared.label ??
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
    final duplicateOf = widget.duplicateOf;
    final state = _previews[_preset];
    return CommonScaffold(
      title: source.url != null ? l10n.profileImportTitle : l10n.addProfile,
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
                    logo: metadata?.logo,
                    monogram: metadata?.name,
                    glyph: source.bytes != null
                        ? AppGlyphs.code
                        : source.shareLink != null
                        ? AppGlyphs.link
                        : AppGlyphs.cloudDownload,
                    loading: state?.loading ?? false,
                    title: title,
                    caption: caption,
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                    alignment: Alignment.topCenter,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (metadata?.announce case final announce?
                            when announce.trim().isNotEmpty)
                          _Announce(text: announce.trim()),
                        if (summary != null && source.shareLink == null)
                          _Stats(
                            summary: summary,
                            info: current?.prepared.subscriptionInfo,
                          ),
                        if (duplicateOf != null)
                          _Notice(
                            glyph: AppGlyphs.info,
                            text: l10n.profileImportAlreadyAdded(duplicateOf),
                          )
                        else if (state?.loading == true)
                          _Notice(
                            glyph: AppGlyphs.cloudSync,
                            text: l10n.profileImportChecking,
                          )
                        else if (state?.failure case final failure?)
                          _Notice(
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
                        if (current?.prepared.snapshot.deviceStatus ==
                            SubscriptionDeviceStatus.limitReached)
                          _Notice(
                            glyph: AppGlyphs.devices,
                            text: l10n.subscriptionDeviceLimit,
                            warning: true,
                          ),
                        if (summary?.hasLosses == true)
                          _Notice(
                            glyph: AppGlyphs.warning,
                            text: l10n.profileImportLosses,
                            warning: true,
                          ),
                      ],
                    ),
                  ),
                  if (duplicateOf == null) ...[
                    const SizedBox(height: 12),
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
                              title: preset == SubscriptionClientPreset.auto
                                  ? l10n.subscriptionClientReclash
                                  : preset.label,
                              description:
                                  preset == SubscriptionClientPreset.auto
                                  ? l10n.profileImportFormatReclash
                                  : l10n.profileImportFormatClient(
                                      preset.label,
                                    ),
                              preview: _previews[preset],
                              selected: preset == _preset,
                              onPressed: () => _select(preset),
                            ),
                        ],
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
                  TextButton(onPressed: _submit, child: Text(l10n.add)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({
    required this.logo,
    required this.monogram,
    required this.glyph,
    required this.loading,
    required this.title,
    required this.caption,
  });

  static const _side = 104.0;
  static const _well = 76.0;

  final String? logo;
  final String? monogram;
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
                  duration: const Duration(milliseconds: 200),
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
                    child: logo == null
                        ? fallback
                        : ProviderLogo(
                            url: logo!,
                            size: _well,
                            fallback: fallback,
                          ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: Text(
              title,
              key: ValueKey(title),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyle.title2.of(context, emphasized: true),
            ),
          ),
          if (caption.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              caption,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyle.subheadline
                  .of(context)
                  .copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }
}

class _Announce extends StatelessWidget {
  const _Announce({required this.text});

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
  const _Stats({required this.summary, required this.info});

  final SubscriptionImportSummary summary;
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
            mainAxisAlignment: MainAxisAlignment.center,
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

class _Notice extends StatelessWidget {
  const _Notice({
    required this.glyph,
    required this.text,
    this.action,
    this.warning = false,
  });

  final Glyph glyph;
  final String text;
  final (String, VoidCallback)? action;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final color = warning ? colorScheme.warning : colorScheme.onSurfaceVariant;
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
    required this.preview,
    required this.selected,
    required this.onPressed,
  });

  final String title;
  final String description;
  final _Preview? preview;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.appLocalizations;
    final prepared = preview?.value?.prepared;
    final result = prepared != null
        ? '${prepared.payload.format.label}  ·  '
              '${l10n.profileImportServerCount(prepared.summary.nodes)}'
        : preview?.loading == true
        ? l10n.profileImportChecking
        : null;
    final muted = AppTextStyle.footnote
        .of(context)
        .copyWith(color: context.colorScheme.onSurfaceVariant);
    return DecorationListItem(
      isSelected: selected,
      onPressed: onPressed,
      title: Text(title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(description, style: muted),
          if (result != null) Text(result, style: muted),
        ],
      ),
      trailing: selected ? const SelectionCheck() : null,
    );
  }
}
