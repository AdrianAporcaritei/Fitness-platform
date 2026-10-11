package com.anafitlab.backend.auth.dto;

import com.anafitlab.backend.common.validation.ValidPassword;

import jakarta.validation.constraints.NotBlank;

public record PasswordResetConfirmRequest(@NotBlank(message = "REQUIRED") String token,
		@NotBlank(message = "REQUIRED") @ValidPassword String newPassword) {
}
