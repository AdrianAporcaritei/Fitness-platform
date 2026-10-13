package com.anafitlab.backend.auth.service;

import com.anafitlab.backend.auth.entity.AppUser;

public record RotationResult(AppUser user, IssuedRefreshToken next) {
}
