package com.anafitlab.backend.common.error;

import java.time.Duration;

import org.springframework.http.HttpStatus;

public class RateLimitedException extends ApiException {

	private final Duration retryAfter;

	public RateLimitedException(Duration retryAfter) {
		super(HttpStatus.TOO_MANY_REQUESTS, "RATE_LIMITED");
		this.retryAfter = retryAfter;
	}

	public Duration retryAfter() {
		return retryAfter;
	}

}
