package com.anafitlab.backend.common.ratelimit;

import java.time.Duration;

public record Limit(int max, Duration window) {
}
