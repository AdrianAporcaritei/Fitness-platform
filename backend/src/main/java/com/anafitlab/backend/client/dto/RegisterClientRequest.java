package com.anafitlab.backend.client.dto;

import com.anafitlab.backend.auth.service.NewUser;
import com.anafitlab.backend.auth.util.EmailNormalizer;
import com.anafitlab.backend.common.validation.ValidLocale;
import com.anafitlab.backend.common.validation.ValidPassword;
import com.anafitlab.backend.common.validation.ValidTimezone;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record RegisterClientRequest(
		@NotBlank(message = "REQUIRED") String code,
		@NotBlank(message = "REQUIRED") @Email(message = "INVALID_EMAIL") @Size(max = 254, message = "TOO_LONG") String email,
		@NotBlank(message = "REQUIRED") @ValidPassword String password,
		@NotBlank(message = "REQUIRED") @Size(max = 100, message = "TOO_LONG") String firstName,
		@NotBlank(message = "REQUIRED") @Size(max = 100, message = "TOO_LONG") String lastName,
		@NotBlank(message = "REQUIRED") @ValidLocale String locale,
		@NotBlank(message = "REQUIRED") @ValidTimezone String timezone) {

	/** Surrounding whitespace and case in the email are not significant, so they are dropped before validation. */
	public RegisterClientRequest {
		email = EmailNormalizer.normalize(email);
	}

	public NewUser toNewUser() {
		return new NewUser(email, password, firstName, lastName, locale, timezone);
	}

}
