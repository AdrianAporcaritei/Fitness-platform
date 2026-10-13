package com.anafitlab.backend.auth;

import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.Matchers.hasItem;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.sql.Timestamp;
import java.time.Duration;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.ResultActions;

import com.anafitlab.backend.auth.entity.ActionTokenPurpose;
import com.anafitlab.backend.auth.entity.AppUser;
import com.anafitlab.backend.auth.entity.Role;
import com.anafitlab.backend.auth.entity.UserStatus;
import com.anafitlab.backend.auth.repository.AppUserRepository;
import com.anafitlab.backend.auth.service.ActionTokenService;
import com.anafitlab.backend.support.IntegrationTestBase;
import com.anafitlab.backend.support.MutableClock;
import com.anafitlab.backend.support.RecordingEmailSender;
import com.anafitlab.backend.support.TestFixtures;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.json.JsonMapper;

class EmailVerificationTest extends IntegrationTestBase {

	private static final String EMAIL = "new@x.test";

	@Autowired
	MockMvc mockMvc;

	@Autowired
	TestFixtures fixtures;

	@Autowired
	MutableClock clock;

	@Autowired
	JdbcTemplate jdbc;

	@Autowired
	JsonMapper json;

	@Autowired
	RecordingEmailSender emails;

	@Autowired
	ActionTokenService actionTokens;

	@Autowired
	AppUserRepository users;

	/** Signs up and returns the access token. */
	private String signup() throws Exception {
		String body = mockMvc.perform(post("/api/v1/auth/register/coach").contentType(MediaType.APPLICATION_JSON)
				.content(json.writeValueAsString(Map.of("email", EMAIL, "password", TestFixtures.PASSWORD,
						"firstName", "Ana", "lastName", "Pop", "locale", "en", "timezone", "Europe/Bucharest"))))
				.andExpect(status().isCreated()).andReturn().getResponse().getContentAsString();
		return json.readTree(body).get("accessToken").asString();
	}

	private String emailedToken() {
		return emails.extractToken(emails.lastTo(EMAIL));
	}

	private ResultActions verify(String token) throws Exception {
		return mockMvc.perform(post("/api/v1/auth/verify-email").contentType(MediaType.APPLICATION_JSON)
				.content(json.writeValueAsString(Map.of("token", token))));
	}

	private ResultActions resend(String access) throws Exception {
		return mockMvc.perform(post("/api/v1/auth/verify-email/resend")
				.header("Authorization", "Bearer " + access));
	}

	private JsonNode me(String access) throws Exception {
		return json.readTree(mockMvc.perform(get("/api/v1/me").header("Authorization", "Bearer " + access))
				.andExpect(status().isOk()).andReturn().getResponse().getContentAsString());
	}

	@Test
	void verifyActivatesUser() throws Exception {
		String access = signup();
		assertThat(me(access).get("status").asString()).isEqualTo("PENDING");
		verify(emailedToken()).andExpect(status().isNoContent());
		assertThat(me(access).get("status").asString()).isEqualTo("ACTIVE");
		Timestamp verifiedAt = jdbc.queryForObject("SELECT email_verified_at FROM app_user WHERE email = ?",
				Timestamp.class, EMAIL);
		assertThat(verifiedAt.toInstant()).isEqualTo(clock.instant());
	}

	@Test
	void tokenIsSingleUse() throws Exception {
		signup();
		String token = emailedToken();
		verify(token).andExpect(status().isNoContent());
		verify(token).andExpect(status().isBadRequest()).andExpect(jsonPath("$.code").value("INVALID_TOKEN"));
	}

	@Test
	void tokenExpiresAfter48h() throws Exception {
		signup();
		String token = emailedToken();
		clock.advance(Duration.ofHours(48).plusSeconds(1));
		verify(token).andExpect(status().isBadRequest()).andExpect(jsonPath("$.code").value("INVALID_TOKEN"));
	}

