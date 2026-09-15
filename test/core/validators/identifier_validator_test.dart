import 'package:apsaratalent_mobile/core/validators/identifier_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('kindOf', () {
    test('recognises an email', () {
      expect(IdentifierValidator.kindOf('sophea.chan@seed.dev'), EIdentifierKind.email);
    });

    test('recognises a phone number — the case the inverted check rejected', () {
      expect(IdentifierValidator.kindOf('012345678'), EIdentifierKind.phone);
      expect(IdentifierValidator.kindOf('+855 12 000 001'), EIdentifierKind.phone);
    });

    test('is null for neither, or for nothing', () {
      expect(IdentifierValidator.kindOf('not-an-identifier'), isNull);
      expect(IdentifierValidator.kindOf('1234'), isNull);
      expect(IdentifierValidator.kindOf('   '), isNull);
    });
  });

  test('validate passes both kinds and explains a bad value', () {
    expect(IdentifierValidator.validate('a@b.dev'), isNull);
    expect(IdentifierValidator.validate('012345678'), isNull);
    expect(IdentifierValidator.validate('nope'), contains('valid'));
    expect(IdentifierValidator.validate(''), isNotNull);
  });

  test('normalize strips formatting from a number but not from an address', () {
    expect(IdentifierValidator.normalize(' +855 12-000 (001) '), '+85512000001');
    expect(IdentifierValidator.normalize('  a.b@c.dev '), 'a.b@c.dev');
  });
}
