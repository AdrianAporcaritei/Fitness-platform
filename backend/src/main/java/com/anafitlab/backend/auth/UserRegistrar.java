package com.anafitlab.backend.auth;

import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import com.anafitlab.backend.common.error.ApiException;
import com.anafitlab.backend.common.error.ConstraintViolations;

/** Creates PENDING accounts. Shared by coach and client signup. */
@Component
public class UserRegistrar {

	private static final String EMAIL_CONSTRAINT = "uq_app_user_email";

	private final AppUserRepository users;
	private final PasswordEncoder encoder;

	UserRegistrar(AppUserRepository users, PasswordEncoder encoder) {
		this.users = users;
		this.encoder = encoder;
	}

	@Transactional(propagation = Propagation.MANDATORY)
	public AppUser register(Role role, NewUser fields) {
		String email = EmailNormalizer.normalize(fields.email());
		if (users.existsByEmail(email)) {
			throw emailTaken();
		}
		AppUser user = new AppUser();
		user.setEmail(email);
		user.setPasswordHash(encoder.encode(fields.password()));
		user.setRole(role);
		user.setFirstName(fields.firstName());
		user.setLastName(fields.lastName());
		user.setLocale(fields.locale());
		user.setTimezone(fields.timezone());
		user.setStatus(UserStatus.PENDING);
		try {
			return users.saveAndFlush(user);
		}
		catch (DataIntegrityViolationException e) {
			if (ConstraintViolations.violates(e, EMAIL_CONSTRAINT)) {
				throw emailTaken();
			}
			throw e;
		}
	}

	private static ApiException emailTaken() {
		return new ApiException(HttpStatus.CONFLICT, "EMAIL_TAKEN");
	}

}
