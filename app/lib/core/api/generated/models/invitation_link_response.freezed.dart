// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'invitation_link_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InvitationLinkResponse {

 String get invitationId; String? get name; String? get email;/// Display form XXXXX-XXXXX (Crockford base32).
 String get code;/// {baseUrl}/join/{code}
 String get link; DateTime get expiresAt;
/// Create a copy of InvitationLinkResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InvitationLinkResponseCopyWith<InvitationLinkResponse> get copyWith => _$InvitationLinkResponseCopyWithImpl<InvitationLinkResponse>(this as InvitationLinkResponse, _$identity);

  /// Serializes this InvitationLinkResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as InvitationLinkResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InvitationLinkResponse&&(identical(other.invitationId, _this.invitationId) || other.invitationId == _this.invitationId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.link, _this.link) || other.link == _this.link)&&(identical(other.expiresAt, _this.expiresAt) || other.expiresAt == _this.expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as InvitationLinkResponse;
  return Object.hash(runtimeType,_this.invitationId,_this.name,_this.email,_this.code,_this.link,_this.expiresAt);
}

@override
String toString() {
  final _this = this as InvitationLinkResponse;
  return 'InvitationLinkResponse(invitationId: ${_this.invitationId}, name: ${_this.name}, email: ${_this.email}, code: ${_this.code}, link: ${_this.link}, expiresAt: ${_this.expiresAt})';
}


}

/// @nodoc
abstract mixin class $InvitationLinkResponseCopyWith<$Res>  {
  factory $InvitationLinkResponseCopyWith(InvitationLinkResponse value, $Res Function(InvitationLinkResponse) _then) = _$InvitationLinkResponseCopyWithImpl;
@useResult
$Res call({
 String invitationId, String? name, String? email, String code, String link, DateTime expiresAt
});




}
/// @nodoc
class _$InvitationLinkResponseCopyWithImpl<$Res>
    implements $InvitationLinkResponseCopyWith<$Res> {
  _$InvitationLinkResponseCopyWithImpl(this._self, this._then);

  final InvitationLinkResponse _self;
  final $Res Function(InvitationLinkResponse) _then;

/// Create a copy of InvitationLinkResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? invitationId = null,Object? name = freezed,Object? email = freezed,Object? code = null,Object? link = null,Object? expiresAt = null,}) {
  return _then(InvitationLinkResponse(
invitationId: null == invitationId ? _self.invitationId : invitationId // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,link: null == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [InvitationLinkResponse].
extension InvitationLinkResponsePatterns on InvitationLinkResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InvitationLinkResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InvitationLinkResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InvitationLinkResponse value)  $default,){
final _that = this;
switch (_that) {
case _InvitationLinkResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InvitationLinkResponse value)?  $default,){
final _that = this;
switch (_that) {
case _InvitationLinkResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String invitationId,  String? name,  String? email,  String code,  String link,  DateTime expiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InvitationLinkResponse() when $default != null:
return $default(_that.invitationId,_that.name,_that.email,_that.code,_that.link,_that.expiresAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String invitationId,  String? name,  String? email,  String code,  String link,  DateTime expiresAt)  $default,) {final _that = this;
switch (_that) {
case _InvitationLinkResponse():
return $default(_that.invitationId,_that.name,_that.email,_that.code,_that.link,_that.expiresAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String invitationId,  String? name,  String? email,  String code,  String link,  DateTime expiresAt)?  $default,) {final _that = this;
switch (_that) {
case _InvitationLinkResponse() when $default != null:
return $default(_that.invitationId,_that.name,_that.email,_that.code,_that.link,_that.expiresAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InvitationLinkResponse implements InvitationLinkResponse {
  const _InvitationLinkResponse({required this.invitationId, required this.name, required this.email, required this.code, required this.link, required this.expiresAt});
  factory _InvitationLinkResponse.fromJson(Map<String, dynamic> json) => _$InvitationLinkResponseFromJson(json);

@override final  String invitationId;
@override final  String? name;
@override final  String? email;
/// Display form XXXXX-XXXXX (Crockford base32).
@override final  String code;
/// {baseUrl}/join/{code}
@override final  String link;
@override final  DateTime expiresAt;

/// Create a copy of InvitationLinkResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InvitationLinkResponseCopyWith<_InvitationLinkResponse> get copyWith => __$InvitationLinkResponseCopyWithImpl<_InvitationLinkResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InvitationLinkResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _InvitationLinkResponse&&(identical(other.invitationId, invitationId) || other.invitationId == invitationId)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.code, code) || other.code == code)&&(identical(other.link, link) || other.link == link)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,invitationId,name,email,code,link,expiresAt);
}

@override
String toString() {
    return 'InvitationLinkResponse(invitationId: $invitationId, name: $name, email: $email, code: $code, link: $link, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class _$InvitationLinkResponseCopyWith<$Res> implements $InvitationLinkResponseCopyWith<$Res> {
  factory _$InvitationLinkResponseCopyWith(_InvitationLinkResponse value, $Res Function(_InvitationLinkResponse) _then) = __$InvitationLinkResponseCopyWithImpl;
@override @useResult
$Res call({
 String invitationId, String? name, String? email, String code, String link, DateTime expiresAt
});




}
/// @nodoc
class __$InvitationLinkResponseCopyWithImpl<$Res>
    implements _$InvitationLinkResponseCopyWith<$Res> {
  __$InvitationLinkResponseCopyWithImpl(this._self, this._then);

  final _InvitationLinkResponse _self;
  final $Res Function(_InvitationLinkResponse) _then;

/// Create a copy of InvitationLinkResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? invitationId = null,Object? name = freezed,Object? email = freezed,Object? code = null,Object? link = null,Object? expiresAt = null,}) {
  return _then(_InvitationLinkResponse(
invitationId: null == invitationId ? _self.invitationId : invitationId // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,link: null == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
