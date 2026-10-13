package com.anafitlab.backend.client.dto;

import com.anafitlab.backend.auth.EmailNormalizer;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record AddClientRequest(@NotBlank(message = "REQUIRED") @Size(max = 100, message = "TOO_LONG") String name,
		@NotBlank(message = "REQUIRED") @Email(message = "INVALID_EMAIL") @Size(max = 254, message = "TOO_LONG") String email) {

	/** Surrounding whitespace is not significant, and email case neither, so they are dropped before validation. */
	public AddClientRequest {
		name = name == null ? null : name.strip();
		email = EmailNormalizer.normalize(email);
	}

}
