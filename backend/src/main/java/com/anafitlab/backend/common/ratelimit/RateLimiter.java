package com.anafitlab.backend.common.ratelimit;

import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.util.concurrent.ConcurrentHashMap;

import org.springframework.stereotype.Component;

import com.anafitlab.backend.common.error.RateLimitedException;

/** In-memory fixed-window rate limiter; expired windows are evicted lazily on access. */
@Component
public class RateLimiter {

	private record Window(Instant end, int count) {
	}

	private final Clock clock;

	private final ConcurrentHashMap<String, Window> windows = new ConcurrentHashMap<>();

	public RateLimiter(Clock clock) {
		this.clock = clock;
	}

	/** Counts one attempt and throws once the count exceeds the limit. */
	public void hit(String bucket, String key, Limit limit) {
		Window w = increment(bucket, key, limit);
		if (w.count() > limit.max()) {
			throw exceeded(w);
		}
	}

	/** Throws if the limit is already reached; does not count. */
	public void ensureUnder(String bucket, String key, Limit limit) {
		Instant now = clock.instant();
		Window w = windows.computeIfPresent(bucket + ":" + key, (k, cur) -> cur.end().isAfter(now) ? cur : null);
		if (w != null && w.count() >= limit.max()) {
			throw exceeded(w);
		}
	}

	/** Counts one attempt without ever throwing. */
	public void record(String bucket, String key, Limit limit) {
		increment(bucket, key, limit);
	}

	public void reset() {
		windows.clear();
	}

	private Window increment(String bucket, String key, Limit limit) {
		Instant now = clock.instant();
		return windows.compute(bucket + ":" + key, (k, cur) -> cur == null || !cur.end().isAfter(now)
				? new Window(now.plus(limit.window()), 1) : new Window(cur.end(), cur.count() + 1));
	}

	private RateLimitedException exceeded(Window w) {
		return new RateLimitedException(Duration.between(clock.instant(), w.end()));
	}

}
