package com.anafitlab.backend.common.validation;

import java.time.ZoneId;
import java.util.Set;

import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;

public class TimezoneValidator implements ConstraintValidator<ValidTimezone, String> {

	private static final Set<String> ZONES = Set.copyOf(ZoneId.getAvailableZoneIds());

	@Override
	public boolean isValid(String value, ConstraintValidatorContext context) {
		// Region ids only: fixed offsets such as "+02:00" are not in this set.
		return value == null || ZONES.contains(value);
	}

}
