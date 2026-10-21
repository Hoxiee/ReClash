import 'dart:async';

import 'package:reclash/common/common.dart';
import 'package:reclash/pages/scan.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/views/profiles/custom/custom.dart';
import 'package:reclash/features/form/form.dart';
import 'package:reclash/subscriptions/compatibility/clients.dart';
import 'package:reclash/subscriptions/compatibility/settings_form.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _customOpenPause = Duration(milliseconds: 150);

void showAddProfilePage(BuildContext origin) {
  final context = globalState.navigatorKey.currentState!.context;
  showExtend(
    context,
    builder: (context) => CommonScaffold(
      title: context.appLocalizations.addProfile,
      body: AddProfileView(context: context, origin: origin),
    ),
  );
}

class AddProfileView extends ConsumerWidget {
  final BuildContext context;

  /// Where a page the add page leads to opens: the desktop sheet is on the root.
  final BuildContext origin;

  const AddProfileView({
    super.key,
    required this.context,
    required this.origin,
  });

  Future<void> _handleAddProfileFormFile(WidgetRef ref) async {
    unawaited(ref.read(profilesActionProvider.notifier).addProfileFormFile());
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
        unawaited(profilesAction.addProfileFromLink(url));
      });
    }
  }

  Future<void> _toAdd(WidgetRef ref) async {
    final profilesAction = ref.read(profilesActionProvider.notifier);
    final appLocalizations = context.appLocalizations;
    var clientSettings = const SubscriptionClientSettings.forNewProfile();
    var clientSettingsExplicit = false;
    var skippedExisting = 0;
    final preventDuplicates = ref
        .read(appSettingProvider)
        .preventDuplicateProfiles;
    final res = await showNamedUrlsForm(
      context,
      title: appLocalizations.importFromLink,
      urlLabel: appLocalizations.link,
      batchTip: appLocalizations.batchLinkInputTip,
      urlValidator: (value) {
        if (value == null || value.isEmpty) {
          return appLocalizations.emptyTip(appLocalizations.link);
        }
        if (!isProfileLinkInput(value)) {
          return appLocalizations.invalidLinkTip;
        }
        return null;
      },
      existingUrls: preventDuplicates
          ? {
              for (final profile in ref.read(profilesProvider))
                if (profile.url.isNotEmpty) profile.url.trim(),
            }
          : const {},
      allowDuplicates: !preventDuplicates,
      withAgeSecretKey: true,
      urlMaxLength: urlSchemeMaxLength,
      onBatchSkipped: (value) => skippedExisting = value,
      ageFollowUpBuilder: (context, rebuild) => SubscriptionSendHwidRow(
        value: clientSettings.sendDeviceIdentity,
        onChanged: (value) {
          clientSettings = clientSettings.copyWith(sendDeviceIdentity: value);
          clientSettingsExplicit = true;
          rebuild();
        },
      ),
      additionalValidator: () => clientSettings.isValid
          ? null
          : appLocalizations.subscriptionClientCustomUserAgentInvalid,
      additionalSectionsBuilder: (context, onChanged) =>
          SubscriptionClientSettingsSection(
            initial: clientSettings,
            onChanged: (value) {
              clientSettings = value;
              clientSettingsExplicit = true;
            },
            onFormChanged: onChanged,
          ),
    );
    switch (res) {
      case null:
        return;
      case [final single]:
        unawaited(
          profilesAction.addProfileFromLink(
            single.url,
            label: single.label,
            ageSecretKey: single.ageSecretKey,
            clientSettings: single.url.isShareLink || !clientSettingsExplicit
                ? null
                : clientSettings,
          ),
        );
      default:
        unawaited(
          profilesAction.addProfilesFromLinks(
            res,
            clientSettings: clientSettingsExplicit ? clientSettings : null,
            skippedExisting: skippedExisting,
          ),
        );
    }
  }

  Future<void> _toAddCustom(BuildContext context, WidgetRef ref) async {
    final profilesAction = ref.read(profilesActionProvider.notifier);
    final label = context.appLocalizations.unnamed;
    Widget editor() => CustomProfileView(
      profileId: profilesAction.addCustomProfile(label),
      isNew: true,
    );
    final navigator = Navigator.of(context);
    if (!origin.mounted || Navigator.of(origin) == navigator) {
      unawaited(BaseNavigator.pushReplacement(context, editor()));
      return;
    }
    // The sheet sits above origin's navigator: a page opened there before the
    // sheet has gone fades in beneath it.
    navigator.pop();
    await whenRouteSettled(context);
    await Future<void>.delayed(_customOpenPause);
    if (origin.mounted) {
      unawaited(BaseNavigator.push(origin, editor()));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    return ListView(
      padding: EdgeInsets.only(top: context.contentTopPadding, bottom: 16),
      children: [
        ListItem(
          leading: const GlyphIcon(AppGlyphs.qrCode),
          title: Text(appLocalizations.qrcode),
          subtitle: Text(appLocalizations.qrcodeDesc),
          onTap: () => _toScan(ref),
        ),
        ListItem(
          leading: const GlyphIcon(AppGlyphs.importFile),
          title: Text(appLocalizations.file),
          subtitle: Text(appLocalizations.fileDesc),
          onTap: () => _handleAddProfileFormFile(ref),
        ),
        ListItem(
          leading: const GlyphIcon(AppGlyphs.cloudDownload),
          title: Text(appLocalizations.link),
          subtitle: Text(appLocalizations.linkDesc),
          onTap: () => _toAdd(ref),
        ),
        ListItem(
          leading: const GlyphIcon(AppGlyphs.customize),
          title: Text(appLocalizations.customProfile),
          subtitle: Text(appLocalizations.customProfileDesc),
          onTap: () => _toAddCustom(context, ref),
        ),
      ],
    );
  }
}
