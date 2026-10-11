package com.anafitlab.backend.auth;

import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.Matchers.hasItem;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
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
import java.util.concurrent.TimeUnit;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;
import org.springframework.test.web.servlet.request.MockHttpServletRequestBuilder;

import com.anafitlab.backend.common.mail.OutgoingEmail;
import com.anafitlab.backend.support.IntegrationTestBase;
import com.anafitlab.backend.support.MutableClock;
import com.anafitlab.backend.support.RecordingEmailSender;
import com.anafitlab.backend.support.TestFixtures;
import tools.jackson.databind.json.JsonMapper;
import tools.jackson.databind.node.ObjectNode;

class CoachSignupAndLoginTest extends IntegrationTestBase {

	@Autowired
	MockMvc mockMvc;

	@Autowired
	TestFixtures fixtures;

	@Autowired
	MutableClock clock;

	@Autowired
	JdbcTemplate jdbc;

	@Autowired
	RecordingEmailSender emails;

	@Autowired
	JsonMapper json;

	private MockHttpServletRequestBuilder signup(String email, String password, String locale, String timezone,
			String ip) throws Exception {
		return post("/api/v1/auth/register/coach").contentType(MediaType.APPLICATION_JSON)
				.with(r -> {
					r.setRemoteAddr(ip);
					return r;
				})
				.content(json.writeValueAsString(Map.of("email", email, "password", password, "firstName", "Ana",
						"lastName", "Pop", "locale", locale, "timezone", timezone)));
	}

	private MockHttpServletRequestBuilder signup(String email) throws Exception {
		return signup(email, "correct-horse-1", "en", "Europe/Bucharest", "10.0.0.1");
	}

	private MockHttpServletRequestBuilder login(String email, String password) throws Exception {
		return login(email, password, "10.0.0.1");
	}

	private MockHttpServletRequestBuilder login(String email, String password, String ip) throws Exception {
		return post("/api/v1/auth/login").contentType(MediaType.APPLICATION_JSON)
				.with(r -> {
					r.setRemoteAddr(ip);
					return r;
				})
				.content(json.writeValueAsString(Map.of("email", email, "password", password)));
	}

	@Test
	void coachSignupCreatesPendingCoachWithProfileAndSession() throws Exception {
		MvcResult result = mockMvc.perform(signup("ana@example.ro"))
				.andExpect(status().isCreated())
				.andExpect(jsonPath("$.user.role").value("COACH"))
				.andExpect(jsonPath("$.user.status").value("PENDING"))
				.andReturn();
		String access = json.readTree(result.getResponse().getContentAsString()).get("accessToken").asString();
		mockMvc.perform(get("/api/v1/me").header(HttpHeaders.AUTHORIZATION, "Bearer " + access))
				.andExpect(status().isOk())
				.andExpect(jsonPath("$.email").value("ana@example.ro"));
		Integer profiles = jdbc.queryForObject("SELECT count(*) FROM coach_profile", Integer.class);
		assertThat(profiles).isEqualTo(1);
		assertThat(emails.sent()).hasSize(1);
		OutgoingEmail mail = emails.lastTo("ana@example.ro");
		assertThat(mail).isNotNull();
		assertThat(mail.body()).contains("verify-email?token=");
		Integer tokens = jdbc.queryForObject(
				"SELECT count(*) FROM user_action_token WHERE purpose = 'EMAIL_VERIFICATION'", Integer.class);
		assertThat(tokens).isEqualTo(1);
		Integer refresh = jdbc.queryForObject("SELECT count(*) FROM refresh_token", Integer.class);
		assertThat(refresh).isEqualTo(1);
	}

	@Test
	void emailIsNormalized() throws Exception {
		mockMvc.perform(signup(" Ana@Example.RO "))
				.andExpect(status().isCreated())
				.andExpect(jsonPath("$.user.email").value("ana@example.ro"));
		mockMvc.perform(login("ANA@example.ro", "correct-horse-1")).andExpect(status().isOk());
		mockMvc.perform(signup("ana@example.ro"))
				.andExpect(status().isConflict())
				.andExpect(jsonPath("$.code").value("EMAIL_TAKEN"));
	}

