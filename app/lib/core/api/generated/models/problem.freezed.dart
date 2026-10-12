// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'problem.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Problem {

 String get type; String get title; int get status;/// Stable machine-readable error code.
 String get code;/// Localized from the user's locale, or Accept-Language when unauthenticated.
 String? get detail; String? get instance;/// Present for validation failures.
 List<Errors>? get errors;
/// Create a copy of Problem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProblemCopyWith<Problem> get copyWith => _$ProblemCopyWithImpl<Problem>(this as Problem, _$identity);

  /// Serializes this Problem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Problem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Problem&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.detail, _this.detail) || other.detail == _this.detail)&&(identical(other.instance, _this.instance) || other.instance == _this.instance)&&const DeepCollectionEquality().equals(other.errors, _this.errors));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Problem;
  return Object.hash(runtimeType,_this.type,_this.title,_this.status,_this.code,_this.detail,_this.instance,const DeepCollectionEquality().hash(_this.errors));
}

@override
String toString() {
  final _this = this as Problem;
  return 'Problem(type: ${_this.type}, title: ${_this.title}, status: ${_this.status}, code: ${_this.code}, detail: ${_this.detail}, instance: ${_this.instance}, errors: ${_this.errors})';
}


}

/// @nodoc
abstract mixin class $ProblemCopyWith<$Res>  {
  factory $ProblemCopyWith(Problem value, $Res Function(Problem) _then) = _$ProblemCopyWithImpl;
@useResult
$Res call({
 String type, String title, int status, String code, String? detail, String? instance, List<Errors>? errors
});




}
/// @nodoc
class _$ProblemCopyWithImpl<$Res>
    implements $ProblemCopyWith<$Res> {
  _$ProblemCopyWithImpl(this._self, this._then);

  final Problem _self;
  final $Res Function(Problem) _then;

/// Create a copy of Problem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? title = null,Object? status = null,Object? code = null,Object? detail = freezed,Object? instance = freezed,Object? errors = freezed,}) {
  return _then(Problem(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,detail: freezed == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String?,instance: freezed == instance ? _self.instance : instance // ignore: cast_nullable_to_non_nullable
as String?,errors: freezed == errors ? _self.errors : errors // ignore: cast_nullable_to_non_nullable
as List<Errors>?,
  ));
}

}


/// Adds pattern-matching-related methods to [Problem].
extension ProblemPatterns on Problem {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Problem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Problem() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Problem value)  $default,){
final _that = this;
switch (_that) {
case _Problem():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Problem value)?  $default,){
final _that = this;
switch (_that) {
case _Problem() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String type,  String title,  int status,  String code,  String? detail,  String? instance,  List<Errors>? errors)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Problem() when $default != null:
return $default(_that.type,_that.title,_that.status,_that.code,_that.detail,_that.instance,_that.errors);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String type,  String title,  int status,  String code,  String? detail,  String? instance,  List<Errors>? errors)  $default,) {final _that = this;
switch (_that) {
case _Problem():
return $default(_that.type,_that.title,_that.status,_that.code,_that.detail,_that.instance,_that.errors);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String type,  String title,  int status,  String code,  String? detail,  String? instance,  List<Errors>? errors)?  $default,) {final _that = this;
switch (_that) {
case _Problem() when $default != null:
return $default(_that.type,_that.title,_that.status,_that.code,_that.detail,_that.instance,_that.errors);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Problem implements Problem {
  const _Problem({required this.type, required this.title, required this.status, required this.code, this.detail, this.instance,  List<Errors>? errors}): _errors = errors;
  factory _Problem.fromJson(Map<String, dynamic> json) => _$ProblemFromJson(json);

@override final  String type;
@override final  String title;
@override final  int status;
/// Stable machine-readable error code.
@override final  String code;
/// Localized from the user's locale, or Accept-Language when unauthenticated.
@override final  String? detail;
@override final  String? instance;
/// Present for validation failures.
 final  List<Errors>? _errors;
/// Present for validation failures.
@override List<Errors>? get errors {
  final value = _errors;
  if (value == null) return null;
  if (_errors is EqualUnmodifiableListView) return _errors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of Problem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProblemCopyWith<_Problem> get copyWith => __$ProblemCopyWithImpl<_Problem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProblemToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Problem&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.status, status) || other.status == status)&&(identical(other.code, code) || other.code == code)&&(identical(other.detail, detail) || other.detail == detail)&&(identical(other.instance, instance) || other.instance == instance)&&const DeepCollectionEquality().equals(other.errors, _errors));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,type,title,status,code,detail,instance,const DeepCollectionEquality().hash(_errors));
}

@override
String toString() {
    return 'Problem(type: $type, title: $title, status: $status, code: $code, detail: $detail, instance: $instance, errors: $errors)';
}


}

/// @nodoc
abstract mixin class _$ProblemCopyWith<$Res> implements $ProblemCopyWith<$Res> {
  factory _$ProblemCopyWith(_Problem value, $Res Function(_Problem) _then) = __$ProblemCopyWithImpl;
@override @useResult
$Res call({
 String type, String title, int status, String code, String? detail, String? instance, List<Errors>? errors
});




}
/// @nodoc
class __$ProblemCopyWithImpl<$Res>
    implements _$ProblemCopyWith<$Res> {
  __$ProblemCopyWithImpl(this._self, this._then);

  final _Problem _self;
  final $Res Function(_Problem) _then;

/// Create a copy of Problem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? title = null,Object? status = null,Object? code = null,Object? detail = freezed,Object? instance = freezed,Object? errors = freezed,}) {
  return _then(_Problem(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,detail: freezed == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String?,instance: freezed == instance ? _self.instance : instance // ignore: cast_nullable_to_non_nullable
as String?,errors: freezed == errors ? _self._errors : errors // ignore: cast_nullable_to_non_nullable
as List<Errors>?,
  ));
}


}

// dart format on
