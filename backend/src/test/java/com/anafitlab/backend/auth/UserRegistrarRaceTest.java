package com.anafitlab.backend.auth;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.doReturn;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.bean.override.mockito.MockitoSpyBean;
import org.springframework.transaction.support.TransactionTemplate;

import com.anafitlab.backend.auth.entity.Role;
import com.anafitlab.backend.auth.repository.AppUserRepository;
import com.anafitlab.backend.auth.service.NewUser;
import com.anafitlab.backend.auth.service.UserRegistrar;
import com.anafitlab.backend.common.error.ApiException;
import com.anafitlab.backend.support.IntegrationTestBase;

class UserRegistrarRaceTest extends IntegrationTestBase {

	@Autowired
	UserRegistrar registrar;

	@Autowired
	TransactionTemplate tx;

	@Autowired
	JdbcTemplate jdbc;

	@MockitoSpyBean
	AppUserRepository users;

	@Test
	void uniqueViolationOnFlushMapsToEmailTaken() {
		jdbc.update("""
				INSERT INTO app_user (id, email, password_hash, role, first_name, last_name, locale, timezone, status)
				VALUES (gen_random_uuid(), 'race@x.test', 'x', 'COACH', 'R', 'R', 'en', 'UTC', 'PENDING')""");
		// a concurrent signup committed after our existsByEmail check
		doReturn(false).when(users).existsByEmail(anyString());
		NewUser fields = new NewUser("race@x.test", "correct-horse-1", "A", "B", "en", "Europe/Bucharest");

		assertThatThrownBy(() -> tx.executeWithoutResult(s -> registrar.register(Role.COACH, fields)))
				.isInstanceOfSatisfying(ApiException.class, e -> assertThat(e.code()).isEqualTo("EMAIL_TAKEN"));
	}

}