	@Test
	void multiByteLongPasswordRejected() throws Exception {
		mockMvc.perform(signup("ana@example.ro", "😀".repeat(19), "en", "Europe/Bucharest", "10.0.0.1"))
				.andExpect(status().isBadRequest())
				.andExpect(jsonPath("$.errors[?(@.field=='password')].code").value(hasItem("PASSWORD_POLICY")));
	}

	@Test
	void invalidLocaleAndTimezoneRejected() throws Exception {
		mockMvc.perform(signup("ana@example.ro", "correct-horse-1", "fr", "Mars/Olympus", "10.0.0.1"))
				.andExpect(status().isBadRequest())
				.andExpect(jsonPath("$.errors[?(@.field=='locale')].code").value(hasItem("INVALID_LOCALE")))
				.andExpect(jsonPath("$.errors[?(@.field=='timezone')].code").value(hasItem("INVALID_TIMEZONE")));
	}

	@Test
	void loginWrongPasswordAndUnknownEmailLookTheSame() throws Exception {
		fixtures.user(Role.COACH, UserStatus.ACTIVE, "coach@x.test");
		String wrong = mockMvc.perform(login("coach@x.test", "wrong-password-1"))
				.andExpect(status().isUnauthorized())
				.andExpect(jsonPath("$.code").value("INVALID_CREDENTIALS"))
				.andReturn().getResponse().getContentAsString();
		String unknown = mockMvc.perform(login("nobody@x.test", "wrong-password-1"))
				.andExpect(status().isUnauthorized())
				.andExpect(jsonPath("$.code").value("INVALID_CREDENTIALS"))
				.andReturn().getResponse().getContentAsString();
		ObjectNode a = (ObjectNode) json.readTree(wrong);
		ObjectNode b = (ObjectNode) json.readTree(unknown);
		a.remove("instance");
		b.remove("instance");
		assertThat(a).isEqualTo(b);
	}

	@Test
	void loginSuspendedIs403() throws Exception {
		fixtures.user(Role.COACH, UserStatus.SUSPENDED, "coach@x.test");
		mockMvc.perform(login("coach@x.test", TestFixtures.PASSWORD))
				.andExpect(status().isForbidden())
				.andExpect(jsonPath("$.code").value("ACCOUNT_SUSPENDED"));
	}

	@Test
	void loginUpdatesLastLoginAt() throws Exception {
		AppUser coach = fixtures.user(Role.COACH, UserStatus.ACTIVE, "coach@x.test");
		clock.advance(Duration.ofHours(3));
		mockMvc.perform(login("coach@x.test", TestFixtures.PASSWORD))
				.andExpect(status().isOk())
				.andExpect(jsonPath("$.user.id").value(coach.getId().toString()));
		Timestamp last = jdbc.queryForObject("SELECT last_login_at FROM app_user WHERE id = ?",
				Timestamp.class, coach.getId());
		assertThat(last.toInstant()).isEqualTo(clock.instant());
	}

	@Test
	void loginLockedAfterFiveFailures() throws Exception {
		fixtures.user(Role.COACH, UserStatus.ACTIVE, "coach@x.test");
		for (int i = 0; i < 5; i++) {
			mockMvc.perform(login("coach@x.test", "wrong-password-1")).andExpect(status().isUnauthorized());
		}
		mockMvc.perform(login("coach@x.test", TestFixtures.PASSWORD))
				.andExpect(status().isTooManyRequests())
				.andExpect(header().exists(HttpHeaders.RETRY_AFTER))
				.andExpect(jsonPath("$.code").value("RATE_LIMITED"));
		clock.advance(Duration.ofMinutes(15));
		mockMvc.perform(login("coach@x.test", TestFixtures.PASSWORD)).andExpect(status().isOk());
	}

