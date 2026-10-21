import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/about.dart';

Widget preview() => const AboutView();

Future<void> previewSetUp() async {
  globalState.packageInfo = PackageInfo(
    appName: 'ReClash',
    packageName: 'com.reclash',
    version: '1.0.0',
    buildNumber: '1',
  );
}
