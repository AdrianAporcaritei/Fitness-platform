package com.anafitlab.backend.auth;

import java.time.Clock;
import java.time.Duration;
import java.time.Instant;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class ActionTokenService {

	private final UserActionTokenRepository tokens;
	private final Clock clock;

	ActionTokenService(UserActionTokenRepository tokens, Clock clock) {
		this.tokens = tokens;
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

	private static Duration ttl(ActionTokenPurpose purpose) {
		return switch (purpose) {
			case EMAIL_VERIFICATION -> Duration.ofHours(48);
			case PASSWORD_RESET -> Duration.ofHours(1);
		};
	}

}
