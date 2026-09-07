import 'panel_meta.dart';
import 'profile.dart';

enum DeveloperSubscriptionId { prism, orbit, atlas }

class DeveloperSubscription {
  const DeveloperSubscription({
    required this.id,
    required this.name,
    required this.configAsset,
    required this.logo,
    required this.panelMeta,
    this.subscriptionInfo,
  });

  final DeveloperSubscriptionId id;
  final String name;
  final String configAsset;
  final String logo;
  final PanelMeta panelMeta;
  final SubscriptionInfo? subscriptionInfo;
}

const developerSubscriptions = <DeveloperSubscription>[
  DeveloperSubscription(
    id: DeveloperSubscriptionId.prism,
    name: 'Prism Lab',
    configAsset: 'assets/data/developer_prism.yaml',
    logo: 'asset:assets/images/developer_prism.svg',
    panelMeta: PanelMeta(
      serviceName: 'Prism Lab',
      serviceLogo: 'asset:assets/images/developer_prism.svg',
      accountUsername: 'brand.tester',
      themeHex: '6E55F5:tonalspot',
      heroRing: '2E5BFF;7A36F0;FF5A8A',
    ),
  ),
  DeveloperSubscription(
    id: DeveloperSubscriptionId.orbit,
    name: 'Orbit Pass',
    configAsset: 'assets/data/developer_orbit.yaml',
    logo: 'asset:assets/images/developer_orbit.svg',
    panelMeta: PanelMeta(
      announce:
          'Planned maintenance: test the announcement, quota, and offer cards.',
      supportUrl: 'https://example.com/support',
      updateIntervalMinutes: 45,
      serviceName: 'Orbit Pass',
      serviceLogo: 'asset:assets/images/developer_orbit.svg',
      buyPlanUrl: 'https://example.com/plans',
      buyTrafficUrl: 'https://example.com/traffic',
      newDomain: 'next.orbit.example',
      accountUsername: 'quota.tester',
    ),
    subscriptionInfo: SubscriptionInfo(
      upload: 18 * 1024 * 1024 * 1024,
      download: 146 * 1024 * 1024 * 1024,
      total: 500 * 1024 * 1024 * 1024,
      expire: 1893456000,
    ),
  ),
  DeveloperSubscription(
    id: DeveloperSubscriptionId.atlas,
    name: 'Atlas Nodes',
    configAsset: 'assets/data/developer_atlas.yaml',
    logo: 'asset:assets/images/developer_atlas.svg',
    panelMeta: PanelMeta(
      announce: 'Provider-controlled dashboard layout is active.',
      supportUrl: 'https://example.com/atlas',
      serviceName: 'Atlas Nodes',
      serviceLogo: 'asset:assets/images/developer_atlas.svg',
      serverInfoGroup: 'Atlas Select',
      widgets: [
        'networkSpeed',
        'announce',
        'serviceInfo',
        'changeServerButton',
        'networkDetection',
        'trafficUsage',
      ],
      widgetsApplyMode: PanelWidgetsApplyMode.update,
      accountUsername: 'layout.tester',
      proxiesView:
          'type:list; sort:delay; layout:tight; icon:standard; card:min',
    ),
  ),
];
