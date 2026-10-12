import 'package:ana_fit_lab/core/errors/api_error.dart';
import 'package:ana_fit_lab/core/errors/error_messages.dart';
import 'package:ana_fit_lab/core/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  final ro = lookupAppLocalizations(const Locale('ro'));

  test('maps known codes', () {
    expect(
      errorMessage(en, const ApiError(code: 'INVALID_CREDENTIALS')),
      'Email or password is incorrect.',
    );
  });

  test('RATE_LIMITED rounds retry-after up to minutes, min 1', () {
    expect(
      errorMessage(
        en,
        const ApiError(code: 'RATE_LIMITED', retryAfter: Duration(seconds: 61)),
      ),
      contains('2 min'),
    );
    expect(
      errorMessage(
        en,
        const ApiError(code: 'RATE_LIMITED', retryAfter: Duration(seconds: 10)),
      ),
      contains('1 min'),
    );
    expect(
      errorMessage(en, const ApiError(code: 'RATE_LIMITED')),
      contains('1 min'),
    );
  });

  test('unknown code falls back to error_UNKNOWN', () {
    expect(
      errorMessage(en, const ApiError(code: 'FOO')),
      'Something went wrong. Please try again.',
    );
  });

  test('field errors', () {
    expect(fieldErrorMessage(en, 'PASSWORD_POLICY'), 'Use 10–64 characters');
    expect(fieldErrorMessage(en, 'NOPE'), en.error_UNKNOWN);
  });

  test('Romanian differs from English', () {
    expect(
      errorMessage(ro, const ApiError(code: 'INVALID_CREDENTIALS')),
      isNot(errorMessage(en, const ApiError(code: 'INVALID_CREDENTIALS'))),
    );
  });
}
