// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/add_client_request.dart';
import '../models/change_password_request.dart';
import '../models/change_relationship_request.dart';
import '../models/client_list_page.dart';
import '../models/client_list_status.dart';
import '../models/coach_client_response.dart';
import '../models/coach_link_request.dart';
import '../models/coach_link_response.dart';
import '../models/coach_profile_response.dart';
import '../models/invitation_link_response.dart';
import '../models/invite_preview_response.dart';
import '../models/login_request.dart';
import '../models/logout_request.dart';
import '../models/my_coach_response.dart';
import '../models/password_reset_confirm_request.dart';
import '../models/password_reset_request.dart';
import '../models/refresh_request.dart';
import '../models/register_client_request.dart';
import '../models/register_coach_request.dart';
import '../models/token_response.dart';
import '../models/update_coach_profile_request.dart';
import '../models/update_me_request.dart';
import '../models/user_response.dart';
import '../models/verify_email_request.dart';

part 'openapi_client.g.dart';

@RestApi()
abstract class OpenapiClient {
  factory OpenapiClient(Dio dio, {String? baseUrl}) = _OpenapiClient;

  /// The authenticated user.
  @GET('/me')
  Future<UserResponse> getMe();

  /// Partially update the authenticated user.
  ///
  /// Every field is optional; an absent or null field is left unchanged. An empty object changes nothing.
  @PATCH('/me')
  Future<UserResponse> updateMe({
    @Body() required UpdateMeRequest body,
  });

  /// Change the password of the authenticated user.
  ///
  /// Revokes every session except the one identified by refreshToken. If refreshToken is not one of the caller's tokens, all sessions are revoked.
  @POST('/me/password')
  Future<void> changePassword({
    @Body() required ChangePasswordRequest body,
  });

  /// Sign up as a coach. Creates a PENDING account, sends a verification email and returns a session.
  @POST('/auth/register/coach')
  Future<TokenResponse> registerCoach({
    @Body() required RegisterCoachRequest body,
  });

  /// Sign up as a client with a coach invite code.
  ///
  /// One transaction: the invite is locked, a PENDING CLIENT account is created, an ACTIVE coach relationship is created and the invite is marked USED. Any failure leaves the invite PENDING and creates no account.
  @POST('/auth/register/client')
  Future<TokenResponse> registerClient({
    @Body() required RegisterClientRequest body,
  });

  /// Link the authenticated client, who has no current coach, to a coach with an invite code.
  ///
  /// CLIENT only. A PENDING client is allowed. Rate limited per IP (20 per 15 minutes).
  @POST('/me/coach-link')
  Future<CoachLinkResponse> linkCoach({
    @Body() required CoachLinkRequest body,
  });

  /// Sign in with email and password.
  @POST('/auth/login')
  Future<TokenResponse> login({
    @Body() required LoginRequest body,
  });

  /// Exchange a refresh token for a new session (rotation with reuse detection).
  @POST('/auth/refresh')
  Future<TokenResponse> refresh({
    @Body() required RefreshRequest body,
  });

  /// Revoke the session (token family) of the given refresh token.
  @POST('/auth/logout')
  Future<void> logout({
    @Body() required LogoutRequest body,
  });

  /// Revoke every session of the authenticated user.
  @POST('/auth/logout-all')
  Future<void> logoutAll();

  /// Verify an email address with the token from the verification email.
  ///
  /// Sets email_verified_at. PENDING becomes ACTIVE; SUSPENDED stays SUSPENDED. The token is single use.
  @POST('/auth/verify-email')
  Future<void> verifyEmail({
    @Body() required VerifyEmailRequest body,
  });

  /// Send a new verification email to the authenticated user.
  ///
  /// Invalidates earlier verification tokens. A no-op (still 204) unless the user is PENDING. Limited to 3 per user per hour.
  @POST('/auth/verify-email/resend')
  Future<void> resendVerificationEmail();

  /// Request a password reset email.
  ///
  /// Always 202 with no body, whether or not the email belongs to an account (suspended accounts get no email). Limited to 3 per email and 10 per IP per hour.
  @POST('/auth/password-reset/request')
  Future<void> requestPasswordReset({
    @Body() required PasswordResetRequest body,
  });

  /// Set a new password with the token from the reset email.
  ///
  /// Single-use token valid for 1 hour. Revokes all refresh tokens, verifies a PENDING user (ACTIVE) and returns a new session.
  @POST('/auth/password-reset/confirm')
  Future<TokenResponse> confirmPasswordReset({
    @Body() required PasswordResetConfirmRequest body,
  });

  /// Public lookup of an invite code (used by the join page).
  ///
  /// The code is accepted loosely: case-insensitive, dashes and spaces ignored, O read as 0 and I/L as 1. Rate limited per IP (20 per 15 minutes). An invalid code is an error, so a 200 always has valid=true.
  @GET('/invites/{code}')
  Future<InvitePreviewResponse> previewInvite({
    @Path('code') required String code,
  });

  /// The authenticated client's current coach (ACTIVE or PAUSED).
  ///
  /// CLIENT only.
  @GET('/me/coach')
  Future<MyCoachResponse> getMyCoach();

  /// End the current relationship with the coach.
  ///
  /// CLIENT only. Works for ACTIVE or PAUSED; sets ended_at.
  @DELETE('/me/coach')
  Future<void> leaveCoach();

  /// The coach's clients and pending invitations, paginated, ordered by name.
  ///
  /// One row per invited client (pending invitation, including expired ones) and per linked client. Without `status`, INVITED, ACTIVE and PAUSED rows are returned. ENDED rows are returned only with `status=ENDED`: one row per former client (most recent relationship), never for a client who is currently linked to this coach. Invitation codes and links are never returned.
  ///
  /// [q] - Case-insensitive substring of the name or email.
  ///
  /// [page] - Zero-based page index.
  @GET('/coach/clients')
  Future<ClientListPage> listClients({
    @Query('page') int? page = 0,
    @Query('size') int? size = 20,
    @Query('q') String? q,
    @Query('status') ClientListStatus? status,
  });

  /// Add a client by creating a single-use invitation (valid 7 days) with the client's name and email.
  ///
  /// No email is sent; the coach shares the returned link. The code and link are returned only in this response; only the code's hash is stored.
  @POST('/coach/clients')
  Future<InvitationLinkResponse> addClient({
    @Body() required AddClientRequest body,
  });

  /// Pause, resume or end the relationship with a client.
  ///
  /// ENDED sets ended_at and is final.
  @PATCH('/coach/clients/{clientId}/relationship')
  Future<CoachClientResponse> changeRelationship({
    @Path('clientId') required String clientId,
    @Body() required ChangeRelationshipRequest body,
  });

  /// The coach's public profile.
  @GET('/coach/profile')
  Future<CoachProfileResponse> getCoachProfile();

  /// Update the coach profile.
  ///
  /// Absent or null fields are left unchanged.
  @PATCH('/coach/profile')
  Future<CoachProfileResponse> updateCoachProfile({
    @Body() required UpdateCoachProfileRequest body,
  });

  /// Replace the code of a pending (possibly expired) invitation and extend it by 7 days.
  ///
  /// The old link stops working. The new code and link are returned only in this response.
  @POST('/coach/invites/{id}/regenerate')
  Future<InvitationLinkResponse> regenerateInvitation({
    @Path('id') required String id,
  });

  /// Cancel a pending (possibly expired) invitation.
  @DELETE('/coach/invites/{id}')
  Future<void> cancelInvitation({
    @Path('id') required String id,
  });
}
