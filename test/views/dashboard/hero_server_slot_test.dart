import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/dashboard/widgets/active_server.dart';
import 'package:reclash/views/dashboard/widgets/hero/hero_connect.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_app.dart';
import '../../helpers/test_profiles.dart';

class _TestDesyncSetting extends DesyncSetting {
  _TestDesyncSetting(this._initial);

  final DesyncProps _initial;

  @override
  DesyncProps build() => _initial;
}

const _profile = Profile(
  id: 1,
  label: 'Test profile',
  autoUpdateDuration: Duration.zero,
);

const _serverKey = ValueKey('server-ready');
const _loadingKey = ValueKey('server-loading');
const _noneKey = ValueKey('server-none');

ActiveServerInfo _server({String displayName = ''}) => ActiveServerInfo(
  name: displayName,
  displayName: displayName,
  countryCode: displayName.isEmpty ? null : 'US',
  testUrl: null,
  delay: displayName.isEmpty ? null : 42,
  measuring: false,
  otherCodes: const [],
  otherLocations: 0,
  smartRouting: false,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ProviderContainer> pumpHero(
    WidgetTester tester, {
    required ActiveServerInfo Function() server,
    List<Group> groups = const [],
  }) async {
    tester.view.physicalSize = const Size(900, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(() => TestProfiles(const [_profile])),
        currentProfileIdProvider.overrideWithBuild((_, _) => _profile.id),
        desyncSettingProvider.overrideWith(
          () => _TestDesyncSetting(const DesyncProps()),
        ),
        byeDpiSupportedProvider.overrideWithValue(true),
        groupsProvider.overrideWithValue(groups),
        activeServerProvider.overrideWith((ref) => server()),
        initProvider.overrideWithBuild((_, _) => true),
        coreStatusProvider.overrideWithBuild((_, _) => CoreStatus.connected),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container
        .read(viewSizeProvider.notifier)
        .update((_) => const Size(900, 1600));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: Scaffold(body: HeroConnect())),
      ),
    );
    await tester.pump();
    return container;
  }

  testWidgets('shows the server card when a server is active', (tester) async {
    await pumpHero(tester, server: () => _server(displayName: 'Tokyo'));
    expect(find.byKey(_serverKey), findsOneWidget);
    expect(find.byKey(_loadingKey), findsNothing);
    expect(find.text('Tokyo'), findsWidgets);
  });

  testWidgets('shows the loading shell when servers are still arriving', (
    tester,
  ) async {
    await pumpHero(
      tester,
      server: () => _server(),
      groups: const [Group(type: GroupType.Selector, name: 'GLOBAL')],
    );
    expect(find.byKey(_loadingKey), findsOneWidget);
    expect(find.byKey(_serverKey), findsNothing);
  });

  testWidgets('keeps no card when the subscription has no servers', (
    tester,
  ) async {
    await pumpHero(tester, server: () => _server());
    await tester.pump(const Duration(seconds: 1));
    expect(find.byKey(_serverKey), findsNothing);
    expect(find.byKey(_loadingKey), findsNothing);
    expect(find.byKey(_noneKey), findsOneWidget);
  });

  testWidgets('holds the card through a transient empty, then collapses', (
    tester,
  ) async {
    var current = _server(displayName: 'Tokyo');
    final container = await pumpHero(tester, server: () => current);
    expect(find.byKey(_serverKey), findsOneWidget);

    current = _server();
    container.invalidate(activeServerProvider);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byKey(_serverKey), findsOneWidget);
    expect(find.byKey(_noneKey), findsNothing);

    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byKey(_serverKey), findsNothing);
    expect(find.byKey(_noneKey), findsOneWidget);
  });
}
