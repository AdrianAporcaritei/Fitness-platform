package com.anafitlab.backend.client;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.time.Duration;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.Callable;
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
import org.springframework.test.web.servlet.ResultActions;

import com.anafitlab.backend.auth.entity.AppUser;
import com.anafitlab.backend.auth.entity.Role;
import com.anafitlab.backend.auth.entity.UserStatus;
import com.anafitlab.backend.client.entity.RelationshipStatus;
import com.anafitlab.backend.support.IntegrationTestBase;
import com.anafitlab.backend.support.MutableClock;
import com.anafitlab.backend.support.RecordingEmailSender;
import com.anafitlab.backend.support.TestFixtures;
import tools.jackson.databind.json.JsonMapper;

class ClientSignupTest extends IntegrationTestBase {

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

	private int invitations;

	private String newCode(AppUser coach) throws Exception {
		String body = mockMvc.perform(post("/api/v1/coach/clients").header(HttpHeaders.AUTHORIZATION, fixtures.bearer(coach))
			.contentType(MediaType.APPLICATION_JSON)
			.content("{\"name\":\"Invitee\",\"email\":\"invitee" + (++invitations) + "@x.test\"}"))
			.andExpect(status().isCreated())
			.andReturn()
			.getResponse()
			.getContentAsString();
		return (String) json.readValue(body, Map.class).get("code");
	}

	private ResultActions signup(String code, String email) throws Exception {
		String body = json.writeValueAsString(Map.of("code", code, "email", email, "password", TestFixtures.PASSWORD,
				"firstName", "Ana", "lastName", "Client", "locale", "en", "timezone", "Europe/Bucharest"));
		return mockMvc.perform(post("/api/v1/auth/register/client").contentType(MediaType.APPLICATION_JSON).content(body));
	}

	private ResultActions link(AppUser client, String code) throws Exception {
		return mockMvc.perform(post("/api/v1/me/coach-link").header(HttpHeaders.AUTHORIZATION, fixtures.bearer(client))
			.contentType(MediaType.APPLICATION_JSON)
			.content(json.writeValueAsString(Map.of("code", code))));
	}

	private AppUser activeCoach(String email) {
		return fixtures.user(Role.COACH, UserStatus.ACTIVE, email);
	}

	private String inviteStatus() {
		return jdbc.queryForObject("SELECT status FROM coach_invite", String.class);
	}

	private int countUsers(Role role) {
		return jdbc.queryForObject("SELECT count(*) FROM app_user WHERE role = ?", Integer.class, role.name());
	}

	@Test
	void clientSignupLinksToCoach() throws Exception {
		AppUser coach = activeCoach("coach@x.test");
		String code = newCode(coach);
		clock.advance(Duration.ofHours(1));

		signup(code, "client@x.test").andExpect(status().isCreated())
			.andExpect(jsonPath("$.user.role").value("CLIENT"))
			.andExpect(jsonPath("$.user.status").value("PENDING"));

		Map<String, Object> row = jdbc.queryForMap("SELECT * FROM coach_client");
		assertThat(row.get("status")).isEqualTo("ACTIVE");
		assertThat(row.get("coach_id")).isEqualTo(coach.getId());
		assertThat(((java.sql.Timestamp) row.get("started_at")).toInstant()).isEqualTo(clock.instant());
		Map<String, Object> invite = jdbc.queryForMap("SELECT * FROM coach_invite");
		assertThat(invite.get("status")).isEqualTo("USED");
		assertThat(invite.get("used_by_client_id")).isEqualTo(row.get("client_id"));
		assertThat(jdbc.queryForObject("SELECT id FROM app_user WHERE email = 'client@x.test'", java.util.UUID.class))
			.isEqualTo(row.get("client_id"));
		assertThat(emails.lastTo("client@x.test")).isNotNull();
	}

