package com.anafitlab.backend.auth;

import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import com.anafitlab.backend.auth.dto.TokenResponse;
import com.anafitlab.backend.auth.dto.UserResponse;

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

}
