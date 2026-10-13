// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'invitation_link_response.freezed.dart';
part 'invitation_link_response.g.dart';

@Freezed()
abstract class InvitationLinkResponse with _$InvitationLinkResponse {
  const factory InvitationLinkResponse({
    required String invitationId,
    required String? name,
    required String? email,

    /// Display form XXXXX-XXXXX (Crockford base32).
    required String code,

    /// {baseUrl}/join/{code}
    required String link,
    required DateTime expiresAt,
  }) = _InvitationLinkResponse;
  
  factory InvitationLinkResponse.fromJson(Map<String, Object?> json) => _$InvitationLinkResponseFromJson(json);
}
