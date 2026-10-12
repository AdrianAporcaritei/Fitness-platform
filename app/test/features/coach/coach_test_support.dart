import 'package:ana_fit_lab/core/auth/token_store.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/app_container.dart';
import '../../support/fake_api.dart';
import '../../support/fixtures.dart';
import '../../support/test_app.dart';

/// Signs in as a coach and opens [location]. [clients] answers
/// `GET /coach/clients` (default: an empty list).
Future<FakeApi> pumpCoach(
  WidgetTester t, {
  String location = '/coach/clients',
  String status = 'ACTIVE',
  FakeHandler? clients,
  Size? size,
}) async {
  final api = FakeApi();
  final store = MemoryTokenStore();
  await store.write('r1', testNow.add(const Duration(days: 10)));
  api.on(
    'POST',
    '/auth/refresh',
    (_) => FakeResponse.json(
      200,
      tokenJson(
        now: testNow,
        user: userJson(role: 'COACH', status: status),
      ),
    ),
  );
  api.on(
    'GET',
    '/coach/clients',
    clients ?? (_) => FakeResponse.json(200, clientPageJson()),
  );
  await pumpApp(t, api: api, store: store, initialLocation: location);
  if (size != null) {
    t.view.physicalSize = size;
    await t.pumpAndSettle();
  }
  return api;
}

/// Query parameters of the last `GET /coach/clients`.
Map<String, dynamic> lastListQuery(FakeApi api) => api.requests
    .lastWhere((r) => r.method == 'GET' && r.path.endsWith('/coach/clients'))
    .queryParameters;
