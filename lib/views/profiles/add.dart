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
  final BuildContext context;
  final bool keepCurrentPage;
  final bool shrinkWrap;
  final ValueChanged<Profile>? onProfileAdded;

  const AddProfileView({
    super.key,
    required this.context,
    this.keepCurrentPage = false,
    this.shrinkWrap = false,
    this.onProfileAdded,
  });

  Future<void> _handleAddProfileFormFile(WidgetRef ref) async {
    final profile = await ref
        .read(profilesActionProvider.notifier)
        .addProfileFormFile(keepCurrentPage: keepCurrentPage);
    if (profile != null) onProfileAdded?.call(profile);
  }

  Future<void> _handleAddUrl(
    ProfilesAction profilesAction,
    String url, {
    SubscriptionClient client = SubscriptionClient.auto,
    String customUserAgent = '',
  }) async {
    final appLocalizations = context.appLocalizations;
    ResolvedExternalLink? resolved;
    try {
      resolved = await resolveExternalLink(url);
    } on IncyLinkException catch (e) {
      await dialogs.showMessage(
        title: appLocalizations.addProfile,
        message: TextSpan(text: e.message),
      );
      return;
    }
    final target = resolved?.url ?? url;
    if (target.isEmpty) {
      final profile = await profilesAction.addProfileFromLocalContent(
        resolved!.data!,
        keepCurrentPage: keepCurrentPage,
      );
      if (profile != null) onProfileAdded?.call(profile);
      return;
    }
    final profile = await profilesAction.addProfileFormURL(
      target,
      client: resolved?.preset ?? client,
      name: resolved?.name,
      customUserAgent: customUserAgent,
      keepCurrentPage: keepCurrentPage,
    );
    if (profile != null) onProfileAdded?.call(profile);
  }

  Future<void> _toScan(WidgetRef ref) async {
    final profilesAction = ref.read(profilesActionProvider.notifier);
    if (system.isDesktop) {
      final profile = await profilesAction.addProfileFormQrCode();
      if (profile != null) onProfileAdded?.call(profile);
      return;
    }
    final url = await BaseNavigator.push(context, const ScanPage());
    if (url != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_handleAddUrl(profilesAction, url));
      });
    }
  }

  Future<void> _toLanImport(WidgetRef ref) async {
    final profilesAction = ref.read(profilesActionProvider.notifier);
    await dialogs.showCommonDialog<void>(
      dismissible: false,
      child: LanProfileImportDialog(
        onImport: (target) async {
          final profile = await profilesAction.addProfileFormURL(
            target.url,
            client: target.client,
            name: target.name,
            keepCurrentPage: keepCurrentPage,
          );
          if (profile == null) throw StateError('Profile import failed');
          onProfileAdded?.call(profile);
        },
      ),
    );
  }

  Future<void> _toAdd(WidgetRef ref) async {
    final profilesAction = ref.read(profilesActionProvider.notifier);
    final result = await dialogs.showCommonDialog<URLFormDialogResult>(
      child: const URLFormDialog(),
    );
    if (result == null) return;
    final url = result.url.trim();
    if (url.isEmpty) return;
    if (!url.isUrl &&
        !url.startsWith('incy://') &&
        !url.startsWith('happ://')) {
      final profile = await profilesAction.addProfileFromLocalContent(
        url,
        keepCurrentPage: keepCurrentPage,
      );
      if (profile != null) onProfileAdded?.call(profile);
      return;
    }
    await _handleAddUrl(
      profilesAction,
      url,
      client: result.client,
      customUserAgent: result.customUserAgent,
    );
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
          onTap: () => _toScan(ref),
        ),
        ListItem(
          leading: const Icon(Icons.upload_file_sharp),
          title: Text(appLocalizations.file),
          subtitle: Text(appLocalizations.fileDesc),
          onTap: () => _handleAddProfileFormFile(ref),
        ),
        ListItem(
          leading: const Icon(Icons.cloud_download_sharp),
          title: Text(appLocalizations.url),
          subtitle: Text(appLocalizations.urlDesc),
          onTap: () => _toAdd(ref),
        ),
      ],
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

  @override
  void dispose() {
    _urlController.dispose();
    _customUserAgentController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;
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
              controller: _urlController,
              decoration: InputDecoration(labelText: appLocalizations.url),
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