	@Test
	void unknownAndBlankTokens() throws Exception {
		verify("nope").andExpect(status().isBadRequest()).andExpect(jsonPath("$.code").value("INVALID_TOKEN"));
		verify(" ").andExpect(status().isBadRequest())
				.andExpect(jsonPath("$.errors[?(@.field=='token')].code").value(hasItem("REQUIRED")));
	}

	@Test
	void resendInvalidatesOlderToken() throws Exception {
		String access = signup();
		String old = emailedToken();
		resend(access).andExpect(status().isNoContent());
		String fresh = emailedToken();
		assertThat(fresh).isNotEqualTo(old);
		verify(old).andExpect(status().isBadRequest()).andExpect(jsonPath("$.code").value("INVALID_TOKEN"));
		verify(fresh).andExpect(status().isNoContent());
	}

	@Test
	void resendRateLimited() throws Exception {
		String access = signup();
		for (int i = 0; i < 3; i++) {
			resend(access).andExpect(status().isNoContent());
		}
		resend(access).andExpect(status().isTooManyRequests());
	}

	@Test
	void resendForActiveUserIsNoOpButCounts() throws Exception {
		AppUser user = fixtures.user(Role.COACH, UserStatus.ACTIVE, "active@x.test");
		String bearer = fixtures.bearer(user);
		for (int i = 0; i < 3; i++) {
			mockMvc.perform(post("/api/v1/auth/verify-email/resend").header("Authorization", bearer))
					.andExpect(status().isNoContent());
		}
		assertThat(emails.lastTo("active@x.test")).isNull();
		mockMvc.perform(post("/api/v1/auth/verify-email/resend").header("Authorization", bearer))
				.andExpect(status().isTooManyRequests());
	}

	@Test
	void resendRequiresAuthentication() throws Exception {
		mockMvc.perform(post("/api/v1/auth/verify-email/resend")).andExpect(status().isUnauthorized());
	}

	@Test
	void suspendedStaysSuspended() throws Exception {
		signup();
		String token = emailedToken();
		jdbc.update("UPDATE app_user SET status = 'SUSPENDED' WHERE email = ?", EMAIL);
		verify(token).andExpect(status().isNoContent());
		assertThat(jdbc.queryForObject("SELECT status FROM app_user WHERE email = ?", String.class, EMAIL))
				.isEqualTo("SUSPENDED");
		assertThat(jdbc.queryForObject("SELECT email_verified_at FROM app_user WHERE email = ?", Timestamp.class,
				EMAIL).toInstant()).isEqualTo(clock.instant());
	}

	@Test
	void resetTokenCannotVerify() throws Exception {
		AppUser user = fixtures.user(Role.COACH, UserStatus.PENDING, "p@x.test");
		String raw = actionTokens.issue(user, ActionTokenPurpose.PASSWORD_RESET);
		verify(raw).andExpect(status().isBadRequest()).andExpect(jsonPath("$.code").value("INVALID_TOKEN"));
		assertThat(users.findById(user.getId()).orElseThrow().getStatus()).isEqualTo(UserStatus.PENDING);
	}

	@Test
	void concurrentVerificationsSucceedOnce() throws Exception {
		signup();
		String token = emailedToken();
		int n = 4;
		ExecutorService pool = Executors.newFixedThreadPool(n);
		CountDownLatch go = new CountDownLatch(1);
		List<Future<Integer>> results = new ArrayList<>();
		for (int i = 0; i < n; i++) {
			results.add(pool.submit(() -> {
				go.await();
				return verify(token).andReturn().getResponse().getStatus();
			}));
		}
		go.countDown();
		int ok = 0;
		for (Future<Integer> f : results) {
			int s = f.get();
			assertThat(s).isIn(204, 400);
			if (s == 204) {
				ok++;
			}
		}
		pool.shutdown();
		assertThat(ok).isEqualTo(1);
	}

}
