// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invite_preview_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InvitePreviewResponse _$InvitePreviewResponseFromJson(
  Map<String, dynamic> json,
) => _InvitePreviewResponse(
  coachFirstName: json['coachFirstName'] as String,
  coachLastName: json['coachLastName'] as String,
  valid: json['valid'] as bool,
);

Map<String, dynamic> _$InvitePreviewResponseToJson(
  _InvitePreviewResponse instance,
) => <String, dynamic>{
  'coachFirstName': instance.coachFirstName,
  'coachLastName': instance.coachLastName,
  'valid': instance.valid,
};
