import 'dart:math';

import '../l10n/app_localizations.dart';
import 'api_error.dart';

/// Codes with a dedicated `error_<CODE>` message; anything else maps to UNKNOWN.
const knownErrorCodes = <String>[
  'UNKNOWN',
  'NETWORK',
  'INTERNAL_ERROR',
  'INVALID_CREDENTIALS',
  'ACCOUNT_SUSPENDED',
  'RATE_LIMITED',
  'EMAIL_TAKEN',
  'ALREADY_HAS_COACH',
  'REQUIRED',
  'TOO_LONG',
  'INVALID_EMAIL',
  'PASSWORD_POLICY',
  'PASSWORDS_DONT_MATCH',
  'INVALID_LOCALE',
  'INVALID_TIMEZONE',
  'INVITE_EXPIRED',
  'INVITE_USED',
  'INVITE_REVOKED',
  'INVITE_NOT_FOUND',
  'COACH_UNAVAILABLE',
  'INVALID_TOKEN',
  'INVITE_NOT_PENDING',
  'INVITE_ALREADY_PENDING',
  'ALREADY_YOUR_CLIENT',
  'EMAIL_NOT_VERIFIED',
  'INVALID_RELATIONSHIP_TRANSITION',
  'CLIENT_NOT_FOUND',
];

String errorMessage(AppLocalizations l, ApiError e) {
  if (e.code == 'RATE_LIMITED') {
    final seconds = e.retryAfter?.inSeconds ?? 0;
    return l.error_RATE_LIMITED(max(1, (seconds / 60).ceil()));
  }
  return fieldErrorMessage(l, e.code);
}

String fieldErrorMessage(AppLocalizations l, String code) => switch (code) {
  'NETWORK' => l.error_NETWORK,
  'INTERNAL_ERROR' => l.error_INTERNAL_ERROR,
  'INVALID_CREDENTIALS' => l.error_INVALID_CREDENTIALS,
  'ACCOUNT_SUSPENDED' => l.error_ACCOUNT_SUSPENDED,
  'EMAIL_TAKEN' => l.error_EMAIL_TAKEN,
  'ALREADY_HAS_COACH' => l.error_ALREADY_HAS_COACH,
  'REQUIRED' => l.error_REQUIRED,
  'TOO_LONG' => l.error_TOO_LONG,
  'INVALID_EMAIL' => l.error_INVALID_EMAIL,
  'PASSWORD_POLICY' => l.error_PASSWORD_POLICY,
  'PASSWORDS_DONT_MATCH' => l.error_PASSWORDS_DONT_MATCH,
  'INVALID_LOCALE' => l.error_INVALID_LOCALE,
  'INVALID_TIMEZONE' => l.error_INVALID_TIMEZONE,
  'INVITE_EXPIRED' => l.error_INVITE_EXPIRED,
  'INVITE_USED' => l.error_INVITE_USED,
  'INVITE_REVOKED' => l.error_INVITE_REVOKED,
  'INVITE_NOT_FOUND' => l.error_INVITE_NOT_FOUND,
  'COACH_UNAVAILABLE' => l.error_COACH_UNAVAILABLE,
  'INVALID_TOKEN' => l.error_INVALID_TOKEN,
  'INVITE_NOT_PENDING' => l.error_INVITE_NOT_PENDING,
  'INVITE_ALREADY_PENDING' => l.error_INVITE_ALREADY_PENDING,
  'ALREADY_YOUR_CLIENT' => l.error_ALREADY_YOUR_CLIENT,
  'EMAIL_NOT_VERIFIED' => l.error_EMAIL_NOT_VERIFIED,
  'INVALID_RELATIONSHIP_TRANSITION' => l.error_INVALID_RELATIONSHIP_TRANSITION,
  'CLIENT_NOT_FOUND' => l.error_CLIENT_NOT_FOUND,
  _ => l.error_UNKNOWN,
};
