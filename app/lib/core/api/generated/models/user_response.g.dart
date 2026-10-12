// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserResponse _$UserResponseFromJson(Map<String, dynamic> json) =>
    _UserResponse(
      id: json['id'] as String,
      email: json['email'] as String,
      role: UserResponseRole.fromJson(json['role'] as String),
      status: UserResponseStatus.fromJson(json['status'] as String),
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      locale: UserResponseLocale.fromJson(json['locale'] as String),
      timezone: json['timezone'] as String,
    );

Map<String, dynamic> _$UserResponseToJson(_UserResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'role': instance.role.toJson(),
      'status': instance.status.toJson(),
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'locale': instance.locale.toJson(),
      'timezone': instance.timezone,
    };
