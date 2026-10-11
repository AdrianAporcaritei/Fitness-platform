// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'coach_client_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CoachClientResponse {

 String get clientId; String get firstName; String get lastName; String get email; CoachClientResponseStatus get status; DateTime get startedAt;
/// Create a copy of CoachClientResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoachClientResponseCopyWith<CoachClientResponse> get copyWith => _$CoachClientResponseCopyWithImpl<CoachClientResponse>(this as CoachClientResponse, _$identity);

  /// Serializes this CoachClientResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CoachClientResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoachClientResponse&&(identical(other.clientId, _this.clientId) || other.clientId == _this.clientId)&&(identical(other.firstName, _this.firstName) || other.firstName == _this.firstName)&&(identical(other.lastName, _this.lastName) || other.lastName == _this.lastName)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.startedAt, _this.startedAt) || other.startedAt == _this.startedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CoachClientResponse;
  return Object.hash(runtimeType,_this.clientId,_this.firstName,_this.lastName,_this.email,_this.status,_this.startedAt);
}

@override
String toString() {
  final _this = this as CoachClientResponse;
  return 'CoachClientResponse(clientId: ${_this.clientId}, firstName: ${_this.firstName}, lastName: ${_this.lastName}, email: ${_this.email}, status: ${_this.status}, startedAt: ${_this.startedAt})';
}


}

/// @nodoc
abstract mixin class $CoachClientResponseCopyWith<$Res>  {
  factory $CoachClientResponseCopyWith(CoachClientResponse value, $Res Function(CoachClientResponse) _then) = _$CoachClientResponseCopyWithImpl;
@useResult
$Res call({
 String clientId, String firstName, String lastName, String email, CoachClientResponseStatus status, DateTime startedAt
});




}
/// @nodoc
class _$CoachClientResponseCopyWithImpl<$Res>
    implements $CoachClientResponseCopyWith<$Res> {
  _$CoachClientResponseCopyWithImpl(this._self, this._then);

  final CoachClientResponse _self;
  final $Res Function(CoachClientResponse) _then;

/// Create a copy of CoachClientResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? clientId = null,Object? firstName = null,Object? lastName = null,Object? email = null,Object? status = null,Object? startedAt = null,}) {
  return _then(CoachClientResponse(
clientId: null == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CoachClientResponseStatus,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [CoachClientResponse].
extension CoachClientResponsePatterns on CoachClientResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoachClientResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoachClientResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoachClientResponse value)  $default,){
final _that = this;
switch (_that) {
case _CoachClientResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoachClientResponse value)?  $default,){
final _that = this;
switch (_that) {
case _CoachClientResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String clientId,  String firstName,  String lastName,  String email,  CoachClientResponseStatus status,  DateTime startedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoachClientResponse() when $default != null:
return $default(_that.clientId,_that.firstName,_that.lastName,_that.email,_that.status,_that.startedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String clientId,  String firstName,  String lastName,  String email,  CoachClientResponseStatus status,  DateTime startedAt)  $default,) {final _that = this;
switch (_that) {
case _CoachClientResponse():
return $default(_that.clientId,_that.firstName,_that.lastName,_that.email,_that.status,_that.startedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String clientId,  String firstName,  String lastName,  String email,  CoachClientResponseStatus status,  DateTime startedAt)?  $default,) {final _that = this;
switch (_that) {
case _CoachClientResponse() when $default != null:
return $default(_that.clientId,_that.firstName,_that.lastName,_that.email,_that.status,_that.startedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CoachClientResponse implements CoachClientResponse {
  const _CoachClientResponse({required this.clientId, required this.firstName, required this.lastName, required this.email, required this.status, required this.startedAt});
  factory _CoachClientResponse.fromJson(Map<String, dynamic> json) => _$CoachClientResponseFromJson(json);

@override final  String clientId;
@override final  String firstName;
@override final  String lastName;
@override final  String email;
@override final  CoachClientResponseStatus status;
@override final  DateTime startedAt;

/// Create a copy of CoachClientResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoachClientResponseCopyWith<_CoachClientResponse> get copyWith => __$CoachClientResponseCopyWithImpl<_CoachClientResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CoachClientResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoachClientResponse&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.email, email) || other.email == email)&&(identical(other.status, status) || other.status == status)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,clientId,firstName,lastName,email,status,startedAt);
}

@override
String toString() {
    return 'CoachClientResponse(clientId: $clientId, firstName: $firstName, lastName: $lastName, email: $email, status: $status, startedAt: $startedAt)';
}


}

/// @nodoc
abstract mixin class _$CoachClientResponseCopyWith<$Res> implements $CoachClientResponseCopyWith<$Res> {
  factory _$CoachClientResponseCopyWith(_CoachClientResponse value, $Res Function(_CoachClientResponse) _then) = __$CoachClientResponseCopyWithImpl;
@override @useResult
$Res call({
 String clientId, String firstName, String lastName, String email, CoachClientResponseStatus status, DateTime startedAt
});




}
/// @nodoc
class __$CoachClientResponseCopyWithImpl<$Res>
    implements _$CoachClientResponseCopyWith<$Res> {
  __$CoachClientResponseCopyWithImpl(this._self, this._then);

  final _CoachClientResponse _self;
  final $Res Function(_CoachClientResponse) _then;

/// Create a copy of CoachClientResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? clientId = null,Object? firstName = null,Object? lastName = null,Object? email = null,Object? status = null,Object? startedAt = null,}) {
  return _then(_CoachClientResponse(
clientId: null == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CoachClientResponseStatus,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
