// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'invite_preview_response.freezed.dart';
part 'invite_preview_response.g.dart';

@Freezed()
abstract class InvitePreviewResponse with _$InvitePreviewResponse {
  const factory InvitePreviewResponse({
    required String coachFirstName,
    required String coachLastName,

    /// Always true; invalid codes are errors.
    required bool valid,
  }) = _InvitePreviewResponse;
  
  factory InvitePreviewResponse.fromJson(Map<String, Object?> json) => _$InvitePreviewResponseFromJson(json);
}
