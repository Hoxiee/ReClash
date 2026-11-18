import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/features/form/form.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/views/proxies/routing.dart';
import 'package:reclash/views/proxies/routing_choice.dart';

import '../../helpers/preferences.dart';
import '../../helpers/test_app.dart';

class _FakeAction extends RcxRoutingAction {
  @override
  Future<RcxStudioResult?> studio(Map<String, Object?> request) async => null;
}

class _Layers extends StatefulWidget {
  const _Layers({required this.a, required this.b});

  final Map<String, Object?> a;
  final Map<String, Object?> b;

  @override
  State<_Layers> createState() => _LayersState();
}

class _LayersState extends State<_Layers> {
  late Map<String, Object?> a = widget.a;
  late Map<String, Object?> b = widget.b;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: RoutingChoiceSection(
        layers: [
          RcxChoiceLayer(
            value: a,
            fields: rcxProgramFields,
            onChanged: (next) => setState(() => a = next),
          ),
          RcxChoiceLayer(
            value: b,
            fields: RcxChoiceField.values.toSet(),
            onChanged: (next) => setState(() => b = next),
          ),
        ],
        servers: const ['NL-1', 'NL-2', 'DE-1'],
      ),
    );
  }
}

Finder _menuItem(String label) => find.descendant(
  of: find.byType(CommonPopupMenu),
  matching: find.text(label),
);

void main() {
  late AppLocalizations l;

  setUpAll(() async {
    await mockPreferences();
    l = await AppLocalizations.load(const Locale('en'));
  });

  Future<_LayersState> pumpLayers(
    WidgetTester tester, {
    Map<String, Object?> a = const {},
    Map<String, Object?> b = const {},
  }) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      TestApp(
        overrides: [
          rcxLibraryProvider.overrideWith((_) async => const []),
          rcxRoutingActionProvider.overrideWith(_FakeAction.new),
        ],
        child: _Layers(a: a, b: b),
      ),
    );
    await tester.pumpAndSettle();
    return tester.state<_LayersState>(find.byType(_Layers));
  }

  Future<void> writePool(WidgetTester tester, String pattern) async {
    await tester.tap(find.text(l.rcxServers));
    await tester.pumpAndSettle();
    final row = find.ancestor(
      of: find.text(l.rcxServersPattern),
      matching: find.byType(FormRow),
    );
    await tester.enterText(
      find.descendant(of: row, matching: find.byType(TextField)),
      pattern,
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
  }

  testWidgets('a pool no layer sets is written to the widest layer', (
    tester,
  ) async {
    final layers = await pumpLayers(tester);

    await writePool(tester, 'NL');

    expect(layers.a, isEmpty);
    expect(layers.b, {
      'pool': {'include': rcxIncludeOf('NL')},
    });
  });

  testWidgets('a pool the first layer sets is written to that layer', (
    tester,
  ) async {
    final layers = await pumpLayers(
      tester,
      a: {
        'pool': {'include': rcxIncludeOf('DE')},
      },
    );

    await writePool(tester, 'NL');

    expect(layers.a, {
      'pool': {'include': rcxIncludeOf('NL')},
    });
    expect(layers.b, isEmpty);
  });

  testWidgets('feel and energy are written to the widest layer', (
    tester,
  ) async {
    final layers = await pumpLayers(tester);

    await tester.tap(find.text(l.rcxSwitching));
    await tester.pumpAndSettle();
    await tester.tap(_menuItem(rcxFeelLabel(l, 'eager')));
    await tester.pumpAndSettle();

    await tester.tap(find.text(l.rcxChecks));
    await tester.pumpAndSettle();
    await tester.tap(_menuItem(rcxEnergyLabel(l, 'precise')));
    await tester.pumpAndSettle();

    expect(layers.a, isEmpty);
    expect(layers.b, {'feel': 'eager', 'energy': 'precise'});
  });
}
