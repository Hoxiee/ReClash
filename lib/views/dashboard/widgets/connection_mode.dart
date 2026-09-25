import 'package:reclash/enum/enum.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/dashboard/widgets/hero/hero_status.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ByeDPI-only is a separate engine rather than a switch inside the tunnel, so
/// every dashboard surface reads which one it is describing from here.
final dashboardModeProvider = Provider<DashboardMode>((ref) {
  final byedpi = ref.watch(
    effectiveDesyncSettingProvider.select(
      (state) => state.enabled && state.onlyDpi,
    ),
  );
  return byedpi ? DashboardMode.byedpi : DashboardMode.vpn;
});

String connectionModeLabel(
  AppLocalizations appLocalizations,
  DashboardMode mode,
) => switch (mode) {
  DashboardMode.vpn => appLocalizations.desyncModeVpn,
  DashboardMode.byedpi => appLocalizations.desyncModeByedpi,
};

Glyph connectionModeIcon(DashboardMode mode) => switch (mode) {
  DashboardMode.vpn => AppGlyphs.vpn,
  DashboardMode.byedpi => AppGlyphs.shield,
};

bool changeDashboardMode(WidgetRef ref, DashboardMode mode) {
  if (mode == DashboardMode.byedpi && !ref.read(byeDpiAvailableProvider)) {
    return false;
  }
  final lifecycle = ref.read(heroLifecycleProvider);
  if (lifecycle == HeroOrbPhase.connecting ||
      lifecycle == HeroOrbPhase.reconnecting) {
    return false;
  }
  if (ref.read(dashboardModeProvider) == mode) {
    return true;
  }
  ref
      .read(desyncSettingProvider.notifier)
      .update(
        (state) => mode == DashboardMode.byedpi
            ? state.copyWith(enabled: true, onlyDpi: true)
            : state.copyWith(enabled: false, onlyDpi: false),
      );
  return true;
}