	@Test
	void usedExpiredRevokedCodesRejected() throws Exception {
		AppUser coach = activeCoach("coach@x.test");

		String used = newCode(coach);
		signup(used, "first@x.test").andExpect(status().isCreated());
		signup(used, "second@x.test").andExpect(status().isGone()).andExpect(jsonPath("$.code").value("INVITE_USED"));

		String revoked = newCode(coach);
		Object revokedId = jdbc.queryForObject("SELECT id FROM coach_invite WHERE status = 'PENDING'", Object.class);
		mockMvc.perform(delete("/api/v1/coach/invites/{id}", revokedId).header(HttpHeaders.AUTHORIZATION,
				fixtures.bearer(coach))).andExpect(status().isNoContent());
		signup(revoked, "third@x.test").andExpect(status().isGone()).andExpect(jsonPath("$.code").value("INVITE_REVOKED"));

		String expired = newCode(coach);
		clock.advance(Duration.ofDays(8));
		signup(expired, "fourth@x.test").andExpect(status().isGone()).andExpect(jsonPath("$.code").value("INVITE_EXPIRED"));

		assertThat(countUsers(Role.CLIENT)).isEqualTo(1);
	}

	@Test
	void unknownCodeIsNotFound() throws Exception {
		signup("ZZZZZ-ZZZZZ", "x@x.test").andExpect(status().isNotFound())
			.andExpect(jsonPath("$.code").value("INVITE_NOT_FOUND"));
		assertThat(countUsers(Role.CLIENT)).isZero();
	}

	@Test
	void missingCodeFailsValidation() throws Exception {
		signup("", "x@x.test").andExpect(status().isBadRequest())
			.andExpect(jsonPath("$.errors[0].code").value("REQUIRED"));
	}

	@Test
	void duplicateEmailDoesNotConsumeInvite() throws Exception {
		AppUser coach = activeCoach("coach@x.test");
		fixtures.user(Role.CLIENT, UserStatus.ACTIVE, "taken@x.test");
		String code = newCode(coach);

		signup(code, "taken@x.test").andExpect(status().isConflict()).andExpect(jsonPath("$.code").value("EMAIL_TAKEN"));

		assertThat(inviteStatus()).isEqualTo("PENDING");
		assertThat(jdbc.queryForObject("SELECT count(*) FROM coach_client", Integer.class)).isZero();
	}

	@Test
	void concurrentSignupsWithSameCode() throws Exception {
		AppUser coach = activeCoach("coach@x.test");
		String code = newCode(coach);
		CountDownLatch start = new CountDownLatch(1);
		ExecutorService pool = Executors.newFixedThreadPool(2);
		try {
			List<Future<MvcResult>> futures = new ArrayList<>();
			for (String email : List.of("a@x.test", "b@x.test")) {
				Callable<MvcResult> task = () -> {
					start.await();
					return signup(code, email).andReturn();
				};
				futures.add(pool.submit(task));
			}
			start.countDown();
			List<Integer> statuses = new ArrayList<>();
			String goneBody = null;
			for (Future<MvcResult> f : futures) {
				MvcResult r = f.get(30, TimeUnit.SECONDS);
				statuses.add(r.getResponse().getStatus());
				if (r.getResponse().getStatus() == 410) {
					goneBody = r.getResponse().getContentAsString();
				}
			}
			assertThat(statuses).containsExactlyInAnyOrder(201, 410);
			assertThat(goneBody).contains("INVITE_USED");
		}
		finally {
			pool.shutdownNow();
		}
		assertThat(countUsers(Role.CLIENT)).isEqualTo(1);
		assertThat(jdbc.queryForObject("SELECT count(*) FROM coach_client", Integer.class)).isEqualTo(1);
		assertThat(inviteStatus()).isEqualTo("USED");
	}

