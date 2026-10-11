// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'invite_preview_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InvitePreviewResponse {

 String get coachFirstName; String get coachLastName;/// Always true; invalid codes are errors.
 bool get valid;
/// Create a copy of InvitePreviewResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InvitePreviewResponseCopyWith<InvitePreviewResponse> get copyWith => _$InvitePreviewResponseCopyWithImpl<InvitePreviewResponse>(this as InvitePreviewResponse, _$identity);

  /// Serializes this InvitePreviewResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as InvitePreviewResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InvitePreviewResponse&&(identical(other.coachFirstName, _this.coachFirstName) || other.coachFirstName == _this.coachFirstName)&&(identical(other.coachLastName, _this.coachLastName) || other.coachLastName == _this.coachLastName)&&(identical(other.valid, _this.valid) || other.valid == _this.valid));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as InvitePreviewResponse;
  return Object.hash(runtimeType,_this.coachFirstName,_this.coachLastName,_this.valid);
}

@override
String toString() {
  final _this = this as InvitePreviewResponse;
  return 'InvitePreviewResponse(coachFirstName: ${_this.coachFirstName}, coachLastName: ${_this.coachLastName}, valid: ${_this.valid})';
}


}

/// @nodoc
abstract mixin class $InvitePreviewResponseCopyWith<$Res>  {
  factory $InvitePreviewResponseCopyWith(InvitePreviewResponse value, $Res Function(InvitePreviewResponse) _then) = _$InvitePreviewResponseCopyWithImpl;
@useResult
$Res call({
 String coachFirstName, String coachLastName, bool valid
});




}
/// @nodoc
class _$InvitePreviewResponseCopyWithImpl<$Res>
    implements $InvitePreviewResponseCopyWith<$Res> {
  _$InvitePreviewResponseCopyWithImpl(this._self, this._then);

  final InvitePreviewResponse _self;
  final $Res Function(InvitePreviewResponse) _then;

/// Create a copy of InvitePreviewResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? coachFirstName = null,Object? coachLastName = null,Object? valid = null,}) {
  return _then(InvitePreviewResponse(
coachFirstName: null == coachFirstName ? _self.coachFirstName : coachFirstName // ignore: cast_nullable_to_non_nullable
as String,coachLastName: null == coachLastName ? _self.coachLastName : coachLastName // ignore: cast_nullable_to_non_nullable
as String,valid: null == valid ? _self.valid : valid // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [InvitePreviewResponse].
extension InvitePreviewResponsePatterns on InvitePreviewResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InvitePreviewResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InvitePreviewResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InvitePreviewResponse value)  $default,){
final _that = this;
switch (_that) {
case _InvitePreviewResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InvitePreviewResponse value)?  $default,){
final _that = this;
switch (_that) {
case _InvitePreviewResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String coachFirstName,  String coachLastName,  bool valid)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InvitePreviewResponse() when $default != null:
return $default(_that.coachFirstName,_that.coachLastName,_that.valid);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String coachFirstName,  String coachLastName,  bool valid)  $default,) {final _that = this;
switch (_that) {
case _InvitePreviewResponse():
return $default(_that.coachFirstName,_that.coachLastName,_that.valid);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String coachFirstName,  String coachLastName,  bool valid)?  $default,) {final _that = this;
switch (_that) {
case _InvitePreviewResponse() when $default != null:
return $default(_that.coachFirstName,_that.coachLastName,_that.valid);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InvitePreviewResponse implements InvitePreviewResponse {
  const _InvitePreviewResponse({required this.coachFirstName, required this.coachLastName, required this.valid});
  factory _InvitePreviewResponse.fromJson(Map<String, dynamic> json) => _$InvitePreviewResponseFromJson(json);

@override final  String coachFirstName;
@override final  String coachLastName;
/// Always true; invalid codes are errors.
@override final  bool valid;

/// Create a copy of InvitePreviewResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InvitePreviewResponseCopyWith<_InvitePreviewResponse> get copyWith => __$InvitePreviewResponseCopyWithImpl<_InvitePreviewResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InvitePreviewResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _InvitePreviewResponse&&(identical(other.coachFirstName, coachFirstName) || other.coachFirstName == coachFirstName)&&(identical(other.coachLastName, coachLastName) || other.coachLastName == coachLastName)&&(identical(other.valid, valid) || other.valid == valid));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,coachFirstName,coachLastName,valid);
}

@override
String toString() {
    return 'InvitePreviewResponse(coachFirstName: $coachFirstName, coachLastName: $coachLastName, valid: $valid)';
}


}

/// @nodoc
abstract mixin class _$InvitePreviewResponseCopyWith<$Res> implements $InvitePreviewResponseCopyWith<$Res> {
  factory _$InvitePreviewResponseCopyWith(_InvitePreviewResponse value, $Res Function(_InvitePreviewResponse) _then) = __$InvitePreviewResponseCopyWithImpl;
@override @useResult
$Res call({
 String coachFirstName, String coachLastName, bool valid
});




}
/// @nodoc
class __$InvitePreviewResponseCopyWithImpl<$Res>
    implements _$InvitePreviewResponseCopyWith<$Res> {
  __$InvitePreviewResponseCopyWithImpl(this._self, this._then);

  final _InvitePreviewResponse _self;
  final $Res Function(_InvitePreviewResponse) _then;

/// Create a copy of InvitePreviewResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? coachFirstName = null,Object? coachLastName = null,Object? valid = null,}) {
  return _then(_InvitePreviewResponse(
coachFirstName: null == coachFirstName ? _self.coachFirstName : coachFirstName // ignore: cast_nullable_to_non_nullable
as String,coachLastName: null == coachLastName ? _self.coachLastName : coachLastName // ignore: cast_nullable_to_non_nullable
as String,valid: null == valid ? _self.valid : valid // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
