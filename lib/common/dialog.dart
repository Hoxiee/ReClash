import 'dart:async';

import 'package:animations/animations.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

class Dialogs {
  Dialogs._();

  static const _enterDuration = Duration(milliseconds: 300);
  static const _exitDuration = Duration(milliseconds: 200);

  BuildContext get _context => rootNavigatorKey.currentContext!;

  Future<T?> showCommonDialog<T>({
    required Widget child,
    BuildContext? context,
    bool? dismissible,
    bool filter = true,
  }) async {
    final callerContext = context ?? _context;
    return showModal<T>(
      useRootNavigator: false,
      context: callerContext,
      configuration: FadeScaleTransitionConfiguration(
        barrierColor: Colors.black38,
        barrierDismissible: dismissible ?? true,
        transitionDuration: callerContext.motionDuration(_enterDuration),
        reverseTransitionDuration: callerContext.motionDuration(_exitDuration),
      ),
      builder: (_) => ModalFocusScope(child: child),
      filter: filter ? commonFilter : null,
    );
  }

  Future<bool?> showMessage({
    required InlineSpan message,
    BuildContext? context,
    String? title,
    String? confirmText,
    String? cancelText,
    bool cancelable = true,
    bool? dismissible,
    bool dangerous = false,
  }) async {
    // A destructive default should rest on Cancel, so one stray center-press on
    // a remote does not delete or reset.
    final focusCancel = dangerous && cancelable;
    return showCommonDialog<bool>(
      context: context,
      dismissible: dismissible,
      child: Builder(
        builder: (context) {
          final appLocalizations = context.appLocalizations;
          return CommonDialog(
            title: title ?? appLocalizations.tip,
            actions: [
              if (cancelable)
                TextButton(
                  autofocus: focusCancel,
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text(cancelText ?? appLocalizations.cancel),
                ),
              TextButton(
                autofocus: !focusCancel,
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: Text(confirmText ?? appLocalizations.confirm),
              ),
            ],
            child: Container(
              width: 300,
              constraints: const BoxConstraints(maxHeight: 200),
              child: SingleChildScrollView(
                child: SelectableText.rich(
                  TextSpan(
                    style: Theme.of(context).textTheme.labelLarge,
                    children: [message],
                  ),
                  style: const TextStyle(overflow: TextOverflow.visible),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// A Happ deep link forces the Happ preset, but the user may prefer ReClash
  /// to fetch the subscription as itself. Returns the chosen client, or null
  /// when cancelled.
  Future<SubscriptionClient?> showHappImportChoice({
    required String source,
    String? name,
    BuildContext? context,
  }) {
    return showCommonDialog<SubscriptionClient>(
      context: context,
      child: HappImportChoiceDialog(source: source, name: name),
    );
  }

  Future<bool?> showAllUpdatingMessagesDialog(
    List<UpdatingMessage> messages,
  ) async {
    return showCommonDialog<bool>(
      child: Builder(
        builder: (context) {
          final appLocalizations = context.appLocalizations;
          return CommonDialog(
            backgroundColor: context.colorScheme.surfaceContainerLow,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            title: appLocalizations.tip,
            actions: [
              TextButton(
                autofocus: true,
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: Text(appLocalizations.confirm),
              ),
            ],
            child: generateSectionV3(
              items: messages.map(
                (message) => _UpdatingMessageItem(message: message),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<bool> showDisclaimer() async {
    return await showCommonDialog<bool>(
          dismissible: false,
          child: CommonDialog(
            title: currentAppLocalizations.disclaimer,
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(_context).pop<bool>(false);
                },
                child: Text(currentAppLocalizations.exit),
              ),
              TextButton(
                autofocus: true,
                onPressed: () {
                  Navigator.of(_context).pop<bool>(true);
                },
                child: Text(currentAppLocalizations.agree),
              ),
            ],
            child: Text(currentAppLocalizations.disclaimerDesc),
          ),
        ) ??
        false;
  }

  void showNotifier(
    String text, {
    MessageLevel level = MessageLevel.info,
    MessageActionState? actionState,
  }) {
    rootNavigatorKey.currentContext?.showNotifier(
      text,
      level: level,
      actionState: actionState,
    );
  }

  Future<void> openUrl(String url) async {
    final res = await showMessage(
      message: TextSpan(text: url),
      title: currentAppLocalizations.externalLink,
      confirmText: currentAppLocalizations.go,
    );
    if (res != true) {
      return;
    }
    unawaited(launchUrl(Uri.parse(url)));
  }
}

class _UpdatingMessageItem extends StatelessWidget {
  final UpdatingMessage message;

  const _UpdatingMessageItem({required this.message});

  @override
  Widget build(BuildContext context) {
    return DecorationListItem(
      minVerticalPadding: 12,
      title: TooltipText(
        text: Text(message.label, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      subtitle: TooltipText(
        text: Text(
          message.message,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

final dialogs = Dialogs._();

class HappImportChoiceDialog extends StatefulWidget {
  const HappImportChoiceDialog({super.key, required this.source, this.name});

  final String source;
  final String? name;

  @override
  State<HappImportChoiceDialog> createState() => _HappImportChoiceDialogState();
}

class _HappImportChoiceDialogState extends State<HappImportChoiceDialog> {
  SubscriptionClient _client = SubscriptionClient.happ;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final displaySource =
        subscriptionDisplaySource(widget.source) ?? widget.source.trim();
    final name = widget.name?.trim();
    return CommonDialog(
      title: appLocalizations.happImportChoiceTitle,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(appLocalizations.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_client),
          child: Text(appLocalizations.import),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appLocalizations.happImportPrompt,
                  style: context.textTheme.bodyMedium?.toLighter,
                ),
                if (displaySource.isNotEmpty ||
                    (name != null && name.isNotEmpty)) ...[
                  const SizedBox(height: 10),
                  if (name != null && name.isNotEmpty)
                    Text(name, style: context.textTheme.bodyMedium),
                  if (displaySource.isNotEmpty)
                    Text(
                      displaySource,
                      style: context.textTheme.bodySmall?.toLighter,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          RadioGroup<SubscriptionClient>(
            groupValue: _client,
            onChanged: (value) {
              if (value != null) setState(() => _client = value);
            },
            child: Column(
              children: [
                ListItem.radio(
                  value: SubscriptionClient.happ,
                  onTap: () =>
                      setState(() => _client = SubscriptionClient.happ),
                  title: Text(appLocalizations.happImportAsHapp),
                  subtitle: Text(appLocalizations.happImportAsHappDesc),
                ),
                ListItem.radio(
                  value: SubscriptionClient.auto,
                  onTap: () =>
                      setState(() => _client = SubscriptionClient.auto),
                  title: Text(appLocalizations.happImportAsClient),
                  subtitle: Text(appLocalizations.happImportAsClientDesc),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

