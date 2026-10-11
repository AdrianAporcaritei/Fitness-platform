import 'dart:convert';
import 'dart:io';

import 'package:ana_fit_lab/core/errors/error_messages.dart';
import 'package:flutter_test/flutter_test.dart';

Set<String> keys(String path) =>
    (jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>).keys
        .where((k) => !k.startsWith('@'))
        .toSet();

void main() {
  final en = keys('lib/core/l10n/app_en.arb');
  final ro = keys('lib/core/l10n/app_ro.arb');

  test('en and ro have the same keys', () {
    expect(ro.difference(en), isEmpty);
    expect(en.difference(ro), isEmpty);
  });

  test('every known error code has an error_ key', () {
    for (final code in knownErrorCodes) {
      expect(en, contains('error_$code'));
    }
  });
}
