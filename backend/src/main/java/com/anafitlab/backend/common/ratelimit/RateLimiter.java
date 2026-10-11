package com.anafitlab.backend.common.ratelimit;

import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.util.concurrent.ConcurrentHashMap;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.anafitlab.backend.common.error.RateLimitedException;

/** In-memory fixed-window rate limiter; expired windows are evicted lazily and by a size-triggered sweep. */
@Component
public class RateLimiter {

	static final int SWEEP_THRESHOLD = 10_000;

	private static final Duration MIN_RETRY_AFTER = Duration.ofSeconds(1);

	private record Window(Instant end, int count) {
	}

	private final Clock clock;

	private final int sweepThreshold;

	private final ConcurrentHashMap<String, Window> windows = new ConcurrentHashMap<>();

	@Autowired
	public RateLimiter(Clock clock) {
		this(clock, SWEEP_THRESHOLD);
	}

	RateLimiter(Clock clock, int sweepThreshold) {
		this.clock = clock;
		this.sweepThreshold = sweepThreshold;
	}

	/** Counts one attempt and throws once the count exceeds the limit. */
	public void hit(String bucket, String key, Limit limit) {
		Instant now = clock.instant();
		Window w = increment(bucket, key, limit, now);
		if (w.count() > limit.max()) {
			throw exceeded(w, now);
		}
	}

	/** Gives back one attempt counted by {@link #hit} in the current window, such as a login that succeeded. */
	public void refund(String bucket, String key) {
		Instant now = clock.instant();
		windows.computeIfPresent(bucket + ":" + key, (k, cur) -> cur.end().isAfter(now) && cur.count() > 0
				? new Window(cur.end(), cur.count() - 1) : cur);
	}

	public void reset() {
		windows.clear();
	}

	int size() {
		return windows.size();
	}

	private Window increment(String bucket, String key, Limit limit, Instant now) {
		if (windows.size() > sweepThreshold) {
			windows.values().removeIf(w -> !w.end().isAfter(now));
		}
		return windows.compute(bucket + ":" + key, (k, cur) -> cur == null || !cur.end().isAfter(now)
				? new Window(now.plus(limit.window()), 1) : new Window(cur.end(), cur.count() + 1));
	}

	private RateLimitedException exceeded(Window w, Instant now) {
		Duration remaining = Duration.between(now, w.end());
		return new RateLimitedException(remaining.compareTo(MIN_RETRY_AFTER) < 0 ? MIN_RETRY_AFTER : remaining);
	}

}
