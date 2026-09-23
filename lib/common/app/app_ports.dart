import 'package:reclash/common/util/provider_reader.dart';
import 'package:reclash/models/models.dart';
import 'package:flutter/widgets.dart';

abstract interface class WindowPort {
  Future<WindowProps?> captureNormalGeometry(WindowProps current);

  Future<void> show();

  Future<void> hide();

  Future<void> toggle();

  Future<void> close();

  void forceExit();
}

abstract interface class TrayPort {
  Future<void> shutdown();

  Future<void> update({
    required TrayState trayState,
    required Traffic traffic,
    required ProviderReader read,
  });
}

abstract interface class NavigationPort {
  List<NavigationItem> getItems({bool openLogs, bool hasProxies});

  /// The rail's status mark. Injected because it speaks the dashboard's hero
  /// vocabulary, which widgets and managers must not import.
  Widget buildStatusMark();

  void openAbout(BuildContext context);
}

WindowPort? windowPort;
TrayPort? trayPort;
NavigationPort? navigationPort;
