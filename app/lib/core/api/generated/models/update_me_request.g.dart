// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_me_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UpdateMeRequest _$UpdateMeRequestFromJson(Map<String, dynamic> json) =>
    _UpdateMeRequest(
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      locale: json['locale'] == null
          ? null
          : UpdateMeRequestLocale.fromJson(json['locale'] as String),
      timezone: json['timezone'] as String?,
    );

Map<String, dynamic> _$UpdateMeRequestToJson(_UpdateMeRequest instance) =>
    <String, dynamic>{
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'locale': instance.locale?.toJson(),
      'timezone': instance.timezone,
    };
