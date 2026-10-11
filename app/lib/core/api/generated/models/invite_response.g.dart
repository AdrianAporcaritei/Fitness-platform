// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invite_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InviteResponse _$InviteResponseFromJson(Map<String, dynamic> json) =>
    _InviteResponse(
      id: json['id'] as String,
      status: InviteResponseStatus.fromJson(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      label: json['label'] as String?,
      usedAt: json['usedAt'] == null
          ? null
          : DateTime.parse(json['usedAt'] as String),
    );

Map<String, dynamic> _$InviteResponseToJson(_InviteResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status.toJson(),
      'createdAt': instance.createdAt.toIso8601String(),
      'expiresAt': instance.expiresAt.toIso8601String(),
      'label': instance.label,
      'usedAt': instance.usedAt?.toIso8601String(),
    };
