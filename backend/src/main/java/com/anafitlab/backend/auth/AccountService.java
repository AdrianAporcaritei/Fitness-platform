package com.anafitlab.backend.auth;

import java.time.Clock;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.anafitlab.backend.auth.dto.UserResponse;
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
	private final Clock clock;

	AccountService(CurrentUserAccounts accounts, ActionTokenService actionTokens, AppUserRepository users,
			AccountEmails emails, RateLimiter rateLimiter, RateLimitProperties limits, Clock clock) {
		this.accounts = accounts;
		this.actionTokens = actionTokens;
		this.users = users;
		this.emails = emails;
		this.rateLimiter = rateLimiter;
		this.limits = limits;
		this.clock = clock;
	}

	@Transactional(readOnly = true)
	public UserResponse me(CurrentUser current) {
		return UserResponse.from(accounts.require(current));
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

}
