package com.anafitlab.backend.common.validation;

import java.nio.charset.StandardCharsets;

import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;

public class PasswordValidator implements ConstraintValidator<ValidPassword, String> {

	@Override
	public boolean isValid(String value, ConstraintValidatorContext context) {
		if (value == null) {
			return true;
		}
		return meetsPolicy(value);
	}

	/** The password policy itself, for callers outside bean validation. */
	public static boolean meetsPolicy(String value) {
		int codePoints = value.codePointCount(0, value.length());
		return codePoints >= 10 && codePoints <= 64 && value.getBytes(StandardCharsets.UTF_8).length <= 72;
	}

}
