// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'created_invite_response.freezed.dart';
part 'created_invite_response.g.dart';

@Freezed()
abstract class CreatedInviteResponse with _$CreatedInviteResponse {
  const factory CreatedInviteResponse({
    required String id,

    /// Display form XXXXX-XXXXX (Crockford base32).
    required String code,

    /// {baseUrl}/join/{code}
    required String link,
    required DateTime expiresAt,
    String? label,
  }) = _CreatedInviteResponse;

  factory CreatedInviteResponse.fromJson(Map<String, Object?> json) =>
      _$CreatedInviteResponseFromJson(json);
}
