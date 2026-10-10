package com.anafitlab.backend.auth.dto;

import jakarta.validation.constraints.NotBlank;

public record LogoutRequest(@NotBlank(message = "REQUIRED") String refreshToken) {
}
