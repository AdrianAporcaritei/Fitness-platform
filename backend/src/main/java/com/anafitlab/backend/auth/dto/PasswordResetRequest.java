package com.anafitlab.backend.auth.dto;

import com.anafitlab.backend.auth.util.EmailNormalizer;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record PasswordResetRequest(
		@NotBlank(message = "REQUIRED") @Email(message = "INVALID_EMAIL") @Size(max = 254, message = "TOO_LONG") String email) {

	public PasswordResetRequest {
		email = EmailNormalizer.normalize(email);
	}

}
