// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'register_client_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RegisterClientRequest {

/// Invite code, accepted loosely like in GET /invites/{code}.
 String get code; String get email;/// 10-64 characters and at most 72 UTF-8 bytes.
 String get password; String get firstName; String get lastName; RegisterClientRequestLocale get locale;/// IANA time zone name.
 String get timezone;
/// Create a copy of RegisterClientRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegisterClientRequestCopyWith<RegisterClientRequest> get copyWith => _$RegisterClientRequestCopyWithImpl<RegisterClientRequest>(this as RegisterClientRequest, _$identity);

  /// Serializes this RegisterClientRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RegisterClientRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegisterClientRequest&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.password, _this.password) || other.password == _this.password)&&(identical(other.firstName, _this.firstName) || other.firstName == _this.firstName)&&(identical(other.lastName, _this.lastName) || other.lastName == _this.lastName)&&(identical(other.locale, _this.locale) || other.locale == _this.locale)&&(identical(other.timezone, _this.timezone) || other.timezone == _this.timezone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RegisterClientRequest;
  return Object.hash(runtimeType,_this.code,_this.email,_this.password,_this.firstName,_this.lastName,_this.locale,_this.timezone);
}

@override
String toString() {
  final _this = this as RegisterClientRequest;
  return 'RegisterClientRequest(code: ${_this.code}, email: ${_this.email}, password: ${_this.password}, firstName: ${_this.firstName}, lastName: ${_this.lastName}, locale: ${_this.locale}, timezone: ${_this.timezone})';
}


}

/// @nodoc
abstract mixin class $RegisterClientRequestCopyWith<$Res>  {
  factory $RegisterClientRequestCopyWith(RegisterClientRequest value, $Res Function(RegisterClientRequest) _then) = _$RegisterClientRequestCopyWithImpl;
@useResult
$Res call({
 String code, String email, String password, String firstName, String lastName, RegisterClientRequestLocale locale, String timezone
});




}
/// @nodoc
class _$RegisterClientRequestCopyWithImpl<$Res>
    implements $RegisterClientRequestCopyWith<$Res> {
  _$RegisterClientRequestCopyWithImpl(this._self, this._then);

  final RegisterClientRequest _self;
  final $Res Function(RegisterClientRequest) _then;

/// Create a copy of RegisterClientRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? email = null,Object? password = null,Object? firstName = null,Object? lastName = null,Object? locale = null,Object? timezone = null,}) {
  return _then(RegisterClientRequest(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,locale: null == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as RegisterClientRequestLocale,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RegisterClientRequest].
extension RegisterClientRequestPatterns on RegisterClientRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RegisterClientRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RegisterClientRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RegisterClientRequest value)  $default,){
final _that = this;
switch (_that) {
case _RegisterClientRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RegisterClientRequest value)?  $default,){
final _that = this;
switch (_that) {
case _RegisterClientRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String code,  String email,  String password,  String firstName,  String lastName,  RegisterClientRequestLocale locale,  String timezone)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RegisterClientRequest() when $default != null:
return $default(_that.code,_that.email,_that.password,_that.firstName,_that.lastName,_that.locale,_that.timezone);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String code,  String email,  String password,  String firstName,  String lastName,  RegisterClientRequestLocale locale,  String timezone)  $default,) {final _that = this;
switch (_that) {
case _RegisterClientRequest():
return $default(_that.code,_that.email,_that.password,_that.firstName,_that.lastName,_that.locale,_that.timezone);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String code,  String email,  String password,  String firstName,  String lastName,  RegisterClientRequestLocale locale,  String timezone)?  $default,) {final _that = this;
switch (_that) {
case _RegisterClientRequest() when $default != null:
return $default(_that.code,_that.email,_that.password,_that.firstName,_that.lastName,_that.locale,_that.timezone);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RegisterClientRequest implements RegisterClientRequest {
  const _RegisterClientRequest({required this.code, required this.email, required this.password, required this.firstName, required this.lastName, required this.locale, required this.timezone});
  factory _RegisterClientRequest.fromJson(Map<String, dynamic> json) => _$RegisterClientRequestFromJson(json);

/// Invite code, accepted loosely like in GET /invites/{code}.
@override final  String code;
@override final  String email;
/// 10-64 characters and at most 72 UTF-8 bytes.
@override final  String password;
@override final  String firstName;
@override final  String lastName;
@override final  RegisterClientRequestLocale locale;
/// IANA time zone name.
@override final  String timezone;

/// Create a copy of RegisterClientRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RegisterClientRequestCopyWith<_RegisterClientRequest> get copyWith => __$RegisterClientRequestCopyWithImpl<_RegisterClientRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RegisterClientRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RegisterClientRequest&&(identical(other.code, code) || other.code == code)&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.timezone, timezone) || other.timezone == timezone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,code,email,password,firstName,lastName,locale,timezone);
}

@override
String toString() {
    return 'RegisterClientRequest(code: $code, email: $email, password: $password, firstName: $firstName, lastName: $lastName, locale: $locale, timezone: $timezone)';
}


}

/// @nodoc
abstract mixin class _$RegisterClientRequestCopyWith<$Res> implements $RegisterClientRequestCopyWith<$Res> {
  factory _$RegisterClientRequestCopyWith(_RegisterClientRequest value, $Res Function(_RegisterClientRequest) _then) = __$RegisterClientRequestCopyWithImpl;
@override @useResult
$Res call({
 String code, String email, String password, String firstName, String lastName, RegisterClientRequestLocale locale, String timezone
});




}
/// @nodoc
class __$RegisterClientRequestCopyWithImpl<$Res>
    implements _$RegisterClientRequestCopyWith<$Res> {
  __$RegisterClientRequestCopyWithImpl(this._self, this._then);

  final _RegisterClientRequest _self;
  final $Res Function(_RegisterClientRequest) _then;

/// Create a copy of RegisterClientRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? email = null,Object? password = null,Object? firstName = null,Object? lastName = null,Object? locale = null,Object? timezone = null,}) {
  return _then(_RegisterClientRequest(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,locale: null == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as RegisterClientRequestLocale,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
