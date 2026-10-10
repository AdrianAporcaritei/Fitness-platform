package com.anafitlab.backend.client;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.util.List;
import java.util.UUID;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.ResultActions;

import com.anafitlab.backend.auth.AppUser;
import com.anafitlab.backend.auth.Role;
import com.anafitlab.backend.auth.UserStatus;
import com.anafitlab.backend.support.IntegrationTestBase;
import com.anafitlab.backend.support.TestFixtures;

class RelationshipsTest extends IntegrationTestBase {

	@Autowired
	MockMvc mockMvc;

	@Autowired
	TestFixtures fixtures;

	@Autowired
	JdbcTemplate jdbc;

	@Autowired
	CoachProfileRepository profiles;

	private AppUser coach(String email) {
		return fixtures.user(Role.COACH, UserStatus.ACTIVE, email);
	}

	private AppUser client(String email) {
		return fixtures.user(Role.CLIENT, UserStatus.ACTIVE, email);
	}

	private ResultActions change(AppUser actor, UUID clientId, String body) throws Exception {
		return mockMvc.perform(patch("/api/v1/coach/clients/{id}/relationship", clientId)
				.header(HttpHeaders.AUTHORIZATION, fixtures.bearer(actor)).contentType(MediaType.APPLICATION_JSON)
				.content(body));
	}

	private ResultActions setStatus(AppUser actor, UUID clientId, String status) throws Exception {
		return change(actor, clientId, "{\"status\":\"" + status + "\"}");
	}

	@Test
	void listsOnlyCurrentClients() throws Exception {
		AppUser coach = coach("c@x.test");
		AppUser other = coach("o@x.test");
		AppUser active = client("a@x.test");
		AppUser paused = client("p@x.test");
		AppUser ended = client("e@x.test");
		AppUser foreign = client("f@x.test");
		fixtures.link(coach, active, RelationshipStatus.ACTIVE);
		fixtures.link(coach, paused, RelationshipStatus.PAUSED);
		fixtures.link(coach, ended, RelationshipStatus.ENDED);
		fixtures.link(other, foreign, RelationshipStatus.ACTIVE);
		mockMvc.perform(get("/api/v1/coach/clients").header(HttpHeaders.AUTHORIZATION, fixtures.bearer(coach)))
			.andExpect(status().isOk())
			.andExpect(jsonPath("$.length()").value(2))
			.andExpect(jsonPath("$[?(@.email=='a@x.test')].status").value("ACTIVE"))
			.andExpect(jsonPath("$[?(@.email=='p@x.test')].status").value("PAUSED"))
			.andExpect(jsonPath("$[0].clientId").exists())
			.andExpect(jsonPath("$[0].startedAt").exists());
	}

	@Test
	void listIsOrderedByLastThenFirstName() throws Exception {
		AppUser coach = coach("c@x.test");
		String[][] names = { { "Zed", "Adams" }, { "Amy", "Brown" }, { "Abe", "Adams" } };
		for (int i = 0; i < names.length; i++) {
			AppUser c = client("n" + i + "@x.test");
			c.setFirstName(names[i][0]);
			c.setLastName(names[i][1]);
			jdbc.update("UPDATE app_user SET first_name = ?, last_name = ? WHERE id = ?", names[i][0], names[i][1],
					c.getId());
			fixtures.link(coach, c, RelationshipStatus.ACTIVE);
		}
		mockMvc.perform(get("/api/v1/coach/clients").header(HttpHeaders.AUTHORIZATION, fixtures.bearer(coach)))
			.andExpect(jsonPath("$[0].firstName").value("Abe"))
			.andExpect(jsonPath("$[1].firstName").value("Zed"))
			.andExpect(jsonPath("$[2].firstName").value("Amy"));
	}

	@Test
	void pauseResumeEnd() throws Exception {
		AppUser coach = coach("c@x.test");
		AppUser client = client("cl@x.test");
		fixtures.link(coach, client, RelationshipStatus.ACTIVE);
		setStatus(coach, client.getId(), "PAUSED").andExpect(status().isOk())
			.andExpect(jsonPath("$.status").value("PAUSED"))
			.andExpect(jsonPath("$.clientId").value(client.getId().toString()));
		setStatus(coach, client.getId(), "ACTIVE").andExpect(status().isOk())
			.andExpect(jsonPath("$.status").value("ACTIVE"));
		setStatus(coach, client.getId(), "ENDED").andExpect(status().isOk())
			.andExpect(jsonPath("$.status").value("ENDED"));
		assertThat(jdbc.queryForObject("SELECT ended_at FROM coach_client WHERE client_id = ?", Object.class,
				client.getId())).isNotNull();
		setStatus(coach, client.getId(), "ACTIVE").andExpect(status().isNotFound())
			.andExpect(jsonPath("$.code").value("CLIENT_NOT_FOUND"));
	}

	@Test
	void invalidTransition() throws Exception {
		AppUser coach = coach("c@x.test");
		AppUser client = client("cl@x.test");
		fixtures.link(coach, client, RelationshipStatus.ACTIVE);
		setStatus(coach, client.getId(), "ACTIVE").andExpect(status().isConflict())
			.andExpect(jsonPath("$.code").value("INVALID_RELATIONSHIP_TRANSITION"));
	}

