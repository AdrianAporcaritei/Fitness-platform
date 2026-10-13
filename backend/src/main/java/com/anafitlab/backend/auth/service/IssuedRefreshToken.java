package com.anafitlab.backend.auth.service;

import java.time.Instant;

public record IssuedRefreshToken(String raw, Instant expiresAt) {
}
