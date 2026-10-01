import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

/// Owner screens feeding the Tools search index, each mapped to the files that
/// render its rows and the category it regroups under; the only hand-kept part.
const ownerSpecs = <OwnerSpec>[
  OwnerSpec('advanced', 'configuration', ['lib/views/config/advanced.dart']),
  OwnerSpec('config', 'configuration', ['lib/views/config/general.dart']),
  OwnerSpec('application', 'application', [
    'lib/views/settings/application_setting.dart',
  ]),
  OwnerSpec('appearance', 'application', [
    'lib/views/appearance/theme_tab.dart',
    'lib/views/appearance/motion_tab.dart',
    'lib/views/appearance/background_tab.dart',
    'lib/views/appearance/color_sections.dart',
  ]),
  OwnerSpec('network', 'configuration', ['lib/views/config/network.dart']),
  OwnerSpec('dns', 'configuration', ['lib/views/config/dns.dart']),
  OwnerSpec('ntp', 'configuration', ['lib/views/config/ntp.dart']),
  OwnerSpec('smartRouting', 'configuration', [
    'lib/views/config/smart_routing.dart',
    'lib/views/config/smart_routing_expert.dart',
    'lib/views/config/smart_routing_markers.dart',
    'lib/views/config/smart_routing_service_route.dart',
  ]),
  OwnerSpec('smartPause', 'configuration', [
    'lib/views/config/smart_pause.dart',
  ]),
  OwnerSpec('desync', 'configuration', ['lib/views/config/desync.dart']),
  OwnerSpec('backup', 'configuration', [
    'lib/views/settings/backup_and_restore.dart',
  ]),
  OwnerSpec('developer', 'info', ['lib/views/settings/developer.dart']),
];

/// Owners whose rows exist only in developer mode; a row that declares no gate
/// of its own inherits this one.
const developerOwners = {'developer'};

/// The availability tokens [SettingGate] offers. The generator refuses any other
/// token so a typo cannot silently bake an always-visible row.
const settingGates = <String>{
  'always',
  'byeDpi',
  'developerMode',
  'android',
  'desktop',
  'mobile',
  'windows',
  'macos',
  'linux',
};

/// Identifiers standing for the l10n object, so `<recv>.getter` reads as key
/// `getter`.
const _l10nReceivers = <String>{
  'l',
  'l10n',
  'appLocalizations',
  'currentAppLocalizations',
};

class OwnerSpec {
  const OwnerSpec(this.paneId, this.category, this.files);

  final String paneId;
  final String category;
  final List<String> files;
}

/// One extracted title: an l10n getter or a literal string.
class SettingTitle {
  const SettingTitle.getter(this.getter) : literal = null;
  const SettingTitle.literal(this.literal) : getter = null;

  final String? getter;
  final String? literal;

  bool get isGetter => getter != null;

  String get expression =>
      isGetter ? 'l.$getter' : "'${literal!.replaceAll(r'$', r'\$')}'";

  @override
  bool operator ==(Object other) =>
      other is SettingTitle &&
      other.getter == getter &&
      other.literal == literal;

  @override
  int get hashCode => Object.hash(getter, literal);
}

/// One searchable row the author marked with `search:`, carrying its reused
/// title and the baked descriptor (keywords and gate token).
class SettingHit {
  const SettingHit(this.title, this.keywords, this.gate);

  final SettingTitle title;
  final List<String> keywords;
  final String gate;
}

/// Hits and any author mistakes found while scanning one source file; a bad
/// gate token or a `search:` on a titleless row is a generator error, never a
/// silent drop.
class Extraction {
  const Extraction(this.hits, this.errors);

  final List<SettingHit> hits;
  final List<String> errors;
}

/// Every `search:`-marked row in [source] plus the enum-switch label maps
/// (DNS/NTP per-value screens). Syntactic parse only — no package resolution.
Extraction extractSettingHits(String source) {
  final result = parseString(content: source, throwIfDiagnostics: false);
  final visitor = _SettingVisitor();
  result.unit.visitChildren(visitor);
  return Extraction(visitor.hits, visitor.errors);
}

class _SettingVisitor extends RecursiveAstVisitor<void> {
  final List<SettingHit> hits = [];
  final List<String> errors = [];

  static const _labelArguments = <String>{'title', 'label'};

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    _scan(node.argumentList);
    super.visitInstanceCreationExpression(node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    _scan(node.argumentList);
    super.visitMethodInvocation(node);
  }

