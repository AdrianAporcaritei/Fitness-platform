// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'invite_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InviteResponse {

 String get id; InviteResponseStatus get status; DateTime get createdAt; DateTime get expiresAt; String? get label; DateTime? get usedAt;
/// Create a copy of InviteResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InviteResponseCopyWith<InviteResponse> get copyWith => _$InviteResponseCopyWithImpl<InviteResponse>(this as InviteResponse, _$identity);

  /// Serializes this InviteResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as InviteResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InviteResponse&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.expiresAt, _this.expiresAt) || other.expiresAt == _this.expiresAt)&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.usedAt, _this.usedAt) || other.usedAt == _this.usedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as InviteResponse;
  return Object.hash(runtimeType,_this.id,_this.status,_this.createdAt,_this.expiresAt,_this.label,_this.usedAt);
}

@override
String toString() {
  final _this = this as InviteResponse;
  return 'InviteResponse(id: ${_this.id}, status: ${_this.status}, createdAt: ${_this.createdAt}, expiresAt: ${_this.expiresAt}, label: ${_this.label}, usedAt: ${_this.usedAt})';
}


}

/// @nodoc
abstract mixin class $InviteResponseCopyWith<$Res>  {
  factory $InviteResponseCopyWith(InviteResponse value, $Res Function(InviteResponse) _then) = _$InviteResponseCopyWithImpl;
@useResult
$Res call({
 String id, InviteResponseStatus status, DateTime createdAt, DateTime expiresAt, String? label, DateTime? usedAt
});




}
/// @nodoc
class _$InviteResponseCopyWithImpl<$Res>
    implements $InviteResponseCopyWith<$Res> {
  _$InviteResponseCopyWithImpl(this._self, this._then);

  final InviteResponse _self;
  final $Res Function(InviteResponse) _then;

/// Create a copy of InviteResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? status = null,Object? createdAt = null,Object? expiresAt = null,Object? label = freezed,Object? usedAt = freezed,}) {
  return _then(InviteResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InviteResponseStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,usedAt: freezed == usedAt ? _self.usedAt : usedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [InviteResponse].
extension InviteResponsePatterns on InviteResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InviteResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InviteResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InviteResponse value)  $default,){
final _that = this;
switch (_that) {
case _InviteResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InviteResponse value)?  $default,){
final _that = this;
switch (_that) {
case _InviteResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  InviteResponseStatus status,  DateTime createdAt,  DateTime expiresAt,  String? label,  DateTime? usedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InviteResponse() when $default != null:
return $default(_that.id,_that.status,_that.createdAt,_that.expiresAt,_that.label,_that.usedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  InviteResponseStatus status,  DateTime createdAt,  DateTime expiresAt,  String? label,  DateTime? usedAt)  $default,) {final _that = this;
switch (_that) {
case _InviteResponse():
return $default(_that.id,_that.status,_that.createdAt,_that.expiresAt,_that.label,_that.usedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  InviteResponseStatus status,  DateTime createdAt,  DateTime expiresAt,  String? label,  DateTime? usedAt)?  $default,) {final _that = this;
switch (_that) {
case _InviteResponse() when $default != null:
return $default(_that.id,_that.status,_that.createdAt,_that.expiresAt,_that.label,_that.usedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InviteResponse implements InviteResponse {
  const _InviteResponse({required this.id, required this.status, required this.createdAt, required this.expiresAt, this.label, this.usedAt});
  factory _InviteResponse.fromJson(Map<String, dynamic> json) => _$InviteResponseFromJson(json);

@override final  String id;
@override final  InviteResponseStatus status;
@override final  DateTime createdAt;
@override final  DateTime expiresAt;
@override final  String? label;
@override final  DateTime? usedAt;

/// Create a copy of InviteResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InviteResponseCopyWith<_InviteResponse> get copyWith => __$InviteResponseCopyWithImpl<_InviteResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InviteResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _InviteResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.label, label) || other.label == label)&&(identical(other.usedAt, usedAt) || other.usedAt == usedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,status,createdAt,expiresAt,label,usedAt);
}

@override
String toString() {
    return 'InviteResponse(id: $id, status: $status, createdAt: $createdAt, expiresAt: $expiresAt, label: $label, usedAt: $usedAt)';
}


}

/// @nodoc
abstract mixin class _$InviteResponseCopyWith<$Res> implements $InviteResponseCopyWith<$Res> {
  factory _$InviteResponseCopyWith(_InviteResponse value, $Res Function(_InviteResponse) _then) = __$InviteResponseCopyWithImpl;
@override @useResult
$Res call({
 String id, InviteResponseStatus status, DateTime createdAt, DateTime expiresAt, String? label, DateTime? usedAt
});




}
/// @nodoc
class __$InviteResponseCopyWithImpl<$Res>
    implements _$InviteResponseCopyWith<$Res> {
  __$InviteResponseCopyWithImpl(this._self, this._then);

  final _InviteResponse _self;
  final $Res Function(_InviteResponse) _then;

/// Create a copy of InviteResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? status = null,Object? createdAt = null,Object? expiresAt = null,Object? label = freezed,Object? usedAt = freezed,}) {
  return _then(_InviteResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InviteResponseStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,usedAt: freezed == usedAt ? _self.usedAt : usedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
