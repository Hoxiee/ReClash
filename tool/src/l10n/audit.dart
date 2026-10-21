import 'placeholders.dart';
import 'workspace.dart';

final _latinWord = RegExp('[A-Za-z]{4,}');
final _han = RegExp(r'\p{Script=Han}', unicode: true);
const _hanLocales = {'ja', 'zh'};

class AuditFinding {
  AuditFinding(this.kind, this.subject, this.detail, {this.error = true});

  final String kind;
  final String subject;
  final String detail;
  final bool error;

  @override
  String toString() => '$kind $subject: $detail';
}

const auditKinds = [
  'assembly',
  'missing-locale',
  'extra-locale',
  'placeholder',
  'han',
  'undeclared',
  'same-as-en',
];

List<AuditFinding> audit(L10nWorkspace workspace, {String? fragment}) {
  final findings = <AuditFinding>[];
  final features = fragment == null ? workspace.fragments.keys : [fragment];
  for (final feature in features) {
    _auditLocaleGaps(workspace, feature, findings);
  }

  final Map<String, ArbMap> assembled;
  try {
    assembled = workspace.assembled();
  } on FormatException catch (error) {
    return findings..add(AuditFinding('assembly', 'arb', error.message));
  }
  final english = assembled['en'] ?? const <String, Object?>{};
  final owned = fragment == null ? null : workspace.fragmentKeys(fragment);
  for (final MapEntry(:key, value: englishText) in english.entries) {
    if (!isMessageKey(key) || englishText is! String) continue;
    if (owned != null && !owned.contains(key)) continue;
    final englishArguments = messageArguments(englishText);
    final placeholderGaps = <String>[];
    final sameAsEnglish = <String>[];
    final han = <String>[];
    if (workspace.fragments.containsKey(workspace.ownerOf(key, 'en'))) {
      final declared = declaredPlaceholders(english['@$key']);
      final undeclared = englishArguments.difference(declared);
      if (undeclared.isNotEmpty) {
        findings.add(
          AuditFinding(
            'undeclared',
            key,
            'en ${formatArguments(undeclared)} not declared in @.placeholders',
            error: false,
          ),
        );
      }
      final unused = declared.difference(englishArguments);
      if (unused.isNotEmpty) {
        findings.add(
          AuditFinding(
            'placeholder',
            key,
            '@.placeholders declares unused ${formatArguments(unused)}',
          ),
        );
      }
    }
    for (final MapEntry(key: locale, value: values) in assembled.entries) {
      final text = values[key];
      if (locale == 'en' || text is! String) continue;
      final arguments = messageArguments(text);
      if (arguments.length != englishArguments.length ||
          !arguments.containsAll(englishArguments)) {
        placeholderGaps.add('$locale ${formatArguments(arguments)}');
      }
      if (text == englishText && _latinWord.hasMatch(text)) {
        sameAsEnglish.add(locale);
      }
      if (!_hanLocales.contains(locale.split('_').first) &&
          _han.hasMatch(text)) {
        han.add(locale);
      }
    }
    if (placeholderGaps.isNotEmpty) {
      findings.add(
        AuditFinding(
          'placeholder',
          key,
          '${placeholderGaps.join(', ')}; en ${formatArguments(englishArguments)}',
        ),
      );
    }
    if (han.isNotEmpty) findings.add(AuditFinding('han', key, han.join(', ')));
    if (sameAsEnglish.isNotEmpty) {
      findings.add(
        AuditFinding(
          'same-as-en',
          key,
          '${sameAsEnglish.join(', ')} "${oneLine(englishText)}"',
          error: false,
        ),
      );
    }
  }
  return findings..sort(
    (a, b) => auditKinds.indexOf(a.kind).compareTo(auditKinds.indexOf(b.kind)),
  );
}

void _auditLocaleGaps(
  L10nWorkspace workspace,
  String feature,
  List<AuditFinding> findings,
) {
  final files = workspace.fragments[feature] ?? const <String, ArbMap>{};
  final englishKeys = (files['en'] ?? const <String, Object?>{}).keys.where(
    isMessageKey,
  );
  final missing = <String, List<String>>{};
  final extra = <String, List<String>>{};
  for (final locale in workspace.locales) {
    if (locale == 'en') continue;
    final keys = (files[locale] ?? const <String, Object?>{}).keys
        .where(isMessageKey)
        .toSet();
    for (final key in englishKeys) {
      if (!keys.contains(key)) missing.putIfAbsent(key, () => []).add(locale);
    }
    for (final key in keys.difference(englishKeys.toSet())) {
      extra.putIfAbsent(key, () => []).add(locale);
    }
  }
  for (final MapEntry(:key, value: locales) in missing.entries) {
    findings.add(
      AuditFinding('missing-locale', '$feature/$key', locales.join(', ')),
    );
  }
  for (final MapEntry(:key, value: locales) in extra.entries) {
    findings.add(
      AuditFinding('extra-locale', '$feature/$key', locales.join(', ')),
    );
  }
}
