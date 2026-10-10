package com.anafitlab.backend.auth;

import java.time.Clock;
import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.anafitlab.backend.auth.dto.LoginRequest;
import com.anafitlab.backend.auth.dto.LogoutRequest;
import com.anafitlab.backend.auth.dto.RefreshRequest;
import com.anafitlab.backend.auth.dto.RegisterCoachRequest;
import com.anafitlab.backend.auth.dto.TokenResponse;
import com.anafitlab.backend.client.CoachProfile;
import com.anafitlab.backend.client.CoachProfileRepository;
import com.anafitlab.backend.common.error.ApiException;
import com.anafitlab.backend.common.ratelimit.RateLimitProperties;
import com.anafitlab.backend.common.ratelimit.RateLimiter;
import com.anafitlab.backend.common.security.CurrentUser;

@Service
public class AuthService {

	/** Shared with password change: wrong passwords count against the same per-email budget. */
	static final String LOGIN_EMAIL_BUCKET = "login-email";

	private final RateLimiter rateLimiter;
	private final RateLimitProperties limits;
	private final UserRegistrar registrar;
	private final CoachProfileRepository coachProfiles;
	private final ActionTokenService actionTokens;
	private final AccountEmails emails;
	private final SessionFactory sessions;
	private final AppUserRepository users;
	private final PasswordEncoder passwordEncoder;
	private final RefreshTokenService refreshTokens;
	private final Clock clock;

	/** Verified against when the email is unknown, so both failures cost the same time. */
	private final String dummyHash;

	AuthService(RateLimiter rateLimiter, RateLimitProperties limits, UserRegistrar registrar, CoachProfileRepository coachProfiles,
			ActionTokenService actionTokens, AccountEmails emails, SessionFactory sessions, AppUserRepository users,
			PasswordEncoder passwordEncoder, RefreshTokenService refreshTokens, Clock clock) {
		this.rateLimiter = rateLimiter;
		this.limits = limits;
		this.registrar = registrar;
		this.coachProfiles = coachProfiles;
		this.actionTokens = actionTokens;
		this.emails = emails;
		this.sessions = sessions;
		this.users = users;
		this.passwordEncoder = passwordEncoder;
		this.refreshTokens = refreshTokens;
		this.clock = clock;
		this.dummyHash = passwordEncoder.encode("dummy-password-for-timing");
	}

	@Transactional
	public TokenResponse registerCoach(RegisterCoachRequest request, String ip) {
		rateLimiter.hit("signup-ip", ip, limits.signupIp().limit());
		AppUser user = registrar.register(Role.COACH, request.toNewUser());
		CoachProfile profile = new CoachProfile();
		profile.setUserId(user.getId());
		profile.setSpecializations(List.of());
		coachProfiles.save(profile);
		String rawToken = actionTokens.issue(user, ActionTokenPurpose.EMAIL_VERIFICATION);
		emails.sendVerification(user, rawToken);
		return sessions.create(user);
	}

	@Transactional
	public TokenResponse login(LoginRequest request, String ip) {
		String email = request.email();
		rateLimiter.ensureUnder(LOGIN_EMAIL_BUCKET, email, limits.loginEmail().limit());
		rateLimiter.ensureUnder("login-ip", ip, limits.loginIp().limit());
		AppUser user = users.findByEmail(email).orElse(null);
		String hash = user != null ? user.getPasswordHash() : dummyHash;
		boolean matches = passwordEncoder.matches(request.password(), hash);
		if (user == null || !matches) {
			rateLimiter.record(LOGIN_EMAIL_BUCKET, email, limits.loginEmail().limit());
			rateLimiter.record("login-ip", ip, limits.loginIp().limit());
			throw new ApiException(HttpStatus.UNAUTHORIZED, "INVALID_CREDENTIALS");
		}
		if (user.getStatus() == UserStatus.SUSPENDED) {
			throw new ApiException(HttpStatus.FORBIDDEN, "ACCOUNT_SUSPENDED");
		}
		user.setLastLoginAt(clock.instant());
		return sessions.create(user);
	}

	/** Not transactional itself: the rotation transaction must commit its revocations even on 401/403. */
	public TokenResponse refresh(RefreshRequest request) {
		return sessions.continueSession(refreshTokens.rotate(request.refreshToken()));
	}

	public void logout(LogoutRequest request) {
		refreshTokens.revokeFamilyOf(request.refreshToken());
	}

	public void logoutAll(CurrentUser current) {
		refreshTokens.revokeAllForUser(current.id());
	}

}
