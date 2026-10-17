import 'package:drift/native.dart';
import 'package:reclash/core/controller.dart';
import 'package:reclash/core/interface.dart';
import 'package:reclash/database/database.dart' as db;
import 'package:reclash/enum/enum.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/providers/action.dart';
import 'package:reclash/providers/core.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';

class _MockCoreHandlerInterface extends Mock implements CoreHandlerInterface {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late db.Database testDatabase;
  late ProviderContainer container;
  late Map<String, int> requests;

  setUpAll(() => AppLocalizations.load(const Locale('en')));

  setUp(() {
    testDatabase = db.Database(NativeDatabase.memory());
    db.database = testDatabase;
    requests = {};
    final core = _MockCoreHandlerInterface();
    when(() => core.updateGeoData(any())).thenAnswer((invocation) async {
      final name = invocation.positionalArguments.single as String;
      final count = requests[name] = (requests[name] ?? 0) + 1;
      return count == 1 ? '' : 'geo update already in progress';
    });
    container = ProviderContainer(
      overrides: [
        coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await testDatabase.close();
  });

  test(
    'an update all that overlaps one running skips what that one runs',
    () async {
      final action = container.read(resourcesActionProvider.notifier);

      final failures = await Future.wait([
        action.updateAll(),
        action.updateAll(),
      ]);

      expect(failures.expand((items) => items), isEmpty);
      expect(requests, {
        for (final geoResource in GeoResource.values) geoResource.name: 1,
      });
    },
  );
}
