// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'coach_link_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CoachLinkRequest {

 String get code;
/// Create a copy of CoachLinkRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoachLinkRequestCopyWith<CoachLinkRequest> get copyWith => _$CoachLinkRequestCopyWithImpl<CoachLinkRequest>(this as CoachLinkRequest, _$identity);

  /// Serializes this CoachLinkRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CoachLinkRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoachLinkRequest&&(identical(other.code, _this.code) || other.code == _this.code));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CoachLinkRequest;
  return Object.hash(runtimeType,_this.code);
}

@override
String toString() {
  final _this = this as CoachLinkRequest;
  return 'CoachLinkRequest(code: ${_this.code})';
}


}

/// @nodoc
abstract mixin class $CoachLinkRequestCopyWith<$Res>  {
  factory $CoachLinkRequestCopyWith(CoachLinkRequest value, $Res Function(CoachLinkRequest) _then) = _$CoachLinkRequestCopyWithImpl;
@useResult
$Res call({
 String code
});




}
/// @nodoc
class _$CoachLinkRequestCopyWithImpl<$Res>
    implements $CoachLinkRequestCopyWith<$Res> {
  _$CoachLinkRequestCopyWithImpl(this._self, this._then);

  final CoachLinkRequest _self;
  final $Res Function(CoachLinkRequest) _then;

/// Create a copy of CoachLinkRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,}) {
  return _then(CoachLinkRequest(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CoachLinkRequest].
extension CoachLinkRequestPatterns on CoachLinkRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoachLinkRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoachLinkRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoachLinkRequest value)  $default,){
final _that = this;
switch (_that) {
case _CoachLinkRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoachLinkRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CoachLinkRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String code)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoachLinkRequest() when $default != null:
return $default(_that.code);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String code)  $default,) {final _that = this;
switch (_that) {
case _CoachLinkRequest():
return $default(_that.code);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String code)?  $default,) {final _that = this;
switch (_that) {
case _CoachLinkRequest() when $default != null:
return $default(_that.code);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CoachLinkRequest implements CoachLinkRequest {
  const _CoachLinkRequest({required this.code});
  factory _CoachLinkRequest.fromJson(Map<String, dynamic> json) => _$CoachLinkRequestFromJson(json);

@override final  String code;

/// Create a copy of CoachLinkRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoachLinkRequestCopyWith<_CoachLinkRequest> get copyWith => __$CoachLinkRequestCopyWithImpl<_CoachLinkRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CoachLinkRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoachLinkRequest&&(identical(other.code, code) || other.code == code));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,code);
}

@override
String toString() {
    return 'CoachLinkRequest(code: $code)';
}


}

/// @nodoc
abstract mixin class _$CoachLinkRequestCopyWith<$Res> implements $CoachLinkRequestCopyWith<$Res> {
  factory _$CoachLinkRequestCopyWith(_CoachLinkRequest value, $Res Function(_CoachLinkRequest) _then) = __$CoachLinkRequestCopyWithImpl;
@override @useResult
$Res call({
 String code
});




}
/// @nodoc
class __$CoachLinkRequestCopyWithImpl<$Res>
    implements _$CoachLinkRequestCopyWith<$Res> {
  __$CoachLinkRequestCopyWithImpl(this._self, this._then);

  final _CoachLinkRequest _self;
  final $Res Function(_CoachLinkRequest) _then;

/// Create a copy of CoachLinkRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,}) {
  return _then(_CoachLinkRequest(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
