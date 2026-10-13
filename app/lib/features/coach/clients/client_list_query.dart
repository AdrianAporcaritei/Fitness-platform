import 'package:flutter/foundation.dart';

import '../../../core/api/generated/export.dart';

/// Search, status filter and page of the client list. Lives in the URL
/// (`/coach/clients?q=ana&status=invited&page=2`) so back, refresh and links
/// keep it. [page] is zero-based; the URL shows it one-based.
@immutable
class ClientListQuery {
  const ClientListQuery({this.search = '', this.status, this.page = 0});

  factory ClientListQuery.fromUri(Uri uri) {
    final params = uri.queryParameters;
    final status = params['status'];
    final page = int.tryParse(params['page'] ?? '');
    return ClientListQuery(
      search: params['q'] ?? '',
      status: ClientListStatus.$valuesDefined
          .where((s) => s.name == status)
          .firstOrNull,
      page: page != null && page > 1 ? page - 1 : 0,
    );
  }

  static const pageSize = 20;

  final String search;
  final ClientListStatus? status;
  final int page;

  bool get hasFilters => search.trim().isNotEmpty || status != null;

  /// The query parameters for the URL; defaults are left out.
  Map<String, String> toQueryParameters() => {
    if (search.isNotEmpty) 'q': search,
    if (status != null) 'status': status!.name,
    if (page > 0) 'page': '${page + 1}',
  };

  /// A new search or filter starts again at the first page.
  ClientListQuery withSearch(String value) =>
      ClientListQuery(search: value, status: status);

  ClientListQuery withStatus(ClientListStatus? value) =>
      ClientListQuery(search: search, status: value);

  ClientListQuery withPage(int value) =>
      ClientListQuery(search: search, status: status, page: value);

  @override
  bool operator ==(Object other) =>
      other is ClientListQuery &&
      other.search == search &&
      other.status == status &&
      other.page == page;

  @override
  int get hashCode => Object.hash(search, status, page);

  @override
  String toString() => 'ClientListQuery($search, $status, $page)';
}
