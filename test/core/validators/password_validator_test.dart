import 'package:apsaratalent_mobile/core/validators/password_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('validateStrong mirrors the API @IsStrongPassword() defaults', () {
    test('accepts a password meeting every rule', () {
      expect(PasswordValidator.validateStrong('Password123!'), isNull);
    });

    for (final (value, missing) in [
      ('Pass1!', 'at least'),
      ('PASSWORD123!', 'lowercase'),
      // The web form accepts this one; the API does not.
      ('password123!', 'uppercase'),
      ('Password!!!', 'number'),
      ('Password1234', 'symbol'),
    ]) {
      test('rejects "$value" for lacking $missing', () {
        expect(PasswordValidator.validateStrong(value), contains(missing));
      });
    }

    test('requires something', () {
      expect(PasswordValidator.validateStrong(''), 'Password is required');
    });
  });

  test('login validation stays loose for existing accounts', () {
    expect(PasswordValidator.validate('password'), isNull);
  });
}
