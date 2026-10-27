import 'package:flutter/foundation.dart';

enum SpeedTestMode { complete, latencyOnly }

@immutable
class SpeedTestSettings {
  const SpeedTestSettings({
    this.backendId = 'cloudflare',
    this.mode = SpeedTestMode.complete,
    this.budgetMiB = 100,
    this.alwaysConfirm = false,
  });

  static const budgets = [25, 50, 100, 250, 500, 1024];

  final String backendId;
  final SpeedTestMode mode;
  final int budgetMiB;
  final bool alwaysConfirm;

  int get byteLimit => budgetMiB * 1024 * 1024;

  static SpeedTestSettings safeFromJson(Object? value) {
    if (value is! Map) return const SpeedTestSettings();
    return SpeedTestSettings(
      backendId: switch (value['backendId']) {
        final String id when id.isNotEmpty => id,
        _ => 'cloudflare',
      },
      mode: value['mode'] == SpeedTestMode.latencyOnly.name
          ? SpeedTestMode.latencyOnly
          : SpeedTestMode.complete,
      budgetMiB: budgets.contains(value['budgetMiB'])
          ? value['budgetMiB'] as int
          : 100,
      alwaysConfirm: value['alwaysConfirm'] == true,
    );
  }

  Map<String, Object?> toJson() => {
    'backendId': backendId,
    'mode': mode.name,
    'budgetMiB': budgetMiB,
    'alwaysConfirm': alwaysConfirm,
  };

  SpeedTestSettings copyWith({
    String? backendId,
    SpeedTestMode? mode,
    int? budgetMiB,
    bool? alwaysConfirm,
  }) => SpeedTestSettings(
    backendId: backendId ?? this.backendId,
    mode: mode ?? this.mode,
    budgetMiB: budgetMiB ?? this.budgetMiB,
    alwaysConfirm: alwaysConfirm ?? this.alwaysConfirm,
  );

  @override
  bool operator ==(Object other) =>
      other is SpeedTestSettings &&
      backendId == other.backendId &&
      mode == other.mode &&
      budgetMiB == other.budgetMiB &&
      alwaysConfirm == other.alwaysConfirm;

  @override
  int get hashCode => Object.hash(backendId, mode, budgetMiB, alwaysConfirm);
}
