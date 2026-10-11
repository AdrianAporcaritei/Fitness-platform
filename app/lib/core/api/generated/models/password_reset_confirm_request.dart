// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'password_reset_confirm_request.freezed.dart';
part 'password_reset_confirm_request.g.dart';

@Freezed()
abstract class PasswordResetConfirmRequest with _$PasswordResetConfirmRequest {
  const factory PasswordResetConfirmRequest({
    required String token,

    /// 10-64 characters and at most 72 UTF-8 bytes.
    required String newPassword,
  }) = _PasswordResetConfirmRequest;

  factory PasswordResetConfirmRequest.fromJson(Map<String, Object?> json) =>
      _$PasswordResetConfirmRequestFromJson(json);
}
