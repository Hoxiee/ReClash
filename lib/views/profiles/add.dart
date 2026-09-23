import 'dart:async';
import 'dart:io';

import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/views/tools/scan.dart';
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

  Future<ProfileImportResult> _import(
    WidgetRef ref,
    ProfileImportRequest request,
  ) => ref.read(profilesActionProvider.notifier).importProfile(request);

  void _notifyAdded(Profile? profile) {
    if (profile != null) onProfileAdded?.call(profile);
  }

  Future<void> _handleAddProfileFormFile(
    WidgetRef ref,
    BuildContext context,
  ) async {
    final result = await _import(ref, const ProfileImportRequest.file());
    if (context.mounted) _notifyAdded(result.profile);
  }

  Future<ProfileImportResult> _handleAddUrl(
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
      if (!context.mounted) return const ProfileImportResult.cancelled();
      await dialogs.showMessage(
        title: appLocalizations.addProfile,
        message: TextSpan(text: incyLinkErrorMessage(error, appLocalizations)),
      );
      return const ProfileImportResult.failed(ProfileImportFailure.invalidUrl);
    }
    if (!context.mounted) return const ProfileImportResult.cancelled();
    final target = resolved?.url ?? url;
    var effectiveClient = resolved?.preset ?? client;
    if (resolved?.preset == SubscriptionClient.happ && target.isNotEmpty) {
      final chosen = await dialogs.showHappImportChoice(
        source: target,
        name: resolved?.name,
      );
      if (chosen == null) return const ProfileImportResult.cancelled();
      effectiveClient = chosen;
    }
    final request = target.isEmpty
        ? ProfileImportRequest.raw(resolved!.data!)
        : ProfileImportRequest.link(
            target,
            client: effectiveClient,
            name: resolved?.name,
            customUserAgent: customUserAgent,
          );
    return _import(ref, request);
  }

  Future<void> _toScan(WidgetRef ref, BuildContext context) async {
    if (system.isDesktop) {
      final result = await _import(ref, const ProfileImportRequest.qrCode());
      if (context.mounted) _notifyAdded(result.profile);
      return;
    }
    final url = await BaseNavigator.push<String>(context, const ScanPage());
    if (url != null && context.mounted) {
      final result = await _handleAddUrl(ref, context, url);
      if (context.mounted) _notifyAdded(result.profile);
    }
  }

  Future<void> _toLanImport(WidgetRef ref, BuildContext context) async {
    Profile? imported;
    final confirmed = await dialogs.showCommonDialog<bool>(
      dismissible: false,
      child: LanProfileImportDialog(
        onImport: (target) async {
          if (!context.mounted) return false;
          final request = target.localContent != null
              ? ProfileImportRequest.raw(target.localContent!)
              : ProfileImportRequest.link(
                  target.url,
                  client: target.client,
                  name: target.name,
                );
          final result = await _import(ref, request);
          imported = result.profile;
          return result.isImported;
        },
      ),
    );
    if (confirmed == true && context.mounted) _notifyAdded(imported);
  }

  Future<void> _toAdd(WidgetRef ref, BuildContext context) async {
    final profile = await dialogs.showCommonDialog<Profile>(
      child: Builder(
        builder: (formContext) => URLFormDialog(
          onSubmit: (value) => _handleAddUrl(
            ref,
            formContext,
            value.url,
            client: value.client,
            customUserAgent: value.customUserAgent,
          ),
        ),
      ),
    );
    if (context.mounted) _notifyAdded(profile);
  }

  Future<void> _toRaw(WidgetRef ref, BuildContext context) async {
    final profile = await dialogs.showCommonDialog<Profile>(
      child: RawProfileDialog(
        onSubmit: (content) => _import(ref, ProfileImportRequest.raw(content)),
      ),
    );
    if (context.mounted) _notifyAdded(profile);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final items = <Widget>[
      if (system.isTV)
        ListItem(
          key: const Key('lan-profile-import'),
          leading: const Icon(Icons.wifi_tethering),
          title: Text(appLocalizations.lanProfileImport),
          subtitle: Text(appLocalizations.lanProfileImportDesc),
          onTap: () => _toLanImport(ref, context),
        ),
      if (!system.isTV)
        ListItem(
          leading: const Icon(Icons.qr_code_sharp),
          title: Text(appLocalizations.qrcode),
          subtitle: Text(appLocalizations.qrcodeDesc),
          onTap: () => _toScan(ref, context),
        ),
      ListItem(
        leading: const Icon(Icons.upload_file_sharp),
        title: Text(appLocalizations.file),
        subtitle: Text(appLocalizations.fileDesc),
        onTap: () => _handleAddProfileFormFile(ref, context),
      ),
      ListItem(
        leading: const Icon(Icons.cloud_download_sharp),
        title: Text(appLocalizations.url),
        subtitle: Text(appLocalizations.urlDesc),
        onTap: () => _toAdd(ref, context),
      ),
      ListItem(
        leading: const Icon(Icons.data_object_rounded),
        title: Text(appLocalizations.setupRawConfig),
        subtitle: Text(appLocalizations.setupRawConfigDesc),
        onTap: () => _toRaw(ref, context),
      ),
    ];
    return shrinkWrap ? Column(children: items) : ListView(children: items);
  }
}

