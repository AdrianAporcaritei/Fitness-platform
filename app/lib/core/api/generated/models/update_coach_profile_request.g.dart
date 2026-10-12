// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_coach_profile_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UpdateCoachProfileRequest _$UpdateCoachProfileRequestFromJson(
  Map<String, dynamic> json,
) => _UpdateCoachProfileRequest(
  bio: json['bio'] as String?,
  specializations: (json['specializations'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$UpdateCoachProfileRequestToJson(
  _UpdateCoachProfileRequest instance,
) => <String, dynamic>{
  'bio': instance.bio,
  'specializations': instance.specializations,
};
