// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_client_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RegisterClientRequest _$RegisterClientRequestFromJson(
  Map<String, dynamic> json,
) => _RegisterClientRequest(
  code: json['code'] as String,
  email: json['email'] as String,
  password: json['password'] as String,
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  locale: RegisterClientRequestLocale.fromJson(json['locale'] as String),
  timezone: json['timezone'] as String,
);

Map<String, dynamic> _$RegisterClientRequestToJson(
  _RegisterClientRequest instance,
) => <String, dynamic>{
  'code': instance.code,
  'email': instance.email,
  'password': instance.password,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'locale': instance.locale.toJson(),
  'timezone': instance.timezone,
};
