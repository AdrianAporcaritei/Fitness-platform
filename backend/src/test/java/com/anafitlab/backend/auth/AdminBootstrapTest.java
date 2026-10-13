package com.anafitlab.backend.auth;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.time.Clock;
import java.util.Map;

import jakarta.validation.Validator;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.web.servlet.MockMvc;

import com.anafitlab.backend.auth.config.AdminBootstrap;
import com.anafitlab.backend.auth.config.AdminProperties;
import com.anafitlab.backend.auth.entity.AppUser;
import com.anafitlab.backend.auth.entity.Role;
import com.anafitlab.backend.auth.entity.UserStatus;
import com.anafitlab.backend.auth.repository.AppUserRepository;
import com.anafitlab.backend.common.validation.PasswordValidator;
import com.anafitlab.backend.support.IntegrationTestBase;
import tools.jackson.databind.json.JsonMapper;

class AdminBootstrapTest extends IntegrationTestBase {

	@Autowired
	AppUserRepository users;

	@Autowired
	PasswordEncoder encoder;

	@Autowired
	Clock clock;

	@Autowired
	Validator validator;

	@Autowired
	MockMvc mockMvc;

	@Autowired
	JdbcTemplate jdbc;

	@Autowired
	JsonMapper json;

	private AdminBootstrap bootstrap(String email, String password) {
		return new AdminBootstrap(new AdminProperties(email, password), users, encoder, clock, validator);
	}

	private long adminCount() {
		return jdbc.queryForObject("select count(*) from app_user where role = 'ADMIN'", Long.class);
	}

	@Test
	void createsAdminWhenNoneExists() throws Exception {
		bootstrap(" Admin@Example.com ", "admin-password-1").run(null);

		AppUser admin = users.findAll().get(0);
		assertThat(admin.getRole()).isEqualTo(Role.ADMIN);
		assertThat(admin.getStatus()).isEqualTo(UserStatus.ACTIVE);
		assertThat(admin.getEmail()).isEqualTo("admin@example.com");
		assertThat(admin.getEmailVerifiedAt()).isEqualTo(clock.instant());
		assertThat(admin.getFirstName()).isEqualTo("Admin");
		assertThat(admin.getLocale()).isEqualTo("en");
		assertThat(admin.getTimezone()).isEqualTo("UTC");
		mockMvc.perform(post("/api/v1/auth/login").contentType(MediaType.APPLICATION_JSON)
				.content(json.writeValueAsString(Map.of("email", "admin@example.com", "password", "admin-password-1"))))
				.andExpect(status().isOk());
	}

	@Test
	void doesNothingWhenAdminExists() throws Exception {
		bootstrap("first@example.com", "admin-password-1").run(null);
		bootstrap("second@example.com", "admin-password-2").run(null);

		assertThat(adminCount()).isEqualTo(1);
		assertThat(users.findAll().get(0).getEmail()).isEqualTo("first@example.com");
	}

	@Test
	void skipsWhenNotConfigured() {
		assertThatCode(() -> bootstrap("", "").run(null)).doesNotThrowAnyException();
		assertThatCode(() -> bootstrap(null, "  ").run(null)).doesNotThrowAnyException();
		assertThat(adminCount()).isZero();
	}

	@Test
	void rejectsWeakPassword() {
		assertThatThrownBy(() -> bootstrap("admin@example.com", "short").run(null))
				.isInstanceOf(IllegalStateException.class);
		assertThat(adminCount()).isZero();
	}

	@Test
	void rejectsMalformedEmail() {
		assertThatThrownBy(() -> bootstrap("not-an-email", "admin-password-1").run(null))
				.isInstanceOf(IllegalStateException.class);
	}

	@Test
	void rejectsHalfConfigurationNamingBothProperties() {
		assertThatThrownBy(() -> bootstrap("admin@example.com", " ").run(null))
				.isInstanceOf(IllegalStateException.class)
				.hasMessageContaining("app.admin.email").hasMessageContaining("app.admin.password");
		assertThatThrownBy(() -> bootstrap("", "admin-password-1").run(null))
				.isInstanceOf(IllegalStateException.class);
	}

	@Test
	void localProfileValuesPassThePolicy() {
		assertThat(PasswordValidator.meetsPolicy("admin-dev-password")).isTrue();
		bootstrap("admin@local.test", "admin-dev-password").run(null);
		assertThat(adminCount()).isEqualTo(1);
	}

}
