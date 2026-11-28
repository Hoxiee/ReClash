import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:prism_ui/measure.dart';
import 'package:prism_ui/theme_data.dart' as prism;
import 'package:reclash/ui/app_theme.dart';
import 'package:reclash/ui/prism_theme.dart';
import 'package:reclash/ui/surface.dart';

void main() {
  testWidgets('a lifted sheet mirrors the elevated theme', (tester) async {
    final theme = buildAppTheme(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6750A4),
        brightness: Brightness.dark,
      ),
      locales: const [Locale('en')],
    );
    prism.ThemeData? page;
    prism.ThemeData? sheet;
    Measure? pageMeasure;
    Measure? sheetMeasure;
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        themeMode: ThemeMode.dark,
        builder: (context, child) => PrismThemeBridge(child: child!),
        home: Builder(
          builder: (context) {
            page = prism.Theme.of(context);
            pageMeasure = MeasureScope.of(context);
            return ElevatedSurfaceTheme(
              child: Builder(
                builder: (context) {
                  sheet = prism.Theme.of(context);
                  sheetMeasure = MeasureScope.of(context);
                  return const SizedBox.shrink();
                },
              ),
            );
          },
        ),
      ),
    );

    expect(page, isNotNull);
    expect(sheet, isNotNull);
    expect(
      sheet!.scaffoldBackgroundColor,
      isNot(page!.scaffoldBackgroundColor),
    );
    expect(sheet!.tooltipTheme, isNotNull);
    expect(sheetMeasure, same(pageMeasure));
  });
}
