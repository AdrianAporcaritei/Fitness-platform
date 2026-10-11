// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'coach_client_response_status.dart';

part 'coach_client_response.freezed.dart';
part 'coach_client_response.g.dart';

@Freezed()
abstract class CoachClientResponse with _$CoachClientResponse {
  const factory CoachClientResponse({
    required String clientId,
    required String firstName,
    required String lastName,
    required String email,
    required CoachClientResponseStatus status,
    required DateTime startedAt,
  }) = _CoachClientResponse;
  
  factory CoachClientResponse.fromJson(Map<String, Object?> json) => _$CoachClientResponseFromJson(json);
}
