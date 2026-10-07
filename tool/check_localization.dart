import 'dart:io';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

/// Keeps static product copy translated without examining API/user data.
class CopyVisitor extends RecursiveAstVisitor<void> {
  final keys = <String>{};
  void arguments(String name, ArgumentList list) {
    if (name == 'Text' &&
        list.arguments.isNotEmpty &&
        list.arguments.first is! NamedExpression) {
      literal(list.arguments.first);
    }
    for (final value in list.arguments.whereType<NamedExpression>()) {
      if (const {
            'labelText',
            'hintText',
            'helperText',
            'tooltip',
            'semanticLabel'
          }.contains(value.name.label.name) ||
          (const {
                'AppButton',
                'PageBanner',
                'PageState',
                'SectionTitle',
                'AppTag',
                'AppStatusPill',
                'AuthScaffold',
                'AppInput',
                'AppPickerField'
              }.contains(name) &&
              const {
                'label',
                'title',
                'subtitle',
                'description',
                'eyebrow',
                'actionLabel'
              }.contains(value.name.label.name))) {
        literal(value.expression);
      }
    }
  }

  void literal(Expression expression) {
    if (expression is StringLiteral && expression.stringValue != null) {
      keys.add(expression.stringValue!);
    } else if (expression is ConditionalExpression) {
      literal(expression.thenExpression);
      literal(expression.elseExpression);
    } else if (expression is MethodInvocation &&
        expression.methodName.name == 'tr' &&
        expression.argumentList.arguments.isNotEmpty) {
      literal(expression.argumentList.arguments.first);
    }
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    arguments(node.constructorName.type.name2.lexeme, node.argumentList);
    super.visitInstanceCreationExpression(node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.target == null) {
      arguments(node.methodName.name, node.argumentList);
    }
    if (node.methodName.name == 'tr' &&
        node.argumentList.arguments.isNotEmpty) {
      literal(node.argumentList.arguments.first);
    }
    super.visitMethodInvocation(node);
  }
}

class CatalogVisitor extends RecursiveAstVisitor<void> {
  final keys = <String>{};
  @override
  void visitMapLiteralEntry(MapLiteralEntry node) {
    final key = node.key;
    if (key is StringLiteral && key.stringValue != null) {
      keys.add(key.stringValue!);
    }
    super.visitMapLiteralEntry(node);
  }
}

void main() {
  final copy = CopyVisitor();
  final catalog = CatalogVisitor();
  for (final file in Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) =>
          f.path.endsWith('.dart') &&
          !f.path.contains('/generated/') &&
          !f.path.endsWith('.g.dart') &&
          !f.path.endsWith('.gr.dart'))) {
    final unit = parseString(content: file.readAsStringSync()).unit;
    if (file.path.contains('/localization/')) {
      unit.accept(catalog);
    } else {
      unit.accept(copy);
    }
  }
  const literalTokens = {
    '',
    '#3366CC',
    '#RRGGBB',
    '+855',
    '+855 12 345 678',
    '9+',
    'Flutter, Dart, REST APIs',
    'https://example.com',
    'you@example.com',
    'English',
    'ប្រើភាសាខ្មែរនៅទូទាំងកម្មវិធី'
  };
  final missing = copy.keys
      .difference(catalog.keys)
      .difference(literalTokens)
      .toList()
    ..sort();
  if (missing.isNotEmpty) {
    stderr.writeln('Missing Khmer product copy:\n${missing.join('\n')}');
    exitCode = 1;
  } else {
    stdout.writeln(
        'Verified ${copy.keys.length} product strings have Khmer translations.');
  }
}
