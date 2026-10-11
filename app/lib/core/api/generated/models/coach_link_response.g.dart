// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coach_link_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CoachLinkResponse _$CoachLinkResponseFromJson(Map<String, dynamic> json) =>
    _CoachLinkResponse(
      coachId: json['coachId'] as String,
      coachFirstName: json['coachFirstName'] as String,
      coachLastName: json['coachLastName'] as String,
      status: CoachLinkResponseStatus.fromJson(json['status'] as String),
      startedAt: DateTime.parse(json['startedAt'] as String),
    );

Map<String, dynamic> _$CoachLinkResponseToJson(_CoachLinkResponse instance) =>
    <String, dynamic>{
      'coachId': instance.coachId,
      'coachFirstName': instance.coachFirstName,
      'coachLastName': instance.coachLastName,
      'status': instance.status.toJson(),
      'startedAt': instance.startedAt.toIso8601String(),
    };
