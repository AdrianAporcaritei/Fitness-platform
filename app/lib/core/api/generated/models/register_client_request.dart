// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'register_client_request_locale.dart';

part 'register_client_request.freezed.dart';
part 'register_client_request.g.dart';

@Freezed()
abstract class RegisterClientRequest with _$RegisterClientRequest {
  const factory RegisterClientRequest({
    /// Invite code, accepted loosely like in GET /invites/{code}.
    required String code,
    required String email,

    /// 10-64 characters and at most 72 UTF-8 bytes.
    required String password,
    required String firstName,
    required String lastName,
    required RegisterClientRequestLocale locale,

    /// IANA time zone name.
    required String timezone,
  }) = _RegisterClientRequest;
  
  factory RegisterClientRequest.fromJson(Map<String, Object?> json) => _$RegisterClientRequestFromJson(json);
}
