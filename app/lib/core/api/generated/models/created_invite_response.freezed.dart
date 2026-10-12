// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'created_invite_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreatedInviteResponse {

 String get id;/// Display form XXXXX-XXXXX (Crockford base32).
 String get code;/// {baseUrl}/join/{code}
 String get link; DateTime get expiresAt; String? get label;
/// Create a copy of CreatedInviteResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreatedInviteResponseCopyWith<CreatedInviteResponse> get copyWith => _$CreatedInviteResponseCopyWithImpl<CreatedInviteResponse>(this as CreatedInviteResponse, _$identity);

  /// Serializes this CreatedInviteResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CreatedInviteResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreatedInviteResponse&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.link, _this.link) || other.link == _this.link)&&(identical(other.expiresAt, _this.expiresAt) || other.expiresAt == _this.expiresAt)&&(identical(other.label, _this.label) || other.label == _this.label));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CreatedInviteResponse;
  return Object.hash(runtimeType,_this.id,_this.code,_this.link,_this.expiresAt,_this.label);
}

@override
String toString() {
  final _this = this as CreatedInviteResponse;
  return 'CreatedInviteResponse(id: ${_this.id}, code: ${_this.code}, link: ${_this.link}, expiresAt: ${_this.expiresAt}, label: ${_this.label})';
}


}

/// @nodoc
abstract mixin class $CreatedInviteResponseCopyWith<$Res>  {
  factory $CreatedInviteResponseCopyWith(CreatedInviteResponse value, $Res Function(CreatedInviteResponse) _then) = _$CreatedInviteResponseCopyWithImpl;
@useResult
$Res call({
 String id, String code, String link, DateTime expiresAt, String? label
});




}
/// @nodoc
class _$CreatedInviteResponseCopyWithImpl<$Res>
    implements $CreatedInviteResponseCopyWith<$Res> {
  _$CreatedInviteResponseCopyWithImpl(this._self, this._then);

  final CreatedInviteResponse _self;
  final $Res Function(CreatedInviteResponse) _then;

/// Create a copy of CreatedInviteResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? code = null,Object? link = null,Object? expiresAt = null,Object? label = freezed,}) {
  return _then(CreatedInviteResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,link: null == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreatedInviteResponse].
extension CreatedInviteResponsePatterns on CreatedInviteResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreatedInviteResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreatedInviteResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreatedInviteResponse value)  $default,){
final _that = this;
switch (_that) {
case _CreatedInviteResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreatedInviteResponse value)?  $default,){
final _that = this;
switch (_that) {
case _CreatedInviteResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String code,  String link,  DateTime expiresAt,  String? label)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreatedInviteResponse() when $default != null:
return $default(_that.id,_that.code,_that.link,_that.expiresAt,_that.label);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String code,  String link,  DateTime expiresAt,  String? label)  $default,) {final _that = this;
switch (_that) {
case _CreatedInviteResponse():
return $default(_that.id,_that.code,_that.link,_that.expiresAt,_that.label);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String code,  String link,  DateTime expiresAt,  String? label)?  $default,) {final _that = this;
switch (_that) {
case _CreatedInviteResponse() when $default != null:
return $default(_that.id,_that.code,_that.link,_that.expiresAt,_that.label);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreatedInviteResponse implements CreatedInviteResponse {
  const _CreatedInviteResponse({required this.id, required this.code, required this.link, required this.expiresAt, this.label});
  factory _CreatedInviteResponse.fromJson(Map<String, dynamic> json) => _$CreatedInviteResponseFromJson(json);

@override final  String id;
/// Display form XXXXX-XXXXX (Crockford base32).
@override final  String code;
/// {baseUrl}/join/{code}
@override final  String link;
@override final  DateTime expiresAt;
@override final  String? label;

/// Create a copy of CreatedInviteResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreatedInviteResponseCopyWith<_CreatedInviteResponse> get copyWith => __$CreatedInviteResponseCopyWithImpl<_CreatedInviteResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreatedInviteResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreatedInviteResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.link, link) || other.link == link)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.label, label) || other.label == label));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,code,link,expiresAt,label);
}

@override
String toString() {
    return 'CreatedInviteResponse(id: $id, code: $code, link: $link, expiresAt: $expiresAt, label: $label)';
}


}

/// @nodoc
abstract mixin class _$CreatedInviteResponseCopyWith<$Res> implements $CreatedInviteResponseCopyWith<$Res> {
  factory _$CreatedInviteResponseCopyWith(_CreatedInviteResponse value, $Res Function(_CreatedInviteResponse) _then) = __$CreatedInviteResponseCopyWithImpl;
@override @useResult
$Res call({
 String id, String code, String link, DateTime expiresAt, String? label
});




}
/// @nodoc
class __$CreatedInviteResponseCopyWithImpl<$Res>
    implements _$CreatedInviteResponseCopyWith<$Res> {
  __$CreatedInviteResponseCopyWithImpl(this._self, this._then);

  final _CreatedInviteResponse _self;
  final $Res Function(_CreatedInviteResponse) _then;

/// Create a copy of CreatedInviteResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? code = null,Object? link = null,Object? expiresAt = null,Object? label = freezed,}) {
  return _then(_CreatedInviteResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,link: null == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
