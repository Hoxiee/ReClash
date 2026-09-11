import 'dart:async';
import 'dart:io';

import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/pages/scan.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/action.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'client_preset_selector.dart';

class AddProfileView extends ConsumerWidget {
  const AddProfileView({
    super.key,
    this.shrinkWrap = false,
    this.onProfileAdded,
  });

  final bool shrinkWrap;
  final ValueChanged<Profile>? onProfileAdded;

  Future<Profile?> _import(WidgetRef ref, ProfileImportRequest request) async {
    final result = await ref
        .read(profilesActionProvider.notifier)
        .importProfile(request);
    final profile = result.profile;
    if (profile != null) onProfileAdded?.call(profile);
    return profile;
  }

  Future<void> _handleAddProfileFormFile(WidgetRef ref) async {
    await _import(ref, const ProfileImportRequest.file());
  }

  Future<void> _handleAddUrl(
    WidgetRef ref,
    BuildContext context,
    String url, {
    SubscriptionClient client = SubscriptionClient.auto,
    String customUserAgent = '',
  }) async {
    final appLocalizations = context.appLocalizations;
    ResolvedExternalLink? resolved;
    try {
      resolved = await resolveExternalLink(url);
    } on IncyLinkException catch (error) {
      await dialogs.showMessage(
        title: appLocalizations.addProfile,
        message: TextSpan(text: incyLinkErrorMessage(error, appLocalizations)),
      );
      return;
    }
    final target = resolved?.url ?? url;
    final request = target.isEmpty
        ? ProfileImportRequest.raw(resolved!.data!)
        : ProfileImportRequest.link(
            target,
            client: resolved?.preset ?? client,
            name: resolved?.name,
            customUserAgent: customUserAgent,
          );
    await _import(ref, request);
  }

  Future<void> _toScan(WidgetRef ref, BuildContext context) async {
    if (system.isDesktop) {
      await _import(ref, const ProfileImportRequest.qrCode());
      return;
    }
    final url = await BaseNavigator.push<String>(context, const ScanPage());
    if (url != null && context.mounted) {
      await _handleAddUrl(ref, context, url);
    }
  }

  Future<void> _toLanImport(WidgetRef ref) async {
    await dialogs.showCommonDialog<void>(
      dismissible: false,
      child: LanProfileImportDialog(
        onImport: (target) async {
          final profile = await _import(
            ref,
            ProfileImportRequest.link(
              target.url,
              client: target.client,
              name: target.name,
            ),
          );
          if (profile == null) throw StateError('Profile import failed');
        },
      ),
    );
  }

  Future<void> _toAdd(WidgetRef ref, BuildContext context) async {
    final result = await dialogs.showCommonDialog<URLFormDialogResult>(
      child: const URLFormDialog(),
    );
    if (result == null || !context.mounted) return;
    await _handleAddUrl(
      ref,
      context,
      result.url,
      client: result.client,
      customUserAgent: result.customUserAgent,
    );
  }

  Future<void> _toRaw(WidgetRef ref) async {
    final content = await dialogs.showCommonDialog<String>(
      child: const RawProfileDialog(),
    );
    if (content == null) return;
    await _import(ref, ProfileImportRequest.raw(content));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    return ListView(
      shrinkWrap: shrinkWrap,
      physics: shrinkWrap ? const NeverScrollableScrollPhysics() : null,
      children: [
        if (system.isTV)
          ListItem(
            key: const Key('lan-profile-import'),
            leading: const Icon(Icons.wifi_tethering),
            title: Text(appLocalizations.lanProfileImport),
            subtitle: Text(appLocalizations.lanProfileImportDesc),
            onTap: () => _toLanImport(ref),
          ),
        ListItem(
          leading: const Icon(Icons.qr_code_sharp),
          title: Text(appLocalizations.qrcode),
          subtitle: Text(appLocalizations.qrcodeDesc),
          onTap: () => _toScan(ref, context),
        ),
        ListItem(
          leading: const Icon(Icons.cloud_download_sharp),
          title: Text(appLocalizations.url),
          subtitle: Text(appLocalizations.urlDesc),
          onTap: () => _toAdd(ref, context),
        ),
        ListItem(
          leading: const Icon(Icons.upload_file_sharp),
          title: Text(appLocalizations.file),
          subtitle: Text(appLocalizations.fileDesc),
          onTap: () => _handleAddProfileFormFile(ref),
        ),
        ListItem(
          leading: const Icon(Icons.data_object_rounded),
          title: Text(appLocalizations.setupRawConfig),
          subtitle: Text(appLocalizations.setupRawConfigDesc),
          onTap: () => _toRaw(ref),
        ),
      ],
    );
  }
}

