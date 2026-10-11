package com.anafitlab.backend.auth;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.time.Duration;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.Callable;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.ResultActions;

import com.anafitlab.backend.support.IntegrationTestBase;
import com.anafitlab.backend.support.MutableClock;
import com.anafitlab.backend.support.TestFixtures;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.json.JsonMapper;

class RefreshAndLogoutTest extends IntegrationTestBase {

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

	private AppUser coach() {
		return fixtures.user(Role.COACH, UserStatus.ACTIVE, "coach@x.test");
	}

	private JsonNode login() throws Exception {
		String body = mockMvc.perform(post("/api/v1/auth/login").contentType(MediaType.APPLICATION_JSON)
				.content(json.writeValueAsString(Map.of("email", "coach@x.test", "password", TestFixtures.PASSWORD))))
				.andExpect(status().isOk()).andReturn().getResponse().getContentAsString();
		return json.readTree(body);
	}

	private ResultActions refresh(String token) throws Exception {
		return mockMvc.perform(post("/api/v1/auth/refresh").contentType(MediaType.APPLICATION_JSON)
				.content(json.writeValueAsString(Map.of("refreshToken", token))));
	}

	private ResultActions logout(String token) throws Exception {
		return mockMvc.perform(post("/api/v1/auth/logout").contentType(MediaType.APPLICATION_JSON)
				.content(json.writeValueAsString(Map.of("refreshToken", token))));
	}

	private JsonNode refreshOk(String token) throws Exception {
		return json.readTree(refresh(token).andExpect(status().isOk()).andReturn().getResponse().getContentAsString());
	}

	private void assertRejected(String token, int status, String code) throws Exception {
		refresh(token).andExpect(status().is(status)).andExpect(jsonPath("$.code").value(code));
	}

	@Test
	void refreshRotates() throws Exception {
		coach();
		JsonNode first = login();
		String r1 = first.get("refreshToken").asString();
		JsonNode second = refreshOk(r1);
		String r2 = second.get("refreshToken").asString();
		assertThat(r2).isNotEqualTo(r1);
		assertThat(second.get("accessToken").asString()).isNotBlank();
		assertThat(second.get("user").get("email").asString()).isEqualTo("coach@x.test");
		JsonNode third = refreshOk(r2);
		assertThat(third.get("refreshToken").asString()).isNotIn(r1, r2);
		Integer families = jdbc.queryForObject("SELECT count(DISTINCT family_id) FROM refresh_token", Integer.class);
		assertThat(families).isEqualTo(1);
	}

	@Test
	void reusingRotatedTokenRevokesFamily() throws Exception {
		coach();
		String r1 = login().get("refreshToken").asString();
		String r2 = refreshOk(r1).get("refreshToken").asString();
		assertRejected(r1, 401, "REFRESH_TOKEN_REUSED");
		assertRejected(r2, 401, "INVALID_REFRESH_TOKEN");
	}

	@Test
	void reuseAfterExpiryStillRevokesFamily() throws Exception {
		coach();
		String r1 = login().get("refreshToken").asString();
		String r2 = refreshOk(r1).get("refreshToken").asString();
		clock.advance(Duration.ofDays(31));
		assertRejected(r1, 401, "REFRESH_TOKEN_REUSED");
		Integer live = jdbc.queryForObject("SELECT count(*) FROM refresh_token WHERE revoked_at IS NULL", Integer.class);
		assertThat(live).isZero();
		assertRejected(r2, 401, "INVALID_REFRESH_TOKEN");
	}

	@Test
	void otherFamiliesSurviveReuse() throws Exception {
		coach();
		String a1 = login().get("refreshToken").asString();
		String b1 = login().get("refreshToken").asString();
		refreshOk(a1);
		assertRejected(a1, 401, "REFRESH_TOKEN_REUSED");
		refreshOk(b1);
	}

