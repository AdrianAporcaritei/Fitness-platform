package com.anafitlab.backend.auth.config;

import java.time.Clock;

import com.anafitlab.backend.auth.entity.AppUser;
import com.anafitlab.backend.auth.entity.Role;
import com.anafitlab.backend.auth.entity.UserStatus;
import com.anafitlab.backend.auth.repository.AppUserRepository;
import com.anafitlab.backend.auth.util.EmailNormalizer;
import com.anafitlab.backend.common.validation.PasswordValidator;

import jakarta.validation.Validator;
import jakarta.validation.constraints.Email;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

/** Creates the first ADMIN from configuration when none exists (spec 5.12). */
@Component
public class AdminBootstrap implements ApplicationRunner {

	private static final Logger log = LoggerFactory.getLogger(AdminBootstrap.class);

	private final AdminProperties properties;
	private final AppUserRepository users;
	private final PasswordEncoder passwordEncoder;
	private final Clock clock;
	private final Validator validator;

	public AdminBootstrap(AdminProperties properties, AppUserRepository users, PasswordEncoder passwordEncoder,
			Clock clock, Validator validator) {
		this.properties = properties;
		this.users = users;
		this.passwordEncoder = passwordEncoder;
		this.clock = clock;
		this.validator = validator;
	}

	@Override
	@Transactional
	public void run(ApplicationArguments args) {
		String email = blankToNull(properties.email());
		String password = blankToNull(properties.password());
		if ((email == null) != (password == null)) {
			throw new IllegalStateException(
					"Admin bootstrap is misconfigured: app.admin.email and app.admin.password must be set together");
		}
		if (users.existsByRole(Role.ADMIN)) {
			return;
		}
		if (email == null) {
			log.warn("No ADMIN exists and app.admin.email / app.admin.password are not set; no admin was created");
			return;
		}
		String normalized = EmailNormalizer.normalize(email);
		if (!validator.validate(new EmailHolder(normalized)).isEmpty()) {
			throw new IllegalStateException("app.admin.email is not a valid email address");
		}
		if (!PasswordValidator.meetsPolicy(password)) {
			throw new IllegalStateException(
					"app.admin.password must be 10-64 characters and at most 72 UTF-8 bytes");
		}
		AppUser admin = new AppUser();
		admin.setEmail(normalized);
		admin.setPasswordHash(passwordEncoder.encode(password));
		admin.setRole(Role.ADMIN);
		admin.setFirstName("Admin");
		admin.setLastName("Admin");
		admin.setLocale("en");
		admin.setTimezone("UTC");
		admin.setStatus(UserStatus.ACTIVE);
		admin.setEmailVerifiedAt(clock.instant());
		users.save(admin);
		log.info("Created first ADMIN account {}", normalized);
	}

	private static String blankToNull(String value) {
		return value == null || value.isBlank() ? null : value;
	}

	private record EmailHolder(@Email String email) {
	}

}
