// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'password_reset_confirm_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PasswordResetConfirmRequest {

 String get token;/// 10-64 characters and at most 72 UTF-8 bytes.
 String get newPassword;
/// Create a copy of PasswordResetConfirmRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PasswordResetConfirmRequestCopyWith<PasswordResetConfirmRequest> get copyWith => _$PasswordResetConfirmRequestCopyWithImpl<PasswordResetConfirmRequest>(this as PasswordResetConfirmRequest, _$identity);

  /// Serializes this PasswordResetConfirmRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PasswordResetConfirmRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PasswordResetConfirmRequest&&(identical(other.token, _this.token) || other.token == _this.token)&&(identical(other.newPassword, _this.newPassword) || other.newPassword == _this.newPassword));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PasswordResetConfirmRequest;
  return Object.hash(runtimeType,_this.token,_this.newPassword);
}

@override
String toString() {
  final _this = this as PasswordResetConfirmRequest;
  return 'PasswordResetConfirmRequest(token: ${_this.token}, newPassword: ${_this.newPassword})';
}


}

/// @nodoc
abstract mixin class $PasswordResetConfirmRequestCopyWith<$Res>  {
  factory $PasswordResetConfirmRequestCopyWith(PasswordResetConfirmRequest value, $Res Function(PasswordResetConfirmRequest) _then) = _$PasswordResetConfirmRequestCopyWithImpl;
@useResult
$Res call({
 String token, String newPassword
});




}
/// @nodoc
class _$PasswordResetConfirmRequestCopyWithImpl<$Res>
    implements $PasswordResetConfirmRequestCopyWith<$Res> {
  _$PasswordResetConfirmRequestCopyWithImpl(this._self, this._then);

  final PasswordResetConfirmRequest _self;
  final $Res Function(PasswordResetConfirmRequest) _then;

/// Create a copy of PasswordResetConfirmRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? token = null,Object? newPassword = null,}) {
  return _then(PasswordResetConfirmRequest(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,newPassword: null == newPassword ? _self.newPassword : newPassword // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PasswordResetConfirmRequest].
extension PasswordResetConfirmRequestPatterns on PasswordResetConfirmRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PasswordResetConfirmRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PasswordResetConfirmRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PasswordResetConfirmRequest value)  $default,){
final _that = this;
switch (_that) {
case _PasswordResetConfirmRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PasswordResetConfirmRequest value)?  $default,){
final _that = this;
switch (_that) {
case _PasswordResetConfirmRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String token,  String newPassword)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PasswordResetConfirmRequest() when $default != null:
return $default(_that.token,_that.newPassword);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String token,  String newPassword)  $default,) {final _that = this;
switch (_that) {
case _PasswordResetConfirmRequest():
return $default(_that.token,_that.newPassword);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String token,  String newPassword)?  $default,) {final _that = this;
switch (_that) {
case _PasswordResetConfirmRequest() when $default != null:
return $default(_that.token,_that.newPassword);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PasswordResetConfirmRequest implements PasswordResetConfirmRequest {
  const _PasswordResetConfirmRequest({required this.token, required this.newPassword});
  factory _PasswordResetConfirmRequest.fromJson(Map<String, dynamic> json) => _$PasswordResetConfirmRequestFromJson(json);

@override final  String token;
/// 10-64 characters and at most 72 UTF-8 bytes.
@override final  String newPassword;

/// Create a copy of PasswordResetConfirmRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PasswordResetConfirmRequestCopyWith<_PasswordResetConfirmRequest> get copyWith => __$PasswordResetConfirmRequestCopyWithImpl<_PasswordResetConfirmRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PasswordResetConfirmRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PasswordResetConfirmRequest&&(identical(other.token, token) || other.token == token)&&(identical(other.newPassword, newPassword) || other.newPassword == newPassword));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,token,newPassword);
}

@override
String toString() {
    return 'PasswordResetConfirmRequest(token: $token, newPassword: $newPassword)';
}


}

/// @nodoc
abstract mixin class _$PasswordResetConfirmRequestCopyWith<$Res> implements $PasswordResetConfirmRequestCopyWith<$Res> {
  factory _$PasswordResetConfirmRequestCopyWith(_PasswordResetConfirmRequest value, $Res Function(_PasswordResetConfirmRequest) _then) = __$PasswordResetConfirmRequestCopyWithImpl;
@override @useResult
$Res call({
 String token, String newPassword
});




}
/// @nodoc
class __$PasswordResetConfirmRequestCopyWithImpl<$Res>
    implements _$PasswordResetConfirmRequestCopyWith<$Res> {
  __$PasswordResetConfirmRequestCopyWithImpl(this._self, this._then);

  final _PasswordResetConfirmRequest _self;
  final $Res Function(_PasswordResetConfirmRequest) _then;

/// Create a copy of PasswordResetConfirmRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? token = null,Object? newPassword = null,}) {
  return _then(_PasswordResetConfirmRequest(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,newPassword: null == newPassword ? _self.newPassword : newPassword // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
