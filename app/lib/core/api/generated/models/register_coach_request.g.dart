// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_coach_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RegisterCoachRequest _$RegisterCoachRequestFromJson(
  Map<String, dynamic> json,
) => _RegisterCoachRequest(
  email: json['email'] as String,
  password: json['password'] as String,
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  locale: RegisterCoachRequestLocale.fromJson(json['locale'] as String),
  timezone: json['timezone'] as String,
);

Map<String, dynamic> _$RegisterCoachRequestToJson(
  _RegisterCoachRequest instance,
) => <String, dynamic>{
  'email': instance.email,
  'password': instance.password,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'locale': instance.locale.toJson(),
  'timezone': instance.timezone,
};
