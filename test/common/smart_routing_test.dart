import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('presets predefine settings and nothing more', () {
    test(
      'every preset ships the data the engine needs to measure anything',
      () {
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
      },
    );

    test('picking a region never turns the engine off', () {
      const props = SmartRoutingProps(enabled: true, waveWidth: 4);
      final applied = props.applyPreset(SmartRoutingPreset.russia);

      expect(applied.enabled, isTrue);
      expect(applied.preset, SmartRoutingPreset.russia);
      expect(applied.waveWidth, SmartRoutingPreset.russia.bundle.waveWidth);
    });

    test('a moved knob is visible, and resetting puts it back', () {
      final edited = const SmartRoutingProps(
        enabled: true,
      ).applyPreset(SmartRoutingPreset.russia).copyWith(dwellSeconds: 600);

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
      expect(params.openMarkers.first.url, contains('telegram'));
      expect(params.openMarkers.first.statuses, contains(404));
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

  group('a pin is the user\'s node, not the engine\'s', () {
    test('the pin holds its node after the engine had to leave it', () {
      const status = RcxStatus(
        enabled: true,
        pinned: true,
        node: 'Frankfurt #1',
        pinNode: 'Amsterdam #3',
      );

      expect(routingPinHolds(status, 'Amsterdam #3'), isTrue);
      expect(routingPinHolds(status, 'Frankfurt #1'), isFalse);
    });

    test('an engine nobody pinned holds nothing at all', () {
      expect(routingPinHolds(null, 'Amsterdam #3'), isFalse);
      expect(
        routingPinHolds(
          const RcxStatus(pinNode: 'Amsterdam #3'),
          'Amsterdam #3',
        ),
        isFalse,
      );
      expect(routingPinHolds(const RcxStatus(enabled: true), ''), isFalse);
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

    test('a forged chain is a measurement the open network did not make', () {
      const forged = RcxLinkReport(foreign: 'mismatch', domestic: 'ok');
      expect(forged.foreignMeasured, isTrue);
      expect(forged.foreignReached, isFalse);
      expect(forged.foreignForged, isTrue);

      const answered = RcxCanaryReport(addr: '1.1.1.1:443');
      expect(answered.measured, isFalse);
      expect(answered.forged, isFalse);

      const mitm = RcxCanaryReport(addr: '1.1.1.1:443', outcome: 'mismatch');
      expect(mitm.measured, isTrue);
      expect(mitm.answered, isFalse);
      expect(mitm.forged, isTrue);
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
      const report = RcxReport(status: RcxStatus(candidates: 12, eligible: 3));
      final counts = routingCountsOf(report);

      expect(counts.total, 12);
      expect(counts.eligible, 3);
    });
  });

  group('the node trail keeps what the engine no longer reports', () {
    test('a new node lands in front and an unchanged one is a no-op', () {
      final first = rcxTrailWith(const [], 'DE-1');
      expect(first, ['DE-1']);
      expect(rcxTrailWith(first, 'DE-1'), same(first));
      expect(rcxTrailWith(first, 'NL-2'), ['NL-2', 'DE-1']);
    });

    test('a node returning moves up instead of appearing twice', () {
      expect(rcxTrailWith(const ['NL-2', 'DE-1'], 'DE-1'), ['DE-1', 'NL-2']);
    });

    test('the trail stops at the limit and an empty node changes nothing', () {
      var trail = const <String>[];
      for (final node in ['a', 'b', 'c', 'd', 'e', 'f']) {
        trail = rcxTrailWith(trail, node);
      }
      expect(trail, hasLength(rcxTrailLimit));
      expect(trail.first, 'f');
      expect(rcxTrailWith(trail, ''), same(trail));
    });
  });
}
