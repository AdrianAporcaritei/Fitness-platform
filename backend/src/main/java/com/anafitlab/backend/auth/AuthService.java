package com.anafitlab.backend.auth;

import java.time.Clock;
import java.time.Duration;
import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.anafitlab.backend.auth.dto.LoginRequest;
import com.anafitlab.backend.auth.dto.RegisterCoachRequest;
import com.anafitlab.backend.auth.dto.TokenResponse;
import com.anafitlab.backend.client.CoachProfile;
import com.anafitlab.backend.client.CoachProfileRepository;
import com.anafitlab.backend.common.error.ApiException;
import com.anafitlab.backend.common.ratelimit.Limit;
import com.anafitlab.backend.common.ratelimit.RateLimiter;

@Service
public class AuthService {

	private static final Limit SIGNUP_IP = new Limit(10, Duration.ofHours(1));
	private static final Limit LOGIN_EMAIL = new Limit(5, Duration.ofMinutes(15));
	private static final Limit LOGIN_IP = new Limit(20, Duration.ofMinutes(15));

	private final RateLimiter rateLimiter;
	private final UserRegistrar registrar;
	private final CoachProfileRepository coachProfiles;
	private final ActionTokenService actionTokens;
	private final AccountEmails emails;
	private final SessionFactory sessions;
	private final AppUserRepository users;
	private final PasswordEncoder passwordEncoder;
	private final Clock clock;

	/** Verified against when the email is unknown, so both failures cost the same time. */
	private final String dummyHash;

	AuthService(RateLimiter rateLimiter, UserRegistrar registrar, CoachProfileRepository coachProfiles,
			ActionTokenService actionTokens, AccountEmails emails, SessionFactory sessions, AppUserRepository users,
			PasswordEncoder passwordEncoder, Clock clock) {
		this.rateLimiter = rateLimiter;
		this.registrar = registrar;
		this.coachProfiles = coachProfiles;
		this.actionTokens = actionTokens;
		this.emails = emails;
		this.sessions = sessions;
		this.users = users;
		this.passwordEncoder = passwordEncoder;
		this.clock = clock;
		this.dummyHash = passwordEncoder.encode("dummy-password-for-timing");
	}

	@Transactional
	public TokenResponse registerCoach(RegisterCoachRequest request, String ip) {
		rateLimiter.hit("signup-ip", ip, SIGNUP_IP);
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
		String email = EmailNormalizer.normalize(request.email());
		rateLimiter.ensureUnder("login-email", email, LOGIN_EMAIL);
		rateLimiter.ensureUnder("login-ip", ip, LOGIN_IP);
		AppUser user = users.findByEmail(email).orElse(null);
		String hash = user != null ? user.getPasswordHash() : dummyHash;
		boolean matches = passwordEncoder.matches(request.password(), hash);
		if (user == null || !matches) {
			rateLimiter.record("login-email", email, LOGIN_EMAIL);
			rateLimiter.record("login-ip", ip, LOGIN_IP);
			throw new ApiException(HttpStatus.UNAUTHORIZED, "INVALID_CREDENTIALS");
		}
		if (user.getStatus() == UserStatus.SUSPENDED) {
			throw new ApiException(HttpStatus.FORBIDDEN, "ACCOUNT_SUSPENDED");
		}
		user.setLastLoginAt(clock.instant());
		return sessions.create(user);
	}

}
