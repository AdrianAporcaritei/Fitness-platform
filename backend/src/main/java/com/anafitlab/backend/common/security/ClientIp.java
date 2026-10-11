package com.anafitlab.backend.common.security;

import jakarta.servlet.http.HttpServletRequest;

/** The caller's address for rate limiting. Forwarded headers are deliberately ignored in this slice. */
public final class ClientIp {

	private ClientIp() {
	}

	public static String of(HttpServletRequest request) {
		return request.getRemoteAddr();
	}

}
