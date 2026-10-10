package com.anafitlab.backend.auth;

import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.util.UUID;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class RefreshTokenService {

	static final Duration TTL = Duration.ofDays(30);

	private final RefreshTokenRepository tokens;
	private final Clock clock;

	RefreshTokenService(RefreshTokenRepository tokens, Clock clock) {
		this.tokens = tokens;
		this.clock = clock;
	}

	/** Starts a new rotation family for the user and returns its first token. */
	@Transactional
	public IssuedRefreshToken startFamily(AppUser user) {
		String raw = SecureTokens.generate();
		Instant expiresAt = clock.instant().plus(TTL);
		RefreshToken token = new RefreshToken();
		token.setUserId(user.getId());
		token.setTokenHash(TokenHasher.sha256(raw));
		token.setFamilyId(UUID.randomUUID());
		token.setExpiresAt(expiresAt);
		tokens.save(token);
		return new IssuedRefreshToken(raw, expiresAt);
	}

}
