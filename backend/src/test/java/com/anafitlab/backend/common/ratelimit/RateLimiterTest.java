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
	void retryAfterIsAtLeastOneSecond() {
		for (int i = 0; i < 3; i++) {
			limiter.hit("login", "a", LIMIT);
		}
		clock.advance(Duration.ofMinutes(15).minusMillis(1));
		assertThatThrownBy(() -> limiter.hit("login", "a", LIMIT)).isInstanceOfSatisfying(RateLimitedException.class,
				e -> assertThat(e.retryAfter()).isEqualTo(Duration.ofSeconds(1)));
	}

	@Test
	void windowBoundaryStartsFreshWindow() {
		for (int i = 0; i < 3; i++) {
			limiter.hit("login", "a", LIMIT);
		}
		clock.advance(Duration.ofMinutes(15));
		for (int i = 0; i < 3; i++) {
			limiter.hit("login", "a", LIMIT);
		}
		assertThatThrownBy(() -> limiter.hit("login", "a", LIMIT)).isInstanceOf(RateLimitedException.class);
	}

	@Test
	void sweepsExpiredEntriesOverThreshold() {
		RateLimiter small = new RateLimiter(clock, 5);
		for (int i = 0; i < 6; i++) {
			small.record("b", "k" + i, LIMIT);
		}
		assertThat(small.size()).isEqualTo(6);
		clock.advance(Duration.ofMinutes(16));
		small.record("b", "fresh", LIMIT);
		assertThat(small.size()).isEqualTo(1);
	}

	@Test
	void concurrentHitsNeverExceedMax() throws Exception {
		int n = 64;
		Limit limit = new Limit(n / 2, Duration.ofMinutes(15));
		java.util.concurrent.ExecutorService pool = java.util.concurrent.Executors.newFixedThreadPool(n);
		java.util.concurrent.CountDownLatch start = new java.util.concurrent.CountDownLatch(1);
		java.util.concurrent.atomic.AtomicInteger ok = new java.util.concurrent.atomic.AtomicInteger();
		java.util.List<java.util.concurrent.Future<?>> fs = new java.util.ArrayList<>();
		for (int i = 0; i < n; i++) {
			fs.add(pool.submit(() -> {
				start.await();
				try {
					limiter.hit("login", "a", limit);
					ok.incrementAndGet();
				}
				catch (RateLimitedException e) {
					// expected for the surplus calls
				}
				return null;
			}));
		}
		start.countDown();
		for (var f : fs) {
			f.get();
		}
		pool.shutdown();
		assertThat(ok.get()).isEqualTo(n / 2);
	}

	@Test
	void limitRejectsInvalidValues() {
		assertThatThrownBy(() -> new Limit(0, Duration.ofMinutes(1))).isInstanceOf(IllegalArgumentException.class);
		assertThatThrownBy(() -> new Limit(1, null)).isInstanceOf(IllegalArgumentException.class);
		assertThatThrownBy(() -> new Limit(1, Duration.ZERO)).isInstanceOf(IllegalArgumentException.class);
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
