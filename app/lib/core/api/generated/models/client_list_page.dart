// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'client_list_item.dart';

part 'client_list_page.freezed.dart';
part 'client_list_page.g.dart';

@Freezed()
abstract class ClientListPage with _$ClientListPage {
  const factory ClientListPage({
    required List<ClientListItem> items,
    required int page,
    required int size,
    required int totalItems,
    required int totalPages,
  }) = _ClientListPage;
  
  factory ClientListPage.fromJson(Map<String, Object?> json) => _$ClientListPageFromJson(json);
}