	@Test
	void clientWithoutCoachLinksWithCode() throws Exception {
		AppUser oldCoach = activeCoach("old@x.test");
		AppUser coach = activeCoach("coach@x.test");
		AppUser client = fixtures.user(Role.CLIENT, UserStatus.ACTIVE, "client@x.test");
		fixtures.link(oldCoach, client, RelationshipStatus.ENDED);
		String code = newCode(coach);

		link(client, code).andExpect(status().isCreated())
			.andExpect(jsonPath("$.coachId").value(coach.getId().toString()))
			.andExpect(jsonPath("$.coachFirstName").value("Test"))
			.andExpect(jsonPath("$.coachLastName").value("COACH"))
			.andExpect(jsonPath("$.status").value("ACTIVE"))
			.andExpect(jsonPath("$.startedAt").exists());

		assertThat(jdbc.queryForObject("SELECT coach_id FROM coach_client WHERE status = 'ACTIVE'", java.util.UUID.class))
			.isEqualTo(coach.getId());
		assertThat(inviteStatus()).isEqualTo("USED");
	}

	@Test
	void clientWithCoachCannotLink() throws Exception {
		AppUser current = activeCoach("old@x.test");
		AppUser coach = activeCoach("coach@x.test");
		AppUser client = fixtures.user(Role.CLIENT, UserStatus.ACTIVE, "client@x.test");
		fixtures.link(current, client, RelationshipStatus.ACTIVE);
		String code = newCode(coach);

		link(client, code).andExpect(status().isConflict()).andExpect(jsonPath("$.code").value("ALREADY_HAS_COACH"));

		assertThat(inviteStatus()).isEqualTo("PENDING");
	}

	@Test
	void pausedCountsAsCurrentCoach() throws Exception {
		AppUser current = activeCoach("old@x.test");
		AppUser coach = activeCoach("coach@x.test");
		AppUser client = fixtures.user(Role.CLIENT, UserStatus.ACTIVE, "client@x.test");
		fixtures.link(current, client, RelationshipStatus.PAUSED);

		link(client, newCode(coach)).andExpect(status().isConflict())
			.andExpect(jsonPath("$.code").value("ALREADY_HAS_COACH"));
	}

	@Test
	void coachCannotUseCoachLink() throws Exception {
		AppUser coach = activeCoach("coach@x.test");
		link(coach, newCode(coach)).andExpect(status().isForbidden()).andExpect(jsonPath("$.code").value("FORBIDDEN"));
	}

	@Test
	void pendingClientIsNotRestricted() throws Exception {
		AppUser old = activeCoach("old@x.test");
		AppUser coach = activeCoach("coach@x.test");
		AppUser client = fixtures.user(Role.CLIENT, UserStatus.PENDING, "client@x.test");
		fixtures.link(old, client, RelationshipStatus.ENDED);

		link(client, newCode(coach)).andExpect(status().isCreated());
	}

	@Test
	void coachLinkIsRateLimitedPerIp() throws Exception {
		AppUser client = fixtures.user(Role.CLIENT, UserStatus.ACTIVE, "client@x.test");
		for (int i = 0; i < 20; i++) {
			link(client, "ZZZZZ-ZZZZZ").andExpect(status().isNotFound());
		}
		link(client, "ZZZZZ-ZZZZZ").andExpect(status().isTooManyRequests());
	}

	@Test
	void suspendedCoachInviteCannotBeUsed() throws Exception {
		AppUser coach = activeCoach("coach@x.test");
		String code = newCode(coach);
		AppUser client = fixtures.user(Role.CLIENT, UserStatus.ACTIVE, "existing@x.test");
		jdbc.update("UPDATE app_user SET status = 'SUSPENDED' WHERE id = ?", coach.getId());

		signup(code, "client@x.test").andExpect(status().isConflict())
			.andExpect(jsonPath("$.code").value("COACH_UNAVAILABLE"));
		link(client, code).andExpect(status().isConflict()).andExpect(jsonPath("$.code").value("COACH_UNAVAILABLE"));

		assertThat(countUsers(Role.CLIENT)).isEqualTo(1);
		assertThat(jdbc.queryForObject("SELECT count(*) FROM coach_client", Integer.class)).isZero();
		assertThat(inviteStatus()).isEqualTo("PENDING");
	}

}
