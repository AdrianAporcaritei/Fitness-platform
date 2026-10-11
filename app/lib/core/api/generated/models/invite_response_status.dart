// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

@JsonEnum()
enum InviteResponseStatus {
  @JsonValue('PENDING')
  pending('PENDING'),
  @JsonValue('USED')
  used('USED'),
  @JsonValue('REVOKED')
  revoked('REVOKED'),
  @JsonValue('EXPIRED')
  expired('EXPIRED'),
  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const InviteResponseStatus(this.json);

  factory InviteResponseStatus.fromJson(String json) => values.firstWhere(
        (e) => e.json == json,
        orElse: () => $unknown,
      );

  final String? json;
  String toJson() {
    final value = json;
    if (value == null) {
      throw StateError('Cannot convert enum value with null JSON representation to String. '
          'This usually happens for \$unknown or @JsonValue(null) entries.');
    }
    return value as String;
  }

  @override
  String toString() => json?.toString() ?? super.toString();
  /// Returns all defined enum values excluding the $unknown value.
  static List<InviteResponseStatus> get $valuesDefined => values.where((value) => value != $unknown).toList();
}