	@Test
	void unknownTokenRejected() throws Exception {
		assertRejected("not-a-token", 401, "INVALID_REFRESH_TOKEN");
	}

	@Test
	void blankTokenIsValidationError() throws Exception {
		refresh("").andExpect(status().isBadRequest())
				.andExpect(jsonPath("$.errors[0].code").value("REQUIRED"));
		logout("").andExpect(status().isBadRequest())
				.andExpect(jsonPath("$.errors[0].code").value("REQUIRED"));
	}

	@Test
	void expiredRefreshRejected() throws Exception {
		coach();
		String r1 = login().get("refreshToken").asString();
		clock.advance(Duration.ofDays(30).plusSeconds(1));
		assertRejected(r1, 401, "INVALID_REFRESH_TOKEN");
	}

	@Test
	void rotationExtendsExpiry() throws Exception {
		coach();
		String r1 = login().get("refreshToken").asString();
		clock.advance(Duration.ofDays(29));
		JsonNode next = refreshOk(r1);
		assertThat(Instant.parse(next.get("refreshTokenExpiresAt").asString()))
				.isEqualTo(clock.instant().plus(Duration.ofDays(30)));
	}

	@Test
	void suspendedUserCannotRefresh() throws Exception {
		AppUser user = coach();
		String r1 = login().get("refreshToken").asString();
		jdbc.update("UPDATE app_user SET status = 'SUSPENDED' WHERE id = ?", user.getId());
		assertRejected(r1, 403, "ACCOUNT_SUSPENDED");
		Integer live = jdbc.queryForObject("SELECT count(*) FROM refresh_token WHERE revoked_at IS NULL", Integer.class);
		assertThat(live).isZero();
	}

	@Test
	void logoutRevokesFamilyOnly() throws Exception {
		coach();
		String a = login().get("refreshToken").asString();
		String b = login().get("refreshToken").asString();
		logout(a).andExpect(status().isNoContent());
		assertRejected(a, 401, "INVALID_REFRESH_TOKEN");
		refreshOk(b);
		logout("unknown-token").andExpect(status().isNoContent());
	}

	@Test
	void logoutAllRevokesEverything() throws Exception {
		AppUser user = coach();
		String a = login().get("refreshToken").asString();
		String b = login().get("refreshToken").asString();
		mockMvc.perform(post("/api/v1/auth/logout-all").header(HttpHeaders.AUTHORIZATION, fixtures.bearer(user)))
				.andExpect(status().isNoContent());
		assertRejected(a, 401, "INVALID_REFRESH_TOKEN");
		assertRejected(b, 401, "INVALID_REFRESH_TOKEN");
	}

	@Test
	void logoutAllRequiresAuthentication() throws Exception {
		mockMvc.perform(post("/api/v1/auth/logout-all")).andExpect(status().isUnauthorized());
	}

	@Test
	void concurrentRefreshesWithSameTokenYieldExactlyOneSuccess() throws Exception {
		coach();
		String r1 = login().get("refreshToken").asString();
		int n = 2;
		ExecutorService pool = Executors.newFixedThreadPool(n);
		CountDownLatch go = new CountDownLatch(1);
		try {
			List<Future<Integer>> results = new ArrayList<>();
			for (int i = 0; i < n; i++) {
				Callable<Integer> call = () -> {
					go.await();
					return refresh(r1).andReturn().getResponse().getStatus();
				};
				results.add(pool.submit(call));
			}
			go.countDown();
			List<Integer> statuses = new ArrayList<>();
			for (Future<Integer> f : results) {
				statuses.add(f.get(30, java.util.concurrent.TimeUnit.SECONDS));
			}
			assertThat(statuses).containsExactlyInAnyOrder(200, 401);
			Integer live = jdbc.queryForObject("SELECT count(*) FROM refresh_token WHERE revoked_at IS NULL",
					Integer.class);
			assertThat(live).isZero();
		}
		finally {
			pool.shutdownNow();
		}
	}

}
