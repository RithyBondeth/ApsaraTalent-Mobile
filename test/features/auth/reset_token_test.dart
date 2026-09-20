import 'package:apsaratalent_mobile/features/auth/providers/password_reset/password_reset_notifier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('drops the full stop the reset email puts after the token', () {
    expect(normalizeResetToken('d48dab24.'), 'd48dab24');
  });

  test('drops whitespace and line breaks from a pasted token', () {
    expect(normalizeResetToken('  d48d\nab24 \t'), 'd48dab24');
  });

  test('leaves a clean token untouched', () {
    const token = '0123456789abcdef0123456789abcdef01234567';
    expect(normalizeResetToken(token), token);
  });
}
