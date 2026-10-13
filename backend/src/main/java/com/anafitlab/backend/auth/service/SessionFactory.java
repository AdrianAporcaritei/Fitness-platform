package com.anafitlab.backend.auth.service;

import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import com.anafitlab.backend.auth.dto.TokenResponse;
import com.anafitlab.backend.auth.dto.UserResponse;
import com.anafitlab.backend.auth.entity.AppUser;

/** Opens a session: an access token plus the first refresh token of a new family. */
@Component
public class SessionFactory {

	private final AccessTokenIssuer accessTokens;
	private final RefreshTokenService refreshTokens;

	SessionFactory(AccessTokenIssuer accessTokens, RefreshTokenService refreshTokens) {
		this.accessTokens = accessTokens;
		this.refreshTokens = refreshTokens;
	}

	@Transactional
	public TokenResponse create(AppUser user) {
		IssuedAccessToken access = accessTokens.issue(user);
		IssuedRefreshToken refresh = refreshTokens.startFamily(user);
		return new TokenResponse(access.token(), access.expiresAt(), refresh.raw(), refresh.expiresAt(),
				UserResponse.from(user));
	}

	/** Continues an existing session after rotation: same family, new refresh token. */
	public TokenResponse continueSession(RotationResult rotation) {
		IssuedAccessToken access = accessTokens.issue(rotation.user());
		IssuedRefreshToken refresh = rotation.next();
		return new TokenResponse(access.token(), access.expiresAt(), refresh.raw(), refresh.expiresAt(),
				UserResponse.from(rotation.user()));
	}

}
