// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'change_relationship_request_status.dart';

part 'change_relationship_request.freezed.dart';
part 'change_relationship_request.g.dart';

@Freezed()
abstract class ChangeRelationshipRequest with _$ChangeRelationshipRequest {
  const factory ChangeRelationshipRequest({
    required ChangeRelationshipRequestStatus status,
  }) = _ChangeRelationshipRequest;

  factory ChangeRelationshipRequest.fromJson(Map<String, Object?> json) =>
      _$ChangeRelationshipRequestFromJson(json);
}
