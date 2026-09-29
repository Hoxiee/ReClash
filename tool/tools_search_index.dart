import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

/// Owner screens feeding the Tools search index, each mapped to the files that
/// render its rows and the category it regroups under; the only hand-kept part.
const ownerSpecs = <OwnerSpec>[
  OwnerSpec('advanced', 'configuration', ['lib/views/config/advanced.dart']),
  OwnerSpec('config', 'configuration', ['lib/views/config/general.dart']),
  OwnerSpec('application', 'system', [
    'lib/views/settings/application_setting.dart',
  ]),
  OwnerSpec('appearance', 'personalization', [
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
  OwnerSpec('backup', 'system', ['lib/views/settings/backup_and_restore.dart']),
  OwnerSpec('developer', 'system', ['lib/views/settings/developer.dart']),
];

/// Owners whose rows exist only in developer mode; the index gates them.
const developerOwners = {'developer'};

/// Constructors whose `title:`/`label:` names a searchable row, plus two
/// synthetic tags: `Info` for a `PreviewChoiceGroup` label and `EnumLabel` for
/// an enum-switch label map. Titles in any other slot are not fixed settings.
const rowTypes = <String>{
  'ConfigToggleItem',
  'ConfigOptionsItem',
  'ConfigTextItem',
  'ConfigListInputItem',
  'ConfigNextItem',
  'DecorationListItem',
  'SelectedDecorationListItem',
  'SettingSliderItem',
  'SettingSection',
  'ListItem',
  'ListHeader',
  'Info',
  'EnumLabel',
  '_vpnToggle',
  '_networkToggle',
  '_clashToggle',
  '_appSettingToggle',
  '_pacingItem',
  '_StringListItem',
  '_CountryListItem',
  '_MarkersItem',
  '_buildPrerequisiteItem',
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

class TitleHit {
  const TitleHit(this.enclosingType, this.title);

  final String enclosingType;
  final SettingTitle title;
}

/// Every static-label `title:`/`label:` in [source], tagged with its owning
/// type. Syntactic parse only — no package resolution needed.
List<TitleHit> extractTitleHits(String source) {
  final result = parseString(content: source, throwIfDiagnostics: false);
  final visitor = _TitleVisitor();
  result.unit.visitChildren(visitor);
  return visitor.hits;
}

class _TitleVisitor extends RecursiveAstVisitor<void> {
  final List<TitleHit> hits = [];

  static const _labelArguments = <String>{'title', 'label'};

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    _scan(node.constructorName.type.name.lexeme, node.argumentList);
    super.visitInstanceCreationExpression(node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    _scan(_calleeName(node), node.argumentList);
    super.visitMethodInvocation(node);
  }

  /// A `label`/`title` accessor whose body switches over enum cases is the
  /// label map for a per-enum-value screen (DNS/NTP overrides); harvest each arm.
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
              hits.add(TitleHit('EnumLabel', title));
            }
          }
        }
      }
    }
    super.visitMethodDeclaration(node);
  }

  /// The type a call names. Keyword-free constructor calls parse as method
  /// invocations, so `Widget(...)` is method `Widget` and `Widget.open(...)` is
  /// method `open` on target `Widget`; fold the latter back to the type.
  String _calleeName(MethodInvocation node) {
    final target = node.target;
    if (target is SimpleIdentifier && target.name.isNotEmpty) {
      final first = target.name[0];
      if (first == first.toUpperCase() && first != first.toLowerCase()) {
        return target.name;
      }
    }
    return node.methodName.name;
  }

  void _scan(String enclosing, ArgumentList argumentList) {
    for (final argument in argumentList.arguments) {
      if (argument is NamedArgument &&
          _labelArguments.contains(argument.name.lexeme)) {
        final title = _classify(argument.argumentExpression);
        if (title != null) {
          hits.add(TitleHit(enclosing, title));
        }
      }
    }
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
