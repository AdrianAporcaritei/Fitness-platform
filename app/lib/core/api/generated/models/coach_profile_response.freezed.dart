// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'coach_profile_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CoachProfileResponse {

 List<String> get specializations; String? get bio;
/// Create a copy of CoachProfileResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoachProfileResponseCopyWith<CoachProfileResponse> get copyWith => _$CoachProfileResponseCopyWithImpl<CoachProfileResponse>(this as CoachProfileResponse, _$identity);

  /// Serializes this CoachProfileResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CoachProfileResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoachProfileResponse&&const DeepCollectionEquality().equals(other.specializations, _this.specializations)&&(identical(other.bio, _this.bio) || other.bio == _this.bio));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CoachProfileResponse;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.specializations),_this.bio);
}

@override
String toString() {
  final _this = this as CoachProfileResponse;
  return 'CoachProfileResponse(specializations: ${_this.specializations}, bio: ${_this.bio})';
}


}

/// @nodoc
abstract mixin class $CoachProfileResponseCopyWith<$Res>  {
  factory $CoachProfileResponseCopyWith(CoachProfileResponse value, $Res Function(CoachProfileResponse) _then) = _$CoachProfileResponseCopyWithImpl;
@useResult
$Res call({
 List<String> specializations, String? bio
});




}
/// @nodoc
class _$CoachProfileResponseCopyWithImpl<$Res>
    implements $CoachProfileResponseCopyWith<$Res> {
  _$CoachProfileResponseCopyWithImpl(this._self, this._then);

  final CoachProfileResponse _self;
  final $Res Function(CoachProfileResponse) _then;

/// Create a copy of CoachProfileResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? specializations = null,Object? bio = freezed,}) {
  return _then(CoachProfileResponse(
specializations: null == specializations ? _self.specializations : specializations // ignore: cast_nullable_to_non_nullable
as List<String>,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CoachProfileResponse].
extension CoachProfileResponsePatterns on CoachProfileResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoachProfileResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoachProfileResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoachProfileResponse value)  $default,){
final _that = this;
switch (_that) {
case _CoachProfileResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoachProfileResponse value)?  $default,){
final _that = this;
switch (_that) {
case _CoachProfileResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> specializations,  String? bio)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoachProfileResponse() when $default != null:
return $default(_that.specializations,_that.bio);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> specializations,  String? bio)  $default,) {final _that = this;
switch (_that) {
case _CoachProfileResponse():
return $default(_that.specializations,_that.bio);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> specializations,  String? bio)?  $default,) {final _that = this;
switch (_that) {
case _CoachProfileResponse() when $default != null:
return $default(_that.specializations,_that.bio);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CoachProfileResponse implements CoachProfileResponse {
  const _CoachProfileResponse({required  List<String> specializations, this.bio}): _specializations = specializations;
  factory _CoachProfileResponse.fromJson(Map<String, dynamic> json) => _$CoachProfileResponseFromJson(json);

 final  List<String> _specializations;
@override List<String> get specializations {
  if (_specializations is EqualUnmodifiableListView) return _specializations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_specializations);
}

@override final  String? bio;

/// Create a copy of CoachProfileResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoachProfileResponseCopyWith<_CoachProfileResponse> get copyWith => __$CoachProfileResponseCopyWithImpl<_CoachProfileResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CoachProfileResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoachProfileResponse&&const DeepCollectionEquality().equals(other.specializations, _specializations)&&(identical(other.bio, bio) || other.bio == bio));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_specializations),bio);
}

@override
String toString() {
    return 'CoachProfileResponse(specializations: $specializations, bio: $bio)';
}


}

/// @nodoc
abstract mixin class _$CoachProfileResponseCopyWith<$Res> implements $CoachProfileResponseCopyWith<$Res> {
  factory _$CoachProfileResponseCopyWith(_CoachProfileResponse value, $Res Function(_CoachProfileResponse) _then) = __$CoachProfileResponseCopyWithImpl;
@override @useResult
$Res call({
 List<String> specializations, String? bio
});




}
/// @nodoc
class __$CoachProfileResponseCopyWithImpl<$Res>
    implements _$CoachProfileResponseCopyWith<$Res> {
  __$CoachProfileResponseCopyWithImpl(this._self, this._then);

  final _CoachProfileResponse _self;
  final $Res Function(_CoachProfileResponse) _then;

/// Create a copy of CoachProfileResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? specializations = null,Object? bio = freezed,}) {
  return _then(_CoachProfileResponse(
specializations: null == specializations ? _self._specializations : specializations // ignore: cast_nullable_to_non_nullable
as List<String>,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
