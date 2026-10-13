package com.anafitlab.backend.auth.dto;

import com.anafitlab.backend.auth.util.EmailNormalizer;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record LoginRequest(
		@NotBlank(message = "REQUIRED") @Size(max = 254, message = "TOO_LONG") String email,
		@NotBlank(message = "REQUIRED") @Size(max = 200, message = "TOO_LONG") String password) {

	public LoginRequest {
		email = EmailNormalizer.normalize(email);
	}

}
