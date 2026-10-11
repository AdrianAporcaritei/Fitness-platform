// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'my_coach_response_status.dart';

part 'my_coach_response.freezed.dart';
part 'my_coach_response.g.dart';

@Freezed()
abstract class MyCoachResponse with _$MyCoachResponse {
  const factory MyCoachResponse({
    required String coachId,
    required String firstName,
    required String lastName,
    required List<String> specializations,
    required MyCoachResponseStatus status,
    required DateTime startedAt,
    String? bio,
  }) = _MyCoachResponse;

  factory MyCoachResponse.fromJson(Map<String, Object?> json) =>
      _$MyCoachResponseFromJson(json);
}
