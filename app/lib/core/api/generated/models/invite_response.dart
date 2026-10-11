// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'invite_response_status.dart';

part 'invite_response.freezed.dart';
part 'invite_response.g.dart';

@Freezed()
abstract class InviteResponse with _$InviteResponse {
  const factory InviteResponse({
    required String id,
    required InviteResponseStatus status,
    required DateTime createdAt,
    required DateTime expiresAt,
    String? label,
    DateTime? usedAt,
  }) = _InviteResponse;
  
  factory InviteResponse.fromJson(Map<String, Object?> json) => _$InviteResponseFromJson(json);
}
