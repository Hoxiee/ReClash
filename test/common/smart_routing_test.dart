import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('presets predefine settings and nothing more', () {
    test('every preset ships the data the engine needs to measure anything', () {
      for (final preset in SmartRoutingPreset.values) {
        final bundle = preset.bundle;
        if (preset == SmartRoutingPreset.off) {
          expect(bundle.openMarkers, isEmpty);
          continue;
        }
        expect(bundle.censorCountries, isNotEmpty, reason: preset.name);
        expect(bundle.canaryForeign, isNotEmpty, reason: preset.name);
        expect(bundle.canaryDomestic, isNotEmpty, reason: preset.name);
        expect(bundle.openMarkers, isNotEmpty, reason: preset.name);
        expect(bundle.domesticMarkers, isNotEmpty, reason: preset.name);
      }
    });

    test('picking a region never turns the engine off', () {
      const props = SmartRoutingProps(enabled: true, waveWidth: 4);
      final applied = props.applyPreset(SmartRoutingPreset.russia);

      expect(applied.enabled, isTrue);
      expect(applied.preset, SmartRoutingPreset.russia);
      expect(applied.waveWidth, SmartRoutingPreset.russia.bundle.waveWidth);
    });

    test('a moved knob is visible, and resetting puts it back', () {
      final edited = const SmartRoutingProps(enabled: true)
          .applyPreset(SmartRoutingPreset.russia)
          .copyWith(dwellSeconds: 600);

      expect(edited.matchesPreset, isFalse);
      expect(edited.applyPreset(edited.preset).matchesPreset, isTrue);
      expect(edited.applyPreset(edited.preset).enabled, isTrue);
    });

    test('the wire payload carries the stored data, not the preset name', () {
      final params = const SmartRoutingProps(
        enabled: true,
      ).applyPreset(SmartRoutingPreset.russia).rcxParams;

      expect(params.preset, 'ru');
      expect(params.defaultsVersion, smartRoutingDefaultsVersion);
      expect(params.censorCountries, ['RU']);
      expect(params.openMarkers.first.statuses, contains(204));
      expect(params.canaryForeign.every((item) => item.contains(':')), isTrue);
      expect(params.breakerPatterns, contains('lte'));
    });

    test('a canary the user corrects is what the core receives', () {
      final corrected = const SmartRoutingProps(enabled: true)
          .applyPreset(SmartRoutingPreset.russia)
          .copyWith(canaryForeign: ['8.8.8.8:443']);

      expect(corrected.matchesPreset, isFalse);
      expect(corrected.rcxParams.canaryForeign, ['8.8.8.8:443']);
    });
  });

  test('a locale implies a region only where one ships', () {
    expect(smartRoutingPresetForLocale('ru'), SmartRoutingPreset.russia);
    expect(smartRoutingPresetForLocale('fa_IR'), SmartRoutingPreset.iran);
    expect(smartRoutingPresetForLocale('zh_CN'), SmartRoutingPreset.china);
    expect(smartRoutingPresetForLocale('en'), SmartRoutingPreset.off);
    expect(smartRoutingPresetForLocale(null), SmartRoutingPreset.off);
  });

  group('network format', () {
    test('every terrain the core reports maps to a format', () {
      expect(networkFormatOf('normal'), NetworkFormat.open);
      expect(networkFormatOf('whitelist'), NetworkFormat.restricted);
      expect(networkFormatOf('portal'), NetworkFormat.portal);
      expect(networkFormatOf('offline'), NetworkFormat.offline);
      expect(networkFormatOf('unknown'), NetworkFormat.unknown);
      expect(networkFormatOf(''), NetworkFormat.unknown);
    });

    test('an unmeasured canary is not a failed one', () {
      const unmeasured = RcxLinkReport();
      expect(unmeasured.foreignMeasured, isFalse);
      expect(unmeasured.foreignReached, isFalse);

      const failed = RcxLinkReport(foreign: 'fail', domestic: 'ok');
      expect(failed.foreignMeasured, isTrue);
      expect(failed.foreignReached, isFalse);
      expect(failed.domesticReached, isTrue);
    });
  });

  group('routing counts', () {
    test('rows win over the status counters when both are present', () {
      const report = RcxReport(
        status: RcxStatus(candidates: 99, eligible: 99),
        candidates: [
          RcxCandidateReport(node: 'a'),
          RcxCandidateReport(node: 'b', block: 'cooling'),
        ],
      );
      final counts = routingCountsOf(report);

      expect(counts.total, 2);
      expect(counts.eligible, 1);
    });

    test('an empty report falls back to what the status says', () {
      const report = RcxReport(
        status: RcxStatus(candidates: 12, eligible: 3),
      );
      final counts = routingCountsOf(report);

      expect(counts.total, 12);
      expect(counts.eligible, 3);
    });
  });
}
