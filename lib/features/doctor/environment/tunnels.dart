import 'dart:io';

import 'facts.dart';

/// One kernel route, reduced to what tunnel detection reads.
final class RouteEntry {
  const RouteEntry({
    required this.adapter,
    required this.destination,
    required this.prefix,
    this.metric,
  });

  /// The adapter's name, whatever the OS calls the key.
  final String adapter;
  final InternetAddress destination;
  final int prefix;
  final int? metric;

  /// `0.0.0.0/0`, `::/0`, or half of a split default (`0/1` and `128/1`).
  bool get isDefault {
    final bytes = destination.rawAddress;
    final zero = bytes.every((b) => b == 0);
    if (prefix == 0) return zero;
    if (prefix != 1) return false;
    if (destination.type == InternetAddressType.IPv4) {
      return bytes[0] == 0 && bytes.skip(1).every((b) => b == 0) ||
          bytes[0] == 128 && bytes.skip(1).every((b) => b == 0);
    }
    return bytes.skip(1).every((b) => b == 0) &&
        (bytes[0] == 0 || bytes[0] == 0x80);
  }
}

/// An adapter that is up, with what its name and description reveal.
final class AdapterInfo {
  const AdapterInfo({required this.name, this.description = ''});

  final String name;
  final String description;
}

TunnelKind? classifyTunnel(String name, [String description = '']) {
  final n = name.toLowerCase();
  final d = description.toLowerCase();
  if (d.contains('wintun') || n.contains('wintun')) return TunnelKind.wintun;
  if (d.contains('wireguard') || RegExp(r'^wg\d').hasMatch(n)) {
    return TunnelKind.wireguard;
  }
  if (d.contains('tap-windows') ||
      d.contains('tap-win') ||
      n.startsWith('tap')) {
    return TunnelKind.tap;
  }
  if (n.startsWith('utun')) return TunnelKind.utun;
  if (RegExp(r'^tun\d*$').hasMatch(n)) return TunnelKind.tun;
  return null;
}

/// The adapter of the lowest-metric route that contains [target], longest
/// prefix first; null when nothing matches.
String? bestRouteAdapter(Iterable<RouteEntry> routes, InternetAddress target) {
  final want = target.rawAddress;
  RouteEntry? best;
  for (final route in routes) {
    final bytes = route.destination.rawAddress;
    if (bytes.length != want.length || !_covers(bytes, route.prefix, want)) {
      continue;
    }
    if (best == null ||
        route.prefix > best.prefix ||
        route.prefix == best.prefix &&
            (route.metric ?? 0) < (best.metric ?? 0)) {
      best = route;
    }
  }
  return best?.adapter;
}

bool _covers(List<int> network, int prefix, List<int> address) {
  for (var bit = 0; bit < prefix; bit += 8) {
    final i = bit ~/ 8;
    final bits = prefix - bit >= 8 ? 8 : prefix - bit;
    final mask = (0xFF << (8 - bits)) & 0xFF;
    if ((network[i] & mask) != (address[i] & mask)) return false;
  }
  return true;
}

/// Builds the tunnels fact from adapters that are up. [ours] is the device
/// name of our TUN, null when it is off. [adapters] holds every up adapter
/// the OS lists; non-tunnels are dropped here. [checkRouting] is false where
/// policy routing hides the real table, as on Linux.
TunnelsFact buildTunnels({
  required Iterable<AdapterInfo> adapters,
  required Iterable<RouteEntry> routes,
  String? ours,
  bool checkRouting = true,
}) {
  TunnelAdapter? own;
  final foreign = <TunnelAdapter>[];
  for (final adapter in adapters) {
    final isOurs = ours != null && adapter.name == ours;
    final kind =
        classifyTunnel(adapter.name, adapter.description) ??
        (isOurs ? TunnelKind.other : null);
    if (kind == null) continue;
    final defaults = [
      for (final route in routes)
        if (route.adapter == adapter.name && route.isDefault) route,
    ];
    final metrics = [
      for (final route in defaults)
        if (route.metric != null) route.metric!,
    ]..sort();
    final tunnel = TunnelAdapter(
      name: adapter.name,
      kind: kind,
      description: adapter.description,
      defaultRoute: defaults.isNotEmpty,
      metric: metrics.isEmpty ? null : metrics.first,
    );
    if (isOurs) {
      own = tunnel;
    } else {
      foreign.add(tunnel);
    }
  }
  bool? through;
  if (own != null && checkRouting) {
    final best = bestRouteAdapter(routes, InternetAddress('1.1.1.1'));
    through = best == null ? null : best == own.name;
  }
  return TunnelsFact(ours: own, foreign: foreign, routedThroughOurs: through);
}
