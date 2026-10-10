package com.anafitlab.backend.auth;

public record RotationResult(AppUser user, IssuedRefreshToken next) {
}
