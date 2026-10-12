// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_list_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClientListItem _$ClientListItemFromJson(Map<String, dynamic> json) =>
    _ClientListItem(
      id: json['id'] as String,
      name: json['name'] as String?,
      status: ClientListStatus.fromJson(json['status'] as String),
      invitationExpired: json['invitationExpired'] as bool,
      email: json['email'] as String?,
      invitedAt: json['invitedAt'] == null
          ? null
          : DateTime.parse(json['invitedAt'] as String),
      invitationExpiresAt: json['invitationExpiresAt'] == null
          ? null
          : DateTime.parse(json['invitationExpiresAt'] as String),
    );

Map<String, dynamic> _$ClientListItemToJson(_ClientListItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'status': instance.status.toJson(),
      'invitationExpired': instance.invitationExpired,
      'email': instance.email,
      'invitedAt': instance.invitedAt?.toIso8601String(),
      'invitationExpiresAt': instance.invitationExpiresAt?.toIso8601String(),
    };
