// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'update_me_request_locale.dart';

part 'update_me_request.freezed.dart';
part 'update_me_request.g.dart';

@Freezed()
abstract class UpdateMeRequest with _$UpdateMeRequest {
  const factory UpdateMeRequest({
    String? firstName,
    String? lastName,
    UpdateMeRequestLocale? locale,

    /// IANA time zone name.
    String? timezone,
  }) = _UpdateMeRequest;

  factory UpdateMeRequest.fromJson(Map<String, Object?> json) =>
      _$UpdateMeRequestFromJson(json);
}
