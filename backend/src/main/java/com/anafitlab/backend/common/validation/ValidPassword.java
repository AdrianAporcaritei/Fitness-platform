package com.anafitlab.backend.common.validation;

import java.lang.annotation.Documented;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

import jakarta.validation.Constraint;
import jakarta.validation.Payload;

import static java.lang.annotation.ElementType.*;

/** 10-64 code points and at most 72 UTF-8 bytes (bcrypt limit). Null is valid. */
@Documented
@Constraint(validatedBy = PasswordValidator.class)
@Target({ FIELD, PARAMETER, RECORD_COMPONENT, METHOD })
@Retention(RetentionPolicy.RUNTIME)
public @interface ValidPassword {

	String message() default "PASSWORD_POLICY";

	Class<?>[] groups() default {};

	Class<? extends Payload>[] payload() default {};

}
