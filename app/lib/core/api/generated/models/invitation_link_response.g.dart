// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invitation_link_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InvitationLinkResponse _$InvitationLinkResponseFromJson(
  Map<String, dynamic> json,
) => _InvitationLinkResponse(
  invitationId: json['invitationId'] as String,
  name: json['name'] as String?,
  email: json['email'] as String?,
  code: json['code'] as String,
  link: json['link'] as String,
  expiresAt: DateTime.parse(json['expiresAt'] as String),
);

Map<String, dynamic> _$InvitationLinkResponseToJson(
  _InvitationLinkResponse instance,
) => <String, dynamic>{
  'invitationId': instance.invitationId,
  'name': instance.name,
  'email': instance.email,
  'code': instance.code,
  'link': instance.link,
  'expiresAt': instance.expiresAt.toIso8601String(),
};
