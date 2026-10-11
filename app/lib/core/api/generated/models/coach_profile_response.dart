// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'coach_profile_response.freezed.dart';
part 'coach_profile_response.g.dart';

@Freezed()
abstract class CoachProfileResponse with _$CoachProfileResponse {
  const factory CoachProfileResponse({
    required List<String> specializations,
    String? bio,
  }) = _CoachProfileResponse;

  factory CoachProfileResponse.fromJson(Map<String, Object?> json) =>
      _$CoachProfileResponseFromJson(json);
}
