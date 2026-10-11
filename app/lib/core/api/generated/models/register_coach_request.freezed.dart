// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'register_coach_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RegisterCoachRequest {

 String get email;/// 10-64 characters and at most 72 UTF-8 bytes.
 String get password; String get firstName; String get lastName; RegisterCoachRequestLocale get locale;/// IANA time zone name.
 String get timezone;
/// Create a copy of RegisterCoachRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegisterCoachRequestCopyWith<RegisterCoachRequest> get copyWith => _$RegisterCoachRequestCopyWithImpl<RegisterCoachRequest>(this as RegisterCoachRequest, _$identity);

  /// Serializes this RegisterCoachRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RegisterCoachRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegisterCoachRequest&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.password, _this.password) || other.password == _this.password)&&(identical(other.firstName, _this.firstName) || other.firstName == _this.firstName)&&(identical(other.lastName, _this.lastName) || other.lastName == _this.lastName)&&(identical(other.locale, _this.locale) || other.locale == _this.locale)&&(identical(other.timezone, _this.timezone) || other.timezone == _this.timezone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RegisterCoachRequest;
  return Object.hash(runtimeType,_this.email,_this.password,_this.firstName,_this.lastName,_this.locale,_this.timezone);
}

@override
String toString() {
  final _this = this as RegisterCoachRequest;
  return 'RegisterCoachRequest(email: ${_this.email}, password: ${_this.password}, firstName: ${_this.firstName}, lastName: ${_this.lastName}, locale: ${_this.locale}, timezone: ${_this.timezone})';
}


}

/// @nodoc
abstract mixin class $RegisterCoachRequestCopyWith<$Res>  {
  factory $RegisterCoachRequestCopyWith(RegisterCoachRequest value, $Res Function(RegisterCoachRequest) _then) = _$RegisterCoachRequestCopyWithImpl;
@useResult
$Res call({
 String email, String password, String firstName, String lastName, RegisterCoachRequestLocale locale, String timezone
});




}
/// @nodoc
class _$RegisterCoachRequestCopyWithImpl<$Res>
    implements $RegisterCoachRequestCopyWith<$Res> {
  _$RegisterCoachRequestCopyWithImpl(this._self, this._then);

  final RegisterCoachRequest _self;
  final $Res Function(RegisterCoachRequest) _then;

/// Create a copy of RegisterCoachRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? email = null,Object? password = null,Object? firstName = null,Object? lastName = null,Object? locale = null,Object? timezone = null,}) {
  return _then(RegisterCoachRequest(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,locale: null == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as RegisterCoachRequestLocale,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RegisterCoachRequest].
extension RegisterCoachRequestPatterns on RegisterCoachRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RegisterCoachRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RegisterCoachRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RegisterCoachRequest value)  $default,){
final _that = this;
switch (_that) {
case _RegisterCoachRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RegisterCoachRequest value)?  $default,){
final _that = this;
switch (_that) {
case _RegisterCoachRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String email,  String password,  String firstName,  String lastName,  RegisterCoachRequestLocale locale,  String timezone)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RegisterCoachRequest() when $default != null:
return $default(_that.email,_that.password,_that.firstName,_that.lastName,_that.locale,_that.timezone);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String email,  String password,  String firstName,  String lastName,  RegisterCoachRequestLocale locale,  String timezone)  $default,) {final _that = this;
switch (_that) {
case _RegisterCoachRequest():
return $default(_that.email,_that.password,_that.firstName,_that.lastName,_that.locale,_that.timezone);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String email,  String password,  String firstName,  String lastName,  RegisterCoachRequestLocale locale,  String timezone)?  $default,) {final _that = this;
switch (_that) {
case _RegisterCoachRequest() when $default != null:
return $default(_that.email,_that.password,_that.firstName,_that.lastName,_that.locale,_that.timezone);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RegisterCoachRequest implements RegisterCoachRequest {
  const _RegisterCoachRequest({required this.email, required this.password, required this.firstName, required this.lastName, required this.locale, required this.timezone});
  factory _RegisterCoachRequest.fromJson(Map<String, dynamic> json) => _$RegisterCoachRequestFromJson(json);

@override final  String email;
/// 10-64 characters and at most 72 UTF-8 bytes.
@override final  String password;
@override final  String firstName;
@override final  String lastName;
@override final  RegisterCoachRequestLocale locale;
/// IANA time zone name.
@override final  String timezone;

/// Create a copy of RegisterCoachRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RegisterCoachRequestCopyWith<_RegisterCoachRequest> get copyWith => __$RegisterCoachRequestCopyWithImpl<_RegisterCoachRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RegisterCoachRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RegisterCoachRequest&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.timezone, timezone) || other.timezone == timezone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,email,password,firstName,lastName,locale,timezone);
}

@override
String toString() {
    return 'RegisterCoachRequest(email: $email, password: $password, firstName: $firstName, lastName: $lastName, locale: $locale, timezone: $timezone)';
}


}

/// @nodoc
abstract mixin class _$RegisterCoachRequestCopyWith<$Res> implements $RegisterCoachRequestCopyWith<$Res> {
  factory _$RegisterCoachRequestCopyWith(_RegisterCoachRequest value, $Res Function(_RegisterCoachRequest) _then) = __$RegisterCoachRequestCopyWithImpl;
@override @useResult
$Res call({
 String email, String password, String firstName, String lastName, RegisterCoachRequestLocale locale, String timezone
});




}
/// @nodoc
class __$RegisterCoachRequestCopyWithImpl<$Res>
    implements _$RegisterCoachRequestCopyWith<$Res> {
  __$RegisterCoachRequestCopyWithImpl(this._self, this._then);

  final _RegisterCoachRequest _self;
  final $Res Function(_RegisterCoachRequest) _then;

/// Create a copy of RegisterCoachRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? email = null,Object? password = null,Object? firstName = null,Object? lastName = null,Object? locale = null,Object? timezone = null,}) {
  return _then(_RegisterCoachRequest(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,locale: null == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as RegisterCoachRequestLocale,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
