// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_coach_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MyCoachResponse _$MyCoachResponseFromJson(Map<String, dynamic> json) =>
    _MyCoachResponse(
      coachId: json['coachId'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      specializations: (json['specializations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      status: MyCoachResponseStatus.fromJson(json['status'] as String),
      startedAt: DateTime.parse(json['startedAt'] as String),
      bio: json['bio'] as String?,
    );

Map<String, dynamic> _$MyCoachResponseToJson(_MyCoachResponse instance) =>
    <String, dynamic>{
      'coachId': instance.coachId,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'specializations': instance.specializations,
      'status': instance.status.toJson(),
      'startedAt': instance.startedAt.toIso8601String(),
      'bio': instance.bio,
    };
