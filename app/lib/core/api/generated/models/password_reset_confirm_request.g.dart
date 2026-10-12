// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'password_reset_confirm_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PasswordResetConfirmRequest _$PasswordResetConfirmRequestFromJson(
  Map<String, dynamic> json,
) => _PasswordResetConfirmRequest(
  token: json['token'] as String,
  newPassword: json['newPassword'] as String,
);

Map<String, dynamic> _$PasswordResetConfirmRequestToJson(
  _PasswordResetConfirmRequest instance,
) => <String, dynamic>{
  'token': instance.token,
  'newPassword': instance.newPassword,
};
