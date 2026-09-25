import 'package:reclash/enum/enum.dart';
import 'package:reclash/views/dashboard/widgets/widgets.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';

extension DashboardWidgetView on DashboardWidget {
  GridItem get widget => switch (this) {
    DashboardWidget.networkSpeed => const GridItem(
      key: ValueKey(DashboardWidget.networkSpeed),
      crossAxisCellCount: 8,
      child: NetworkSpeed(),
    ),
    DashboardWidget.outboundModeV2 => const GridItem(
      key: ValueKey(DashboardWidget.outboundModeV2),
      crossAxisCellCount: 8,
      child: OutboundModeV2(),
    ),
    DashboardWidget.outboundMode => const GridItem(
      key: ValueKey(DashboardWidget.outboundMode),
      crossAxisCellCount: 4,
      child: OutboundMode(),
    ),
    DashboardWidget.trafficUsage => const GridItem(
      key: ValueKey(DashboardWidget.trafficUsage),
      crossAxisCellCount: 4,
      child: TrafficUsage(),
    ),
    DashboardWidget.networkDetection => const GridItem(
      key: ValueKey(DashboardWidget.networkDetection),
      crossAxisCellCount: 4,
      child: NetworkDetection(),
    ),
    DashboardWidget.tunButton => const GridItem(
      key: ValueKey(DashboardWidget.tunButton),
      crossAxisCellCount: 4,
      child: TUNButton(),
    ),
    DashboardWidget.vpnButton => const GridItem(
      key: ValueKey(DashboardWidget.vpnButton),
      crossAxisCellCount: 4,
      child: VpnButton(),
    ),
    DashboardWidget.systemProxyButton => const GridItem(
      key: ValueKey(DashboardWidget.systemProxyButton),
      crossAxisCellCount: 4,
      child: SystemProxyButton(),
    ),
    DashboardWidget.intranetIp => const GridItem(
      key: ValueKey(DashboardWidget.intranetIp),
      crossAxisCellCount: 4,
      child: IntranetIP(),
    ),
    DashboardWidget.memoryInfo => const GridItem(
      key: ValueKey(DashboardWidget.memoryInfo),
      crossAxisCellCount: 4,
      child: MemoryInfo(),
    ),
    DashboardWidget.goroutineInfo => const GridItem(
      key: ValueKey(DashboardWidget.goroutineInfo),
      crossAxisCellCount: 4,
      child: GoroutineInfo(),
    ),
    DashboardWidget.metaInfo => const GridItem(
      key: ValueKey(DashboardWidget.metaInfo),
      crossAxisCellCount: 8,
      child: MetaInfo(),
    ),
    DashboardWidget.announce => const GridItem(
      key: ValueKey(DashboardWidget.announce),
      crossAxisCellCount: 8,
      child: Announce(),
    ),
    DashboardWidget.serviceInfo => const GridItem(
      key: ValueKey(DashboardWidget.serviceInfo),
      crossAxisCellCount: 4,
      child: ServiceInfo(),
    ),
    DashboardWidget.changeServerButton => const GridItem(
      key: ValueKey(DashboardWidget.changeServerButton),
      crossAxisCellCount: 4,
      child: ChangeServerButton(),
    ),
    DashboardWidget.smartRouting => const GridItem(
      key: ValueKey(DashboardWidget.smartRouting),
      crossAxisCellCount: 4,
      child: SmartRoutingCard(),
    ),
    DashboardWidget.desyncStrategy => const GridItem(
      key: ValueKey(DashboardWidget.desyncStrategy),
      crossAxisCellCount: 8,
      child: DesyncStrategyCard(),
    ),
    DashboardWidget.desyncTest => const GridItem(
      key: ValueKey(DashboardWidget.desyncTest),
      crossAxisCellCount: 4,
      child: DesyncTestCard(),
    ),
    DashboardWidget.desyncEngine => const GridItem(
      key: ValueKey(DashboardWidget.desyncEngine),
      crossAxisCellCount: 4,
      child: DesyncEngineCard(),
    ),
    DashboardWidget.serviceStatus => const GridItem(
      key: ValueKey(DashboardWidget.serviceStatus),
      crossAxisCellCount: 8,
      child: ServiceStatusCard(),
    ),
    DashboardWidget.connections => const GridItem(
      key: ValueKey(DashboardWidget.connections),
      crossAxisCellCount: 4,
      child: ConnectionsCard(),
    ),
    DashboardWidget.dnsQueries => const GridItem(
      key: ValueKey(DashboardWidget.dnsQueries),
      crossAxisCellCount: 4,
      child: DnsQueriesCard(),
    ),
    DashboardWidget.requests => const GridItem(
      key: ValueKey(DashboardWidget.requests),
      crossAxisCellCount: 4,
      child: RequestsCard(),
    ),
    DashboardWidget.runTime => const GridItem(
      key: ValueKey(DashboardWidget.runTime),
      crossAxisCellCount: 4,
      child: RunTimeCard(),
    ),
    DashboardWidget.proxyGroups => const GridItem(
      key: ValueKey(DashboardWidget.proxyGroups),
      crossAxisCellCount: 4,
      child: ProxyGroupsCard(),
    ),
    DashboardWidget.profiles => const GridItem(
      key: ValueKey(DashboardWidget.profiles),
      crossAxisCellCount: 4,
      child: ProfilesCard(),
    ),
    DashboardWidget.overrideDnsButton => const GridItem(
      key: ValueKey(DashboardWidget.overrideDnsButton),
      crossAxisCellCount: 4,
      child: OverrideDnsButton(),
    ),
  };
}

DashboardWidget dashboardWidgetOf(GridItem gridItem) {
  return (gridItem.key! as ValueKey<DashboardWidget>).value;
}
