package com.anafitlab.backend.auth.dto;

import com.anafitlab.backend.common.validation.ValidPassword;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record ChangePasswordRequest(@NotBlank(message = "REQUIRED") @Size(max = 200, message = "TOO_LONG") String currentPassword,
		@NotBlank(message = "REQUIRED") @ValidPassword String newPassword,
		@NotBlank(message = "REQUIRED") String refreshToken) {
}
