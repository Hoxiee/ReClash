import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/features/doctor/report/html.dart';
import 'package:reclash/features/doctor/report/report.dart';

ReportData _data() => ReportData.fromJson(
  jsonDecode(
        File(
          'test/features/doctor/report/fixtures/report_data.json',
        ).readAsStringSync(),
      )
      as Map<String, Object?>,
);

String _embedded(String html) => RegExp(
  r'<script id="report" type="application/json">(.*?)</script>',
  dotAll: true,
).firstMatch(html)!.group(1)!;

void main() {
  test('embeds the report data without the config', () {
    final data = _data();
    final html = renderReportHtml(data);
    expect(
      jsonDecode(_embedded(html)),
      jsonDecode(jsonEncode(data.toJson(withConfig: false))),
    );
    expect(html, isNot(contains(data.config!)));
  });

  test('markup in log lines cannot close the data script', () {
    final data = _data().copyWith(
      logs: {
        'core': ['</script><script>alert(1)</script><!--'],
      },
    );
    final html = renderReportHtml(data);
    final embedded = _embedded(html);
    expect(embedded, isNot(contains('<')));
    expect((jsonDecode(embedded) as Map)['logs'], {
      'core': ['</script><script>alert(1)</script><!--'],
    });
  });

  test('blocks network access and themes both brightnesses', () {
    final html = renderReportHtml(_data());
    expect(html, contains("default-src 'none'"));
    expect(html, contains('prefers-color-scheme:dark'));
    expect(RegExp('--bg:#[0-9a-f]{6}').allMatches(html), hasLength(2));
  });
}
