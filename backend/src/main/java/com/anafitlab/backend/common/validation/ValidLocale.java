package com.anafitlab.backend.common.validation;

import java.lang.annotation.Documented;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

import jakarta.validation.Constraint;
import jakarta.validation.Payload;

import static java.lang.annotation.ElementType.*;

/** Exactly {@code ro} or {@code en}. Null is valid. */
@Documented
@Constraint(validatedBy = LocaleValidator.class)
@Target({ FIELD, PARAMETER, RECORD_COMPONENT, METHOD })
@Retention(RetentionPolicy.RUNTIME)
public @interface ValidLocale {

	String message() default "INVALID_LOCALE";

	Class<?>[] groups() default {};

	Class<? extends Payload>[] payload() default {};

}
