import 'package:ana_fit_lab/core/api/generated/export.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fixtures.dart';

void main() {
  test('TokenResponse parses the contract JSON', () {
    final now = DateTime.utc(2026, 1, 1, 12);
    final t = TokenResponse.fromJson(tokenJson(now: now));
    expect(t.user.email, 'ana@example.ro');
    expect(t.user.role, UserResponseRole.coach);
    expect(t.user.status, UserResponseStatus.pending);
    expect(t.user.locale, UserResponseLocale.en);
    expect(t.accessTokenExpiresAt.isUtc, isTrue);
    expect(t.accessTokenExpiresAt, DateTime.utc(2026, 1, 1, 12, 15));
    expect(TokenResponse.fromJson(t.toJson()), t);
  });

  test('unknown enum values are tolerated', () {
    final u = UserResponse.fromJson(userJson(role: 'SUPERHERO'));
    expect(u.role, UserResponseRole.$unknown);
  });

  test('ClientListItem parses an INVITED row with nullable fields', () {
    final i = ClientListItem.fromJson({
      'id': 'x',
      'name': null,
      'email': null,
      'status': 'INVITED',
      'invitedAt': '2026-01-01T00:00:00Z',
      'invitationExpiresAt': '2026-01-08T00:00:00Z',
      'invitationExpired': true,
    });
    expect(i.name, isNull);
    expect(i.status, ClientListStatus.invited);
    expect(i.invitationExpiresAt, DateTime.utc(2026, 1, 8));
    expect(i.invitationExpired, isTrue);
  });

  test('RegisterCoachRequest serializes the contract keys', () {
    final json = const RegisterCoachRequest(
      email: 'a@b.ro',
      password: 'xxxxxxxxxx',
      firstName: 'Ana',
      lastName: 'P',
      locale: RegisterCoachRequestLocale.en,
      timezone: 'Europe/Bucharest',
    ).toJson();
    expect(json.keys.toSet(), {
      'email',
      'password',
      'firstName',
      'lastName',
      'locale',
      'timezone',
    });
    expect(json['locale'], 'en');
  });
}
