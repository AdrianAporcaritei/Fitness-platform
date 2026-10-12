// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'my_coach_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MyCoachResponse {

 String get coachId; String get firstName; String get lastName; List<String> get specializations; MyCoachResponseStatus get status; DateTime get startedAt; String? get bio;
/// Create a copy of MyCoachResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MyCoachResponseCopyWith<MyCoachResponse> get copyWith => _$MyCoachResponseCopyWithImpl<MyCoachResponse>(this as MyCoachResponse, _$identity);

  /// Serializes this MyCoachResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MyCoachResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MyCoachResponse&&(identical(other.coachId, _this.coachId) || other.coachId == _this.coachId)&&(identical(other.firstName, _this.firstName) || other.firstName == _this.firstName)&&(identical(other.lastName, _this.lastName) || other.lastName == _this.lastName)&&const DeepCollectionEquality().equals(other.specializations, _this.specializations)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.startedAt, _this.startedAt) || other.startedAt == _this.startedAt)&&(identical(other.bio, _this.bio) || other.bio == _this.bio));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MyCoachResponse;
  return Object.hash(runtimeType,_this.coachId,_this.firstName,_this.lastName,const DeepCollectionEquality().hash(_this.specializations),_this.status,_this.startedAt,_this.bio);
}

@override
String toString() {
  final _this = this as MyCoachResponse;
  return 'MyCoachResponse(coachId: ${_this.coachId}, firstName: ${_this.firstName}, lastName: ${_this.lastName}, specializations: ${_this.specializations}, status: ${_this.status}, startedAt: ${_this.startedAt}, bio: ${_this.bio})';
}


}

/// @nodoc
abstract mixin class $MyCoachResponseCopyWith<$Res>  {
  factory $MyCoachResponseCopyWith(MyCoachResponse value, $Res Function(MyCoachResponse) _then) = _$MyCoachResponseCopyWithImpl;
@useResult
$Res call({
 String coachId, String firstName, String lastName, List<String> specializations, MyCoachResponseStatus status, DateTime startedAt, String? bio
});




}
/// @nodoc
class _$MyCoachResponseCopyWithImpl<$Res>
    implements $MyCoachResponseCopyWith<$Res> {
  _$MyCoachResponseCopyWithImpl(this._self, this._then);

  final MyCoachResponse _self;
  final $Res Function(MyCoachResponse) _then;

/// Create a copy of MyCoachResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? coachId = null,Object? firstName = null,Object? lastName = null,Object? specializations = null,Object? status = null,Object? startedAt = null,Object? bio = freezed,}) {
  return _then(MyCoachResponse(
coachId: null == coachId ? _self.coachId : coachId // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,specializations: null == specializations ? _self.specializations : specializations // ignore: cast_nullable_to_non_nullable
as List<String>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MyCoachResponseStatus,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MyCoachResponse].
extension MyCoachResponsePatterns on MyCoachResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MyCoachResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MyCoachResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MyCoachResponse value)  $default,){
final _that = this;
switch (_that) {
case _MyCoachResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MyCoachResponse value)?  $default,){
final _that = this;
switch (_that) {
case _MyCoachResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String coachId,  String firstName,  String lastName,  List<String> specializations,  MyCoachResponseStatus status,  DateTime startedAt,  String? bio)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MyCoachResponse() when $default != null:
return $default(_that.coachId,_that.firstName,_that.lastName,_that.specializations,_that.status,_that.startedAt,_that.bio);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String coachId,  String firstName,  String lastName,  List<String> specializations,  MyCoachResponseStatus status,  DateTime startedAt,  String? bio)  $default,) {final _that = this;
switch (_that) {
case _MyCoachResponse():
return $default(_that.coachId,_that.firstName,_that.lastName,_that.specializations,_that.status,_that.startedAt,_that.bio);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String coachId,  String firstName,  String lastName,  List<String> specializations,  MyCoachResponseStatus status,  DateTime startedAt,  String? bio)?  $default,) {final _that = this;
switch (_that) {
case _MyCoachResponse() when $default != null:
return $default(_that.coachId,_that.firstName,_that.lastName,_that.specializations,_that.status,_that.startedAt,_that.bio);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MyCoachResponse implements MyCoachResponse {
  const _MyCoachResponse({required this.coachId, required this.firstName, required this.lastName, required  List<String> specializations, required this.status, required this.startedAt, this.bio}): _specializations = specializations;
  factory _MyCoachResponse.fromJson(Map<String, dynamic> json) => _$MyCoachResponseFromJson(json);

@override final  String coachId;
@override final  String firstName;
@override final  String lastName;
 final  List<String> _specializations;
@override List<String> get specializations {
  if (_specializations is EqualUnmodifiableListView) return _specializations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_specializations);
}

@override final  MyCoachResponseStatus status;
@override final  DateTime startedAt;
@override final  String? bio;

/// Create a copy of MyCoachResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MyCoachResponseCopyWith<_MyCoachResponse> get copyWith => __$MyCoachResponseCopyWithImpl<_MyCoachResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MyCoachResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MyCoachResponse&&(identical(other.coachId, coachId) || other.coachId == coachId)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&const DeepCollectionEquality().equals(other.specializations, _specializations)&&(identical(other.status, status) || other.status == status)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.bio, bio) || other.bio == bio));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,coachId,firstName,lastName,const DeepCollectionEquality().hash(_specializations),status,startedAt,bio);
}

@override
String toString() {
    return 'MyCoachResponse(coachId: $coachId, firstName: $firstName, lastName: $lastName, specializations: $specializations, status: $status, startedAt: $startedAt, bio: $bio)';
}


}

/// @nodoc
abstract mixin class _$MyCoachResponseCopyWith<$Res> implements $MyCoachResponseCopyWith<$Res> {
  factory _$MyCoachResponseCopyWith(_MyCoachResponse value, $Res Function(_MyCoachResponse) _then) = __$MyCoachResponseCopyWithImpl;
@override @useResult
$Res call({
 String coachId, String firstName, String lastName, List<String> specializations, MyCoachResponseStatus status, DateTime startedAt, String? bio
});




}
/// @nodoc
class __$MyCoachResponseCopyWithImpl<$Res>
    implements _$MyCoachResponseCopyWith<$Res> {
  __$MyCoachResponseCopyWithImpl(this._self, this._then);

  final _MyCoachResponse _self;
  final $Res Function(_MyCoachResponse) _then;

/// Create a copy of MyCoachResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? coachId = null,Object? firstName = null,Object? lastName = null,Object? specializations = null,Object? status = null,Object? startedAt = null,Object? bio = freezed,}) {
  return _then(_MyCoachResponse(
coachId: null == coachId ? _self.coachId : coachId // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,specializations: null == specializations ? _self._specializations : specializations // ignore: cast_nullable_to_non_nullable
as List<String>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MyCoachResponseStatus,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
