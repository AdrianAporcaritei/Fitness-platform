// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'client_list_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ClientListItem {

/// The invitation id when status is INVITED, otherwise the client's user id.
 String get id;/// Invitation name for INVITED (null only for invitations created before names were required), otherwise the client's first and last name.
 String? get name; ClientListStatus get status;/// True for an INVITED row whose invitation has expired.
 bool get invitationExpired;/// Invitation email for INVITED (may be null for older invitations), otherwise the client's email.
 String? get email;/// When the invitation was created.
 DateTime? get invitedAt;/// Set only for INVITED.
 DateTime? get invitationExpiresAt;
/// Create a copy of ClientListItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClientListItemCopyWith<ClientListItem> get copyWith => _$ClientListItemCopyWithImpl<ClientListItem>(this as ClientListItem, _$identity);

  /// Serializes this ClientListItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ClientListItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClientListItem&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.invitationExpired, _this.invitationExpired) || other.invitationExpired == _this.invitationExpired)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.invitedAt, _this.invitedAt) || other.invitedAt == _this.invitedAt)&&(identical(other.invitationExpiresAt, _this.invitationExpiresAt) || other.invitationExpiresAt == _this.invitationExpiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ClientListItem;
  return Object.hash(runtimeType,_this.id,_this.name,_this.status,_this.invitationExpired,_this.email,_this.invitedAt,_this.invitationExpiresAt);
}

@override
String toString() {
  final _this = this as ClientListItem;
  return 'ClientListItem(id: ${_this.id}, name: ${_this.name}, status: ${_this.status}, invitationExpired: ${_this.invitationExpired}, email: ${_this.email}, invitedAt: ${_this.invitedAt}, invitationExpiresAt: ${_this.invitationExpiresAt})';
}


}

/// @nodoc
abstract mixin class $ClientListItemCopyWith<$Res>  {
  factory $ClientListItemCopyWith(ClientListItem value, $Res Function(ClientListItem) _then) = _$ClientListItemCopyWithImpl;
@useResult
$Res call({
 String id, String? name, ClientListStatus status, bool invitationExpired, String? email, DateTime? invitedAt, DateTime? invitationExpiresAt
});




}
/// @nodoc
class _$ClientListItemCopyWithImpl<$Res>
    implements $ClientListItemCopyWith<$Res> {
  _$ClientListItemCopyWithImpl(this._self, this._then);

  final ClientListItem _self;
  final $Res Function(ClientListItem) _then;

/// Create a copy of ClientListItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = freezed,Object? status = null,Object? invitationExpired = null,Object? email = freezed,Object? invitedAt = freezed,Object? invitationExpiresAt = freezed,}) {
  return _then(ClientListItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ClientListStatus,invitationExpired: null == invitationExpired ? _self.invitationExpired : invitationExpired // ignore: cast_nullable_to_non_nullable
as bool,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,invitedAt: freezed == invitedAt ? _self.invitedAt : invitedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,invitationExpiresAt: freezed == invitationExpiresAt ? _self.invitationExpiresAt : invitationExpiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ClientListItem].
extension ClientListItemPatterns on ClientListItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClientListItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClientListItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClientListItem value)  $default,){
final _that = this;
switch (_that) {
case _ClientListItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClientListItem value)?  $default,){
final _that = this;
switch (_that) {
case _ClientListItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? name,  ClientListStatus status,  bool invitationExpired,  String? email,  DateTime? invitedAt,  DateTime? invitationExpiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClientListItem() when $default != null:
return $default(_that.id,_that.name,_that.status,_that.invitationExpired,_that.email,_that.invitedAt,_that.invitationExpiresAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? name,  ClientListStatus status,  bool invitationExpired,  String? email,  DateTime? invitedAt,  DateTime? invitationExpiresAt)  $default,) {final _that = this;
switch (_that) {
case _ClientListItem():
return $default(_that.id,_that.name,_that.status,_that.invitationExpired,_that.email,_that.invitedAt,_that.invitationExpiresAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? name,  ClientListStatus status,  bool invitationExpired,  String? email,  DateTime? invitedAt,  DateTime? invitationExpiresAt)?  $default,) {final _that = this;
switch (_that) {
case _ClientListItem() when $default != null:
return $default(_that.id,_that.name,_that.status,_that.invitationExpired,_that.email,_that.invitedAt,_that.invitationExpiresAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ClientListItem implements ClientListItem {
  const _ClientListItem({required this.id, required this.name, required this.status, required this.invitationExpired, this.email, this.invitedAt, this.invitationExpiresAt});
  factory _ClientListItem.fromJson(Map<String, dynamic> json) => _$ClientListItemFromJson(json);

/// The invitation id when status is INVITED, otherwise the client's user id.
@override final  String id;
/// Invitation name for INVITED (null only for invitations created before names were required), otherwise the client's first and last name.
@override final  String? name;
@override final  ClientListStatus status;
/// True for an INVITED row whose invitation has expired.
@override final  bool invitationExpired;
/// Invitation email for INVITED (may be null for older invitations), otherwise the client's email.
@override final  String? email;
/// When the invitation was created.
@override final  DateTime? invitedAt;
/// Set only for INVITED.
@override final  DateTime? invitationExpiresAt;

/// Create a copy of ClientListItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClientListItemCopyWith<_ClientListItem> get copyWith => __$ClientListItemCopyWithImpl<_ClientListItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClientListItemToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClientListItem&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.status, status) || other.status == status)&&(identical(other.invitationExpired, invitationExpired) || other.invitationExpired == invitationExpired)&&(identical(other.email, email) || other.email == email)&&(identical(other.invitedAt, invitedAt) || other.invitedAt == invitedAt)&&(identical(other.invitationExpiresAt, invitationExpiresAt) || other.invitationExpiresAt == invitationExpiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,status,invitationExpired,email,invitedAt,invitationExpiresAt);
}

@override
String toString() {
    return 'ClientListItem(id: $id, name: $name, status: $status, invitationExpired: $invitationExpired, email: $email, invitedAt: $invitedAt, invitationExpiresAt: $invitationExpiresAt)';
}


}

/// @nodoc
abstract mixin class _$ClientListItemCopyWith<$Res> implements $ClientListItemCopyWith<$Res> {
  factory _$ClientListItemCopyWith(_ClientListItem value, $Res Function(_ClientListItem) _then) = __$ClientListItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String? name, ClientListStatus status, bool invitationExpired, String? email, DateTime? invitedAt, DateTime? invitationExpiresAt
});




}
/// @nodoc
class __$ClientListItemCopyWithImpl<$Res>
    implements _$ClientListItemCopyWith<$Res> {
  __$ClientListItemCopyWithImpl(this._self, this._then);

  final _ClientListItem _self;
  final $Res Function(_ClientListItem) _then;

/// Create a copy of ClientListItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = freezed,Object? status = null,Object? invitationExpired = null,Object? email = freezed,Object? invitedAt = freezed,Object? invitationExpiresAt = freezed,}) {
  return _then(_ClientListItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ClientListStatus,invitationExpired: null == invitationExpired ? _self.invitationExpired : invitationExpired // ignore: cast_nullable_to_non_nullable
as bool,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,invitedAt: freezed == invitedAt ? _self.invitedAt : invitedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,invitationExpiresAt: freezed == invitationExpiresAt ? _self.invitationExpiresAt : invitationExpiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
