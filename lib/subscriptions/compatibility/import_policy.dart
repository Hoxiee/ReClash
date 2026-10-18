import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../imports/import.dart';

String subscriptionImportScope(String url, String ageSecretKey) =>
    sha256.convert(utf8.encode(jsonEncode([url, ageSecretKey]))).toString();

class SubscriptionImportPolicy {
  const SubscriptionImportPolicy({
    this.scope = '',
    this.format,
    this.ignoredSections = const [],
    this.allowPartialNodes = false,
    this.allowOtherLosses = false,
  });

  final String scope;
  final SubscriptionFormat? format;
  final List<String> ignoredSections;
  final bool allowPartialNodes;
  final bool allowOtherLosses;

  bool get isEmpty => format == null || scope.isEmpty;

  bool allows(
    SubscriptionFormat sourceFormat,
    SubscriptionImportSummary summary, {
    required String sourceScope,
  }) {
    if (!summary.hasLosses) return true;
    if (isEmpty || scope != sourceScope || format != sourceFormat) return false;
    if (summary.nodes == 0) return false;
    if (!summary.ignoredSections.every(ignoredSections.contains)) return false;
    final partial =
        summary.skippedNodes.isNotEmpty || summary.skipped.isNotEmpty;
    if (partial && !allowPartialNodes) return false;
    final other =
        summary.hasOtherLosses || summary.ignoredSections.isEmpty && !partial;
    return !other || allowOtherLosses;
  }

  factory SubscriptionImportPolicy.accepted({
    required String scope,
    required SubscriptionFormat format,
    required SubscriptionImportSummary summary,
  }) => SubscriptionImportPolicy(
    scope: scope,
    format: format,
    ignoredSections: List.unmodifiable(summary.ignoredSections.toSet()),
    allowPartialNodes:
        summary.skippedNodes.isNotEmpty || summary.skipped.isNotEmpty,
    allowOtherLosses:
        summary.hasOtherLosses ||
        summary.hasLosses &&
            summary.ignoredSections.isEmpty &&
            summary.skippedNodes.isEmpty &&
            summary.skipped.isEmpty,
  );

  Map<String, Object?> toJson() => {
    'scope': scope,
    'format': format?.name,
    'ignoredSections': ignoredSections,
    'allowPartialNodes': allowPartialNodes,
    'allowOtherLosses': allowOtherLosses,
  };

  static SubscriptionImportPolicy safeFromJson(Object? value) {
    if (value is! Map) return const SubscriptionImportPolicy();
    final scope = value['scope'];
    final format = SubscriptionFormat.values
        .where((item) => item.name == value['format'])
        .firstOrNull;
    final sections = value['ignoredSections'];
    if (scope is! String ||
        !RegExp(r'^[a-f0-9]{64}$').hasMatch(scope) ||
        format == null ||
        format == SubscriptionFormat.unknown ||
        format == SubscriptionFormat.encrypted ||
        sections is! List ||
        sections.length > 64 ||
        sections.any(
          (item) =>
              item is! String ||
              item.length > 128 ||
              item.contains(RegExp(r'[\x00-\x1f\x7f]')),
        )) {
      return const SubscriptionImportPolicy();
    }
    return SubscriptionImportPolicy(
      scope: scope,
      format: format,
      ignoredSections: List.unmodifiable(sections.cast<String>().toSet()),
      allowPartialNodes: value['allowPartialNodes'] == true,
      allowOtherLosses: value['allowOtherLosses'] == true,
    );
  }
}

class SubscriptionImportApproval {
  const SubscriptionImportApproval({this.rememberedPolicy});

  final SubscriptionImportPolicy? rememberedPolicy;
}