	@Test
	void missingOrUnknownStatusIsRejected() throws Exception {
		AppUser coach = coach("c@x.test");
		AppUser client = client("cl@x.test");
		fixtures.link(coach, client, RelationshipStatus.ACTIVE);
		change(coach, client.getId(), "{}").andExpect(status().isBadRequest())
			.andExpect(jsonPath("$.errors[0].code").value("REQUIRED"));
		setStatus(coach, client.getId(), "BOGUS").andExpect(status().isBadRequest())
			.andExpect(jsonPath("$.code").value("MALFORMED_REQUEST"));
	}

	@Test
	void otherCoachsClientIs404() throws Exception {
		AppUser coach = coach("c@x.test");
		AppUser other = coach("o@x.test");
		AppUser client = client("cl@x.test");
		fixtures.link(other, client, RelationshipStatus.ACTIVE);
		setStatus(coach, client.getId(), "PAUSED").andExpect(status().isNotFound())
			.andExpect(jsonPath("$.code").value("CLIENT_NOT_FOUND"));
		setStatus(coach, UUID.randomUUID(), "PAUSED").andExpect(status().isNotFound());
	}

	@Test
	void clientSeesAndLeavesCoach() throws Exception {
		AppUser coach = coach("c@x.test");
		AppUser client = client("cl@x.test");
		fixtures.link(coach, client, RelationshipStatus.ACTIVE);
		CoachProfile profile = new CoachProfile();
		profile.setUserId(coach.getId());
		profile.setBio("Strength coach");
		profile.setSpecializations(List.of("strength"));
		profiles.save(profile);
		String bearer = fixtures.bearer(client);
		mockMvc.perform(get("/api/v1/me/coach").header(HttpHeaders.AUTHORIZATION, bearer))
			.andExpect(status().isOk())
			.andExpect(jsonPath("$.coachId").value(coach.getId().toString()))
			.andExpect(jsonPath("$.bio").value("Strength coach"))
			.andExpect(jsonPath("$.specializations[0]").value("strength"))
			.andExpect(jsonPath("$.status").value("ACTIVE"));
		mockMvc.perform(delete("/api/v1/me/coach").header(HttpHeaders.AUTHORIZATION, bearer))
			.andExpect(status().isNoContent());
		mockMvc.perform(get("/api/v1/me/coach").header(HttpHeaders.AUTHORIZATION, bearer))
			.andExpect(status().isNotFound())
			.andExpect(jsonPath("$.code").value("NO_COACH"));
		mockMvc.perform(delete("/api/v1/me/coach").header(HttpHeaders.AUTHORIZATION, bearer))
			.andExpect(status().isNotFound())
			.andExpect(jsonPath("$.code").value("NO_COACH"));
		mockMvc.perform(get("/api/v1/coach/clients").header(HttpHeaders.AUTHORIZATION, fixtures.bearer(coach)))
			.andExpect(jsonPath("$.length()").value(0));
	}

	@Test
	void pausedClientStillSeesAndCanLeaveCoach() throws Exception {
		AppUser coach = coach("c@x.test");
		AppUser client = client("cl@x.test");
		fixtures.link(coach, client, RelationshipStatus.PAUSED);
		String bearer = fixtures.bearer(client);
		mockMvc.perform(get("/api/v1/me/coach").header(HttpHeaders.AUTHORIZATION, bearer))
			.andExpect(status().isOk())
			.andExpect(jsonPath("$.status").value("PAUSED"))
			.andExpect(jsonPath("$.specializations.length()").value(0));
		mockMvc.perform(delete("/api/v1/me/coach").header(HttpHeaders.AUTHORIZATION, bearer))
			.andExpect(status().isNoContent());
		assertThat(jdbc.queryForObject("SELECT status FROM coach_client WHERE client_id = ?", String.class,
				client.getId())).isEqualTo("ENDED");
		assertThat(jdbc.queryForObject("SELECT ended_at FROM coach_client WHERE client_id = ?", Object.class,
				client.getId())).isNotNull();
	}

	@Test
	void clientCannotPause() throws Exception {
		AppUser coach = coach("c@x.test");
		AppUser client = client("cl@x.test");
		fixtures.link(coach, client, RelationshipStatus.ACTIVE);
		setStatus(client, client.getId(), "PAUSED").andExpect(status().isForbidden());
		mockMvc.perform(get("/api/v1/coach/clients").header(HttpHeaders.AUTHORIZATION, fixtures.bearer(client)))
			.andExpect(status().isForbidden());
	}

	@Test
	void coachCannotUseClientEndpoints() throws Exception {
		AppUser coach = coach("c@x.test");
		String bearer = fixtures.bearer(coach);
		mockMvc.perform(get("/api/v1/me/coach").header(HttpHeaders.AUTHORIZATION, bearer))
			.andExpect(status().isForbidden());
		mockMvc.perform(delete("/api/v1/me/coach").header(HttpHeaders.AUTHORIZATION, bearer))
			.andExpect(status().isForbidden());
	}

}
