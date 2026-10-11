// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_me_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UpdateMeRequest {

 String? get firstName; String? get lastName; UpdateMeRequestLocale? get locale;/// IANA time zone name.
 String? get timezone;
/// Create a copy of UpdateMeRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateMeRequestCopyWith<UpdateMeRequest> get copyWith => _$UpdateMeRequestCopyWithImpl<UpdateMeRequest>(this as UpdateMeRequest, _$identity);

  /// Serializes this UpdateMeRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as UpdateMeRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateMeRequest&&(identical(other.firstName, _this.firstName) || other.firstName == _this.firstName)&&(identical(other.lastName, _this.lastName) || other.lastName == _this.lastName)&&(identical(other.locale, _this.locale) || other.locale == _this.locale)&&(identical(other.timezone, _this.timezone) || other.timezone == _this.timezone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UpdateMeRequest;
  return Object.hash(runtimeType,_this.firstName,_this.lastName,_this.locale,_this.timezone);
}

@override
String toString() {
  final _this = this as UpdateMeRequest;
  return 'UpdateMeRequest(firstName: ${_this.firstName}, lastName: ${_this.lastName}, locale: ${_this.locale}, timezone: ${_this.timezone})';
}


}

/// @nodoc
abstract mixin class $UpdateMeRequestCopyWith<$Res>  {
  factory $UpdateMeRequestCopyWith(UpdateMeRequest value, $Res Function(UpdateMeRequest) _then) = _$UpdateMeRequestCopyWithImpl;
@useResult
$Res call({
 String? firstName, String? lastName, UpdateMeRequestLocale? locale, String? timezone
});




}
/// @nodoc
class _$UpdateMeRequestCopyWithImpl<$Res>
    implements $UpdateMeRequestCopyWith<$Res> {
  _$UpdateMeRequestCopyWithImpl(this._self, this._then);

  final UpdateMeRequest _self;
  final $Res Function(UpdateMeRequest) _then;

/// Create a copy of UpdateMeRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? firstName = freezed,Object? lastName = freezed,Object? locale = freezed,Object? timezone = freezed,}) {
  return _then(UpdateMeRequest(
firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,locale: freezed == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as UpdateMeRequestLocale?,timezone: freezed == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateMeRequest].
extension UpdateMeRequestPatterns on UpdateMeRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateMeRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateMeRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateMeRequest value)  $default,){
final _that = this;
switch (_that) {
case _UpdateMeRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateMeRequest value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateMeRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? firstName,  String? lastName,  UpdateMeRequestLocale? locale,  String? timezone)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateMeRequest() when $default != null:
return $default(_that.firstName,_that.lastName,_that.locale,_that.timezone);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? firstName,  String? lastName,  UpdateMeRequestLocale? locale,  String? timezone)  $default,) {final _that = this;
switch (_that) {
case _UpdateMeRequest():
return $default(_that.firstName,_that.lastName,_that.locale,_that.timezone);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? firstName,  String? lastName,  UpdateMeRequestLocale? locale,  String? timezone)?  $default,) {final _that = this;
switch (_that) {
case _UpdateMeRequest() when $default != null:
return $default(_that.firstName,_that.lastName,_that.locale,_that.timezone);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateMeRequest implements UpdateMeRequest {
  const _UpdateMeRequest({this.firstName, this.lastName, this.locale, this.timezone});
  factory _UpdateMeRequest.fromJson(Map<String, dynamic> json) => _$UpdateMeRequestFromJson(json);

@override final  String? firstName;
@override final  String? lastName;
@override final  UpdateMeRequestLocale? locale;
/// IANA time zone name.
@override final  String? timezone;

/// Create a copy of UpdateMeRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateMeRequestCopyWith<_UpdateMeRequest> get copyWith => __$UpdateMeRequestCopyWithImpl<_UpdateMeRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateMeRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateMeRequest&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.timezone, timezone) || other.timezone == timezone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,firstName,lastName,locale,timezone);
}

@override
String toString() {
    return 'UpdateMeRequest(firstName: $firstName, lastName: $lastName, locale: $locale, timezone: $timezone)';
}


}

/// @nodoc
abstract mixin class _$UpdateMeRequestCopyWith<$Res> implements $UpdateMeRequestCopyWith<$Res> {
  factory _$UpdateMeRequestCopyWith(_UpdateMeRequest value, $Res Function(_UpdateMeRequest) _then) = __$UpdateMeRequestCopyWithImpl;
@override @useResult
$Res call({
 String? firstName, String? lastName, UpdateMeRequestLocale? locale, String? timezone
});




}
/// @nodoc
class __$UpdateMeRequestCopyWithImpl<$Res>
    implements _$UpdateMeRequestCopyWith<$Res> {
  __$UpdateMeRequestCopyWithImpl(this._self, this._then);

  final _UpdateMeRequest _self;
  final $Res Function(_UpdateMeRequest) _then;

/// Create a copy of UpdateMeRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? firstName = freezed,Object? lastName = freezed,Object? locale = freezed,Object? timezone = freezed,}) {
  return _then(_UpdateMeRequest(
firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,locale: freezed == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as UpdateMeRequestLocale?,timezone: freezed == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
