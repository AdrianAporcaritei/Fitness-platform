// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'coach_link_response_status.dart';

part 'coach_link_response.freezed.dart';
part 'coach_link_response.g.dart';

@Freezed()
abstract class CoachLinkResponse with _$CoachLinkResponse {
  const factory CoachLinkResponse({
    required String coachId,
    required String coachFirstName,
    required String coachLastName,
    required CoachLinkResponseStatus status,
    required DateTime startedAt,
  }) = _CoachLinkResponse;

  factory CoachLinkResponse.fromJson(Map<String, Object?> json) =>
      _$CoachLinkResponseFromJson(json);
}
