// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'change_relationship_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChangeRelationshipRequest _$ChangeRelationshipRequestFromJson(
  Map<String, dynamic> json,
) => _ChangeRelationshipRequest(
  status: ChangeRelationshipRequestStatus.fromJson(json['status'] as String),
);

Map<String, dynamic> _$ChangeRelationshipRequestToJson(
  _ChangeRelationshipRequest instance,
) => <String, dynamic>{'status': instance.status.toJson()};
