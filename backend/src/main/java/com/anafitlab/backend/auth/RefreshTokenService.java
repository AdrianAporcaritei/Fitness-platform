package com.anafitlab.backend.auth;

import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.util.UUID;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.anafitlab.backend.common.error.ApiException;

@Service
public class RefreshTokenService {

	static final Duration TTL = Duration.ofDays(30);

	private final RefreshTokenRepository tokens;
	private final AppUserRepository users;
	private final Clock clock;

	RefreshTokenService(RefreshTokenRepository tokens, AppUserRepository users, Clock clock) {
		this.tokens = tokens;
		this.users = users;
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

	/**
	 * Exchanges a refresh token for the next one in the same family. A token that was already rotated is
	 * reuse (likely theft): its whole family is revoked. Revocations must commit even though a 401/403 is
	 * returned, hence noRollbackFor. Revoke calls clear the persistence context, so nothing is modified
	 * after them.
	 */
	@Transactional(noRollbackFor = ApiException.class)
	public RotationResult rotate(String raw) {
		Instant now = clock.instant();
		RefreshToken current = tokens.findByTokenHashForUpdate(TokenHasher.sha256(raw))
				.orElseThrow(() -> new ApiException(HttpStatus.UNAUTHORIZED, "INVALID_REFRESH_TOKEN"));
		if (current.getReplacedById() != null) {
			tokens.revokeFamily(current.getFamilyId(), now);
			throw new ApiException(HttpStatus.UNAUTHORIZED, "REFRESH_TOKEN_REUSED");
		}
		if (current.getRevokedAt() != null || !now.isBefore(current.getExpiresAt())) {
			throw new ApiException(HttpStatus.UNAUTHORIZED, "INVALID_REFRESH_TOKEN");
		}
		AppUser user = users.findById(current.getUserId())
				.orElseThrow(() -> new ApiException(HttpStatus.UNAUTHORIZED, "INVALID_REFRESH_TOKEN"));
		if (user.getStatus() == UserStatus.SUSPENDED) {
			tokens.revokeFamily(current.getFamilyId(), now);
			throw new ApiException(HttpStatus.FORBIDDEN, "ACCOUNT_SUSPENDED");
		}
		String nextRaw = SecureTokens.generate();
		Instant expiresAt = now.plus(TTL);
		RefreshToken next = new RefreshToken();
		next.setUserId(user.getId());
		next.setTokenHash(TokenHasher.sha256(nextRaw));
		next.setFamilyId(current.getFamilyId());
		next.setExpiresAt(expiresAt);
		tokens.saveAndFlush(next);
		current.setRevokedAt(now);
		current.setReplacedById(next.getId());
		tokens.save(current);
		return new RotationResult(user, new IssuedRefreshToken(nextRaw, expiresAt));
	}

	/** Logout: revokes the family of the token. Unknown tokens are ignored. */
	@Transactional
	public void revokeFamilyOf(String raw) {
		tokens.findByTokenHash(TokenHasher.sha256(raw))
				.ifPresent(t -> tokens.revokeFamily(t.getFamilyId(), clock.instant()));
	}

	@Transactional
	public void revokeAllForUser(UUID userId) {
		tokens.revokeAllForUser(userId, clock.instant());
	}

	/**
	 * Revokes every session of the user except the one the token belongs to. If the token is not one of the
	 * user's, nothing is kept: all sessions are revoked.
	 */
	@Transactional
	public void revokeAllExceptFamilyOf(UUID userId, String raw) {
		Instant now = clock.instant();
		tokens.findByTokenHash(TokenHasher.sha256(raw)).filter(t -> t.getUserId().equals(userId))
				.ifPresentOrElse(t -> tokens.revokeAllForUserExceptFamily(userId, t.getFamilyId(), now),
						() -> tokens.revokeAllForUser(userId, now));
	}

}
