// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'change_relationship_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChangeRelationshipRequest {

 ChangeRelationshipRequestStatus get status;
/// Create a copy of ChangeRelationshipRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChangeRelationshipRequestCopyWith<ChangeRelationshipRequest> get copyWith => _$ChangeRelationshipRequestCopyWithImpl<ChangeRelationshipRequest>(this as ChangeRelationshipRequest, _$identity);

  /// Serializes this ChangeRelationshipRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ChangeRelationshipRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChangeRelationshipRequest&&(identical(other.status, _this.status) || other.status == _this.status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ChangeRelationshipRequest;
  return Object.hash(runtimeType,_this.status);
}

@override
String toString() {
  final _this = this as ChangeRelationshipRequest;
  return 'ChangeRelationshipRequest(status: ${_this.status})';
}


}

/// @nodoc
abstract mixin class $ChangeRelationshipRequestCopyWith<$Res>  {
  factory $ChangeRelationshipRequestCopyWith(ChangeRelationshipRequest value, $Res Function(ChangeRelationshipRequest) _then) = _$ChangeRelationshipRequestCopyWithImpl;
@useResult
$Res call({
 ChangeRelationshipRequestStatus status
});




}
/// @nodoc
class _$ChangeRelationshipRequestCopyWithImpl<$Res>
    implements $ChangeRelationshipRequestCopyWith<$Res> {
  _$ChangeRelationshipRequestCopyWithImpl(this._self, this._then);

  final ChangeRelationshipRequest _self;
  final $Res Function(ChangeRelationshipRequest) _then;

/// Create a copy of ChangeRelationshipRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,}) {
  return _then(ChangeRelationshipRequest(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ChangeRelationshipRequestStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [ChangeRelationshipRequest].
extension ChangeRelationshipRequestPatterns on ChangeRelationshipRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChangeRelationshipRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChangeRelationshipRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChangeRelationshipRequest value)  $default,){
final _that = this;
switch (_that) {
case _ChangeRelationshipRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChangeRelationshipRequest value)?  $default,){
final _that = this;
switch (_that) {
case _ChangeRelationshipRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ChangeRelationshipRequestStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChangeRelationshipRequest() when $default != null:
return $default(_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ChangeRelationshipRequestStatus status)  $default,) {final _that = this;
switch (_that) {
case _ChangeRelationshipRequest():
return $default(_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ChangeRelationshipRequestStatus status)?  $default,) {final _that = this;
switch (_that) {
case _ChangeRelationshipRequest() when $default != null:
return $default(_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChangeRelationshipRequest implements ChangeRelationshipRequest {
  const _ChangeRelationshipRequest({required this.status});
  factory _ChangeRelationshipRequest.fromJson(Map<String, dynamic> json) => _$ChangeRelationshipRequestFromJson(json);

@override final  ChangeRelationshipRequestStatus status;

/// Create a copy of ChangeRelationshipRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChangeRelationshipRequestCopyWith<_ChangeRelationshipRequest> get copyWith => __$ChangeRelationshipRequestCopyWithImpl<_ChangeRelationshipRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChangeRelationshipRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChangeRelationshipRequest&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,status);
}

@override
String toString() {
    return 'ChangeRelationshipRequest(status: $status)';
}


}

/// @nodoc
abstract mixin class _$ChangeRelationshipRequestCopyWith<$Res> implements $ChangeRelationshipRequestCopyWith<$Res> {
  factory _$ChangeRelationshipRequestCopyWith(_ChangeRelationshipRequest value, $Res Function(_ChangeRelationshipRequest) _then) = __$ChangeRelationshipRequestCopyWithImpl;
@override @useResult
$Res call({
 ChangeRelationshipRequestStatus status
});




}
/// @nodoc
class __$ChangeRelationshipRequestCopyWithImpl<$Res>
    implements _$ChangeRelationshipRequestCopyWith<$Res> {
  __$ChangeRelationshipRequestCopyWithImpl(this._self, this._then);

  final _ChangeRelationshipRequest _self;
  final $Res Function(_ChangeRelationshipRequest) _then;

/// Create a copy of ChangeRelationshipRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,}) {
  return _then(_ChangeRelationshipRequest(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ChangeRelationshipRequestStatus,
  ));
}


}

// dart format on
