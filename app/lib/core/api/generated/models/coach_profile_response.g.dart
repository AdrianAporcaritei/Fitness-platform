// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coach_profile_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CoachProfileResponse _$CoachProfileResponseFromJson(
  Map<String, dynamic> json,
) => _CoachProfileResponse(
  specializations: (json['specializations'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  bio: json['bio'] as String?,
);

Map<String, dynamic> _$CoachProfileResponseToJson(
  _CoachProfileResponse instance,
) => <String, dynamic>{
  'specializations': instance.specializations,
  'bio': instance.bio,
};
