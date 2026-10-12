// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coach_client_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CoachClientResponse _$CoachClientResponseFromJson(Map<String, dynamic> json) =>
    _CoachClientResponse(
      clientId: json['clientId'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      status: CoachClientResponseStatus.fromJson(json['status'] as String),
      startedAt: DateTime.parse(json['startedAt'] as String),
    );

Map<String, dynamic> _$CoachClientResponseToJson(
  _CoachClientResponse instance,
) => <String, dynamic>{
  'clientId': instance.clientId,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'email': instance.email,
  'status': instance.status.toJson(),
  'startedAt': instance.startedAt.toIso8601String(),
};
