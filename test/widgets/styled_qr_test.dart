import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

void main() {
  testWidgets('renders a themed styled QR without a logo', (tester) async {
    await tester.pumpWidget(
      const TestApp(
        includeNavigatorKey: false,
        child: Center(
          child: StyledQrCode(data: 'https://example.com/import'),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(StyledQrCode), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('overlays a center logo when one is given', (tester) async {
    await tester.pumpWidget(
      const TestApp(
        includeNavigatorKey: false,
        child: Center(
          child: StyledQrCode(
            data: 'https://example.com/import',
            logo: SizedBox.square(dimension: 24),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    final size = tester.getSize(find.byType(StyledQrCode));
    expect(size, const Size(220, 220));
  });

  testWidgets('falls back to a blank box when data overflows the symbol', (
    tester,
  ) async {
    await tester.pumpWidget(
      TestApp(
        includeNavigatorKey: false,
        child: Center(child: StyledQrCode(data: 'x' * 4000)),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byType(StyledQrCode), findsOneWidget);
  });
}
