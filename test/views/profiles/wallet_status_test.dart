import 'dart:typed_data';
import 'dart:ui' show Color;

import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/common/constant.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/subscriptions/branding/brand.dart';
import 'package:reclash/subscriptions/branding/color.dart';
import 'package:reclash/subscriptions/metadata/metadata.dart';
import 'package:reclash/views/profiles/wallet/status.dart';

final _now = DateTime.utc(2026, 11, 15, 12);

int _expireIn(Duration offset) =>
    _now.add(offset).millisecondsSinceEpoch ~/ 1000;

SubscriptionInfo _info({
  int upload = 0,
  int download = 0,
  int total = 0,
  int expire = 0,
}) => SubscriptionInfo(
  upload: upload,
  download: download,
  total: total,
  expire: expire,
);

Profile _profile({
  int id = 1,
  ProfileType type = ProfileType.url,
  String label = 'Nebula VPN',
  SubscriptionInfo info = const SubscriptionInfo(),
  Map<String, Object?> metadata = const {},
}) => Profile(
  id: id,
  type: type,
  label: label,
  url: 'https://provider.test/sub/token',
  autoUpdateDuration: defaultUpdateDuration,
  subscriptionInfo: info,
  subscriptionSnapshot: SubscriptionSnapshot(
    metadata: SubscriptionMetadata(metadata),
    receivedAt: _now,
  ),
);

WalletFacts _facts(Profile profile) => walletFactsOf(profile, _now);

final _plans = Uri.parse('https://provider.test/plans');
final _traffic = Uri.parse('https://provider.test/gb');

