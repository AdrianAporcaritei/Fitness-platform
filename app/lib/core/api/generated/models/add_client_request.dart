// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'add_client_request.freezed.dart';
part 'add_client_request.g.dart';

@Freezed()
abstract class AddClientRequest with _$AddClientRequest {
  const factory AddClientRequest({
    /// The client's full name, as the coach knows it.
    required String name,

    /// Informational; the client may sign up with another email.
    required String email,
  }) = _AddClientRequest;
  
  factory AddClientRequest.fromJson(Map<String, Object?> json) => _$AddClientRequestFromJson(json);
}
