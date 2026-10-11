// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'coach_link_request.freezed.dart';
part 'coach_link_request.g.dart';

@Freezed()
abstract class CoachLinkRequest with _$CoachLinkRequest {
  const factory CoachLinkRequest({required String code}) = _CoachLinkRequest;

  factory CoachLinkRequest.fromJson(Map<String, Object?> json) =>
      _$CoachLinkRequestFromJson(json);
}
