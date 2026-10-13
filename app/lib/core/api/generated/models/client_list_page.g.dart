// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_list_page.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClientListPage _$ClientListPageFromJson(Map<String, dynamic> json) =>
    _ClientListPage(
      items: (json['items'] as List<dynamic>)
          .map((e) => ClientListItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      page: (json['page'] as num).toInt(),
      size: (json['size'] as num).toInt(),
      totalItems: (json['totalItems'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
    );

Map<String, dynamic> _$ClientListPageToJson(_ClientListPage instance) =>
    <String, dynamic>{
      'items': instance.items.map((e) => e.toJson()).toList(),
      'page': instance.page,
      'size': instance.size,
      'totalItems': instance.totalItems,
      'totalPages': instance.totalPages,
    };
