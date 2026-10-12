// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'created_invite_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreatedInviteResponse _$CreatedInviteResponseFromJson(
  Map<String, dynamic> json,
) => _CreatedInviteResponse(
  id: json['id'] as String,
  code: json['code'] as String,
  link: json['link'] as String,
  expiresAt: DateTime.parse(json['expiresAt'] as String),
  label: json['label'] as String?,
);

Map<String, dynamic> _$CreatedInviteResponseToJson(
  _CreatedInviteResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'code': instance.code,
  'link': instance.link,
  'expiresAt': instance.expiresAt.toIso8601String(),
  'label': instance.label,
};
