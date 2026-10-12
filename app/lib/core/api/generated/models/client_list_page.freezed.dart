// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'client_list_page.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ClientListPage {

 List<ClientListItem> get items; int get page; int get size; int get totalItems; int get totalPages;
/// Create a copy of ClientListPage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClientListPageCopyWith<ClientListPage> get copyWith => _$ClientListPageCopyWithImpl<ClientListPage>(this as ClientListPage, _$identity);

  /// Serializes this ClientListPage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ClientListPage;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClientListPage&&const DeepCollectionEquality().equals(other.items, _this.items)&&(identical(other.page, _this.page) || other.page == _this.page)&&(identical(other.size, _this.size) || other.size == _this.size)&&(identical(other.totalItems, _this.totalItems) || other.totalItems == _this.totalItems)&&(identical(other.totalPages, _this.totalPages) || other.totalPages == _this.totalPages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ClientListPage;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.items),_this.page,_this.size,_this.totalItems,_this.totalPages);
}

@override
String toString() {
  final _this = this as ClientListPage;
  return 'ClientListPage(items: ${_this.items}, page: ${_this.page}, size: ${_this.size}, totalItems: ${_this.totalItems}, totalPages: ${_this.totalPages})';
}


}

/// @nodoc
abstract mixin class $ClientListPageCopyWith<$Res>  {
  factory $ClientListPageCopyWith(ClientListPage value, $Res Function(ClientListPage) _then) = _$ClientListPageCopyWithImpl;
@useResult
$Res call({
 List<ClientListItem> items, int page, int size, int totalItems, int totalPages
});




}
/// @nodoc
class _$ClientListPageCopyWithImpl<$Res>
    implements $ClientListPageCopyWith<$Res> {
  _$ClientListPageCopyWithImpl(this._self, this._then);

  final ClientListPage _self;
  final $Res Function(ClientListPage) _then;

/// Create a copy of ClientListPage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? page = null,Object? size = null,Object? totalItems = null,Object? totalPages = null,}) {
  return _then(ClientListPage(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<ClientListItem>,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,totalItems: null == totalItems ? _self.totalItems : totalItems // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ClientListPage].
extension ClientListPagePatterns on ClientListPage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClientListPage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClientListPage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClientListPage value)  $default,){
final _that = this;
switch (_that) {
case _ClientListPage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClientListPage value)?  $default,){
final _that = this;
switch (_that) {
case _ClientListPage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ClientListItem> items,  int page,  int size,  int totalItems,  int totalPages)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClientListPage() when $default != null:
return $default(_that.items,_that.page,_that.size,_that.totalItems,_that.totalPages);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ClientListItem> items,  int page,  int size,  int totalItems,  int totalPages)  $default,) {final _that = this;
switch (_that) {
case _ClientListPage():
return $default(_that.items,_that.page,_that.size,_that.totalItems,_that.totalPages);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ClientListItem> items,  int page,  int size,  int totalItems,  int totalPages)?  $default,) {final _that = this;
switch (_that) {
case _ClientListPage() when $default != null:
return $default(_that.items,_that.page,_that.size,_that.totalItems,_that.totalPages);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ClientListPage implements ClientListPage {
  const _ClientListPage({required  List<ClientListItem> items, required this.page, required this.size, required this.totalItems, required this.totalPages}): _items = items;
  factory _ClientListPage.fromJson(Map<String, dynamic> json) => _$ClientListPageFromJson(json);

 final  List<ClientListItem> _items;
@override List<ClientListItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  int page;
@override final  int size;
@override final  int totalItems;
@override final  int totalPages;

/// Create a copy of ClientListPage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClientListPageCopyWith<_ClientListPage> get copyWith => __$ClientListPageCopyWithImpl<_ClientListPage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClientListPageToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClientListPage&&const DeepCollectionEquality().equals(other.items, _items)&&(identical(other.page, page) || other.page == page)&&(identical(other.size, size) || other.size == size)&&(identical(other.totalItems, totalItems) || other.totalItems == totalItems)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),page,size,totalItems,totalPages);
}

@override
String toString() {
    return 'ClientListPage(items: $items, page: $page, size: $size, totalItems: $totalItems, totalPages: $totalPages)';
}


}

/// @nodoc
abstract mixin class _$ClientListPageCopyWith<$Res> implements $ClientListPageCopyWith<$Res> {
  factory _$ClientListPageCopyWith(_ClientListPage value, $Res Function(_ClientListPage) _then) = __$ClientListPageCopyWithImpl;
@override @useResult
$Res call({
 List<ClientListItem> items, int page, int size, int totalItems, int totalPages
});




}
/// @nodoc
class __$ClientListPageCopyWithImpl<$Res>
    implements _$ClientListPageCopyWith<$Res> {
  __$ClientListPageCopyWithImpl(this._self, this._then);

  final _ClientListPage _self;
  final $Res Function(_ClientListPage) _then;

/// Create a copy of ClientListPage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? page = null,Object? size = null,Object? totalItems = null,Object? totalPages = null,}) {
  return _then(_ClientListPage(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<ClientListItem>,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,totalItems: null == totalItems ? _self.totalItems : totalItems // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
