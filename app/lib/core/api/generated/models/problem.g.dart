// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'problem.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Problem _$ProblemFromJson(Map<String, dynamic> json) => _Problem(
  type: json['type'] as String,
  title: json['title'] as String,
  status: (json['status'] as num).toInt(),
  code: json['code'] as String,
  detail: json['detail'] as String?,
  instance: json['instance'] as String?,
  errors: (json['errors'] as List<dynamic>?)
      ?.map((e) => Errors.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ProblemToJson(_Problem instance) => <String, dynamic>{
  'type': instance.type,
  'title': instance.title,
  'status': instance.status,
  'code': instance.code,
  'detail': instance.detail,
  'instance': instance.instance,
  'errors': instance.errors?.map((e) => e.toJson()).toList(),
};
