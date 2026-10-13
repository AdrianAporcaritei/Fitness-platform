// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'client_list_status.dart';

part 'client_list_item.freezed.dart';
part 'client_list_item.g.dart';

@Freezed()
abstract class ClientListItem with _$ClientListItem {
  const factory ClientListItem({
    /// The invitation id when status is INVITED, otherwise the client's user id.
    required String id,

    /// Invitation name for INVITED (null only for invitations created before names were required), otherwise the client's first and last name.
    required String? name,
    required ClientListStatus status,

    /// True for an INVITED row whose invitation has expired.
    required bool invitationExpired,

    /// Invitation email for INVITED (may be null for older invitations), otherwise the client's email.
    String? email,

    /// When the invitation was created.
    DateTime? invitedAt,

    /// Set only for INVITED.
    DateTime? invitationExpiresAt,
  }) = _ClientListItem;
  
  factory ClientListItem.fromJson(Map<String, Object?> json) => _$ClientListItemFromJson(json);
}
