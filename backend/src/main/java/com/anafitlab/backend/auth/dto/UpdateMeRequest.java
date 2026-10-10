package com.anafitlab.backend.auth.dto;

import com.anafitlab.backend.common.validation.ValidLocale;
import com.anafitlab.backend.common.validation.ValidTimezone;

import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

/** Every field is optional; null means unchanged. A present name must not be blank. */
public record UpdateMeRequest(
		@Pattern(regexp = ".*\\S.*", message = "REQUIRED") @Size(max = 100, message = "TOO_LONG") String firstName,
		@Pattern(regexp = ".*\\S.*", message = "REQUIRED") @Size(max = 100, message = "TOO_LONG") String lastName,
		@ValidLocale String locale, @ValidTimezone String timezone) {
}
