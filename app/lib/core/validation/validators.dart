import 'dart:convert';

/// Client-side validators. They return API-style error codes (or null) so the
/// UI maps client and server errors with one mapper.

final _emailShape = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

String? validateRequired(String? v) => (v == null || v.isEmpty) ? 'REQUIRED' : null;

String? validateEmail(String? v) {
  final t = v?.trim() ?? '';
  if (t.isEmpty) return 'REQUIRED';
  if (t.length > 254) return 'TOO_LONG';
  if (!_emailShape.hasMatch(t)) return 'INVALID_EMAIL';
  return null;
}

String? validateName(String? v) {
  final t = v?.trim() ?? '';
  if (t.isEmpty) return 'REQUIRED';
  if (t.length > 100) return 'TOO_LONG';
  return null;
}

/// Mirrors the backend: 10-64 code points and at most 72 UTF-8 bytes.
/// The password is intentionally not trimmed.
String? validateNewPassword(String? v) {
  if (v == null || v.isEmpty) return 'REQUIRED';
  final points = v.runes.length;
  if (points < 10 || points > 64 || utf8.encode(v).length > 72) {
    return 'PASSWORD_POLICY';
  }
  return null;
}

String? validatePasswordConfirmation(String? v, String password) {
  if (v == null || v.isEmpty) return 'REQUIRED';
  return v == password ? null : 'PASSWORDS_DONT_MATCH';
}
