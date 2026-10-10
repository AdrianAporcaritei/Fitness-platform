package com.anafitlab.backend.client.dto;

import java.util.List;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/** Null fields are left unchanged. */
public record UpdateCoachProfileRequest(@Size(max = 2000, message = "TOO_LONG") String bio,
		@Size(max = 20, message = "TOO_MANY") List<@NotBlank(message = "REQUIRED") @Size(max = 50, message = "TOO_LONG") String> specializations) {
}
