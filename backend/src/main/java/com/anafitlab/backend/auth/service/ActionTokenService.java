package com.anafitlab.backend.auth.service;

import java.time.Clock;
import java.time.Duration;
import java.time.Instant;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.anafitlab.backend.auth.entity.ActionTokenPurpose;
import com.anafitlab.backend.auth.entity.AppUser;
import com.anafitlab.backend.auth.entity.UserActionToken;
import com.anafitlab.backend.auth.repository.AppUserRepository;
import com.anafitlab.backend.auth.repository.UserActionTokenRepository;
import com.anafitlab.backend.auth.util.SecureTokens;
import com.anafitlab.backend.auth.util.TokenHasher;
import com.anafitlab.backend.common.error.ApiException;

@Service
public class ActionTokenService {

	private final UserActionTokenRepository tokens;
	private final AppUserRepository users;
	private final Clock clock;

	ActionTokenService(UserActionTokenRepository tokens, AppUserRepository users, Clock clock) {
		this.tokens = tokens;
		this.users = users;
		this.clock = clock;
	}

	/** Issues a single-use token, invalidating earlier unused tokens of the same purpose. Returns the raw token. */
	@Transactional
	public String issue(AppUser user, ActionTokenPurpose purpose) {
		Instant now = clock.instant();
		tokens.invalidateUnused(user.getId(), purpose, now);
		String raw = SecureTokens.generate();
		UserActionToken token = new UserActionToken();
		token.setUserId(user.getId());
		token.setPurpose(purpose);
		token.setTokenHash(TokenHasher.sha256(raw));
		token.setExpiresAt(now.plus(ttl(purpose)));
		tokens.save(token);
		return raw;
	}

	/**
	 * Marks a token used and returns its user. Unknown, wrong-purpose, used and expired tokens are
	 * indistinguishable (400 INVALID_TOKEN). The token row is locked so concurrent consumers cannot both succeed.
	 */
	@Transactional
	public AppUser consume(String raw, ActionTokenPurpose purpose) {
		Instant now = clock.instant();
		UserActionToken token = tokens.lockByTokenHashAndPurpose(TokenHasher.sha256(raw), purpose)
				.filter(t -> t.getUsedAt() == null && now.isBefore(t.getExpiresAt()))
				.orElseThrow(ActionTokenService::invalid);
		AppUser user = users.findById(token.getUserId()).orElseThrow(ActionTokenService::invalid);
		token.setUsedAt(now);
		tokens.save(token);
		return user;
	}

	private static ApiException invalid() {
		return new ApiException(HttpStatus.BAD_REQUEST, "INVALID_TOKEN");
	}

	private static Duration ttl(ActionTokenPurpose purpose) {
		return switch (purpose) {
			case EMAIL_VERIFICATION -> Duration.ofHours(48);
			case PASSWORD_RESET -> Duration.ofHours(1);
		};
	}

}
