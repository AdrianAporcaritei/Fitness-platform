// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_invite_request.freezed.dart';
part 'create_invite_request.g.dart';

@Freezed()
abstract class CreateInviteRequest with _$CreateInviteRequest {
  const factory CreateInviteRequest({
    /// Optional note for the coach, such as the prospective client's name.
    String? label,
  }) = _CreateInviteRequest;

  factory CreateInviteRequest.fromJson(Map<String, Object?> json) =>
      _$CreateInviteRequestFromJson(json);
}
