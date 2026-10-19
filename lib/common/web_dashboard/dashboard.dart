import 'package:reclash/enum/enum.dart';

const webDashboardDirectoryName = 'web-dashboard';
const webDashboardWorkDirectoryName = '.web-dashboard-work';
const webDashboardEntryName = 'index.html';
const webDashboardManifestName = '.reclash-panel.json';
const webDashboardMaxDownloadBytes = 64 * 1024 * 1024;
const webDashboardMaxExtractedBytes = 256 * 1024 * 1024;
const webDashboardMaxFileBytes = 32 * 1024 * 1024;
const webDashboardMaxFiles = 10000;

class WebDashboardRelease {
  const WebDashboardRelease({
    required this.version,
    required this.url,
    required this.sha256,
  });

  final String version;
  final String url;
  final String sha256;
}

extension WebDashboardFlavorRelease on WebDashboardFlavor {
  WebDashboardRelease get release => switch (this) {
    WebDashboardFlavor.zashboard => const WebDashboardRelease(
      version: '3.26.0',
      url:
          'https://github.com/Zephyruso/zashboard/releases/download/'
          'v3.26.0/dist-no-fonts.zip',
      sha256:
          '5b4cf64e6c9e36767d7245d2275d1f64c91d576a74ecf0d51cec53e9b13344c1',
    ),
    WebDashboardFlavor.metacubexd => const WebDashboardRelease(
      version: '1.273.1',
      url:
          'https://github.com/MetaCubeX/metacubexd/releases/download/'
          'v1.273.1/compressed-dist.tgz',
      sha256:
          'a178e00b67acabcda2dcef00afa90be6a7bb261e466a67dad58c8478d9553603',
    ),
  };
}

class WebDashboardException implements Exception {
  const WebDashboardException(this.failure);

  final WebDashboardFailure failure;

  @override
  String toString() => 'WebDashboardException(${failure.name})';
}

class WebDashboardInstallation {
  const WebDashboardInstallation({required this.version});

  final String version;
}

class WebDashboardProgress {
  const WebDashboardProgress(this.phase, {this.received = 0, this.total = 0});

  final WebDashboardPhase phase;
  final int received;
  final int total;
}

class WebDashboardEndpoint {
  const WebDashboardEndpoint({required this.controller, required this.secret});

  final Uri controller;
  final String secret;

  Uri uriFor(WebDashboardFlavor flavor) {
    final query = Uri(
      queryParameters: {
        'hostname': controller.host,
        'port': '${controller.port}',
        'secret': secret,
        if (flavor == WebDashboardFlavor.zashboard) ...{
          'protocol': controller.scheme,
          'label': 'ReClash',
          'disableUpgradeCore': '1',
          'disableTunMode': '1',
        } else
          controller.scheme: '1',
      },
    ).query;
    return controller.replace(
      path: '/ui/${flavor.name}/',
      query: '',
      fragment: '/setup?$query',
    );
  }

  @override
  String toString() => 'WebDashboardEndpoint(${controller.origin})';
}