	@Test
	void concurrentWrongPasswordsCannotExceedEmailLimit() throws Exception {
		fixtures.user(Role.COACH, UserStatus.ACTIVE, "coach@x.test");
		int attempts = 12;
		CountDownLatch start = new CountDownLatch(1);
		ExecutorService pool = Executors.newFixedThreadPool(attempts);
		List<Integer> statuses = new ArrayList<>();
		try {
			List<Future<Integer>> futures = new ArrayList<>();
			for (int i = 0; i < attempts; i++) {
				futures.add(pool.submit(() -> {
					start.await();
					return mockMvc.perform(login("coach@x.test", "wrong-password-1")).andReturn().getResponse().getStatus();
				}));
			}
			start.countDown();
			for (Future<Integer> f : futures) {
				statuses.add(f.get(60, TimeUnit.SECONDS));
			}
		}
		finally {
			pool.shutdownNow();
		}
		// every request is counted before its password is checked, so at most 5 guesses reach bcrypt
		assertThat(statuses.stream().filter(s -> s == 401).count()).isEqualTo(5);
		assertThat(statuses.stream().filter(s -> s == 429).count()).isEqualTo(attempts - 5);
	}

	@Test
	void successfulLoginsDoNotUseUpAttempts() throws Exception {
		fixtures.user(Role.COACH, UserStatus.ACTIVE, "coach@x.test");
		for (int i = 0; i < 25; i++) {
			mockMvc.perform(login("coach@x.test", TestFixtures.PASSWORD)).andExpect(status().isOk());
		}
		for (int i = 0; i < 5; i++) {
			mockMvc.perform(login("coach@x.test", "wrong-password-1")).andExpect(status().isUnauthorized());
		}
		mockMvc.perform(login("coach@x.test", TestFixtures.PASSWORD)).andExpect(status().isTooManyRequests());
	}

	@Test
	void loginLockedPerIpAfterTwentyFailuresAcrossEmails() throws Exception {
		for (int i = 0; i < 20; i++) {
			mockMvc.perform(login("nobody" + i + "@x.test", "wrong-password-1")).andExpect(status().isUnauthorized());
		}
		mockMvc.perform(login("nobody20@x.test", "wrong-password-1"))
				.andExpect(status().isTooManyRequests())
				.andExpect(header().exists(HttpHeaders.RETRY_AFTER));
	}

	@Test
	void signupRateLimitedPerIp() throws Exception {
		for (int i = 0; i < 10; i++) {
			mockMvc.perform(signup("coach" + i + "@x.test")).andExpect(status().isCreated());
		}
		mockMvc.perform(signup("coach10@x.test"))
				.andExpect(status().isTooManyRequests())
				.andExpect(header().exists(HttpHeaders.RETRY_AFTER));
	}

	@Test
	void takenEmailStillCountsAgainstSignupLimit() throws Exception {
		fixtures.user(Role.COACH, UserStatus.ACTIVE, "taken@x.test");
		for (int i = 0; i < 10; i++) {
			mockMvc.perform(signup("taken@x.test")).andExpect(status().isConflict());
		}
		mockMvc.perform(signup("taken@x.test")).andExpect(status().isTooManyRequests());
	}

	@Test
	void missingFieldsAreRequired() throws Exception {
		mockMvc.perform(post("/api/v1/auth/register/coach").contentType(MediaType.APPLICATION_JSON).content("{}"))
				.andExpect(status().isBadRequest())
				.andExpect(jsonPath("$.errors[?(@.field=='email')].code").value(hasItem("REQUIRED")))
				.andExpect(jsonPath("$.errors[?(@.field=='password')].code").value(hasItem("REQUIRED")))
				.andExpect(jsonPath("$.errors[?(@.field=='locale')].code").value(hasItem("REQUIRED")));
		mockMvc.perform(post("/api/v1/auth/login").contentType(MediaType.APPLICATION_JSON).content("{}"))
				.andExpect(status().isBadRequest())
				.andExpect(jsonPath("$.errors[?(@.field=='email')].code").value(hasItem("REQUIRED")));
	}

}
