import 'package:ana_fit_lab/core/validation/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('validateNewPassword', () {
    test('empty is REQUIRED', () {
      expect(validateNewPassword(''), 'REQUIRED');
      expect(validateNewPassword(null), 'REQUIRED');
    });
    test('length bounds in code points', () {
      expect(validateNewPassword('a' * 9), 'PASSWORD_POLICY');
      expect(validateNewPassword('a' * 10), isNull);
      expect(validateNewPassword('a' * 64), isNull);
      expect(validateNewPassword('a' * 65), 'PASSWORD_POLICY');
    });
    test('emoji counted as code points', () {
      expect(validateNewPassword('🔥' * 10), isNull);
      expect(validateNewPassword('🔥' * 19), 'PASSWORD_POLICY');
    });
    test('72 UTF-8 byte limit', () {
      expect(validateNewPassword('ă' * 37), 'PASSWORD_POLICY');
      expect(validateNewPassword('ă' * 36), isNull);
    });
    test('is not trimmed', () {
      expect(validateNewPassword(' ' * 10), isNull);
    });
  });

  group('validateEmail', () {
    test('valid trimmed', () => expect(validateEmail(' ana@example.ro '), isNull));
    test('required', () {
      expect(validateEmail('  '), 'REQUIRED');
      expect(validateEmail(null), 'REQUIRED');
    });
    test('invalid shapes', () {
      for (final v in ['ana', 'ana@', '@x.ro', 'a b@x.ro']) {
        expect(validateEmail(v), 'INVALID_EMAIL', reason: v);
      }
    });
    test('too long', () {
      final v = '${'a' * 244}@example.ro';
      expect(v.length, 255);
      expect(validateEmail(v), 'TOO_LONG');
      final ok = '${'a' * 243}@example.ro';
      expect(ok.length, 254);
      expect(validateEmail(ok), isNull);
    });
  });

  group('validateName', () {
    test('blank required', () => expect(validateName('  '), 'REQUIRED'));
    test('bounds', () {
      expect(validateName('a' * 100), isNull);
      expect(validateName('a' * 101), 'TOO_LONG');
    });
  });

  test('validateRequired', () {
    expect(validateRequired(null), 'REQUIRED');
    expect(validateRequired(''), 'REQUIRED');
    expect(validateRequired('x'), isNull);
  });

  test('validatePasswordConfirmation', () {
    expect(validatePasswordConfirmation('', 'abc'), 'REQUIRED');
    expect(validatePasswordConfirmation('abd', 'abc'), 'PASSWORDS_DONT_MATCH');
    expect(validatePasswordConfirmation('abc', 'abc'), isNull);
  });
}
