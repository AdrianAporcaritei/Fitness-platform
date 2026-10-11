// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'register_coach_request_locale.dart';

part 'register_coach_request.freezed.dart';
part 'register_coach_request.g.dart';

@Freezed()
abstract class RegisterCoachRequest with _$RegisterCoachRequest {
  const factory RegisterCoachRequest({
    required String email,

    /// 10-64 characters and at most 72 UTF-8 bytes.
    required String password,
    required String firstName,
    required String lastName,
    required RegisterCoachRequestLocale locale,

    /// IANA time zone name.
    required String timezone,
  }) = _RegisterCoachRequest;

  factory RegisterCoachRequest.fromJson(Map<String, Object?> json) =>
      _$RegisterCoachRequestFromJson(json);
}
