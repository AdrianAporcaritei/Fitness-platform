package com.anafitlab.backend.auth;

import java.time.Instant;

public record IssuedAccessToken(String token, Instant expiresAt) {
}