class RawProfileDialog extends StatefulWidget {
  const RawProfileDialog({super.key});

  @override
  State<RawProfileDialog> createState() => _RawProfileDialogState();
}

class _RawProfileDialogState extends State<RawProfileDialog> {
  final _controller = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final content = _controller.text.trim();
    if (content.isEmpty) {
      setState(() => _errorText = context.appLocalizations.contentNotEmpty);
      return;
    }
    Navigator.of(context).pop(content);
  }

  Future<void> _handlePaste() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (!mounted) return;
    final text = clipboardData?.text?.trim();
    if (text != null && text.isNotEmpty) {
      _controller.text = text;
      if (_errorText != null) setState(() => _errorText = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return CommonDialog(
      title: appLocalizations.setupRawConfig,
      actions: [
        IconButton.filledTonal(
          tooltip: appLocalizations.pasteFromClipboard,
          onPressed: _handlePaste,
          icon: const Icon(Icons.content_paste),
        ),
        TextButton(
          onPressed: _handleSubmit,
          child: Text(appLocalizations.submit),
        ),
      ],
      child: SizedBox(
        width: 420,
        child: TextField(
          controller: _controller,
          autofocus: true,
          minLines: 10,
          maxLines: 18,
          onChanged: (_) {
            if (_errorText != null) setState(() => _errorText = null);
          },
          decoration: InputDecoration(
            labelText: appLocalizations.content,
            errorText: _errorText,
          ),
        ),
      ),
    );
  }
}

class URLFormDialogResult {
  const URLFormDialogResult({
    required this.url,
    required this.client,
    required this.customUserAgent,
  });

  final String url;
  final SubscriptionClient client;
  final String customUserAgent;
}

class URLFormDialog extends StatefulWidget {
  const URLFormDialog({super.key});

  @override
  State<URLFormDialog> createState() => _URLFormDialogState();
}

class _URLFormDialogState extends State<URLFormDialog> {
  Widget get _moreBody => _isMore
      ? ClientPresetSelector(
          selected: _client,
          onChanged: (value) => setState(() => _client = value),
          customUserAgentController: _customUserAgentController,
        )
      : const SizedBox(width: double.infinity);

  final _urlController = TextEditingController();
  final _customUserAgentController = TextEditingController();
  SubscriptionClient _client = SubscriptionClient.auto;
  bool _isMore = false;
  String? _errorText;

  @override
  void dispose() {
    _urlController.dispose();
    _customUserAgentController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      setState(() {
        _errorText = context.appLocalizations.profileUrlNullValidationDesc;
      });
      return;
    }
    final looksLikeUrl = RegExp(r'^[A-Za-z][A-Za-z0-9+.-]*://').hasMatch(url);
    if (!looksLikeUrl || !url.isProfileImportLink) {
      setState(() {
        _errorText = context.appLocalizations.profileUrlInvalidValidationDesc;
      });
      return;
    }
    Navigator.of(context).pop<URLFormDialogResult>(
      URLFormDialogResult(
        url: url,
        client: _client,
        customUserAgent: _customUserAgentController.text.trim(),
      ),
    );
  }

  Future<void> _handlePaste() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (!mounted) return;
    final text = clipboardData?.text?.trim();
    if (text != null && text.isNotEmpty) {
      _urlController.text = text;
      if (_errorText != null) setState(() => _errorText = null);
    }
  }

  void _handleMore() {
    setState(() {
      _isMore = !_isMore;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return CommonDialog(
      title: appLocalizations.importFromURL,
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              spacing: 8,
              children: [
                IconButton.filledTonal(
                  tooltip: _isMore
                      ? appLocalizations.showLess
                      : appLocalizations.showMore,
                  onPressed: _handleMore,
                  icon: CommonExpandIcon(expand: _isMore),
                ),
                IconButton.filledTonal(
                  tooltip: appLocalizations.pasteFromClipboard,
                  onPressed: _handlePaste,
                  icon: const Icon(Icons.content_paste),
                ),
              ],
            ),
            TextButton(
              onPressed: _handleSubmit,
              child: Text(appLocalizations.submit),
            ),
          ],
        ),
      ],
      child: SizedBox(
        width: 300,
        child: Column(
          spacing: 24,
          children: [
            TextField(
              keyboardType: TextInputType.url,
              autofocus: true,
              minLines: 1,
              maxLines: 5,
              inputFormatters: TextInputLimits.limit(TextInputLimits.url),
              onSubmitted: (_) => _handleSubmit(),
              onChanged: (_) {
                if (_errorText != null) setState(() => _errorText = null);
              },
              controller: _urlController,
              decoration: InputDecoration(
                labelText: appLocalizations.url,
                errorText: _errorText,
              ),
            ),
            context.disableAnimations
                ? _moreBody
                : AnimatedSize(
                    duration: midDuration,
                    curve: Easing.standard,
                    alignment: Alignment.topCenter,
                    child: _moreBody,
                  ),
          ],
        ),
      ),
    );
  }
}

