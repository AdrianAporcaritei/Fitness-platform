package com.anafitlab.backend.auth;

import java.time.Clock;

import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.anafitlab.backend.auth.dto.ChangePasswordRequest;
import com.anafitlab.backend.auth.dto.TokenResponse;
import com.anafitlab.backend.auth.dto.UpdateMeRequest;
import com.anafitlab.backend.auth.dto.UserResponse;
import com.anafitlab.backend.common.error.ApiException;
import com.anafitlab.backend.common.ratelimit.RateLimitProperties;
import com.anafitlab.backend.common.ratelimit.RateLimiter;
import com.anafitlab.backend.common.security.CurrentUser;

@Service
public class AccountService {

	private final CurrentUserAccounts accounts;
	private final ActionTokenService actionTokens;
	private final AppUserRepository users;
	private final AccountEmails emails;
	private final RateLimiter rateLimiter;
	private final RateLimitProperties limits;
	private final PasswordEncoder passwordEncoder;
	private final RefreshTokenService refreshTokens;
	private final SessionFactory sessions;
	private final Clock clock;

	AccountService(CurrentUserAccounts accounts, ActionTokenService actionTokens, AppUserRepository users,
			AccountEmails emails, RateLimiter rateLimiter, RateLimitProperties limits,
			PasswordEncoder passwordEncoder, RefreshTokenService refreshTokens, SessionFactory sessions, Clock clock) {
		this.accounts = accounts;
		this.actionTokens = actionTokens;
		this.users = users;
		this.emails = emails;
		this.rateLimiter = rateLimiter;
		this.limits = limits;
		this.passwordEncoder = passwordEncoder;
		this.refreshTokens = refreshTokens;
		this.sessions = sessions;
		this.clock = clock;
	}

	@Transactional(readOnly = true)
	public UserResponse me(CurrentUser current) {
		return UserResponse.from(accounts.require(current));
	}

	@Transactional
	public UserResponse updateMe(CurrentUser current, UpdateMeRequest request) {
		AppUser user = accounts.require(current);
		if (request.firstName() != null) {
			user.setFirstName(request.firstName().strip());
		}
		if (request.lastName() != null) {
			user.setLastName(request.lastName().strip());
		}
		if (request.locale() != null) {
			user.setLocale(request.locale());
		}
		if (request.timezone() != null) {
			user.setTimezone(request.timezone());
		}
		return UserResponse.from(users.save(user));
	}

	/** PENDING becomes ACTIVE; SUSPENDED stays SUSPENDED but is marked verified. */
	@Transactional
	public void verifyEmail(String token) {
		AppUser user = actionTokens.consume(token, ActionTokenPurpose.EMAIL_VERIFICATION);
		if (user.getEmailVerifiedAt() == null) {
			user.setEmailVerifiedAt(clock.instant());
		}
		if (user.getStatus() == UserStatus.PENDING) {
			user.setStatus(UserStatus.ACTIVE);
		}
		users.save(user);
	}

	/** Counts against the limit even for users who are not PENDING (a 204 no-op). */
	@Transactional
	public void resendVerification(CurrentUser current) {
		rateLimiter.hit("verify-resend", current.id().toString(), limits.verifyResend().limit());
		AppUser user = accounts.require(current);
		if (user.getStatus() != UserStatus.PENDING) {
			return;
		}
		String raw = actionTokens.issue(user, ActionTokenPurpose.EMAIL_VERIFICATION);
		emails.sendVerification(user, raw);
	}

	/**
	 * Indistinguishable for existing, unknown and suspended emails. Both rate-limit hits happen first, so
	 * the outcome never depends on whether the account exists.
	 */
	@Transactional
	public void requestPasswordReset(String email, String ip) {
		rateLimiter.hit("reset-email", email, limits.resetEmail().limit());
		rateLimiter.hit("reset-ip", ip, limits.resetIp().limit());
		users.findByEmail(email).filter(u -> u.getStatus() != UserStatus.SUSPENDED).ifPresent(user -> {
			String raw = actionTokens.issue(user, ActionTokenPurpose.PASSWORD_RESET);
			emails.sendPasswordReset(user, raw);
		});
	}

	/**
	 * The user is saved before the revoke: the bulk revoke clears the persistence context and would drop
	 * unflushed changes.
	 */
	@Transactional
	public TokenResponse confirmPasswordReset(String token, String newPassword) {
		AppUser user = actionTokens.consume(token, ActionTokenPurpose.PASSWORD_RESET);
		if (user.getStatus() == UserStatus.SUSPENDED) {
			throw new ApiException(HttpStatus.FORBIDDEN, "ACCOUNT_SUSPENDED");
		}
		user.setPasswordHash(passwordEncoder.encode(newPassword));
		if (user.getEmailVerifiedAt() == null) {
			user.setEmailVerifiedAt(clock.instant());
		}
		if (user.getStatus() == UserStatus.PENDING) {
			user.setStatus(UserStatus.ACTIVE);
		}
		users.saveAndFlush(user);
		refreshTokens.revokeAllForUser(user.getId());
		return sessions.create(user);
	}

	@Transactional
	public void changePassword(CurrentUser current, ChangePasswordRequest request) {
		AppUser user = accounts.require(current);
		rateLimiter.hit(AuthService.LOGIN_EMAIL_BUCKET, user.getEmail(), limits.loginEmail().limit());
		if (!passwordEncoder.matches(request.currentPassword(), user.getPasswordHash())) {
			throw new ApiException(HttpStatus.BAD_REQUEST, "INVALID_CURRENT_PASSWORD");
		}
		rateLimiter.refund(AuthService.LOGIN_EMAIL_BUCKET, user.getEmail());
		user.setPasswordHash(passwordEncoder.encode(request.newPassword()));
		users.saveAndFlush(user);
		refreshTokens.revokeAllExceptFamilyOf(user.getId(), request.refreshToken());
	}

}
