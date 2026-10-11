// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'coach_link_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CoachLinkResponse {

 String get coachId; String get coachFirstName; String get coachLastName; CoachLinkResponseStatus get status; DateTime get startedAt;
/// Create a copy of CoachLinkResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoachLinkResponseCopyWith<CoachLinkResponse> get copyWith => _$CoachLinkResponseCopyWithImpl<CoachLinkResponse>(this as CoachLinkResponse, _$identity);

  /// Serializes this CoachLinkResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CoachLinkResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoachLinkResponse&&(identical(other.coachId, _this.coachId) || other.coachId == _this.coachId)&&(identical(other.coachFirstName, _this.coachFirstName) || other.coachFirstName == _this.coachFirstName)&&(identical(other.coachLastName, _this.coachLastName) || other.coachLastName == _this.coachLastName)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.startedAt, _this.startedAt) || other.startedAt == _this.startedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CoachLinkResponse;
  return Object.hash(runtimeType,_this.coachId,_this.coachFirstName,_this.coachLastName,_this.status,_this.startedAt);
}

@override
String toString() {
  final _this = this as CoachLinkResponse;
  return 'CoachLinkResponse(coachId: ${_this.coachId}, coachFirstName: ${_this.coachFirstName}, coachLastName: ${_this.coachLastName}, status: ${_this.status}, startedAt: ${_this.startedAt})';
}


}

/// @nodoc
abstract mixin class $CoachLinkResponseCopyWith<$Res>  {
  factory $CoachLinkResponseCopyWith(CoachLinkResponse value, $Res Function(CoachLinkResponse) _then) = _$CoachLinkResponseCopyWithImpl;
@useResult
$Res call({
 String coachId, String coachFirstName, String coachLastName, CoachLinkResponseStatus status, DateTime startedAt
});




}
/// @nodoc
class _$CoachLinkResponseCopyWithImpl<$Res>
    implements $CoachLinkResponseCopyWith<$Res> {
  _$CoachLinkResponseCopyWithImpl(this._self, this._then);

  final CoachLinkResponse _self;
  final $Res Function(CoachLinkResponse) _then;

/// Create a copy of CoachLinkResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? coachId = null,Object? coachFirstName = null,Object? coachLastName = null,Object? status = null,Object? startedAt = null,}) {
  return _then(CoachLinkResponse(
coachId: null == coachId ? _self.coachId : coachId // ignore: cast_nullable_to_non_nullable
as String,coachFirstName: null == coachFirstName ? _self.coachFirstName : coachFirstName // ignore: cast_nullable_to_non_nullable
as String,coachLastName: null == coachLastName ? _self.coachLastName : coachLastName // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CoachLinkResponseStatus,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [CoachLinkResponse].
extension CoachLinkResponsePatterns on CoachLinkResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoachLinkResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoachLinkResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoachLinkResponse value)  $default,){
final _that = this;
switch (_that) {
case _CoachLinkResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoachLinkResponse value)?  $default,){
final _that = this;
switch (_that) {
case _CoachLinkResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String coachId,  String coachFirstName,  String coachLastName,  CoachLinkResponseStatus status,  DateTime startedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoachLinkResponse() when $default != null:
return $default(_that.coachId,_that.coachFirstName,_that.coachLastName,_that.status,_that.startedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String coachId,  String coachFirstName,  String coachLastName,  CoachLinkResponseStatus status,  DateTime startedAt)  $default,) {final _that = this;
switch (_that) {
case _CoachLinkResponse():
return $default(_that.coachId,_that.coachFirstName,_that.coachLastName,_that.status,_that.startedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String coachId,  String coachFirstName,  String coachLastName,  CoachLinkResponseStatus status,  DateTime startedAt)?  $default,) {final _that = this;
switch (_that) {
case _CoachLinkResponse() when $default != null:
return $default(_that.coachId,_that.coachFirstName,_that.coachLastName,_that.status,_that.startedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CoachLinkResponse implements CoachLinkResponse {
  const _CoachLinkResponse({required this.coachId, required this.coachFirstName, required this.coachLastName, required this.status, required this.startedAt});
  factory _CoachLinkResponse.fromJson(Map<String, dynamic> json) => _$CoachLinkResponseFromJson(json);

@override final  String coachId;
@override final  String coachFirstName;
@override final  String coachLastName;
@override final  CoachLinkResponseStatus status;
@override final  DateTime startedAt;

/// Create a copy of CoachLinkResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoachLinkResponseCopyWith<_CoachLinkResponse> get copyWith => __$CoachLinkResponseCopyWithImpl<_CoachLinkResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CoachLinkResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoachLinkResponse&&(identical(other.coachId, coachId) || other.coachId == coachId)&&(identical(other.coachFirstName, coachFirstName) || other.coachFirstName == coachFirstName)&&(identical(other.coachLastName, coachLastName) || other.coachLastName == coachLastName)&&(identical(other.status, status) || other.status == status)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,coachId,coachFirstName,coachLastName,status,startedAt);
}

@override
String toString() {
    return 'CoachLinkResponse(coachId: $coachId, coachFirstName: $coachFirstName, coachLastName: $coachLastName, status: $status, startedAt: $startedAt)';
}


}

/// @nodoc
abstract mixin class _$CoachLinkResponseCopyWith<$Res> implements $CoachLinkResponseCopyWith<$Res> {
  factory _$CoachLinkResponseCopyWith(_CoachLinkResponse value, $Res Function(_CoachLinkResponse) _then) = __$CoachLinkResponseCopyWithImpl;
@override @useResult
$Res call({
 String coachId, String coachFirstName, String coachLastName, CoachLinkResponseStatus status, DateTime startedAt
});




}
/// @nodoc
class __$CoachLinkResponseCopyWithImpl<$Res>
    implements _$CoachLinkResponseCopyWith<$Res> {
  __$CoachLinkResponseCopyWithImpl(this._self, this._then);

  final _CoachLinkResponse _self;
  final $Res Function(_CoachLinkResponse) _then;

/// Create a copy of CoachLinkResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? coachId = null,Object? coachFirstName = null,Object? coachLastName = null,Object? status = null,Object? startedAt = null,}) {
  return _then(_CoachLinkResponse(
coachId: null == coachId ? _self.coachId : coachId // ignore: cast_nullable_to_non_nullable
as String,coachFirstName: null == coachFirstName ? _self.coachFirstName : coachFirstName // ignore: cast_nullable_to_non_nullable
as String,coachLastName: null == coachLastName ? _self.coachLastName : coachLastName // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CoachLinkResponseStatus,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