class LanProfileImportDialog extends StatefulWidget {
  const LanProfileImportDialog({
    super.key,
    required this.onImport,
    this.resolve = resolveSubscriptionImport,
    this.timeout = const Duration(minutes: 3),
    this.address,
  });

  final LanProfileImportCallback onImport;
  final LanProfileImportResolver resolve;
  final Duration timeout;
  final InternetAddress? address;

  @override
  State<LanProfileImportDialog> createState() => _LanProfileImportDialogState();
}

class _LanProfileImportDialogState extends State<LanProfileImportDialog> {
  LanProfileImportServer? _server;
  StreamSubscription<LanProfileImportState>? _subscription;
  Timer? _countdown;
  Uri? _uri;
  Object? _startError;
  LanProfileImportState _state = LanProfileImportState.waiting;
  late int _secondsLeft;

  @override
  void initState() {
    super.initState();
    _secondsLeft = widget.timeout.inSeconds;
    unawaited(_start());
  }

  Future<void> _start() async {
    final server = LanProfileImportServer(
      onImport: widget.onImport,
      resolve: widget.resolve,
      timeout: widget.timeout,
    );
    _server = server;
    _subscription = server.state.stream.listen((state) {
      if (!mounted || state == LanProfileImportState.closed) return;
      setState(() => _state = state);
      if (state == LanProfileImportState.imported) {
        Navigator.of(context).pop();
      }
    });
    try {
      final uri = await server.start(address: widget.address);
      if (!mounted) return;
      setState(() => _uri = uri);
      _countdown = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted || _secondsLeft <= 0) return;
        setState(() => _secondsLeft--);
      });
    } on Object catch (error) {
      await server.close();
      if (!mounted) return;
      setState(() => _startError = error);
    }
  }

  @override
  void dispose() {
    _countdown?.cancel();
    unawaited(_subscription?.cancel());
    unawaited(_server?.close());
    super.dispose();
  }

  String _status(AppLocalizations appLocalizations) {
    if (_startError != null) {
      return appLocalizations.lanProfileImportStartFailed;
    }
    return switch (_state) {
      LanProfileImportState.waiting =>
        '${appLocalizations.lanProfileImportWaiting} ${_secondsLeft}s',
      LanProfileImportState.importing =>
        appLocalizations.lanProfileImportImporting,
      LanProfileImportState.imported =>
        appLocalizations.lanProfileImportImported,
      LanProfileImportState.failed => appLocalizations.lanProfileImportFailed,
      LanProfileImportState.timedOut =>
        appLocalizations.lanProfileImportTimedOut,
      LanProfileImportState.closed => appLocalizations.lanProfileImportTimedOut,
    };
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final uri = _uri;
    return CommonDialog(
      title: appLocalizations.lanProfileImportTitle,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(appLocalizations.close),
        ),
      ],
      child: Column(
        spacing: 12,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            appLocalizations.lanProfileImportScan,
            textAlign: TextAlign.center,
          ),
          if (uri != null)
            QrImageView(
              data: uri.toString(),
              size: 220,
              backgroundColor: Colors.white,
            )
          else
            const SizedBox.square(
              dimension: 220,
              child: Center(child: CircularProgressIndicator()),
            ),
          Text(
            _status(appLocalizations),
            key: const Key('lan-profile-import-status'),
            textAlign: TextAlign.center,
          ),
          if (uri != null)
            SelectableText(
              appLocalizations.lanProfileImportAddress(uri.toString()),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
}
