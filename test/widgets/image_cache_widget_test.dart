import 'package:reclash/widgets/base/icon.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

void main() {
  testWidgets('renders an asset SVG without the remote cache path', (
    tester,
  ) async {
    await tester.pumpWidget(
      const TestApp(
        includeNavigatorKey: false,
        child: ImageCacheWidget(
          src: 'asset:assets/images/developer/developer_prism.svg',
          fit: BoxFit.contain,
          defaultWidget: Icon(Icons.error_outline),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(SvgPicture), findsOne);
    expect(find.byIcon(Icons.error_outline), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
