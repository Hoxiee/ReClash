import 'package:reclash/common/common.dart';
import 'package:reclash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

SubscriptionDialReport _dial({
  int attempts = 0,
  int failure = 0,
  List<SubscriptionOutcome> byEgress = const [],
}) {
  return SubscriptionDialReport(
    attempts: attempts,
    failure: failure,
    success: attempts - failure,
    byEgress: byEgress,
  );
}

SubscriptionOutcome _egress(String key, int attempts, int failure) {
  return SubscriptionOutcome(key: key, attempts: attempts, failure: failure);
}

SubscriptionUpdateReport _update({
  required bool attempted,
  required bool succeeded,
}) {
  return SubscriptionUpdateReport(attempted: attempted, succeeded: succeeded);
}

SubscriptionFault _faultOf({
  String terrain = 'normal',
  String causeCode = '',
  DoctorLayer layer = DoctorLayer.unknown,
  SubscriptionUpdateReport? update,
  SubscriptionDialReport? dial,
}) {
  return subscriptionFaultOf(
    terrain: terrain,
    doctorCauseCode: causeCode,
    doctorLayer: layer,
    update: update,
    dial: dial ?? _dial(),
  );
}

void main() {
  group('subscriptionFaultOf priority', () {
    test('a dead network wins over every downstream signal', () {
      final fault = _faultOf(
        terrain: 'offline',
        causeCode: 'captivePortal',
        update: _update(attempted: true, succeeded: false),
        dial: _dial(
          attempts: 100,
          failure: 100,
          byEgress: [_egress('US', 50, 50), _egress('NL', 50, 0)],
        ),
      );
      expect(fault, SubscriptionFault.yourNetwork);
    });

    test('a network cause code alone reads as yourNetwork', () {
      expect(
        _faultOf(causeCode: 'networkUnvalidated'),
        SubscriptionFault.yourNetwork,
      );
    });

    test('an inactive tunnel is the client, not the provider', () {
      expect(_faultOf(causeCode: 'tunNotActive'), SubscriptionFault.client);
    });

    test('a capture-layer verdict is the client', () {
      expect(_faultOf(layer: DoctorLayer.capture), SubscriptionFault.client);
    });

    test('a failed update is blamed on the subscription over dial', () {
      final fault = _faultOf(
        update: _update(attempted: true, succeeded: false),
        dial: _dial(
          attempts: 100,
          failure: 100,
          byEgress: [_egress('US', 50, 50), _egress('NL', 50, 0)],
        ),
      );
      expect(fault, SubscriptionFault.subscription);
    });
  });

  group('server bar', () {
    test(
      'mass failure with contrasting egress and a live network is server',
      () {
        final fault = _faultOf(
          update: _update(attempted: true, succeeded: true),
          dial: _dial(
            attempts: 40,
            failure: 30,
            byEgress: [_egress('US', 20, 18), _egress('NL', 20, 1)],
          ),
        );
        expect(fault, SubscriptionFault.server);
      },
    );

    test('uniform failure across egresses stays inconclusive', () {
      final fault = _faultOf(
        dial: _dial(
          attempts: 40,
          failure: 40,
          byEgress: [_egress('US', 20, 20), _egress('NL', 20, 20)],
        ),
      );
      expect(fault, SubscriptionFault.inconclusive);
    });

    test('too few attempts never reaches server', () {
      final fault = _faultOf(
        dial: _dial(
          attempts: 2,
          failure: 2,
          byEgress: [_egress('US', 1, 1), _egress('NL', 1, 0)],
        ),
      );
      expect(fault, SubscriptionFault.inconclusive);
    });

    test('a failure ratio under the threshold stays inconclusive', () {
      final fault = _faultOf(
        dial: _dial(
          attempts: 40,
          failure: 10,
          byEgress: [_egress('US', 20, 9), _egress('NL', 20, 1)],
        ),
      );
      expect(fault, SubscriptionFault.inconclusive);
    });
  });

  test('no data at all is inconclusive, never a blame', () {
    expect(_faultOf(), SubscriptionFault.inconclusive);
  });
}
