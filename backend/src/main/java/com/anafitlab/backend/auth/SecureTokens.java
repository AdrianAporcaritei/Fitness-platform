package com.anafitlab.backend.auth;

import java.security.SecureRandom;
import java.util.Base64;

public final class SecureTokens {

	private static final SecureRandom RANDOM = new SecureRandom();

	private SecureTokens() {
	}

	/** 32 random bytes as base64url without padding (43 characters). */
	public static String generate() {
		byte[] bytes = new byte[32];
		RANDOM.nextBytes(bytes);
		return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
	}

}
