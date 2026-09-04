import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:test/test.dart';

void main() {
  group('Rule.parse', () {
    test('reads MATCH as a target-only rule', () {
      final rule = Rule.parse('MATCH,DIRECT');

      expect(rule.ruleAction, RuleAction.MATCH);
      expect(rule.content, isNull);
      expect(rule.ruleTarget, 'DIRECT');
    });

    test('keeps content and target apart for a payload rule', () {
      final rule = Rule.parse('DOMAIN-SUFFIX,example.com,PROXY');

      expect(rule.ruleAction, RuleAction.DOMAIN_SUFFIX);
      expect(rule.content, 'example.com');
      expect(rule.ruleTarget, 'PROXY');
    });

    test('reads RULE-SET payloads as a rule provider', () {
      final rule = Rule.parse('RULE-SET,my-set,PROXY');

      expect(rule.ruleProvider, 'my-set');
      expect(rule.content, isNull);
      expect(rule.ruleTarget, 'PROXY');
    });

    test('reads SUB-RULE payloads as a sub rule target', () {
      final rule = Rule.parse('SUB-RULE,payload,my-sub-rule');

      expect(rule.content, 'payload');
      expect(rule.subRule, 'my-sub-rule');
      expect(rule.ruleTarget, isNull);
    });

    test('reads the no-resolve flag', () {
      final rule = Rule.parse('IP-CIDR,1.1.1.1/32,DIRECT,no-resolve');

      expect(rule.content, '1.1.1.1/32');
      expect(rule.ruleTarget, 'DIRECT');
      expect(rule.noResolve, isTrue);
    });

    test('tolerates a rule without a target', () {
      final rule = Rule.parse('MATCH');

      expect(rule.ruleAction, RuleAction.MATCH);
      expect(rule.content, isNull);
      expect(rule.ruleTarget, isNull);
    });

    test('keeps a target-less payload rule as content only', () {
      final rule = Rule.parse('DOMAIN-SUFFIX,example.com');

      expect(rule.ruleAction, RuleAction.DOMAIN_SUFFIX);
      expect(rule.content, 'example.com');
      expect(rule.ruleTarget, isNull);
      expect(rule.rawValue, 'DOMAIN-SUFFIX,example.com');
    });

    test('falls back to a default rule for a payload with no fields', () {
      final rule = Rule.parse(',,');

      expect(rule.ruleAction, RuleAction.DOMAIN);
      expect(rule.ruleTarget, RuleTarget.DIRECT.name);
    });
  });

  group('Rule.rawValue', () {
    test('serializes MATCH without an empty content field', () {
      const rule = Rule(ruleAction: RuleAction.MATCH, ruleTarget: 'DIRECT');

      expect(rule.rawValue, 'MATCH,DIRECT');
    });

    test('drops content stored on a MATCH rule by an older build', () {
      const rule = Rule(
        ruleAction: RuleAction.MATCH,
        content: 'DIRECT',
        ruleTarget: 'DIRECT',
      );

      expect(rule.rawValue, 'MATCH,DIRECT');
    });

    test('round-trips the payload rules mihomo accepts', () {
      for (final value in const [
        'MATCH,DIRECT',
        'DOMAIN-SUFFIX,example.com,PROXY',
        'RULE-SET,my-set,PROXY',
        'SUB-RULE,payload,my-sub-rule',
        'IP-CIDR,1.1.1.1/32,DIRECT,no-resolve',
      ]) {
        expect(Rule.parse(value).rawValue, value, reason: value);
      }
    });
  });
}
