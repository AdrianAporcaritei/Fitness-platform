import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_api.dart';
import '../../support/test_app.dart';
import 'coach_test_support.dart';

void main() {
  testWidgets('sidebar: only Clients is active, the rest are coming soon', (
    t,
  ) async {
    await pumpCoach(t);
    for (final label in [
      'Dashboard',
      'Clients',
      'Workouts',
      'Meal plans',
      'Chat',
    ]) {
      expect(find.text(label), findsWidgets, reason: label);
    }
    expect(find.text('Coming soon'), findsNWidgets(4));

    await t.tap(find.text('Workouts'));
    await t.pumpAndSettle();
    expect(currentLocation(t), '/coach/clients');
    expect(find.byType(Drawer), findsNothing);
  });

  testWidgets('shows the coach and signs out', (t) async {
    final api = await pumpCoach(t);
    api.on('POST', '/auth/logout', (_) => FakeResponse.empty(204));
    expect(find.text('Ana Popescu'), findsOneWidget);
    await t.tap(find.byTooltip('Sign out'));
    await t.pumpAndSettle();
    expect(currentLocation(t), startsWith('/login'));
    expect(api.count('POST', '/auth/logout'), 1);
  });

  testWidgets('unverified coach sees the confirm-email banner', (t) async {
    await pumpCoach(t, status: 'PENDING');
    expect(
      find.text('Confirm your email – we sent a link to ana@example.ro'),
      findsOneWidget,
    );
  });

  testWidgets('narrow screen: sidebar moves into a drawer', (t) async {
    await pumpCoach(t, size: const Size(700, 900));
    expect(find.text('Meal plans'), findsNothing);
    await t.tap(find.byTooltip('Open menu'));
    await t.pumpAndSettle();
    expect(find.text('Meal plans'), findsOneWidget);

    await t.tap(find.text('Clients').last);
    await t.pumpAndSettle();
    expect(find.text('Meal plans'), findsNothing);
    expect(currentLocation(t), '/coach/clients');
  });
}
