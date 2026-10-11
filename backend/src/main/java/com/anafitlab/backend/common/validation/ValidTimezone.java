package com.anafitlab.backend.common.validation;

import java.lang.annotation.Documented;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

import jakarta.validation.Constraint;
import jakarta.validation.Payload;

import static java.lang.annotation.ElementType.*;

/** A region-based IANA zone id (not a fixed offset). Null is valid. */
@Documented
@Constraint(validatedBy = TimezoneValidator.class)
@Target({ FIELD, PARAMETER, RECORD_COMPONENT, METHOD })
@Retention(RetentionPolicy.RUNTIME)
public @interface ValidTimezone {

	String message() default "INVALID_TIMEZONE";

	Class<?>[] groups() default {};

	Class<? extends Payload>[] payload() default {};

}
