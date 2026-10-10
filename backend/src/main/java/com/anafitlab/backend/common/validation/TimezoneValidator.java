package com.anafitlab.backend.common.validation;

import java.time.ZoneId;

import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;

public class TimezoneValidator implements ConstraintValidator<ValidTimezone, String> {

	@Override
	public boolean isValid(String value, ConstraintValidatorContext context) {
		// Region ids only: fixed offsets such as "+02:00" are not in this set.
		return value == null || ZoneId.getAvailableZoneIds().contains(value);
	}

}
