import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/features/doctor/fixlink/apply.dart';
import 'package:reclash/features/doctor/fixlink/providers.dart';
import 'package:reclash/features/doctor/fixlink/sheet.dart';
import 'package:reclash/features/doctor/fixlink/verifier.dart';
import 'package:reclash/features/doctor/remedies/remedy.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/subscriptions/metadata/metadata.dart';

import '../../../helpers/preferences.dart';
import '../../../helpers/test_app.dart';
import '../../../helpers/test_profiles.dart';
import '../../../views/doctor/doctor_fakes.dart';
import 'fixture.dart';

class _Kernel extends FakeDoctorKernel {
  final undone = <String>[];

  @override
  Future<RemedyOutcome> apply(String remedyId, {bool confirmed = false}) async {
    applied.add(remedyId);
    return RemedyOutcome(
      remedyId: remedyId,
      status: RemedyStatus.applied,
      canUndo: true,
    );
  }

  @override
  Future<RemedyOutcome> undo(String remedyId) async {
    undone.add(remedyId);
    return RemedyOutcome(remedyId: remedyId, status: RemedyStatus.undone);
  }
}

class _Actions implements FixActions {
  final calls = <String>[];

  @override
  Future<void> updateProfile(int profileId) async => calls.add('update');

  @override
  Future<void> activateProfile(int profileId) async => calls.add('activate');

  @override
  Future<void> selectProxy(int profileId, String group, String node) async =>
      calls.add('select $group $node');

  @override
  Future<void> resetConnections() async => calls.add('reset');

  @override
  Future<void> restartCore() async => calls.add('restart');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() => mockPreferences());

  final profile = Profile.normal(label: 'Saved label').copyWith(
    subscriptionSnapshot: SubscriptionSnapshot(
      metadata: const SubscriptionMetadata({'provider.name': 'Example VPN'}),
      receivedAt: DateTime.utc(2025, 12, 29),
    ),
  );

  Future<(_Kernel, _Actions)> pumpSheet(
    WidgetTester tester,
    String Function() link,
  ) async {
    final kernel = _Kernel();
    final actions = _Actions();
    final service = await tester.runAsync(
      () async => FixLinkService(
        verifier: await fixtureVerifier(
          keys: [
            TrustedKey(
              profileId: profile.id,
              key: await publicKey(await seededKeys()),
            ),
          ],
          reports: [fixtureReport(profileId: profile.id)],
        ),
        kernel: kernel,
        actions: actions,
      ),
    );
    await tester.pumpWidget(
      TestApp(
        locale: const Locale('en'),
        overrides: [
          profilesProvider.overrideWith(() => TestProfiles([profile])),
          fixLinkServiceProvider.overrideWithValue(service!),
        ],
        child: FixLinkSheet(link: link()),
      ),
    );
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
    return (kernel, actions);
  }

  testWidgets('shows who signed the fix and what it does before applying', (
    tester,
  ) async {
    final link = await tester.runAsync(
      () async => signLink(
        fixturePayload(
          fix: [
            {'id': 'proxy.select', 'group': 'Auto', 'node': 'NL-1'},
            {'id': 'overrides.reset'},
          ],
        ),
      ),
    );
    final (kernel, actions) = await pumpSheet(tester, () => link!);
    final l = currentAppLocalizations;

    expect(find.text('Example VPN'), findsOneWidget);
    expect(find.text(l.fixLinkVerified), findsOneWidget);
    expect(find.text(l.fixLinkActionProxySelect('NL-1', 'Auto')), findsOne);
    expect(find.text(l.fixLinkActionOverridesReset), findsOneWidget);
    expect(find.text(l.fixLinkReport(vectorReport)), findsOneWidget);
    expect(actions.calls, isEmpty);
    expect(kernel.applied, isEmpty);

    await tester.tap(find.text(l.fixLinkApply));
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
    expect(actions.calls, ['select Auto NL-1']);
    expect(kernel.applied, ['overrides.reset']);
    expect(find.text(l.fixLinkApplied), findsOneWidget);

    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String;
        }
        return null;
      },
    );
    await tester.tap(find.text(l.fixLinkCopyResult));
    await tester.pumpAndSettle();
    expect(copied, startsWith('$vectorReport · fix applied'));

    await tester.tap(find.text(l.undo));
    await tester.pumpAndSettle();
    expect(kernel.undone, ['overrides.reset']);
  });

  testWidgets('a refused link says why and offers nothing to apply', (
    tester,
  ) async {
    final link = await tester.runAsync(
      () async => signLink(fixturePayload(), keys: await seededKeys(7)),
    );
    final (kernel, actions) = await pumpSheet(tester, () => link!);
    final l = currentAppLocalizations;

    expect(find.text(l.fixLinkRejectedTitle), findsOneWidget);
    expect(find.text(l.fixLinkRejectBadSignature), findsOneWidget);
    expect(find.text(l.fixLinkApply), findsNothing);
    expect(find.text(l.close), findsOneWidget);
    expect(actions.calls, isEmpty);
    expect(kernel.applied, isEmpty);
  });
}
