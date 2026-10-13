import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/generated/export.dart';
import '../../../core/errors/api_error.dart';
import 'client_list_query.dart';

/// The coach's clients and invitations. Failures are thrown as [ApiError].
class ClientsRepository {
  ClientsRepository(this._api);

  final ApiClient _api;

  Future<ClientListPage> list(ClientListQuery query) {
    final search = query.search.trim();
    return apiCall(
      () => _api.openapi.listClients(
        q: search.isEmpty ? null : search,
        status: query.status,
        page: query.page,
        size: ClientListQuery.pageSize,
      ),
    );
  }

  Future<InvitationLinkResponse> add({
    required String name,
    required String email,
  }) => apiCall(
    () => _api.openapi.addClient(
      body: AddClientRequest(name: name.trim(), email: email.trim()),
    ),
  );

  Future<InvitationLinkResponse> regenerate(String invitationId) =>
      apiCall(() => _api.openapi.regenerateInvitation(id: invitationId));

  Future<void> cancel(String invitationId) =>
      apiCall(() => _api.openapi.cancelInvitation(id: invitationId));
}

final clientsRepositoryProvider = Provider<ClientsRepository>(
  (ref) => ClientsRepository(ref.watch(apiProvider)),
);

/// One page of the list. No automatic retry: the page shows the error and a
/// Retry button instead. Refresh after a change with `ref.invalidate`.
final clientListProvider = FutureProvider.autoDispose
    .family<ClientListPage, ClientListQuery>(
      (ref, query) => ref.watch(clientsRepositoryProvider).list(query),
      retry: (_, _) => null,
    );
