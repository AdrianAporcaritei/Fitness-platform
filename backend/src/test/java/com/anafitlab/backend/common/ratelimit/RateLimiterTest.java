package com.anafitlab.backend.common.ratelimit;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import java.time.Duration;
import java.time.Instant;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import com.anafitlab.backend.common.error.RateLimitedException;
import com.anafitlab.backend.support.MutableClock;

class RateLimiterTest {

	private static final Limit LIMIT = new Limit(3, Duration.ofMinutes(15));

	private MutableClock clock;

	private RateLimiter limiter;

	@BeforeEach
	void setUp() {
		clock = new MutableClock(Instant.parse("2026-01-01T00:00:00Z"));
		limiter = new RateLimiter(clock);
	}

	@Test
	void hitAllowsMaxThenThrowsWithRemainingWindow() {
		for (int i = 0; i < 3; i++) {
			limiter.hit("login", "a", LIMIT);
		}
		clock.advance(Duration.ofMinutes(5));
		assertThatThrownBy(() -> limiter.hit("login", "a", LIMIT)).isInstanceOfSatisfying(RateLimitedException.class,
				e -> assertThat(e.retryAfter()).isEqualTo(Duration.ofMinutes(10)));
	}

	@Test
	void allowsAgainAfterWindow() {
		for (int i = 0; i < 3; i++) {
			limiter.hit("login", "a", LIMIT);
		}
		clock.advance(Duration.ofMinutes(15));
		assertThatCode(() -> limiter.hit("login", "a", LIMIT)).doesNotThrowAnyException();
	}

	@Test
	void ensureUnderDoesNotCount() {
		for (int i = 0; i < 10; i++) {
			limiter.ensureUnder("login", "a", LIMIT);
		}
		for (int i = 0; i < 3; i++) {
			limiter.hit("login", "a", LIMIT);
		}
		assertThatThrownBy(() -> limiter.ensureUnder("login", "a", LIMIT)).isInstanceOf(RateLimitedException.class);
	}

	@Test
	void recordIncrementsWithoutThrowing() {
		for (int i = 0; i < 5; i++) {
			limiter.record("login", "a", LIMIT);
		}
		assertThatThrownBy(() -> limiter.ensureUnder("login", "a", LIMIT)).isInstanceOf(RateLimitedException.class);
	}

	@Test
	void keysAndBucketsAreIndependent() {
		for (int i = 0; i < 3; i++) {
			limiter.hit("login", "a", LIMIT);
		}
		assertThatCode(() -> limiter.hit("login", "b", LIMIT)).doesNotThrowAnyException();
		assertThatCode(() -> limiter.hit("signup", "a", LIMIT)).doesNotThrowAnyException();
	}

	@Test
	void resetClearsCounters() {
		for (int i = 0; i < 3; i++) {
			limiter.hit("login", "a", LIMIT);
		}
		limiter.reset();
		assertThatCode(() -> limiter.hit("login", "a", LIMIT)).doesNotThrowAnyException();
	}

}
