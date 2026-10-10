package com.anafitlab.backend.auth.dto;

import jakarta.validation.constraints.NotBlank;

public record VerifyEmailRequest(@NotBlank(message = "REQUIRED") String token) {
}
