package com.anafitlab.backend.common.ratelimit;

import java.time.Duration;

public record Limit(int max, Duration window) {

	public Limit {
		if (max <= 0) {
			throw new IllegalArgumentException("max must be positive");
		}
		if (window == null || window.isZero() || window.isNegative()) {
			throw new IllegalArgumentException("window must be positive");
		}
	}

}