  /// A `label`/`title` accessor whose body switches over enum cases is the
  /// label map for a per-enum-value screen (DNS/NTP overrides); harvest each arm
  /// as an always-available row with no extra keywords.
  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    final name = node.name.lexeme;
    if (name == 'label' || name == 'title') {
      final body = node.body;
      if (body is ExpressionFunctionBody) {
        final expression = body.expression;
        if (expression is SwitchExpression) {
          for (final arm in expression.cases) {
            final title = _classify(arm.expression);
            if (title != null) {
              hits.add(SettingHit(title, const [], 'always'));
            }
          }
        }
      }
    }
    super.visitMethodDeclaration(node);
  }

  /// A call that carries `search:` is a row the author marked searchable. Reuse
  /// its sibling `title:`/`label:` for the text and bake the descriptor.
  void _scan(ArgumentList argumentList) {
    NamedArgument? searchArgument;
    Expression? titleExpression;
    for (final argument in argumentList.arguments) {
      if (argument is! NamedArgument) {
        continue;
      }
      final name = argument.name.lexeme;
      if (name == 'search') {
        searchArgument = argument;
      } else if (_labelArguments.contains(name)) {
        titleExpression ??= argument.argumentExpression;
      }
    }
    if (searchArgument == null) {
      return;
    }
    final title = titleExpression == null ? null : _classify(titleExpression);
    if (title == null) {
      errors.add('search: on a row without a resolvable title/label literal');
      return;
    }
    final (keywords, gate) = _descriptor(searchArgument.argumentExpression);
    hits.add(SettingHit(title, keywords, gate));
  }

  /// Reads the `SettingSearch(...)` the author passed to `search:`: its keyword
  /// literals and the gate enum constant as a token.
  (List<String>, String) _descriptor(Expression expression) {
    var keywords = const <String>[];
    var gate = 'always';
    if (expression is InstanceCreationExpression) {
      for (final argument in expression.argumentList.arguments) {
        if (argument is! NamedArgument) {
          continue;
        }
        switch (argument.name.lexeme) {
          case 'keywords':
            keywords = _stringList(argument.argumentExpression);
          case 'gate':
            final token = _gateToken(argument.argumentExpression);
            if (token == null || !settingGates.contains(token)) {
              errors.add('unknown SettingGate: ${argument.argumentExpression}');
            } else {
              gate = token;
            }
        }
      }
    }
    return (keywords, gate);
  }

  /// The constant name of a `SettingGate.<name>` reference, seen as a prefixed
  /// identifier or a property access; else null.
  String? _gateToken(Expression expression) {
    if (expression is PrefixedIdentifier) {
      return expression.identifier.name;
    }
    if (expression is PropertyAccess) {
      return expression.propertyName.name;
    }
    return null;
  }

  List<String> _stringList(Expression expression) {
    if (expression is! ListLiteral) {
      return const [];
    }
    final values = <String>[];
    for (final element in expression.elements) {
      if (element is SimpleStringLiteral) {
        values.add(element.value);
      }
    }
    return values;
  }

  /// The fixed label an expression carries, or null: unwraps `(l) =>` builders
  /// and `Text(...)`, reads `<l10n>.getter` and string literals; else null.
  SettingTitle? _classify(Expression expression) {
    if (expression is FunctionExpression) {
      final body = expression.body;
      return body is ExpressionFunctionBody ? _classify(body.expression) : null;
    }
    final unwrapped = _unwrapText(expression);
    if (unwrapped != null) {
      return _classify(unwrapped);
    }
    if (expression is SimpleStringLiteral) {
      final value = expression.value.trim();
      return value.isEmpty ? null : SettingTitle.literal(value);
    }
    if (expression is PrefixedIdentifier) {
      return _l10nReceivers.contains(expression.prefix.name)
          ? SettingTitle.getter(expression.identifier.name)
          : null;
    }
    if (expression is PropertyAccess) {
      final target = expression.target?.toSource() ?? '';
      final receiver = target.split('.').last;
      return _l10nReceivers.contains(receiver)
          ? SettingTitle.getter(expression.propertyName.name)
          : null;
    }
    return null;
  }

  /// First argument of a `Text(...)`/`TooltipText(...)` wrapper, seen as either
  /// a constructor (`const Text`) or a method invocation (`Text`); else null.
  Expression? _unwrapText(Expression expression) {
    if (expression is InstanceCreationExpression) {
      final type = expression.constructorName.type.name.lexeme;
      return _isTextType(type) ? _firstArgument(expression.argumentList) : null;
    }
    if (expression is MethodInvocation && expression.target == null) {
      return _isTextType(expression.methodName.name)
          ? _firstArgument(expression.argumentList)
          : null;
    }
    return null;
  }

  bool _isTextType(String type) => type == 'Text' || type == 'TooltipText';

  Expression? _firstArgument(ArgumentList list) {
    final args = list.arguments;
    return args.isEmpty ? null : args.first.argumentExpression;
  }
}
