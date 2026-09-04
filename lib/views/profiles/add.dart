import 'dart:async';

import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/pages/scan.dart';
import 'package:reclash/providers/action.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'client_preset_selector.dart';

class AddProfileView extends ConsumerWidget {
  final BuildContext context;
  final bool keepCurrentPage;

  const AddProfileView({
    super.key,
    required this.context,
    this.keepCurrentPage = false,
  });

  Future<void> _handleAddProfileFormFile(WidgetRef ref) async {
    unawaited(
      ref.read(profilesActionProvider.notifier).addProfileFormFile(
        keepCurrentPage: keepCurrentPage,
      ),
    );
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
      unawaited(
        profilesAction.addProfileFromLocalContent(
          resolved!.data!,
          keepCurrentPage: keepCurrentPage,
        ),
      );
      return;
    }
    unawaited(
      profilesAction.addProfileFormURL(
        target,
        client: resolved?.preset ?? client,
        name: resolved?.name,
        customUserAgent: customUserAgent,
        keepCurrentPage: keepCurrentPage,
      ),
    );
  }

  Future<void> _toScan(WidgetRef ref) async {
    final profilesAction = ref.read(profilesActionProvider.notifier);
    if (system.isDesktop) {
      unawaited(profilesAction.addProfileFormQrCode());
      return;
    }
    final url = await BaseNavigator.push(context, const ScanPage());
    if (url != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_handleAddUrl(profilesAction, url));
      });
    }
  }

  Future<void> _toAdd(WidgetRef ref) async {
    final profilesAction = ref.read(profilesActionProvider.notifier);
    final result = await dialogs.showCommonDialog<URLFormDialogResult>(
      child: const URLFormDialog(),
    );
    if (result == null) return;
    final url = result.url.trim();
    if (url.isEmpty) return;
    if (!url.isUrl && !url.startsWith('incy://') && !url.startsWith('happ://')) {
      unawaited(
        profilesAction.addProfileFromLocalContent(
          url,
          keepCurrentPage: keepCurrentPage,
        ),
      );
      return;
    }
    unawaited(
      _handleAddUrl(
        profilesAction,
        url,
        client: result.client,
        customUserAgent: result.customUserAgent,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    return ListView(
      children: [
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
            AnimatedSize(
              duration: midDuration,
              curve: Curves.easeOutQuad,
              alignment: Alignment.topCenter,
              child: _isMore
                  ? ClientPresetSelector(
                      selected: _client,
                      onChanged: (value) => setState(() => _client = value),
                      customUserAgentController: _customUserAgentController,
                    )
                  : const SizedBox(width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }
}
