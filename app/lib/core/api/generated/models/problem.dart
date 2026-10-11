// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'errors.dart';

part 'problem.freezed.dart';
part 'problem.g.dart';

@Freezed()
abstract class Problem with _$Problem {
  const factory Problem({
    required String type,
    required String title,
    required int status,

    /// Stable machine-readable error code.
    required String code,

    /// Localized from the user's locale, or Accept-Language when unauthenticated.
    String? detail,
    String? instance,

    /// Present for validation failures.
    List<Errors>? errors,
  }) = _Problem;
  
  factory Problem.fromJson(Map<String, Object?> json) => _$ProblemFromJson(json);
}