void main() {
  group('walletFactsOf', () {
    test('local and custom profiles carry no subscription state', () {
      for (final type in [ProfileType.file, ProfileType.custom]) {
        final facts = _facts(
          _profile(type: type, info: _info(upload: 1000, total: 1000)),
        );
        expect(facts.state, WalletState.ok, reason: '$type');
        expect(facts.subscription, isFalse, reason: '$type');
      }
    });

    test('a plan with traffic and days left is ok with its numbers', () {
      final facts = _facts(
        _profile(
          info: _info(
            upload: 100,
            download: 200,
            total: 1000,
            expire: _expireIn(const Duration(days: 60)),
          ),
          metadata: {'provider.buyPlanUrl': _plans.toString()},
        ),
      );
      expect(facts.state, WalletState.ok);
      expect(facts.subscription, isTrue);
      expect(facts.cta, isNull);
      expect(facts.ctaUrl, isNull);
      expect(facts.left, 700);
      expect(facts.leftFraction, closeTo(0.7, 1e-9));
      expect(facts.daysLeft, 60);
    });

    test('traffic used up is critical with a top-up link', () {
      final facts = _facts(
        _profile(
          info: _info(
            upload: 600,
            download: 400,
            total: 1000,
            expire: _expireIn(const Duration(days: 60)),
          ),
          metadata: {'provider.buyTrafficUrl': _traffic.toString()},
        ),
      );
      expect(facts.state, WalletState.critical);
      expect(facts.left, 0);
      expect(facts.cta, WalletCta.topUp);
      expect(facts.ctaUrl, _traffic);
    });

    test('traffic used up without a top-up link offers nothing', () {
      final facts = _facts(
        _profile(
          info: _info(
            upload: 600,
            download: 400,
            total: 1000,
            expire: _expireIn(const Duration(days: 60)),
          ),
        ),
      );
      expect(facts.state, WalletState.critical);
      expect(facts.cta, isNull);
      expect(facts.ctaUrl, isNull);
    });

    test('an ended plan is expired and renews through the plan link', () {
      final facts = _facts(
        _profile(
          info: _info(
            upload: 100,
            total: 1000,
            expire: _expireIn(const Duration(days: -1)),
          ),
          metadata: {
            'provider.buyPlanUrl': _plans.toString(),
            'provider.buyTrafficUrl': _traffic.toString(),
          },
        ),
      );
      expect(facts.state, WalletState.expired);
      expect(facts.cta, WalletCta.renew);
      expect(facts.ctaUrl, _plans);
    });

    test('an ended plan renews through the traffic link when no plan link', () {
      final facts = _facts(
        _profile(
          info: _info(
            upload: 100,
            total: 1000,
            expire: _expireIn(const Duration(days: -1)),
          ),
          metadata: {'provider.buyTrafficUrl': _traffic.toString()},
        ),
      );
      expect(facts.state, WalletState.expired);
      expect(facts.cta, WalletCta.renew);
      expect(facts.ctaUrl, _traffic);
    });

    test('an ended plan without any link offers nothing', () {
      final facts = _facts(
        _profile(
          info: _info(total: 1000, expire: _expireIn(const Duration(days: -1))),
        ),
      );
      expect(facts.state, WalletState.expired);
      expect(facts.cta, isNull);
      expect(facts.ctaUrl, isNull);
    });

    test('a plan inside the reminder days is critical and renews', () {
      final facts = _facts(
        _profile(
          info: _info(expire: _expireIn(const Duration(days: 2))),
          metadata: {'provider.buyPlanUrl': _plans.toString()},
        ),
      );
      expect(facts.state, WalletState.critical);
      expect(facts.cta, WalletCta.renew);
      expect(facts.ctaUrl, _plans);
      expect(facts.daysLeft, 2);
    });

    test('a plan beyond the reminder days stays ok', () {
      final facts = _facts(
        _profile(info: _info(expire: _expireIn(const Duration(days: 4)))),
      );
      expect(facts.state, WalletState.ok);
    });

    test('traffic past the warning percent is critical with a top-up', () {
      final facts = _facts(
        _profile(
          info: _info(
            upload: 500,
            download: 450,
            total: 1000,
            expire: _expireIn(const Duration(days: 60)),
          ),
          metadata: {'provider.buyTrafficUrl': _traffic.toString()},
        ),
      );
      expect(facts.state, WalletState.critical);
      expect(facts.cta, WalletCta.topUp);
      expect(facts.ctaUrl, _traffic);
    });

    test('traffic under the warning percent stays ok', () {
      final facts = _facts(
        _profile(
          info: _info(
            upload: 500,
            download: 300,
            total: 1000,
            expire: _expireIn(const Duration(days: 60)),
          ),
        ),
      );
      expect(facts.state, WalletState.ok);
    });

    test('unlimited metadata drops the total', () {
      final facts = _facts(
        _profile(
          info: _info(
            upload: 100,
            total: 1000,
            expire: _expireIn(const Duration(days: 60)),
          ),
          metadata: {'subscription.unlimited': true},
        ),
      );
      expect(facts.total, isNull);
      expect(facts.unlimited, isTrue);
      expect(facts.left, isNull);
      expect(facts.leftFraction, isNull);
      expect(facts.state, WalletState.ok);
    });

    test('perpetual metadata drops the expiry', () {
      final facts = _facts(
        _profile(
          info: _info(expire: _expireIn(const Duration(days: 2))),
          metadata: {'subscription.perpetual': true},
        ),
      );
      expect(facts.expire, isNull);
      expect(facts.daysLeft, isNull);
      expect(facts.state, WalletState.ok);
    });
  });

  group('walletBrandColor', () {
    test('local and custom profiles stay neutral even with a brand color', () {
      final brand = ProviderBrand(
        source: ProviderBrandSource.manifest,
        resolvedAt: _now,
        logo: ProviderLogo(bytes: Uint8List.fromList([1])),
        color: 0xFF2255AA,
      );
      for (final type in [ProfileType.file, ProfileType.custom]) {
        expect(
          walletBrandColor(_profile(type: type), brand),
          isNull,
          reason: '$type',
        );
        expect(walletBrandColor(_profile(type: type), null), isNull);
      }
    });

    test('without a brand the name monogram color is used', () {
      final color = walletBrandColor(_profile(label: 'Nebula VPN'), null);
      expect(color, isNotNull);
      expect(
        walletBrandColor(_profile(id: 2, label: 'Nebula VPN'), null),
        color,
      );
    });

    test('a monogram-source brand takes the same color as no brand', () {
      final profile = _profile(label: 'Nebula VPN');
      final monogram = ProviderBrand(
        source: ProviderBrandSource.monogram,
        resolvedAt: _now,
        color: monogramColor(monogramHue('Nebula VPN')),
      );
      expect(
        walletBrandColor(profile, monogram),
        walletBrandColor(profile, null),
      );
    });

    test('a logo brand keeps the color extracted from its logo', () {
      final brand = ProviderBrand(
        source: ProviderBrandSource.manifest,
        resolvedAt: _now,
        logo: ProviderLogo(bytes: Uint8List.fromList([1])),
        color: 0xFF2255AA,
      );
      expect(walletBrandColor(_profile(), brand), const Color(0xFF2255AA));
    });

    test('a logo without a dominant color stays neutral', () {
      final brand = ProviderBrand(
        source: ProviderBrandSource.site,
        resolvedAt: _now,
        logo: ProviderLogo(bytes: Uint8List.fromList([1])),
      );
      expect(walletBrandColor(_profile(), brand), isNull);
    });
  });
}