void closeProfileImportRoute<T>(BuildContext context, [T? result]) {
  if (!context.mounted) return;
  final route = ModalRoute.of(context);
  if (route == null || !route.isActive) return;
  final navigator = route.navigator;
  if (navigator == null) return;
  if (route.isCurrent) {
    navigator.pop(result);
  } else {
    navigator.removeRoute(route, result);
  }
}

mixin _ProfileFormSubmit<T extends StatefulWidget> on State<T> {
  bool _pending = false;
  bool _completed = false;
  String? _errorText;

  Future<void> _submit(Future<ProfileImportResult> Function() action) async {
    if (_pending || _completed) return;
    setState(() {
      _pending = true;
      _errorText = null;
    });
    try {
      final result = await action();
      if (!mounted) return;
      if (result.isImported) {
        _completed = true;
        closeProfileImportRoute(context, result.profile);
      } else if (result.failure case final failure?) {
        setState(() {
          _errorText = profileImportFailureMessage(
            failure,
            context.appLocalizations,
          );
        });
      }
    } on Object {
      if (mounted) {
        setState(() {
          _errorText = profileImportFailureMessage(
            ProfileImportFailure.unexpected,
            context.appLocalizations,
          );
        });
      }
    } finally {
      if (mounted) setState(() => _pending = false);
    }
  }
}

class RawProfileDialog extends StatefulWidget {
  const RawProfileDialog({super.key, required this.onSubmit});

  final Future<ProfileImportResult> Function(String content) onSubmit;

  @override
  State<RawProfileDialog> createState() => _RawProfileDialogState();
}

class _RawProfileDialogState extends State<RawProfileDialog>
    with _ProfileFormSubmit<RawProfileDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_pending || _completed) return;
    final content = _controller.text.trim();
    if (content.isEmpty) {
      setState(() => _errorText = context.appLocalizations.contentNotEmpty);
      return;
    }
    await _submit(() => widget.onSubmit(content));
  }

  Future<void> _handlePaste() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (!mounted || _pending) return;
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
          onPressed: _pending ? null : _handlePaste,
          icon: const Icon(Icons.content_paste),
        ),
        TextButton(
          onPressed: _pending ? null : _handleSubmit,
          child: _pending
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(appLocalizations.submit),
        ),
      ],
      child: SizedBox(
        width: 420,
        child: TextField(
          controller: _controller,
          readOnly: _pending,
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
  const URLFormDialog({super.key, required this.onSubmit});

  final Future<ProfileImportResult> Function(URLFormDialogResult value)
  onSubmit;

  @override
  State<URLFormDialog> createState() => _URLFormDialogState();
}

class _URLFormDialogState extends State<URLFormDialog>
    with _ProfileFormSubmit<URLFormDialog> {
  Widget get _moreBody => _isMore
      ? AbsorbPointer(
          absorbing: _pending,
          child: ExcludeFocus(
            excluding: _pending,
            child: ClientPresetSelector(
              selected: _client,
              onChanged: (value) => setState(() => _client = value),
              customUserAgentController: _customUserAgentController,
            ),
          ),
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

  Future<void> _handleSubmit() async {
    if (_pending || _completed) return;
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
    final value = URLFormDialogResult(
      url: url,
      client: _client,
      customUserAgent: _customUserAgentController.text.trim(),
    );
    await _submit(() => widget.onSubmit(value));
  }

  Future<void> _handlePaste() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (!mounted || _pending) return;
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
                  onPressed: _pending ? null : _handleMore,
                  icon: CommonExpandIcon(expand: _isMore),
                ),
                IconButton.filledTonal(
                  tooltip: appLocalizations.pasteFromClipboard,
                  onPressed: _pending ? null : _handlePaste,
                  icon: const Icon(Icons.content_paste),
                ),
              ],
            ),
            TextButton(
              onPressed: _pending ? null : _handleSubmit,
              child: _pending
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(appLocalizations.submit),
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
              readOnly: _pending,
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
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _secondsLeft = widget.timeout.inSeconds;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_server == null) unawaited(_start());
  }

  Future<void> _start() async {
    final server = LanProfileImportServer(
      onImport: widget.onImport,
      resolve: widget.resolve,
      page: buildLanProfileImportPage(
        localizations: context.appLocalizations,
        colors: context.colorScheme,
      ),
      timeout: widget.timeout,
    );
    _server = server;
    _subscription = server.state.stream.listen((state) {
      if (!mounted || _completed || state == LanProfileImportState.closed) {
        return;
      }
      setState(() => _state = state);
      if (state == LanProfileImportState.imported) {
        _completed = true;
        closeProfileImportRoute(context, true);
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
      LanProfileImportState.awaitingConfirmation ||
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
          onPressed: () {
            if (_completed) return;
            _completed = true;
            closeProfileImportRoute(context);
          },
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
          else if (_startError == null)
            const SizedBox.square(
              dimension: 220,
              child: Center(child: CircularProgressIndicator()),
            )
          else
            SizedBox.square(
              dimension: 220,
              child: Icon(
                Icons.wifi_off_rounded,
                size: 72,
                color: context.colorScheme.error,
              ),
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
