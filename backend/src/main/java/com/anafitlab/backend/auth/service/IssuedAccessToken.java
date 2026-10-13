package com.anafitlab.backend.auth.service;

import java.time.Instant;

public record IssuedAccessToken(String token, Instant expiresAt) {
}
