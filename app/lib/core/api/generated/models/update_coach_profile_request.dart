// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_coach_profile_request.freezed.dart';
part 'update_coach_profile_request.g.dart';

@Freezed()
abstract class UpdateCoachProfileRequest with _$UpdateCoachProfileRequest {
  const factory UpdateCoachProfileRequest({
    String? bio,
    List<String>? specializations,
  }) = _UpdateCoachProfileRequest;

  factory UpdateCoachProfileRequest.fromJson(Map<String, Object?> json) =>
      _$UpdateCoachProfileRequestFromJson(json);
}
