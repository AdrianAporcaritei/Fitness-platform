package com.anafitlab.backend.auth;

import java.time.Instant;

public record IssuedRefreshToken(String raw, Instant expiresAt) {
}
