Map<String, dynamic> userJson({
  String role = 'CLIENT',
  String status = 'PENDING',
  String locale = 'en',
  String email = 'ana@example.ro',
  String firstName = 'Ana',
}) => {
  'id': '11111111-1111-1111-1111-111111111111',
  'email': email,
  'role': role,
  'status': status,
  'firstName': firstName,
  'lastName': 'Popescu',
  'locale': locale,
  'timezone': 'Europe/Bucharest',
};

Map<String, dynamic> tokenJson({
  Map<String, dynamic>? user,
  String access = 'access-1',
  String refresh = 'refresh-1',
  Duration accessValidFor = const Duration(minutes: 15),
  DateTime? now,
}) {
  final base = (now ?? DateTime.now()).toUtc();
  return {
    'accessToken': access,
    'accessTokenExpiresAt': base.add(accessValidFor).toIso8601String(),
    'refreshToken': refresh,
    'refreshTokenExpiresAt': base
        .add(const Duration(days: 30))
        .toIso8601String(),
    'user': user ?? userJson(),
  };
}

Map<String, dynamic> clientItemJson({
  String id = '22222222-2222-2222-2222-222222222222',
  String? name = 'Maria Pavel',
  String? email = 'maria@example.ro',
  String status = 'ACTIVE',
  String? invitedAt = '2026-10-01T09:00:00Z',
  String? invitationExpiresAt,
  bool invitationExpired = false,
}) => {
  'id': id,
  'name': name,
  'email': email,
  'status': status,
  'invitedAt': invitedAt,
  'invitationExpiresAt': invitationExpiresAt,
  'invitationExpired': invitationExpired,
};

Map<String, dynamic> clientPageJson({
  List<Map<String, dynamic>> items = const [],
  int page = 0,
  int size = 20,
  int? totalItems,
}) {
  final total = totalItems ?? items.length;
  return {
    'items': items,
    'page': page,
    'size': size,
    'totalItems': total,
    'totalPages': (total + size - 1) ~/ size,
  };
}
