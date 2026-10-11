package com.anafitlab.backend.common.validation;

import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;

public class LocaleValidator implements ConstraintValidator<ValidLocale, String> {

	@Override
	public boolean isValid(String value, ConstraintValidatorContext context) {
		return value == null || value.equals("ro") || value.equals("en");
	}

}
