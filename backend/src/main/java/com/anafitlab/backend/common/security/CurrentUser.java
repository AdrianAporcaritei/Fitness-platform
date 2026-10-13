package com.anafitlab.backend.common.security;

import java.util.UUID;

import com.anafitlab.backend.auth.entity.Role;

/** The authenticated caller, taken from the access token's {@code sub} and {@code role} claims. */
public record CurrentUser(UUID id, Role role) {
}
