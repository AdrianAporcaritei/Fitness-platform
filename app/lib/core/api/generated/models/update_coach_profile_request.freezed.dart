// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_coach_profile_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UpdateCoachProfileRequest {

 String? get bio; List<String>? get specializations;
/// Create a copy of UpdateCoachProfileRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateCoachProfileRequestCopyWith<UpdateCoachProfileRequest> get copyWith => _$UpdateCoachProfileRequestCopyWithImpl<UpdateCoachProfileRequest>(this as UpdateCoachProfileRequest, _$identity);

  /// Serializes this UpdateCoachProfileRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as UpdateCoachProfileRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateCoachProfileRequest&&(identical(other.bio, _this.bio) || other.bio == _this.bio)&&const DeepCollectionEquality().equals(other.specializations, _this.specializations));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UpdateCoachProfileRequest;
  return Object.hash(runtimeType,_this.bio,const DeepCollectionEquality().hash(_this.specializations));
}

@override
String toString() {
  final _this = this as UpdateCoachProfileRequest;
  return 'UpdateCoachProfileRequest(bio: ${_this.bio}, specializations: ${_this.specializations})';
}


}

/// @nodoc
abstract mixin class $UpdateCoachProfileRequestCopyWith<$Res>  {
  factory $UpdateCoachProfileRequestCopyWith(UpdateCoachProfileRequest value, $Res Function(UpdateCoachProfileRequest) _then) = _$UpdateCoachProfileRequestCopyWithImpl;
@useResult
$Res call({
 String? bio, List<String>? specializations
});




}
/// @nodoc
class _$UpdateCoachProfileRequestCopyWithImpl<$Res>
    implements $UpdateCoachProfileRequestCopyWith<$Res> {
  _$UpdateCoachProfileRequestCopyWithImpl(this._self, this._then);

  final UpdateCoachProfileRequest _self;
  final $Res Function(UpdateCoachProfileRequest) _then;

/// Create a copy of UpdateCoachProfileRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bio = freezed,Object? specializations = freezed,}) {
  return _then(UpdateCoachProfileRequest(
bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,specializations: freezed == specializations ? _self.specializations : specializations // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateCoachProfileRequest].
extension UpdateCoachProfileRequestPatterns on UpdateCoachProfileRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateCoachProfileRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateCoachProfileRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateCoachProfileRequest value)  $default,){
final _that = this;
switch (_that) {
case _UpdateCoachProfileRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateCoachProfileRequest value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateCoachProfileRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? bio,  List<String>? specializations)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateCoachProfileRequest() when $default != null:
return $default(_that.bio,_that.specializations);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? bio,  List<String>? specializations)  $default,) {final _that = this;
switch (_that) {
case _UpdateCoachProfileRequest():
return $default(_that.bio,_that.specializations);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? bio,  List<String>? specializations)?  $default,) {final _that = this;
switch (_that) {
case _UpdateCoachProfileRequest() when $default != null:
return $default(_that.bio,_that.specializations);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateCoachProfileRequest implements UpdateCoachProfileRequest {
  const _UpdateCoachProfileRequest({this.bio,  List<String>? specializations}): _specializations = specializations;
  factory _UpdateCoachProfileRequest.fromJson(Map<String, dynamic> json) => _$UpdateCoachProfileRequestFromJson(json);

@override final  String? bio;
 final  List<String>? _specializations;
@override List<String>? get specializations {
  final value = _specializations;
  if (value == null) return null;
  if (_specializations is EqualUnmodifiableListView) return _specializations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of UpdateCoachProfileRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateCoachProfileRequestCopyWith<_UpdateCoachProfileRequest> get copyWith => __$UpdateCoachProfileRequestCopyWithImpl<_UpdateCoachProfileRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateCoachProfileRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateCoachProfileRequest&&(identical(other.bio, bio) || other.bio == bio)&&const DeepCollectionEquality().equals(other.specializations, _specializations));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,bio,const DeepCollectionEquality().hash(_specializations));
}

@override
String toString() {
    return 'UpdateCoachProfileRequest(bio: $bio, specializations: $specializations)';
}


}

/// @nodoc
abstract mixin class _$UpdateCoachProfileRequestCopyWith<$Res> implements $UpdateCoachProfileRequestCopyWith<$Res> {
  factory _$UpdateCoachProfileRequestCopyWith(_UpdateCoachProfileRequest value, $Res Function(_UpdateCoachProfileRequest) _then) = __$UpdateCoachProfileRequestCopyWithImpl;
@override @useResult
$Res call({
 String? bio, List<String>? specializations
});




}
/// @nodoc
class __$UpdateCoachProfileRequestCopyWithImpl<$Res>
    implements _$UpdateCoachProfileRequestCopyWith<$Res> {
  __$UpdateCoachProfileRequestCopyWithImpl(this._self, this._then);

  final _UpdateCoachProfileRequest _self;
  final $Res Function(_UpdateCoachProfileRequest) _then;

/// Create a copy of UpdateCoachProfileRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bio = freezed,Object? specializations = freezed,}) {
  return _then(_UpdateCoachProfileRequest(
bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,specializations: freezed == specializations ? _self._specializations : specializations // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}


}

// dart format on
